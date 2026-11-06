/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "oppo_ril"

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>

#include "qcril_functions.h"
#include "qmi_interface.h"

#define QMI_DMS_ESN_MAX_V01 32
#define QMI_DMS_IMEI_MAX_V01 32
#define QMI_DMS_MEID_MAX_V01 32
#define QMI_DMS_IMEISV_MAX_V01 255

#define IMEI_PROP "oppo.device.imeicache"
#define IMEISV_PROP "ro.vendor.radio.imei.sv"

using android::base::GetProperty;

typedef struct {
	qmi_response_type_v01 resp;

	/* ESN */
	uint8_t esn_valid;
	char esn[QMI_DMS_ESN_MAX_V01 + 1];

	/* IMEI */
	uint8_t imei_valid;
	char imei[QMI_DMS_IMEI_MAX_V01 + 1];

	/* MEID */
	uint8_t meid_valid;
	char meid[QMI_DMS_MEID_MAX_V01 + 1];

	/* IMEI SVN */
	uint8_t imeisv_svn_valid;
	char imeisv_svn[QMI_DMS_IMEISV_MAX_V01 + 1];
} sn_resp;

// Shim for qmi_client_send_msg_sync_with_shm
extern "C" int qmi_client_send_msg_sync_shim_fun(void *user_handle, int msg_id,
		void *req_c_struct, int req_c_struct_len,
		void *resp_c_struct, int resp_c_struct_len,
		int timeout_msecs)
{
	std::string prop;
	sn_resp *response;

	if (msg_id == 0x0025) { /* QMI_DMS_GET_DEVICE_SERIAL_NUMBERS_REQ_V01 */
		response = (sn_resp *) resp_c_struct;

		// Read from IMEI cache
		prop = GetProperty(IMEI_PROP, "");
		if (prop.empty()) {
			LOG(ERROR) << IMEI_PROP << " is not set";
			return QMI_INTERNAL_ERR;
		}

		// Set IMEI based on SIM slot
		int sim_slot = qmi_ril_get_sim_slot();
		switch (sim_slot) {
			case 0:
				strcpy(response->imei,
				       prop.substr(0, prop.find(",")).c_str());
				break;
			case 1:
				strcpy(response->imei,
				       prop.substr(prop.find(",") + 1, prop.length()).c_str());
				break;
			default:
				LOG(ERROR) << "Unknown SIM slot " << sim_slot;
				return QMI_INTERNAL_ERR;
		}
		response->imei_valid = true;

		// Set IMEI SV after IMEI
		prop = GetProperty(IMEISV_PROP, "");
		if (prop.empty()) {
			LOG(ERROR) << IMEISV_PROP << " is not set";
			return QMI_INTERNAL_ERR;
		}
		sprintf(response->imeisv_svn, "%x", atoi(prop.c_str()));
		response->imeisv_svn_valid = true;

		// Respond as no error
		response->resp.result = 0;
		response->resp.error = 0;
	} else {
		return qmi_client_send_msg_sync(user_handle, msg_id,
				req_c_struct, req_c_struct_len,
				resp_c_struct, resp_c_struct_len,
				timeout_msecs
		);
	}

	return QMI_NO_ERR;
}
