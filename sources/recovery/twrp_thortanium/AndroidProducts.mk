#
# Copyright (C) 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/A57/twrp_A57.mk \
    $(LOCAL_DIR)/R9s/twrp_R9s.mk \
    $(LOCAL_DIR)/R9sPlus/twrp_R9sPlus.mk \
    $(LOCAL_DIR)/R9Plus/twrp_R9Plus.mk \
    $(LOCAL_DIR)/R9Plus/twrp_R9PlusL.mk

COMMON_LUNCH_CHOICES := \
    twrp_A57-user \
    twrp_A57-userdebug \
    twrp_A57-eng \
    twrp_R9s-user \
    twrp_R9s-userdebug \
    twrp_R9s-eng \
    twrp_R9sPlus-user \
    twrp_R9sPlus-userdebug \
    twrp_R9sPlus-eng \
    twrp_R9Plus-user \
    twrp_R9Plus-userdebug \
    twrp_R9Plus-eng \
    twrp_R9PlusL-user \
    twrp_R9PlusL-userdebug \
    twrp_R9PlusL-eng
