/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "WebRTC/RTCAudioSession.h"

#import <UIKit/UIKit.h>

#include "webrtc/base/atomicops.h"
#include "webrtc/base/checks.h"
#include "webrtc/base/criticalsection.h"


#import "WebRTC/RTCAudioSessionConfiguration.h"
#import "WebRTC/RTCLogging.h"

#import "RTCAudioSession+Private.h"


NSString * const kRTCAudioSessionErrorDomain = @"org.webrtc.RTCAudioSession";
NSInteger const kRTCAudioSessionErrorLockRequired = -1;
NSInteger const kRTCAudioSessionErrorConfiguration = -2;
NSString * const kRTCAudioSessionOutputVolumeSelector = @"outputVolume";

// This class needs to be thread-safe because it is accessed from many threads.
// TODO(tkchin): Consider more granular locking. We're not expecting a lot of
// lock contention so coarse locks should be fine for now.
@implementation RTCAudioSession {
  rtc::CriticalSection _crit;
  AVAudioSession *_session;
  volatile int _activationCount;
  volatile int _lockRecursionCount;
  volatile int _webRTCSessionCount;
  BOOL _isActive;
  BOOL _useManualAudio;
  BOOL _isAudioEnabled;
  BOOL _canPlayOrRecord;
  BOOL _isInterrupted;
}

@synthesize session = _session;
@synthesize delegates = _delegates;

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static RTCAudioSession *sharedInstance = nil;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  if (self = [super init]) {
    _session = [AVAudioSession sharedInstance];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(handleInterruptionNotification:)
                   name:AVAudioSessionInterruptionNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleRouteChangeNotification:)
                   name:AVAudioSessionRouteChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleMediaServicesWereLost:)
                   name:AVAudioSessionMediaServicesWereLostNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleMediaServicesWereReset:)
                   name:AVAudioSessionMediaServicesWereResetNotification
                 object:nil];
    // Posted on the main thread when the primary audio from other applications
    // starts and stops. Foreground applications may use this notification as a
    // hint to enable or disable audio that is secondary.
    [center addObserver:self
               selector:@selector(handleSilenceSecondaryAudioHintNotification:)
                   name:AVAudioSessionSilenceSecondaryAudioHintNotification
                 object:nil];
    // Also track foreground event in order to deal with interruption ended situation.
    [center addObserver:self
               selector:@selector(handleApplicationDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    [_session addObserver:self
               forKeyPath:kRTCAudioSessionOutputVolumeSelector
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];

    RTCLog(@"RTCAudioSession (%p): init.", self);
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_session removeObserver:self forKeyPath:kRTCAudioSessionOutputVolumeSelector context:nil];
  RTCLog(@"RTCAudioSession (%p): dealloc.", self);
}

- (NSString *)description {
  NSString *format =
      @"RTCAudioSession: {\n"
       "  category: %@\n"
       "  categoryOptions: %ld\n"
       "  mode: %@\n"
       "  isActive: %d\n"
       "  sampleRate: %.2f\n"
       "  IOBufferDuration: %f\n"
       "  outputNumberOfChannels: %ld\n"
       "  inputNumberOfChannels: %ld\n"
       "  outputLatency: %f\n"
       "  inputLatency: %f\n"
       "  outputVolume: %f\n"
       "}";
  NSString *description = [NSString stringWithFormat:format,
      self.category, (long)self.categoryOptions, self.mode,
      self.isActive, self.sampleRate, self.IOBufferDuration,
      self.outputNumberOfChannels, self.inputNumberOfChannels,
      self.outputLatency, self.inputLatency, self.outputVolume];
  return description;
}

- (void)setIsActive:(BOOL)isActive {
  @synchronized(self) {
    _isActive = isActive;
  }
}

- (BOOL)isActive {
  @synchronized(self) {
    return _isActive;
  }
}

- (BOOL)isLocked {
  return _lockRecursionCount > 0;
}

- (void)setUseManualAudio:(BOOL)useManualAudio {
  @synchronized(self) {
    if (_useManualAudio == useManualAudio) {
      return;
    }
    _useManualAudio = useManualAudio;
  }
  [self updateCanPlayOrRecord];
}

- (BOOL)useManualAudio {
  @synchronized(self) {
    return _useManualAudio;
  }
}

