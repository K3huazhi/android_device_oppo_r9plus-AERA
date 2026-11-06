/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef QMI_INTERFACE_H
#define QMI_INTERFACE_H

/* Error codes returned from QMI interface functions */
#define QMI_NO_ERR			 0	/* No Error */
#define QMI_INTERNAL_ERR		-1	/* Linux/System Error */
#define QMI_SERVICE_ERR			-2	/* QMI error, check QMI error code */
#define QMI_TIMEOUT_ERR			-3	/* Transaction timeout error code */
#define QMI_EXTENDED_ERR		-4	/* SubSystem specific error codes(example: ds_profile) */
#define QMI_PORT_NOT_OPEN_ERR		-5	/* QMI control port is not open */
#define QMI_QMUXD_NOT_SUPPORTED_ERR	-6	/* SHIM layer supported by modem. */

/**
 * qmi_response_type_v01 - common response header (decoded)
 * @result:     result of the transaction
 * @error:      error value, when @result is QMI_RESULT_FAILURE_V01
 */
struct qmi_response_type_v01 {
	int32_t result;
	int32_t error;
};

#endif
