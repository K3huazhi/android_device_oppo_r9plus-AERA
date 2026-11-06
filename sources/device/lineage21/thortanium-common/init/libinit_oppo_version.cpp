/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_oppo_version.h>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>

using android::base::ReadFileToString;
using android::base::Trim;

constexpr const char* kPrjVersion = "/proc/oppoVersion/prjVersion";
constexpr const char* kOperatorName = "/proc/oppoVersion/operatorName";
constexpr const char* kPcbVersion = "/proc/oppoVersion/pcbVersion";

int32_t ReadProjectVersion() {
    std::string buf;
    if (ReadFileToString(kPrjVersion, &buf)) {
        return std::stoi(Trim(buf));
    }
    return -1;
}

int32_t ReadOperatorName() {
    std::string buf;
    if (ReadFileToString(kOperatorName, &buf)) {
        return std::stoi(Trim(buf));
    }
    return -1;
}

int32_t ReadPcbVersion() {
    std::string buf;
    if (ReadFileToString(kPcbVersion, &buf)) {
        return std::stoi(Trim(buf));
    }
    return -1;
}