- (void)setIsAudioEnabled:(BOOL)isAudioEnabled {
  @synchronized(self) {
    if (_isAudioEnabled == isAudioEnabled) {
      return;
    }
    _isAudioEnabled = isAudioEnabled;
  }
  [self updateCanPlayOrRecord];
}

- (BOOL)isAudioEnabled {
  @synchronized(self) {
    return _isAudioEnabled;
  }
}

// TODO(tkchin): Check for duplicates.
- (void)addDelegate:(id<RTCAudioSessionDelegate>)delegate {
  RTCLog(@"Adding delegate: (%p)", delegate);
  if (!delegate) {
    return;
  }
  @synchronized(self) {
    _delegates.push_back(delegate);
    [self removeZeroedDelegates];
  }
}

- (void)removeDelegate:(id<RTCAudioSessionDelegate>)delegate {
  RTCLog(@"Removing delegate: (%p)", delegate);
  if (!delegate) {
    return;
  }
  @synchronized(self) {
    _delegates.erase(std::remove(_delegates.begin(),
                                 _delegates.end(),
                                 delegate),
                     _delegates.end());
    [self removeZeroedDelegates];
  }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wthread-safety-analysis"

- (void)lockForConfiguration {
  _crit.Enter();
  rtc::AtomicOps::Increment(&_lockRecursionCount);
}

- (void)unlockForConfiguration {
  // Don't let threads other than the one that called lockForConfiguration
  // unlock.
  if (_crit.TryEnter()) {
    rtc::AtomicOps::Decrement(&_lockRecursionCount);
    // One unlock for the tryLock, and another one to actually unlock. If this
    // was called without anyone calling lock, we will hit an assertion.
    _crit.Leave();
    _crit.Leave();
  }
}

#pragma clang diagnostic pop

#pragma mark - AVAudioSession proxy methods

- (NSString *)category {
  return self.session.category;
}

- (AVAudioSessionCategoryOptions)categoryOptions {
  return self.session.categoryOptions;
}

- (NSString *)mode {
  return self.session.mode;
}

- (BOOL)secondaryAudioShouldBeSilencedHint {
  return self.session.secondaryAudioShouldBeSilencedHint;
}

- (AVAudioSessionRouteDescription *)currentRoute {
  return self.session.currentRoute;
}

- (NSInteger)maximumInputNumberOfChannels {
  return self.session.maximumInputNumberOfChannels;
}

- (NSInteger)maximumOutputNumberOfChannels {
  return self.session.maximumOutputNumberOfChannels;
}

- (float)inputGain {
  return self.session.inputGain;
}

- (BOOL)inputGainSettable {
  return self.session.inputGainSettable;
}

- (BOOL)inputAvailable {
  return self.session.inputAvailable;
}

- (NSArray<AVAudioSessionDataSourceDescription *> *)inputDataSources {
  return self.session.inputDataSources;
}

- (AVAudioSessionDataSourceDescription *)inputDataSource {
  return self.session.inputDataSource;
}

- (NSArray<AVAudioSessionDataSourceDescription *> *)outputDataSources {
  return self.session.outputDataSources;
}

- (AVAudioSessionDataSourceDescription *)outputDataSource {
  return self.session.outputDataSource;
}

- (double)sampleRate {
  return self.session.sampleRate;
}

- (double)preferredSampleRate {
  return self.session.preferredSampleRate;
}

- (NSInteger)inputNumberOfChannels {
  return self.session.inputNumberOfChannels;
}

- (NSInteger)outputNumberOfChannels {
  return self.session.outputNumberOfChannels;
}

- (float)outputVolume {
  return self.session.outputVolume;
}

- (NSTimeInterval)inputLatency {
  return self.session.inputLatency;
}

- (NSTimeInterval)outputLatency {
  return self.session.outputLatency;
}

- (NSTimeInterval)IOBufferDuration {
  return self.session.IOBufferDuration;
}

- (NSTimeInterval)preferredIOBufferDuration {
  return self.session.preferredIOBufferDuration;
}

// TODO(tkchin): Simplify the amount of locking happening here. Likely that we
// can just do atomic increments / decrements.
- (BOOL)setActive:(BOOL)active
            error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  int activationCount = _activationCount;
  if (!active && activationCount == 0) {
    RTCLogWarning(@"Attempting to deactivate without prior activation.");
  }
  BOOL success = YES;
  BOOL isActive = self.isActive;
  // Keep a local error so we can log it.
  NSError *error = nil;
  BOOL shouldSetActive =
      (active && !isActive) || (!active && isActive && activationCount == 1);
  // Attempt to activate if we're not active.
  // Attempt to deactivate if we're active and it's the last unbalanced call.
  if (shouldSetActive) {
    AVAudioSession *session = self.session;
    // AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation is used to ensure
    // that other audio sessions that were interrupted by our session can return
    // to their active state. It is recommended for VoIP apps to use this
    // option.
    AVAudioSessionSetActiveOptions options =
        active ? 0 : AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
      if (active) {
          success = [session setActive:active
                           withOptions:options
                                 error:&error];
      }
      else
          success = true;
    if (outError) {
      *outError = error;
    }
  }
  if (success) {
    if (shouldSetActive) {
      self.isActive = active;
    }
    if (active) {
      [self incrementActivationCount];
    }
  } else {
    RTCLogError(@"Failed to setActive:%d. Error: %@",
                active, error.localizedDescription);
  }
  // Decrement activation count on deactivation whether or not it succeeded.
  if (!active) {
    [self decrementActivationCount];
  }
  RTCLog(@"Number of current activations: %d", _activationCount);
  return success;
}

