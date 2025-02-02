#!/usr/bin/env python
# Copyright (c) 2013 The WebRTC project authors. All Rights Reserved.
#
# Use of this source code is governed by a BSD-style license
# that can be found in the LICENSE file in the root of the source
# tree. An additional intellectual property rights grant can be found
# in the file PATENTS.  All contributing project authors may
# be found in the AUTHORS file in the root of the source tree.

import os

# This is just a forwarding script during the transition of renaming tools to
# rtc_tools. To avoid breaking Chromium tests.

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RTC_TOOLS_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, os.pardir,
                                             'rtc_tools'))
os.system(os.path.join(RTC_TOOLS_DIR, 'compare_videos.py'))
