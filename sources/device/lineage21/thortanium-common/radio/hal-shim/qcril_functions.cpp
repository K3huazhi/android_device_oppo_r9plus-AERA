/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "oppo_ril"

#include <dlfcn.h>
#include <android-base/logging.h>

#include "qcril_functions.h"
#include "qmi_interface.h"

#define QMI_CCI_LIB "libqmi_cci.so"
#define QCRIL_LIB "libril-qc-hal-qmi.so"

static void *qmi_cci_handle = NULL;
static void *qcril_handle = NULL;

int get_qmi_cci_handle()
{
	if (qmi_cci_handle)
		return QMI_NO_ERR;

	qmi_cci_handle = dlopen(QMI_CCI_LIB, RTLD_NOW);
	if (!qmi_cci_handle) {
		LOG(ERROR) << "Failed to open " << QMI_CCI_LIB << ": " << dlerror();
		return QMI_INTERNAL_ERR;
	}

	return QMI_NO_ERR;
}

int get_qcril_handle()
{
	if (qcril_handle)
		return QMI_NO_ERR;

	qcril_handle = dlopen(QCRIL_LIB, RTLD_NOW);
	if (!qcril_handle) {
		LOG(ERROR) << "Failed to open " << QCRIL_LIB << ": " << dlerror();
		return QMI_INTERNAL_ERR;
	}

	return QMI_NO_ERR;
}

int qmi_client_send_msg_sync(void *user_handle, int msg_id,
		void *req_c_struct, int req_c_struct_len,
		void *resp_c_struct, int resp_c_struct_len,
		int timeout_msecs)
{
	int (*send_msg_sync)(void *, int, void *, int, void *, int, int);

	if (get_qmi_cci_handle())
		return QMI_INTERNAL_ERR;

	send_msg_sync = reinterpret_cast<decltype(send_msg_sync)>(
		dlsym(qmi_cci_handle, "qmi_client_send_msg_sync"));
	if (!send_msg_sync) {
		LOG(ERROR) << "Failed to resolve function: " << __func__;
		return QMI_INTERNAL_ERR;
	}

	return send_msg_sync(user_handle, msg_id,
			req_c_struct, req_c_struct_len,
			resp_c_struct, resp_c_struct_len,
			timeout_msecs);
}

uint32_t qmi_ril_get_sim_slot(void)
{
	uint32_t (*get_sim_slot)(void);

	if (get_qcril_handle())
		return QMI_INTERNAL_ERR;

	get_sim_slot = reinterpret_cast<decltype(get_sim_slot)>(
		dlsym(qcril_handle, "qmi_ril_get_sim_slot"));
	if (!get_sim_slot) {
		LOG(ERROR) << "Failed to resolve function: " << __func__;
		return QMI_INTERNAL_ERR;
	}

	return get_sim_slot();
}
