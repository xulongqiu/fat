/*************************************************************************
> File: cfgparse.h
> Author: eric.xu
> Mail:   eric.xu@libratone.com.cn 
> Time:   2017-12-01 13:12:53
*************************************************************************/
#ifndef __CFGPARSE_H__
#define __CFGPARSE_H__

#include <stdint.h>
#include "cJSON.h"

#ifdef __cpluspuls
extern "C" {
#endif
#define FILE_NAME_LEN 56
#define FREQ_VEC_LEN_MAX 100
#define DEBUG 0
typedef enum{
    cfg_ok = 0,
    cfg_invalid_paras,
    cfg_file_open_err,
    cfg_json_parse_err,
}cfg_ret_t;

typedef struct {
    char sOutFile[FILE_NAME_LEN];
    char sFilterSignalFile[FILE_NAME_LEN];
    int32_t iSampleRate;
    int32_t iChannels;
    float fSegmentSecs;  /*length of audio segment*/
    int32_t iStartFreq;
    int32_t iEndFreq;
    int32_t iVecFreq[FREQ_VEC_LEN_MAX];
    float   fVecAmp[FREQ_VEC_LEN_MAX];
    int32_t iVecFreqCnt;
    float fStartSilenceSecs;
    float fEndSilenceSecs;
    float fFadeInSecs;
    float fFadeOutSecs;
    float fIntervalSecs;
    float fLagSecs;
    int32_t iSegmentNum; /*count of audio segment*/
}generator_t;

typedef enum{
    type_tx = 0,
    type_fr,
    type_ncd,
    type_max
}analyzer_type_t;

typedef struct{
    analyzer_type_t type;
    char sInFile[FILE_NAME_LEN];
    char sFilterSignalFile[FILE_NAME_LEN];
    char sRetTxFile[FILE_NAME_LEN];
    char sRetFrFile[FILE_NAME_LEN];//store the analysis result of sInFile, content is text
    char sRetThdFile[FILE_NAME_LEN];
    char sRetNcdFile[FILE_NAME_LEN];
    int32_t iSampleRate;
    int32_t iChannels;
    float fSegmentSecs;  /*length of audio segment*/
    int32_t iStartFreq;
    int32_t iEndFreq;
    float fStartSilenceSecs;
    float fEndSilenceSecs;
    float fFadeInSecs;
    float fFadeOutSecs;
    float fIntervalSecs;
    float fLagSecs;
    int32_t iSegmentNum; /*count of audio segment*/
    float fIrDuration;
    float fIrRollPortion;
    int32_t iOrder;
    int32_t iOctOrder;
}analyzer_t;

typedef struct{
    const char* sCfgFile;
    char* sContent;
    cJSON* json;
}cfg_file_t;


int cfg_init(const char* filename, cfg_file_t* cfg);
int cfg_exit(cfg_file_t* cfg);
void cfg_dump_gernerator_config(generator_t* generator);
void cfg_dump_analyzer_config(analyzer_t* analyzer);
int cfg_get_generator_multitone_config(cfg_file_t* cfg, generator_t* generator);
int cfg_get_generator_sweep_config(cfg_file_t* cfg, generator_t* generator);
int cfg_get_analyzer_config(cfg_file_t* cfg, analyzer_t* analyzer);
int cfg_normal_get(cfg_file_t* cfg, int argc, const char* argv[], const char* buf, int buf_len);

#ifdef __cpluspuls
}
#endif
#endif /*__CFGPARSE_H__*/
