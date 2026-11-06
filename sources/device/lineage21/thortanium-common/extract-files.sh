#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system_ext/lib64/lib-imsvideocodec.so)
            "${PATCHELF}" --add-needed "libgui_shim.so" "${2}"
            "${PATCHELF}" --replace-needed "libqdMetaData.so" "libqdMetaData.system.so" "${2}"
            ;;
        vendor/lib/libmmcamera_dbg.so)
            sed -i "s|/data/vendor/camera/|///data/vendor/qcam/|g" "${2}"
            ;;
        vendor/lib64/libril-qc-hal-qmi.so)
            for v in 1.{0..2}; do
                sed -i "s|android.hardware.radio.config@${v}.so|android.hardware.radio.c_shim@${v}.so|g" "${2}"
            done

            "${PATCHELF_0_17_2}" --add-needed "libril-qcril-oppo.so" "${2}"
            sed -i "s|qmi_client_send_msg_sync_with_shm|qmi_client_send_msg_sync_shim_fun|g" "${2}"
            ;;
        vendor/lib64/libwvhidl.so|vendor/lib64/mediadrm/libwvdrmengine.so)
            sed -i 's|libprotobuf-cpp-lite-3.9.1.so|libprotobuf-cpp-full-3.9.1.so|g' "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE_COMMON}" "${VENDOR_COMMON:-$VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"
extract "${MY_DIR}/proprietary-files-fm.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../../${VENDOR}/${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