- (BOOL)setCategory:(NSString *)category
        withOptions:(AVAudioSessionCategoryOptions)options
              error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setCategory:category withOptions:options error:outError];
}

- (BOOL)setMode:(NSString *)mode error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setMode:mode error:outError];
}

- (BOOL)setInputGain:(float)gain error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setInputGain:gain error:outError];
}

- (BOOL)setPreferredSampleRate:(double)sampleRate error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setPreferredSampleRate:sampleRate error:outError];
}

- (BOOL)setPreferredIOBufferDuration:(NSTimeInterval)duration
                               error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setPreferredIOBufferDuration:duration error:outError];
}

- (BOOL)setPreferredInputNumberOfChannels:(NSInteger)count
                                    error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setPreferredInputNumberOfChannels:count error:outError];
}
- (BOOL)setPreferredOutputNumberOfChannels:(NSInteger)count
                                     error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setPreferredOutputNumberOfChannels:count error:outError];
}

- (BOOL)overrideOutputAudioPort:(AVAudioSessionPortOverride)portOverride
                          error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session overrideOutputAudioPort:portOverride error:outError];
}

- (BOOL)setPreferredInput:(AVAudioSessionPortDescription *)inPort
                    error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setPreferredInput:inPort error:outError];
}

- (BOOL)setInputDataSource:(AVAudioSessionDataSourceDescription *)dataSource
                     error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setInputDataSource:dataSource error:outError];
}

- (BOOL)setOutputDataSource:(AVAudioSessionDataSourceDescription *)dataSource
                      error:(NSError **)outError {
  if (![self checkLock:outError]) {
    return NO;
  }
  return [self.session setOutputDataSource:dataSource error:outError];
}

#pragma mark - Notifications

- (void)handleInterruptionNotification:(NSNotification *)notification {
  NSNumber* typeNumber =
      notification.userInfo[AVAudioSessionInterruptionTypeKey];
  AVAudioSessionInterruptionType type =
      (AVAudioSessionInterruptionType)typeNumber.unsignedIntegerValue;
  switch (type) {
    case AVAudioSessionInterruptionTypeBegan:
      RTCLog(@"Audio session interruption began.");
      self.isActive = NO;
      self.isInterrupted = YES;
      [self notifyDidBeginInterruption];
      break;
    case AVAudioSessionInterruptionTypeEnded: {
      RTCLog(@"Audio session interruption ended.");
      self.isInterrupted = NO;
      [self updateAudioSessionAfterEvent];
      NSNumber *optionsNumber =
          notification.userInfo[AVAudioSessionInterruptionOptionKey];
      AVAudioSessionInterruptionOptions options =
          optionsNumber.unsignedIntegerValue;
      BOOL shouldResume =
          options & AVAudioSessionInterruptionOptionShouldResume;
      [self notifyDidEndInterruptionWithShouldResumeSession:shouldResume];
      break;
    }
  }
}

