# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := expat
### Rules for final target.
$(obj).target/chromium/src/third_party/expat/expat.stamp: TOOLSET := $(TOOLSET)
$(obj).target/chromium/src/third_party/expat/expat.stamp:  FORCE_DO_CMD
	$(call do_cmd,touch)

all_deps += $(obj).target/chromium/src/third_party/expat/expat.stamp
# Add target alias
.PHONY: expat
expat: $(obj).target/chromium/src/third_party/expat/expat.stamp

# Add target alias to "all" target.
.PHONY: all
all: expat

