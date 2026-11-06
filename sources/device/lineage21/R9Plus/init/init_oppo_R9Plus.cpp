/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_dalvik_heap.h>
#include <libinit_oppo_version.h>
#include <libinit_utils.h>
#include <libinit_variant.h>

#include "vendor_init.h"

#include <android-base/file.h>
#include <android-base/logging.h>

using android::base::ReadFileToString;

static const variant_info_t r9plus_info = {
    .brand = "OPPO",
    .device = "R9PlusA",
    .marketname = "OPPO R9s Plus",
    .model = "OPPO R9 Plusm A",
    .build_fingerprint = "OPPO/R9PlusmA/R9PlusA:5.1.1/LMY47V/1521209354:user/release-keys",
    .build_description = "msm8952_64-user 5.1.1 LMY47V eng.root.20190904.035419 dev-keys",
};

static const variant_info_t r9plust_info = {
    .brand = "OPPO",
    .device = "R9PlusA",
    .marketname = "OPPO R9s Plust",
    .model = "OPPO R9 Plustm A",
    .build_fingerprint = "OPPO/R9PlustmA/R9PlusA:5.1.1/LMY47V/1521209354:user/release-keys",
    .build_description = "msm8952_64-user 5.1.1 LMY47V eng.root.20190904.035419 dev-keys",
};

static const variant_info_t x9079_info = {
    .brand = "OPPO",
    .device = "X9079",
    .marketname = "OPPO R9s Plus",
    .model = "X9079",
    .build_fingerprint = "OPPO/msm8952_64/msm8952_64:5.1.1/LMY47V/root03041246:user/release-keys",
    .build_description = "msm8952_64-user 5.1.1 LMY47V eng.root.20190304.124440 release-keys",
};

static void determine_device() {
    if (ReadProjectVersion() == 15103) {
        switch (ReadOperatorName()) {
            /* China */
            case 8:
                set_variant_props(r9plus_info);
                break;

            case 9:
                set_variant_props(r9plust_info);
                break;

            /* Global */
            case 101:
                set_variant_props(x9079_info);
                break;

            default:
                LOG(WARNING) << "Unknown operator variant, setting X9079";
                set_variant_props(x9079_info);
                break;
        }
    } else {
        LOG(ERROR) << "Unknown device variant";
    }
}

void vendor_load_properties() {
    determine_device();
    set_dalvik_heap();
}