- (void)handleRouteChangeNotification:(NSNotification *)notification {
  // Get reason for current route change.
  NSNumber* reasonNumber =
      notification.userInfo[AVAudioSessionRouteChangeReasonKey];
  AVAudioSessionRouteChangeReason reason =
      (AVAudioSessionRouteChangeReason)reasonNumber.unsignedIntegerValue;
  RTCLog(@"Audio route changed:");
  switch (reason) {
    case AVAudioSessionRouteChangeReasonUnknown:
      RTCLog(@"Audio route changed: ReasonUnknown");
      break;
    case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
      RTCLog(@"Audio route changed: NewDeviceAvailable");
      break;
    case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
      RTCLog(@"Audio route changed: OldDeviceUnavailable");
      break;
    case AVAudioSessionRouteChangeReasonCategoryChange:
      RTCLog(@"Audio route changed: CategoryChange to :%@",
             self.session.category);
      break;
    case AVAudioSessionRouteChangeReasonOverride:
      RTCLog(@"Audio route changed: Override");
      break;
    case AVAudioSessionRouteChangeReasonWakeFromSleep:
      RTCLog(@"Audio route changed: WakeFromSleep");
      break;
    case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
      RTCLog(@"Audio route changed: NoSuitableRouteForCategory");
      break;
    case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
      RTCLog(@"Audio route changed: RouteConfigurationChange");
      break;
  }
  AVAudioSessionRouteDescription* previousRoute =
      notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
  // Log previous route configuration.
  RTCLog(@"Previous route: %@\nCurrent route:%@",
         previousRoute, self.session.currentRoute);
  [self notifyDidChangeRouteWithReason:reason previousRoute:previousRoute];
}

- (void)handleMediaServicesWereLost:(NSNotification *)notification {
  RTCLog(@"Media services were lost.");
  [self updateAudioSessionAfterEvent];
  [self notifyMediaServicesWereLost];
}

- (void)handleMediaServicesWereReset:(NSNotification *)notification {
  RTCLog(@"Media services were reset.");
  [self updateAudioSessionAfterEvent];
  [self notifyMediaServicesWereReset];
}

- (void)handleSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
  // TODO(henrika): just adding logs here for now until we know if we are ever
  // see this notification and might be affected by it or if further actions
  // are required.
  NSNumber *typeNumber =
      notification.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey];
  AVAudioSessionSilenceSecondaryAudioHintType type =
      (AVAudioSessionSilenceSecondaryAudioHintType)typeNumber.unsignedIntegerValue;
  switch (type) {
    case AVAudioSessionSilenceSecondaryAudioHintTypeBegin:
      RTCLog(@"Another application's primary audio has started.");
      break;
    case AVAudioSessionSilenceSecondaryAudioHintTypeEnd:
      RTCLog(@"Another application's primary audio has stopped.");
      break;
  }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
  RTCLog(@"Application became active after an interruption. Treating as interruption "
         " end. isInterrupted changed from %d to 0.", self.isInterrupted);
  if (self.isInterrupted) {
    self.isInterrupted = NO;
    [self updateAudioSessionAfterEvent];
  }
  // Always treat application becoming active as an interruption end event.
  [self notifyDidEndInterruptionWithShouldResumeSession:YES];
}

#pragma mark - Private

+ (NSError *)lockError {
  NSDictionary *userInfo = @{
    NSLocalizedDescriptionKey:
        @"Must call lockForConfiguration before calling this method."
  };
  NSError *error =
      [[NSError alloc] initWithDomain:kRTCAudioSessionErrorDomain
                                 code:kRTCAudioSessionErrorLockRequired
                             userInfo:userInfo];
  return error;
}

- (std::vector<__weak id<RTCAudioSessionDelegate> >)delegates {
  @synchronized(self) {
    // Note: this returns a copy.
    return _delegates;
  }
}

// TODO(tkchin): check for duplicates.
- (void)pushDelegate:(id<RTCAudioSessionDelegate>)delegate {
  @synchronized(self) {
    _delegates.insert(_delegates.begin(), delegate);
  }
}

- (void)removeZeroedDelegates {
  @synchronized(self) {
    _delegates.erase(
        std::remove_if(_delegates.begin(),
                       _delegates.end(),
                       [](id delegate) -> bool { return delegate == nil; }),
        _delegates.end());
  }
}

- (int)activationCount {
  return _activationCount;
}

- (int)incrementActivationCount {
  RTCLog(@"Incrementing activation count.");
  return rtc::AtomicOps::Increment(&_activationCount);
}

