# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := usrsctplib
DEFS_Debug := \
	'-DSCTP_PROCESS_LEVEL_LOCKS' \
	'-DSCTP_SIMPLE_ALLOCATOR' \
	'-DSCTP_USE_OPENSSL_SHA1' \
	'-D__Userspace__' \
	'-DV8_DEPRECATION_WARNINGS' \
	'-D_FILE_OFFSET_BITS=64' \
	'-DCHROMIUM_BUILD' \
	'-DCR_CLANG_REVISION=274369-1' \
	'-DUI_COMPOSITOR_IMAGE_TRANSPORT' \
	'-DUSE_AURA=1' \
	'-DUSE_PANGO=1' \
	'-DUSE_CAIRO=1' \
	'-DUSE_DEFAULT_RENDER_THEME=1' \
	'-DUSE_LIBJPEG_TURBO=1' \
	'-DUSE_X11=1' \
	'-DUSE_CLIPBOARD_AURAX11=1' \
	'-DENABLE_WEBRTC=1' \
	'-DENABLE_MEDIA_ROUTER=1' \
	'-DENABLE_PEPPER_CDMS' \
	'-DENABLE_NOTIFICATIONS' \
	'-DUSE_UDEV' \
	'-DFIELDTRIAL_TESTING_ENABLED' \
	'-DENABLE_TASK_MANAGER=1' \
	'-DENABLE_EXTENSIONS=1' \
	'-DENABLE_PDF=1' \
	'-DENABLE_PLUGINS=1' \
	'-DENABLE_SESSION_SERVICE=1' \
	'-DENABLE_THEMES=1' \
	'-DENABLE_PRINTING=1' \
	'-DENABLE_BASIC_PRINTING=1' \
	'-DENABLE_PRINT_PREVIEW=1' \
	'-DENABLE_SPELLCHECK=1' \
	'-DENABLE_CAPTIVE_PORTAL_DETECTION=1' \
	'-DENABLE_SUPERVISED_USERS=1' \
	'-DENABLE_MDNS=1' \
	'-DENABLE_SERVICE_DISCOVERY=1' \
	'-DV8_USE_EXTERNAL_STARTUP_DATA' \
	'-DFULL_SAFE_BROWSING' \
	'-DSAFE_BROWSING_CSD' \
	'-DSAFE_BROWSING_DB_LOCAL' \
	'-D__Userspace_os_Linux' \
	'-D_GNU_SOURCE' \
	'-DNON_WINDOWS_DEFINE' \
	'-DUSE_LIBPCI=1' \
	'-DUSE_GLIB=1' \
	'-DUSE_NSS_CERTS=1' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=1' \
	'-DWTF_USE_DYNAMIC_ANNOTATIONS=1' \
	'-D_DEBUG' \
	'-D_GLIBCXX_DEBUG=1'

# Flags passed to all source files.
CFLAGS_Debug := \
	-fstack-protector \
	--param=ssp-buffer-size=4 \
	-pthread \
	-fno-strict-aliasing \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-Xclang \
	-load \
	-Xclang \
	/data/home/RTChatServer/webrtc-checkout/src/third_party/llvm-build/Release+Asserts/lib/libFindBadConstructs.so \
	-Xclang \
	-add-plugin \
	-Xclang \
	find-bad-constructs \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	check-templates \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	follow-macro-expansion \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	check-implicit-copy-ctors \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	check-ipc \
	-B/data/home/RTChatServer/webrtc-checkout/src//usr/bin \
	-Wno-char-subscripts \
	-Wno-unused-function \
	-Wno-unused-variable \
	-w \
	-m64 \
	-march=x86-64 \
	--sysroot=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot \
	-O0 \
	-g \
	-funwind-tables \
	-gsplit-dwarf

# Flags passed to only C files.
CFLAGS_C_Debug :=

# Flags passed to only C++ files.
CFLAGS_CC_Debug := \
	-fno-exceptions \
	-fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden \
	-std=gnu++11 \
	-Wno-deprecated

INCS_Debug := \
	-Ichromium/src/third_party/usrsctp/usrsctplib/usrsctplib \
	-Ichromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet \
	-I$(obj)/gen \
	-Ichromium/src/third_party/boringssl/src/include

