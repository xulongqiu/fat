/*************************************************************************
> File: sig_analyzer.c
> Author: eric.xu
> Mail:   eric.xu@libratone.com.cn
> Time:   2017-12-01 16:50:25
*************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<stdint.h>
#include<string.h>
#include "cfgparse.h"

static void copy_file(const char* source_path, char* destination_path)
{
    char buffer[1024];
    FILE* in, *out;

    if ((in = fopen(source_path, "r")) == NULL) {
        fprintf(stderr, "open %s fail\n", source_path);
        return;
    }

    if ((out = fopen(destination_path, "w")) == NULL) {
        fprintf(stderr, "open %s fail\n", destination_path);
        return;
    }

    int len;

    while ((len = fread(buffer, 1, 1024, in)) > 0) {
        fwrite(buffer, 1, len, out);
    }

    fclose(out);
    fclose(in);
}

static int __analyzer(analyzer_t* analyzer)
{
    const char* src = "/system/bin/analyzer_ret_demo.txt";
    if (NULL == analyzer) {
        return -1;
    }

    switch (analyzer->type) {
    case type_tx:
        copy_file(src, analyzer->sRetTxFile);
        break;

    case type_fr:
        copy_file(src, analyzer->sRetFrFile);
        copy_file(src, analyzer->sRetThdFile);
        break;

    case type_ncd:
        copy_file(src, analyzer->sRetNcdFile);
        break;

    default:
        return -1;
    }

    return cfg_ok;
}

int main(int argc, char* argv[])
{
    cfg_file_t* cfg = NULL;
    analyzer_t* analyzer = NULL;
    int ret = 0;
    analyzer_type_t type = type_max;

    if (argc != 3) {
        fprintf(stderr, "Usage: %s cfgfile.json type\n", argv[0]);
        return -1;
    }

    type = (analyzer_type_t)atoi(argv[2]);

    if (type < type_tx || type >= type_max) {
        fprintf(stderr, "type must be ge %d && lt %d\n", type_tx, type_max);
        return -1;
    }

    cfg = (cfg_file_t*)malloc(sizeof(cfg_file_t));

    if (!cfg) {
        fprintf(stderr, "no mem malloc for cfg_file_t\n");
        return -1;
    }
    free(cfg);
    analyzer = (analyzer_t*)malloc(sizeof(analyzer_t));

    if (!analyzer) {
        fprintf(stderr, "no mem malloc for analyzer_t\n");
        goto finish;
    }

    analyzer->type = type;
    ret = cfg_init(argv[1], cfg);

    if (ret != cfg_ok) {
        fprintf(stderr, "cfg_init error: ret=%d\n", ret);
        goto finish;
    }

    ret = cfg_get_analyzer_config(cfg, analyzer);
    if (ret != cfg_ok) {
        fprintf(stderr, "get analyzer config error: ret=%d\n", ret);
        goto finish;
    }

    cfg_dump_analyzer_config(analyzer);
    ret = __analyzer(analyzer);

    if (ret != 0) {
        fprintf(stderr, "__analyzer_multitone_ error: ret=%d\n", ret);
        goto finish;
    }

finish:
    cfg_exit(cfg);

    if (cfg) {
        free(cfg);
    }

    if (analyzer) {
        free(analyzer);
    }

    return ret;
}