- (NSInteger)decrementActivationCount {
  RTCLog(@"Decrementing activation count.");
  return rtc::AtomicOps::Decrement(&_activationCount);
}

- (int)webRTCSessionCount {
  return _webRTCSessionCount;
}

- (BOOL)canPlayOrRecord {
  return !self.useManualAudio || self.isAudioEnabled;
}

- (BOOL)isInterrupted {
  @synchronized(self) {
    return _isInterrupted;
  }
}

- (void)setIsInterrupted:(BOOL)isInterrupted {
  @synchronized(self) {
    if (_isInterrupted == isInterrupted) {
      return;
   }
   _isInterrupted = isInterrupted;
  }
}

- (BOOL)checkLock:(NSError **)outError {
  // Check ivar instead of trying to acquire lock so that we won't accidentally
  // acquire lock if it hasn't already been called.
  if (!self.isLocked) {
    if (outError) {
      *outError = [RTCAudioSession lockError];
    }
    return NO;
  }
  return YES;
}

- (BOOL)beginWebRTCSession:(NSError **)outError {
  if (outError) {
    *outError = nil;
  }
  if (![self checkLock:outError]) {
    return NO;
  }
  rtc::AtomicOps::Increment(&_webRTCSessionCount);
  [self notifyDidStartPlayOrRecord];
  return YES;
}

- (BOOL)endWebRTCSession:(NSError **)outError {
  if (outError) {
    *outError = nil;
  }
  if (![self checkLock:outError]) {
    return NO;
  }
  rtc::AtomicOps::Decrement(&_webRTCSessionCount);
  [self notifyDidStopPlayOrRecord];
  return YES;
}

- (BOOL)configureWebRTCSession:(NSError **)outError {
  if (outError) {
    *outError = nil;
  }
  if (![self checkLock:outError]) {
    return NO;
  }
  RTCLog(@"Configuring audio session for WebRTC.");

  // Configure the AVAudioSession and activate it.
  // Provide an error even if there isn't one so we can log it.
  NSError *error = nil;
  RTCAudioSessionConfiguration *webRTCConfig =
      [RTCAudioSessionConfiguration webRTCConfiguration];
  if (![self setConfiguration:webRTCConfig active:YES error:&error]) {
    RTCLogError(@"Failed to set WebRTC audio configuration: %@",
                error.localizedDescription);
    // Do not call setActive:NO if setActive:YES failed.
    if (outError) {
      *outError = error;
    }
    return NO;
  }

  // Ensure that the device currently supports audio input.
  // TODO(tkchin): Figure out if this is really necessary.
  if (!self.inputAvailable) {
    RTCLogError(@"No audio input path is available!");
    [self unconfigureWebRTCSession:nil];
    if (outError) {
      *outError = [self configurationErrorWithDescription:@"No input path."];
    }
    return NO;
  }

  // It can happen (e.g. in combination with BT devices) that the attempt to set
  // the preferred sample rate for WebRTC (48kHz) fails. If so, make a new
  // configuration attempt using the sample rate that worked using the active
  // audio session. A typical case is that only 8 or 16kHz can be set, e.g. in
  // combination with BT headsets. Using this "trick" seems to avoid a state
  // where Core Audio asks for a different number of audio frames than what the
  // session's I/O buffer duration corresponds to.
  // TODO(henrika): this fix resolves bugs.webrtc.org/6004 but it has only been
  // tested on a limited set of iOS devices and BT devices.
  double sessionSampleRate = self.sampleRate;
  double preferredSampleRate = webRTCConfig.sampleRate;
  if (sessionSampleRate != preferredSampleRate) {
    RTCLogWarning(
        @"Current sample rate (%.2f) is not the preferred rate (%.2f)",
        sessionSampleRate, preferredSampleRate);
    if (![self setPreferredSampleRate:preferredSampleRate
                                error:&error]) {
      RTCLogError(@"Failed to set preferred sample rate: %@",
                  error.localizedDescription);
      if (outError) {
        *outError = error;
      }
    }
  }

  return YES;
}

- (BOOL)unconfigureWebRTCSession:(NSError **)outError {
  if (outError) {
    *outError = nil;
  }
  if (![self checkLock:outError]) {
    return NO;
  }
  RTCLog(@"Unconfiguring audio session for WebRTC.");
  [self setActive:NO error:outError];

  return YES;
}