DEFS_Release := \
	'-DSCTP_PROCESS_LEVEL_LOCKS' \
	'-DSCTP_SIMPLE_ALLOCATOR' \
	'-DSCTP_USE_OPENSSL_SHA1' \
	'-D__Userspace__' \
	'-DV8_DEPRECATION_WARNINGS' \
	'-D_FILE_OFFSET_BITS=64' \
	'-DCHROMIUM_BUILD' \
	'-DCR_CLANG_REVISION=274369-1' \
	'-DUI_COMPOSITOR_IMAGE_TRANSPORT' \
	'-DUSE_AURA=1' \
	'-DUSE_PANGO=1' \
	'-DUSE_CAIRO=1' \
	'-DUSE_DEFAULT_RENDER_THEME=1' \
	'-DUSE_LIBJPEG_TURBO=1' \
	'-DUSE_X11=1' \
	'-DUSE_CLIPBOARD_AURAX11=1' \
	'-DENABLE_WEBRTC=1' \
	'-DENABLE_MEDIA_ROUTER=1' \
	'-DENABLE_PEPPER_CDMS' \
	'-DENABLE_NOTIFICATIONS' \
	'-DUSE_UDEV' \
	'-DFIELDTRIAL_TESTING_ENABLED' \
	'-DENABLE_TASK_MANAGER=1' \
	'-DENABLE_EXTENSIONS=1' \
	'-DENABLE_PDF=1' \
	'-DENABLE_PLUGINS=1' \
	'-DENABLE_SESSION_SERVICE=1' \
	'-DENABLE_THEMES=1' \
	'-DENABLE_PRINTING=1' \
	'-DENABLE_BASIC_PRINTING=1' \
	'-DENABLE_PRINT_PREVIEW=1' \
	'-DENABLE_SPELLCHECK=1' \
	'-DENABLE_CAPTIVE_PORTAL_DETECTION=1' \
	'-DENABLE_SUPERVISED_USERS=1' \
	'-DENABLE_MDNS=1' \
	'-DENABLE_SERVICE_DISCOVERY=1' \
	'-DV8_USE_EXTERNAL_STARTUP_DATA' \
	'-DFULL_SAFE_BROWSING' \
	'-DSAFE_BROWSING_CSD' \
	'-DSAFE_BROWSING_DB_LOCAL' \
	'-D__Userspace_os_Linux' \
	'-D_GNU_SOURCE' \
	'-DNON_WINDOWS_DEFINE' \
	'-DUSE_LIBPCI=1' \
	'-DUSE_GLIB=1' \
	'-DUSE_NSS_CERTS=1' \
	'-DNDEBUG' \
	'-DNVALGRIND' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=0'

# Flags passed to all source files.
CFLAGS_Release := \
	-fstack-protector \
	--param=ssp-buffer-size=4 \
	-pthread \
	-fno-strict-aliasing \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-Xclang \
	-load \
	-Xclang \
	/data/home/RTChatServer/webrtc-checkout/src/third_party/llvm-build/Release+Asserts/lib/libFindBadConstructs.so \
	-Xclang \
	-add-plugin \
	-Xclang \
	find-bad-constructs \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	check-templates \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	follow-macro-expansion \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	check-implicit-copy-ctors \
	-Xclang \
	-plugin-arg-find-bad-constructs \
	-Xclang \
	check-ipc \
	-B/data/home/RTChatServer/webrtc-checkout/src//usr/bin \
	-Wno-char-subscripts \
	-Wno-unused-function \
	-Wno-unused-variable \
	-w \
	-m64 \
	-march=x86-64 \
	--sysroot=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot \
	-O2 \
	-fno-ident \
	-fdata-sections \
	-ffunction-sections \
	-funwind-tables

# Flags passed to only C files.
CFLAGS_C_Release :=

# Flags passed to only C++ files.
CFLAGS_CC_Release := \
	-fno-exceptions \
	-fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden \
	-std=gnu++11 \
	-Wno-deprecated

INCS_Release := \
	-Ichromium/src/third_party/usrsctp/usrsctplib/usrsctplib \
	-Ichromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet \
	-I$(obj)/gen \
	-Ichromium/src/third_party/boringssl/src/include

