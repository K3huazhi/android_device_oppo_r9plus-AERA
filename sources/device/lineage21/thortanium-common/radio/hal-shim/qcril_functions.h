/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// From libqmi_cci.so
int qmi_client_send_msg_sync(void *user_handle, int msg_id,
		void *req_c_struct, int req_c_struct_len,
		void *resp_c_struct, int resp_c_struct_len,
		int timeout_msecs);

// From libril-qc-hal-qmi.so
uint32_t qmi_ril_get_sim_slot(void);