- (NSError *)configurationErrorWithDescription:(NSString *)description {
  NSDictionary* userInfo = @{
    NSLocalizedDescriptionKey: description,
  };
  return [[NSError alloc] initWithDomain:kRTCAudioSessionErrorDomain
                                    code:kRTCAudioSessionErrorConfiguration
                                userInfo:userInfo];
}

- (void)updateAudioSessionAfterEvent {
  BOOL shouldActivate = self.activationCount > 0;
  AVAudioSessionSetActiveOptions options = shouldActivate ?
      0 : AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
  NSError *error = nil;
  if ([self.session setActive:shouldActivate
                  withOptions:options
                        error:&error]) {
    self.isActive = shouldActivate;
  } else {
    RTCLogError(@"Failed to set session active to %d. Error:%@",
                shouldActivate, error.localizedDescription);
  }
}

- (void)updateCanPlayOrRecord {
  BOOL canPlayOrRecord = NO;
  BOOL shouldNotify = NO;
  @synchronized(self) {
    canPlayOrRecord = !self.useManualAudio || self.isAudioEnabled;
    if (_canPlayOrRecord == canPlayOrRecord) {
      return;
    }
    _canPlayOrRecord = canPlayOrRecord;
    shouldNotify = YES;
  }
  if (shouldNotify) {
    [self notifyDidChangeCanPlayOrRecord:canPlayOrRecord];
  }
}

- (void)audioSessionDidActivate:(AVAudioSession *)session {
  if (_session != session) {
    RTCLogError(@"audioSessionDidActivate called on different AVAudioSession");
  }
  [self incrementActivationCount];
  self.isActive = YES;
}

- (void)audioSessionDidDeactivate:(AVAudioSession *)session {
  if (_session != session) {
    RTCLogError(@"audioSessionDidDeactivate called on different AVAudioSession");
  }
  self.isActive = NO;
  [self decrementActivationCount];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == _session) {
    NSNumber *newVolume = change[NSKeyValueChangeNewKey];
    RTCLog(@"OutputVolumeDidChange to %f", newVolume.floatValue);
    [self notifyDidChangeOutputVolume:newVolume.floatValue];
  } else {
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
}

- (void)notifyDidBeginInterruption {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionDidBeginInterruption:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionDidBeginInterruption:self];
    }
  }
}

- (void)notifyDidEndInterruptionWithShouldResumeSession:
    (BOOL)shouldResumeSession {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionDidEndInterruption:shouldResumeSession:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionDidEndInterruption:self
                           shouldResumeSession:shouldResumeSession];
    }
  }
}

- (void)notifyDidChangeRouteWithReason:(AVAudioSessionRouteChangeReason)reason
    previousRoute:(AVAudioSessionRouteDescription *)previousRoute {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionDidChangeRoute:reason:previousRoute:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionDidChangeRoute:self
                                    reason:reason
                             previousRoute:previousRoute];
    }
  }
}

- (void)notifyMediaServicesWereLost {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionMediaServerTerminated:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionMediaServerTerminated:self];
    }
  }
}

- (void)notifyMediaServicesWereReset {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionMediaServerReset:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionMediaServerReset:self];
    }
  }
}

- (void)notifyDidChangeCanPlayOrRecord:(BOOL)canPlayOrRecord {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSession:didChangeCanPlayOrRecord:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSession:self didChangeCanPlayOrRecord:canPlayOrRecord];
    }
  }
}

- (void)notifyDidStartPlayOrRecord {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionDidStartPlayOrRecord:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionDidStartPlayOrRecord:self];
    }
  }
}

- (void)notifyDidStopPlayOrRecord {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSessionDidStopPlayOrRecord:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSessionDidStopPlayOrRecord:self];
    }
  }
}

- (void)notifyDidChangeOutputVolume:(float)volume {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSession:didChangeOutputVolume:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSession:self didChangeOutputVolume:volume];
    }
  }
}

- (void)notifyDidDetectPlayoutGlitch:(int64_t)totalNumberOfGlitches {
  for (auto delegate : self.delegates) {
    SEL sel = @selector(audioSession:didDetectPlayoutGlitch:);
    if ([delegate respondsToSelector:sel]) {
      [delegate audioSession:self didDetectPlayoutGlitch:totalNumberOfGlitches];
    }
  }
}

@end
