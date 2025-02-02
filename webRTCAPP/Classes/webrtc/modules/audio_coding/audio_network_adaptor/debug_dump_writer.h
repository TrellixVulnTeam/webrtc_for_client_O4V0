/*
 *  Copyright (c) 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef WEBRTC_MODULES_AUDIO_CODING_AUDIO_NETWORK_ADAPTOR_DEBUG_DUMP_WRITER_H_
#define WEBRTC_MODULES_AUDIO_CODING_AUDIO_NETWORK_ADAPTOR_DEBUG_DUMP_WRITER_H_

#include <memory>

#include "webrtc/base/constructormagic.h"
#include "webrtc/base/ignore_wundef.h"
#include "webrtc/modules/audio_coding/audio_network_adaptor/controller.h"
#include "webrtc/modules/audio_coding/audio_network_adaptor/include/audio_network_adaptor.h"
#include "webrtc/system_wrappers/include/file_wrapper.h"
#if WEBRTC_ENABLE_PROTOBUF
RTC_PUSH_IGNORING_WUNDEF()
#ifdef WEBRTC_ANDROID_PLATFORM_BUILD
#include "external/webrtc/webrtc/modules/audio_coding/audio_network_adaptor/config.pb.h"
#else
#include "webrtc/modules/audio_coding/audio_network_adaptor/config.pb.h"
#endif
RTC_POP_IGNORING_WUNDEF()
#endif

namespace webrtc {

class DebugDumpWriter {
 public:
  static std::unique_ptr<DebugDumpWriter> Create(FILE* file_handle);

  virtual ~DebugDumpWriter() = default;

  virtual void DumpEncoderRuntimeConfig(const AudioEncoderRuntimeConfig& config,
                                        int64_t timestamp) = 0;

  virtual void DumpNetworkMetrics(const Controller::NetworkMetrics& metrics,
                                  int64_t timestamp) = 0;

#if WEBRTC_ENABLE_PROTOBUF
  virtual void DumpControllerManagerConfig(
      const audio_network_adaptor::config::ControllerManager&
          controller_manager_config,
      int64_t timestamp) = 0;
#endif
};

}  // namespace webrtc

#endif  // WEBRTC_MODULES_AUDIO_CODING_AUDIO_NETWORK_ADAPTOR_DEBUG_DUMP_WRITER_H_
