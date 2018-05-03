/*
  Copyright (c) 2017 Libratone

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "cfgparse.h"
#if DEBUG
#define CFG_INFO_CLEAN(fmt, args...)  do { fprintf(stderr, fmt, ##args); } while(0)
#define CFG_INFO(fmt, args...)  do { fprintf(stderr, "[info |%s|%d]-" fmt, __func__, __LINE__, ##args); } while(0)
#define CFG_DEBUG(fmt, args...) do { fprintf(stderr, "[debug|%s|%s]-" fmt, __func__, __LINE__, ##args); } while(0)
#define CFG_ERROR(fmt, args...) do { fprintf(stderr, "[error|%s|%d]-" fmt, __func__, __LINE__, ##args); } while(0)
#else
#define CFG_INFO
#define CFG_INFO_CLEAN
#define CFG_DEBUG
#define CFG_ERROR
#endif

int cfg_init(const char* filename, cfg_file_t* cfg)
{
    FILE* f = NULL;

    if (filename == NULL || cfg == NULL) {
        return -cfg_invalid_paras;
    }

    cfg->sCfgFile = filename;
    f = fopen(filename, "rb");

    if (!f) {
        return -cfg_file_open_err;
    }

    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);

    if (cfg->sContent) {
        free(cfg->sContent);
    }

    cfg->sContent = (char*)malloc(len + 1);
    fread(cfg->sContent, 1, len, f);
    fclose(f);

    cfg->json = cJSON_Parse(cfg->sContent);

    if (!cfg->json) {
        CFG_ERROR("json parse erro:%s\n", cJSON_GetErrorPtr());
        free(cfg->sContent);
        cfg->sContent = NULL;
        cfg->sCfgFile = NULL;
        return -cfg_json_parse_err;
    }

    CFG_INFO("OK\n");
    return cfg_ok;
}

int cfg_exit(cfg_file_t* cfg)
{
    if (cfg == NULL) {
        return -cfg_invalid_paras;
    }

    if (cfg->json) {
        cJSON_Delete(cfg->json);
        cfg->json = NULL;
    }

    if (cfg->sContent) {
        free(cfg->sContent);
        cfg->sContent = NULL;
    }

    CFG_INFO("OK\n");
    return cfg_ok;
}

void cfg_dump_gernerator_config(generator_t* generator)
{
    int i = 0;

    if (!generator) {
        return;
    }
    
    CFG_INFO("sOutFile=%s\n", generator->sOutFile);
    CFG_INFO("sFilterSignalFile=%s\n", generator->sFilterSignalFile);
    CFG_INFO("iSampleRate=%d\n", generator->iSampleRate);
    CFG_INFO("iChannels=%d\n", generator->iChannels);
    CFG_INFO("fSegmentSecs=%f\n", generator->fSegmentSecs);
    CFG_INFO("iStartFreq=%d\n", generator->iStartFreq);
    CFG_INFO("iEndFreq=%d\n", generator->iEndFreq);
    CFG_INFO("fStartSilenceSecs=%f\n", generator->fStartSilenceSecs);
    CFG_INFO("fEndSilenceSecs=%f\n", generator->fEndSilenceSecs);
    CFG_INFO("fFadeInSecs=%f\n", generator->fFadeInSecs);
    CFG_INFO("fFadeOutSecs=%f\n", generator->fFadeOutSecs);
    CFG_INFO("fIntervalSecs=%f\n", generator->fIntervalSecs);
    CFG_INFO("fLagSecs=%f\n", generator->fLagSecs);
    CFG_INFO("iSegmentNum=%d\n", generator->iSegmentNum);
    CFG_INFO("iVecFreqCnt=%d\n", generator->iVecFreqCnt);
    for(i = 0; i < generator->iVecFreqCnt; i++){
        if(i==0){
            CFG_INFO("iVecFreq=[%d,", generator->iVecFreq[i]);
        }else if(i == (generator->iVecFreqCnt - 1)){
            CFG_INFO_CLEAN("%d]\n", generator->iVecFreq[i]);
        }else{
            CFG_INFO_CLEAN("%d,", generator->iVecFreq[i]);
        }
    }
    for(i = 0; i < generator->iVecFreqCnt; i++){
        if(i==0){
            CFG_INFO("iVecAmp=[%f,", generator->fVecAmp[i]);
        }else if(i == (generator->iVecFreqCnt - 1)){
            CFG_INFO_CLEAN("%f]\n", generator->fVecAmp[i]);
        }else{
            CFG_INFO_CLEAN("%f,", generator->fVecAmp[i]);
        }
    }

}

void cfg_dump_analyzer_config(analyzer_t* analyzer)
{
    if (!analyzer) {
        return;
    }
    
    CFG_INFO("sInFile=%s\n", analyzer->sInFile);
    CFG_INFO("sFilterSignalFile=%s\n", analyzer->sFilterSignalFile);
    CFG_INFO("sRetTxFile=%s\n", analyzer->sRetTxFile);
    CFG_INFO("sRetFrFile=%s\n", analyzer->sRetFrFile);
    CFG_INFO("sRetNcdFile=%s\n", analyzer->sRetNcdFile);
    CFG_INFO("sRetThdFile=%s\n", analyzer->sRetThdFile);
    CFG_INFO("iSampleRate=%d\n", analyzer->iSampleRate);
    CFG_INFO("iChannels=%d\n", analyzer->iChannels);
    CFG_INFO("fSegmentSecs=%f\n", analyzer->fSegmentSecs);
    CFG_INFO("iStartFreq=%d\n", analyzer->iStartFreq);
    CFG_INFO("iEndFreq=%d\n", analyzer->iEndFreq);
    CFG_INFO("fStartSilenceSecs=%f\n", analyzer->fStartSilenceSecs);
    CFG_INFO("fEndSilenceSecs=%f\n", analyzer->fEndSilenceSecs);
    CFG_INFO("fFadeInSecs=%f\n", analyzer->fFadeInSecs);
    CFG_INFO("fFadeOutSecs=%f\n", analyzer->fFadeOutSecs);
    CFG_INFO("fIntervalSecs=%f\n", analyzer->fIntervalSecs);
    CFG_INFO("fLagSecs=%f\n", analyzer->fLagSecs);
    CFG_INFO("iSegmentNum=%d\n", analyzer->iSegmentNum);
    CFG_INFO("fIrDuration=%f\n", analyzer->fIrDuration);
    CFG_INFO("fIrRollPortion=%f\n", analyzer->fIrRollPortion);
    CFG_INFO("iOrder=%d\n", analyzer->iOrder);
    CFG_INFO("iOctOrder=%d\n", analyzer->iOctOrder);
}

static int __get_generator(cJSON* subJsonP, generator_t* generator)
{
    cJSON* obj = NULL;
    cJSON* vec = NULL;
    int j = 0;

    if (NULL == subJsonP || NULL == generator) {
        return -cfg_invalid_paras;
    }

    obj = cJSON_GetObjectItem(subJsonP, "sOutFile");
    if (obj && strlen(obj->valuestring)) {
        strncpy(generator->sOutFile, obj->valuestring, FILE_NAME_LEN);;
    }

    obj = cJSON_GetObjectItem(subJsonP, "sFilterSignal");
    if (obj && strlen(obj->valuestring)) {
        strncpy(generator->sFilterSignalFile, obj->valuestring, FILE_NAME_LEN);;
    }

    vec = cJSON_GetObjectItem(subJsonP, "iVecFreq");
    if (vec != NULL) {
        generator->iVecFreqCnt = cJSON_GetArraySize(vec);
        if (generator->iVecFreqCnt > FREQ_VEC_LEN_MAX) {
            generator->iVecFreqCnt = FREQ_VEC_LEN_MAX;
        }
        for (j = 0; j < generator->iVecFreqCnt; j++) {
            generator->iVecFreq[j] = cJSON_GetArrayItem(vec, j)->valueint;
        }
    }

    vec = cJSON_GetObjectItem(subJsonP, "fVecAmplitude");
    if (vec != NULL) {
        generator->iVecFreqCnt = cJSON_GetArraySize(vec);
        if (generator->iVecFreqCnt > FREQ_VEC_LEN_MAX) {
            generator->iVecFreqCnt = FREQ_VEC_LEN_MAX;
        }
        for (j = 0; j < generator->iVecFreqCnt; j++) {
            generator->fVecAmp[j] = cJSON_GetArrayItem(vec, j)->valuedouble;
        }
    }

    obj = cJSON_GetObjectItem(subJsonP, "iSampleRate");
    generator->iSampleRate = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iChannels");
    generator->iChannels = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "fSegmentSecs");
    generator->fSegmentSecs = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iStartFreq");
    generator->iStartFreq = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iEndFreq");
    generator->iEndFreq = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "fFadeInSecs");
    generator->fFadeInSecs = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "fFadeOutSecs");
    generator->fFadeOutSecs = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iSegmentNum");
    generator->iSegmentNum = obj ? obj->valueint : 0;

    return cfg_ok;
}

static int __get_analyzer(cJSON* subJsonP, analyzer_t* analyzer)
{
    cJSON* obj = NULL;

    if (NULL == subJsonP || NULL == analyzer) {
        return -cfg_invalid_paras;
    }

    obj = cJSON_GetObjectItem(subJsonP, "sInFile");
    if (obj && strlen(obj->valuestring)) {
        strncpy(analyzer->sInFile, obj->valuestring, FILE_NAME_LEN);
    }
    
    obj = cJSON_GetObjectItem(subJsonP, "sRetTxFile");
    if (obj && strlen(obj->valuestring)) {
        strncpy(analyzer->sRetTxFile, obj->valuestring, FILE_NAME_LEN);
    }

    obj = cJSON_GetObjectItem(subJsonP, "sFilterSignal");
    if (obj && strlen(obj->valuestring)) {
        strncpy(analyzer->sFilterSignalFile, obj->valuestring, FILE_NAME_LEN);;
    }
    obj = cJSON_GetObjectItem(subJsonP, "sRetFrFile");
    if (obj && strlen(obj->valuestring)) {
        strncpy(analyzer->sRetFrFile, obj->valuestring, FILE_NAME_LEN);
    }
    obj = cJSON_GetObjectItem(subJsonP, "sRetThdFile");
    if (obj && strlen(obj->valuestring)) {
        strncpy(analyzer->sRetThdFile, obj->valuestring, FILE_NAME_LEN);
    }
    obj = cJSON_GetObjectItem(subJsonP, "sRetNcdFile");
    if (obj && strlen(obj->valuestring)) {
        strncpy(analyzer->sRetNcdFile, obj->valuestring, FILE_NAME_LEN);
    }
    obj = cJSON_GetObjectItem(subJsonP, "fSegmentSecs");
    analyzer->fSegmentSecs = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iStartFreq");
    analyzer->iStartFreq = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iEndFreq");
    analyzer->iEndFreq = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "fIrDuration");
    analyzer->fIrDuration = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "fIrRollPortion");
    analyzer->fIrRollPortion = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iOrder");
    analyzer->iOrder = obj ? obj->valueint : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iSegmentNum");
    analyzer->iSegmentNum = obj ? obj->valuedouble : 0;
    obj = cJSON_GetObjectItem(subJsonP, "iOctOrder");
    analyzer->iOctOrder = obj ? obj->valueint : 0;

    return cfg_ok;
}

int cfg_get_generator_sweep_config(cfg_file_t* cfg, generator_t* generator)
{
    cJSON* sub_generator = NULL;
    cJSON* sub_global = NULL;
    cJSON* subJsonP = NULL;
    cJSON* obj = NULL;

    if (NULL == cfg || NULL == generator) {
        return -cfg_invalid_paras;
    }

    if (cfg->json) {
        sub_global = cJSON_GetObjectItem(cfg->json, "global_paras");

        if (sub_global) {
            obj = cJSON_GetObjectItem(sub_global, "fStartSilenceSecs");
            generator->fStartSilenceSecs = obj ? obj->valuedouble : 0;
            obj = cJSON_GetObjectItem(sub_global, "fEndSilenceSecs");
            generator->fEndSilenceSecs = obj ? obj->valuedouble : 0;
            obj = cJSON_GetObjectItem(sub_global, "fIntervalSecs");
            generator->fIntervalSecs = obj ? obj->valuedouble : 0;
            obj = cJSON_GetObjectItem(sub_global, "fLagSecs");
            generator->fLagSecs = obj ? obj->valuedouble : 0;
        } else {
            return -cfg_json_parse_err;
        }

        sub_generator = cJSON_GetObjectItem(cfg->json, "signal_generator");

        if (sub_generator) {
            sub_generator = cJSON_GetObjectItem(sub_generator, "sweep_signal");

            if (sub_generator) {
                return __get_generator(sub_generator, generator);
            } else {
                CFG_ERROR("get sweep_signal error:%s\n", cJSON_GetErrorPtr());
                return -cfg_json_parse_err;
            }
        } else {

            CFG_ERROR("get signal_generator error:%s\n", cJSON_GetErrorPtr());
            return -cfg_json_parse_err;
        }
    } else {

        CFG_ERROR("pls cfg_init firstly.\n");
        return -cfg_json_parse_err;
    }

    return cfg_ok;
}

int cfg_get_generator_multitone_config(cfg_file_t* cfg, generator_t* generator)
{
    cJSON* sub_generator = NULL;
    cJSON* sub_global = NULL;
    cJSON* subJsonP = NULL;
    cJSON* obj = NULL;

    if (NULL == cfg || NULL == generator) {
        return -cfg_invalid_paras;
    }

    if (cfg->json) {
        sub_global = cJSON_GetObjectItem(cfg->json, "global_paras");

        if (sub_global) {
            obj = cJSON_GetObjectItem(sub_global, "fStartSilenceSecs");
            generator->fStartSilenceSecs = obj ? obj->valuedouble : 0;
            obj = cJSON_GetObjectItem(sub_global, "fEndSilenceSecs");
            generator->fEndSilenceSecs = obj ? obj->valuedouble : 0;
            obj = cJSON_GetObjectItem(sub_global, "fIntervalSecs");
            generator->fIntervalSecs = obj ? obj->valuedouble : 0;
            obj = cJSON_GetObjectItem(sub_global, "fLagSecs");
            generator->fLagSecs = obj ? obj->valuedouble : 0;
        } else {
            return -cfg_json_parse_err;
        }

        sub_generator = cJSON_GetObjectItem(cfg->json, "signal_generator");

        if (sub_generator) {
            sub_generator = cJSON_GetObjectItem(sub_generator, "multitone_signal");

            if (sub_generator) {
                return __get_generator(sub_generator, generator);
            } else {
                CFG_ERROR("get sweep_signal error:%s\n", cJSON_GetErrorPtr());
                return -cfg_json_parse_err;
            }
        } else {

            CFG_ERROR("get signal_generator error:%s\n", cJSON_GetErrorPtr());
            return -cfg_json_parse_err;
        }
    } else {

        CFG_ERROR("pls cfg_init firstly.\n");
        return -cfg_json_parse_err;
    }

    return cfg_ok;
}


int cfg_get_analyzer_config(cfg_file_t* cfg, analyzer_t* analyzer)
{
    cJSON* sub_analyzer = NULL;
    cJSON* sub_global = NULL;
    cJSON* subJsonP = NULL;
    cJSON* obj = NULL;

    if (NULL == cfg || NULL == analyzer || NULL == cfg->json) {
        return -cfg_invalid_paras;
    }

    sub_global = cJSON_GetObjectItem(cfg->json, "global_paras");

    if (sub_global) {
        obj = cJSON_GetObjectItem(sub_global, "fStartSilenceSecs");
        analyzer->fStartSilenceSecs = obj ? obj->valuedouble : 0;
        obj = cJSON_GetObjectItem(sub_global, "fEndSilenceSecs");
        analyzer->fEndSilenceSecs = obj ? obj->valuedouble : 0;
        obj = cJSON_GetObjectItem(sub_global, "fIntervalSecs");
        analyzer->fIntervalSecs = obj ? obj->valuedouble : 0;
        obj = cJSON_GetObjectItem(sub_global, "fLagSecs");
        analyzer->fLagSecs = obj ? obj->valuedouble : 0;
    } else {
        return -cfg_json_parse_err;
    }
    switch (analyzer->type) {
    case type_tx:
        sub_analyzer = cJSON_GetObjectItem(cfg->json, "tx_test");

        if (sub_analyzer) {
            sub_analyzer = cJSON_GetObjectItem(sub_analyzer, "tx_analyzer");

            if (sub_analyzer) {
                return __get_analyzer(sub_analyzer, analyzer);
            } else {
                CFG_ERROR("get tx_analyzer error:%s\n", cJSON_GetErrorPtr());
                return -cfg_json_parse_err;
            }
        } else {
            CFG_ERROR("get tx_test error:%s\n", cJSON_GetErrorPtr());
            return -cfg_json_parse_err;
        }

        break;

    case type_fr:
        sub_analyzer = cJSON_GetObjectItem(cfg->json, "closed_loop");

        if (sub_analyzer) {
            sub_analyzer = cJSON_GetObjectItem(sub_analyzer, "fr_analyzer");

            if (sub_analyzer) {
                return __get_analyzer(sub_analyzer, analyzer);
            } else {
                CFG_ERROR("get fr_analyzer error:%s\n", cJSON_GetErrorPtr());
                return -cfg_json_parse_err;
            }
        } else {
            CFG_ERROR("get closed_loop error:%s\n", cJSON_GetErrorPtr());
            return -cfg_json_parse_err;
        }

        break;

    case type_ncd:
        sub_analyzer = cJSON_GetObjectItem(cfg->json, "closed_loop");

        if (sub_analyzer) {
            sub_analyzer = cJSON_GetObjectItem(sub_analyzer, "ncd_analyzer");

            if (sub_analyzer) {
                return __get_analyzer(sub_analyzer, analyzer);
            } else {
                CFG_ERROR("get ncd_analyzer error:%s\n", cJSON_GetErrorPtr());
                return -cfg_json_parse_err;
            }
        } else {
            CFG_ERROR("get closed_loop error:%s\n", cJSON_GetErrorPtr());
            return -cfg_json_parse_err;
        }

        break;

    default:
        return -cfg_invalid_paras;
    }

    return cfg_ok;
}

int cfg_normal_get(cfg_file_t* cfg, int argc, const char* argv[], const char* buf, int buf_len)
{
    int i = 0;
    cJSON* obj = NULL;

    if (!cfg || !cfg->json || argc == 0 || !argv[0] || !buf || buf_len == 0) {
        return -cfg_invalid_paras;
    }

    obj = cfg->json;

    for (i = 0; i < argc; i++) {
        if (argv[i] && obj) {
            //printf("argv[%d]=%s\n", i, argv[i]);
            obj = cJSON_GetObjectItem(obj, argv[i]);
        } else {
            break;
        }
    }

    if (obj) {
        if (obj->valuestring) {
            strncpy(buf, obj->valuestring, buf_len);
        } else {
            snprintf(buf, buf_len, "%.2f", obj->valuedouble);
        }
    } else {
        return -cfg_json_parse_err;
    }

    return 0;
}
