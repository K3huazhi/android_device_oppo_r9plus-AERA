/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "QCOMKeyMaster"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <string.h>
#include <dlfcn.h>

#include <android-base/logging.h>

#include "QSEEComAPI.h"

struct qcom_keymaster_handle {
    struct QSEECom_handle *qseecom;
    void *libhandle;
    int (*QSEECom_start_app)(struct QSEECom_handle ** handle, char* path,
                          char* appname, uint32_t size);
    int (*QSEECom_shutdown_app)(struct QSEECom_handle **handle);
};
typedef struct qcom_keymaster_handle qcom_keymaster_handle_t;

static int qcom_km_get_lib_sym(qcom_keymaster_handle_t* km_handle)
{
    km_handle->libhandle = dlopen("libQSEEComAPI.so", RTLD_NOW);
    if (  km_handle->libhandle  ) {
        *(void **)(&km_handle->QSEECom_start_app) =
                               dlsym(km_handle->libhandle,"QSEECom_start_app");
        if (km_handle->QSEECom_start_app == NULL) {
            LOG(ERROR) << "dlsym: Error Loading QSEECom_start_app";
            dlclose(km_handle->libhandle );
            km_handle->libhandle  = NULL;
            return -1;
        }
        *(void **)(&km_handle->QSEECom_shutdown_app) =
                               dlsym(km_handle->libhandle,"QSEECom_shutdown_app");
        if (km_handle->QSEECom_shutdown_app == NULL) {
            LOG(ERROR) << "dlsym: Error Loading QSEECom_shutdown_app";
            dlclose(km_handle->libhandle );
            km_handle->libhandle  = NULL;
            return -1;
        }
    } else {
        LOG(ERROR) << "failed to load qseecom library";
        return -1;
    }
    return 0;
}

int main(int argc, char **argv) {
    int ret = 0;
    qcom_keymaster_handle_t* km_handle;

    (void)argc;
    (void)argv;

    km_handle = (qcom_keymaster_handle_t *)malloc(sizeof(qcom_keymaster_handle_t));
    if (km_handle == NULL) {
        LOG(ERROR) << "Memalloc for keymaster handle failed";
        return -1;
    }
    km_handle->qseecom = NULL;
    km_handle->libhandle = NULL;
    ret = qcom_km_get_lib_sym(km_handle);
    if (ret) {
        free(km_handle);
        return -1;
    }
    ret = (*km_handle->QSEECom_start_app)((struct QSEECom_handle **)&km_handle->qseecom,
                         "/vendor/firmware_mnt/image", "keymaste", 4096*2);
    if (ret) {
        LOG(ERROR) << "Loading keymaster app failed";
        free(km_handle);
        return -1;
    }

    // Keep QSEE app loaded
    LOG(DEBUG) << "Starting sleep loop";
    while (true) {
        sleep(UINT32_MAX);
    }

    // The process should never reach here
    LOG(ERROR) << "Keymaster loader exited";
    if (km_handle->qseecom == NULL) {
        LOG(ERROR) << "Context  == NULL";
        return 0;
    }
    (*km_handle->QSEECom_shutdown_app)((struct QSEECom_handle **)&km_handle->qseecom);
    return 0;
}
