/*
 * Copyright (C) 2021 The LineageOS Project
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

#include "KeySwapper.h"

namespace vendor {
namespace lineage {
namespace touch {
namespace V1_0 {
namespace implementation {

constexpr const char kControlPath[] = "/proc/touchpanel/touchkey_reverse_enable";
constexpr const char kControlPath2[] = "/proc/touchkey/key_rep";

KeySwapper::KeySwapper() {
    if (!access(kControlPath, F_OK))
        mControlPaths.push_back(kControlPath);

    if (!access(kControlPath2, F_OK))
        mControlPaths.push_back(kControlPath2);

    mHasKeySwapper = !mControlPaths.empty();
}

// Methods from ::vendor::lineage::touch::V1_0::IKeySwapper follow.
Return<bool> KeySwapper::isEnabled() {
    std::vector<int> ret;
    std::string buf;

    if (!mHasKeySwapper) return false;

    for (auto path : mControlPaths) {
        ret.push_back(android::base::ReadFileToString(path, &buf));
        if (!ret.back())
            LOG(WARNING) << "Failed to read " << path;
    }

    return std::stoi(android::base::Trim(buf)) == 1 || !std::any_of(ret.begin(), ret.end(), [](int val) { return val; });
}

Return<bool> KeySwapper::setEnabled(bool enabled) {
    std::vector<int> ret;

    if (!mHasKeySwapper) return false;

    for (auto path : mControlPaths) {
        ret.push_back(android::base::WriteStringToFile((enabled ? "1" : "0"), path));
        if (!ret.back())
            LOG(WARNING) << "Failed to write " << path;
    }

    return !std::any_of(ret.begin(), ret.end(), [](int val) { return val; });
}

}  // namespace implementation
}  // namespace V1_0
}  // namespace touch
}  // namespace lineage
}  // namespace vendor
