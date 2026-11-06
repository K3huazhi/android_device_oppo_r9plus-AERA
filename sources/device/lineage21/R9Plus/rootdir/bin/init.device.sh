#! /vendor/bin/sh

#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

operator_name=$(cat /proc/oppoVersion/operatorName)

if [ $operator_name = 8 ] || [ $operator_name = 9 ]; then # China
    # Separate soft
    setprop ro.separate.soft 15103

    # WiFi NV
    case $operator_name in
        "2" ) # 15110 CMCC
            setprop ro.vendor.wifi.nv 15110
            ;;
        * ) # 15103
            setprop ro.vendor.wifi.nv 15103
            ;;
    esac

    # IMEI SV
    setprop ro.vendor.radio.imei.sv 29
else # Global
    # Separate soft
    setprop ro.separate.soft 16303

    # WiFi NV
    setprop ro.vendor.wifi.nv 16303

    # IMEI SV
    setprop ro.vendor.radio.imei.sv 15
fi
