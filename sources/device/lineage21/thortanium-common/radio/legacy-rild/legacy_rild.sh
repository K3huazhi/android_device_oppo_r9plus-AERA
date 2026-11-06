#! /vendor/bin/sh

#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

retry_sec=15

while [ -z "$(getprop oppo.device.imeicache)" ]; do
	echo "Waiting for OPPO NV dump for IMEI..."
	sleep $retry_sec

	stop vendor.legacy-ril-daemon
	stop vendor.legacy-ril-daemon2

	start vendor.legacy-ril-daemon
	start vendor.legacy-ril-daemon2
done
