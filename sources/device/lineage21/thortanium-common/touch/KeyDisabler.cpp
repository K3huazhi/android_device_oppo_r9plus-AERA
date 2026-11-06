/*
 * Copyright (C) 2019 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>

#include "KeyDisabler.h"

namespace vendor {
namespace lineage {
namespace touch {
namespace V1_0 {
namespace implementation {

constexpr const char kControlPath[] = "/proc/touchpanel/touchkey_enable";
constexpr const char kControlPath2[] = "/proc/touchkey/key_enable";
constexpr const char kControlPathKeys[] = "/sys/devices/platform/soc/soc:gpio_keys/disabled_keys";

KeyDisabler::KeyDisabler() {
    if (!access(kControlPath, F_OK))
        mControlPaths.push_back(kControlPath);

    if (!access(kControlPath2, F_OK))
        mControlPaths.push_back(kControlPath2);

    mHasKeyDisabler = !mControlPaths.empty();
}

// Methods from ::vendor::lineage::touch::V1_0::IKeyDisabler follow.
Return<bool> KeyDisabler::isEnabled() {
    std::vector<int> ret;
    std::string buf;

    if (!mHasKeyDisabler) return false;

    for (auto path : mControlPaths) {
        ret.push_back(android::base::ReadFileToString(path, &buf));
        if (!ret.back())
            LOG(WARNING) << "Failed to read " << path;
    }

    return std::stoi(android::base::Trim(buf)) == 0 || !std::any_of(ret.begin(), ret.end(), [](int val) { return val; });
}

Return<bool> KeyDisabler::setEnabled(bool enabled) {
    std::vector<int> ret;

    if (!mHasKeyDisabler) return false;

    for (auto path : mControlPaths) {
        ret.push_back(android::base::WriteStringToFile((enabled ? "0" : "1"), path));
        if (!ret.back())
            LOG(WARNING) << "Failed to write " << path;
    }

    if (!access(kControlPathKeys, F_OK)) {
        ret.push_back(android::base::WriteStringToFile((enabled ? "102" : ""), kControlPathKeys));
        if (!ret.back())
            LOG(WARNING) << "Failed to read " << kControlPathKeys;
    }

    return !std::any_of(ret.begin(), ret.end(), [](int val) { return val; });
}

}  // namespace implementation
}  // namespace V1_0
}  // namespace touch
}  // namespace lineage
}  // namespace vendor