OBJS := \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_asconf.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_auth.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_bsd_addr.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_callout.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_cc_functions.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_crc32.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_indata.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_input.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_output.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_pcb.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_peeloff.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_sha1.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_ss_functions.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_sysctl.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_timer.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_userspace.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctp_usrreq.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet/sctputil.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/netinet6/sctp6_usrreq.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/user_environment.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/user_mbuf.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/user_recv_thread.o \
	$(obj).target/$(TARGET)/chromium/src/third_party/usrsctp/usrsctplib/usrsctplib/user_socket.o

# Add to the list of files we specially track dependencies for.
all_deps += $(OBJS)

# CFLAGS et al overrides must be target-local.
# See "Target-specific Variable Values" in the GNU Make manual.
$(OBJS): TOOLSET := $(TOOLSET)
$(OBJS): GYP_CFLAGS := $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE))  $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_C_$(BUILDTYPE))
$(OBJS): GYP_CXXFLAGS := $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE))  $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_CC_$(BUILDTYPE))

# Suffix rules, putting all outputs into $(obj).

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(srcdir)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

# Try building from generated source, too.

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj).$(TOOLSET)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

# End of this set of suffix rules
### Rules for final target.
LDFLAGS_Debug := \
	-Wl,-z,now \
	-Wl,-z,relro \
	-Wl,--fatal-warnings \
	-Wl,-z,defs \
	-pthread \
	-Wl,-z,noexecstack \
	-fPIC \
	-fuse-ld=gold \
	-B/data/home/RTChatServer/webrtc-checkout/src//usr/bin \
	-Wl,--disable-new-dtags \
	-m64 \
	--sysroot=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot \
	-L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/lib/x86_64-linux-gnu -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/lib/x86_64-linux-gnu -L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/x86_64-linux-gnu -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/x86_64-linux-gnu -L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/gcc/x86_64-linux-gnu/4.6 -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/gcc/x86_64-linux-gnu/4.6 -L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib \
	-Wl,--threads \
	-Wl,--thread-count=4 \
	-Wl,--detect-odr-violations \
	-Wl,--icf=all

LDFLAGS_Release := \
	-Wl,-z,now \
	-Wl,-z,relro \
	-Wl,--fatal-warnings \
	-Wl,-z,defs \
	-pthread \
	-Wl,-z,noexecstack \
	-fPIC \
	-fuse-ld=gold \
	-B/data/home/RTChatServer/webrtc-checkout/src//usr/bin \
	-Wl,--disable-new-dtags \
	-m64 \
	--sysroot=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot \
	-L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/lib/x86_64-linux-gnu -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/lib/x86_64-linux-gnu -L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/x86_64-linux-gnu -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/x86_64-linux-gnu -L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/gcc/x86_64-linux-gnu/4.6 -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib/gcc/x86_64-linux-gnu/4.6 -L/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib -Wl,-rpath-link=/data/home/RTChatServer/webrtc-checkout/src/build/linux/debian_wheezy_amd64-sysroot/usr/lib \
	-Wl,--threads \
	-Wl,--thread-count=4 \
	-Wl,--detect-odr-violations \
	-Wl,--icf=all \
	-Wl,-O1 \
	-Wl,--as-needed \
	-Wl,--gc-sections \
	-Wl,--no-as-needed \
	-lpthread \
	-Wl,--as-needed

LIBS := \
	

$(obj).target/chromium/src/third_party/usrsctp/libusrsctplib.a: GYP_LDFLAGS := $(LDFLAGS_$(BUILDTYPE))
$(obj).target/chromium/src/third_party/usrsctp/libusrsctplib.a: LIBS := $(LIBS)
$(obj).target/chromium/src/third_party/usrsctp/libusrsctplib.a: TOOLSET := $(TOOLSET)
$(obj).target/chromium/src/third_party/usrsctp/libusrsctplib.a: $(OBJS) FORCE_DO_CMD
	$(call do_cmd,alink_thin)

all_deps += $(obj).target/chromium/src/third_party/usrsctp/libusrsctplib.a
# Add target alias
.PHONY: usrsctplib
usrsctplib: $(obj).target/chromium/src/third_party/usrsctp/libusrsctplib.a

# Add target alias to "all" target.
.PHONY: all
all: usrsctplib

