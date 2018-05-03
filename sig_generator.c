/*************************************************************************
> File: audio_generator.c
> Author: eric.xu
> Mail:   eric.xu@libratone.com.cn
> Time:   2017-12-01 14:22:02
*************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<stdint.h>
#include<string.h>
#include "cfgparse.h"

static void copy_file(char* destination_path)
{
    char buffer[1024];
    const char* source_path = "/system/bin/test_signal_demo.wav";
    FILE* in, *out;

    if ((in = fopen(source_path, "r")) == NULL) {
        return;
    }

    if ((out = fopen(destination_path, "w")) == NULL) {
        return;
    }

    int len;

    while ((len = fread(buffer, 1, 1024, in)) > 0) {
        fwrite(buffer, 1, len, out);
    }

    fclose(out);
    fclose(in);
}


static int __generator_sweep(generator_t* generator)
{
    FILE* outFile = NULL;

    //TODO, generater sweep audio based on generator
    //
    copy_file(generator->sOutFile); 
    return 0;
}

static int __generator_multitone(generator_t* generator)
{
    FILE* outFile = NULL;

    //TODO, generater sweep audio based on generator
    //
    copy_file(generator->sOutFile); 
    
    return 0;
}


int main(int argc, char* argv[])
{
    cfg_file_t* cfg = NULL;
    generator_t* generator = NULL;
    int ret = 0;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s cfgfile.json\n", argv[0]);
        return -1;
    }

    cfg = (cfg_file_t*)malloc(sizeof(cfg_file_t));

    if (!cfg) {
        fprintf(stderr, "no mem malloc for cfg_file_t\n");
        return -1;
    }
    generator = (generator_t*)malloc(sizeof(generator_t));
    memset(generator, 0, sizeof(generator_t));
    if (!generator) {
        fprintf(stderr, "no mem malloc for generator_t\n");
        goto finish;
    }

    ret = cfg_init(argv[1], cfg);

    if (ret != cfg_ok) {
        fprintf(stderr, "cfg_init error: ret=%d\n", ret);
        goto finish;
    }
    
    //sweep
    ret = cfg_get_generator_sweep_config(cfg, generator);
    if (ret != cfg_ok) {
        fprintf(stderr, "get sweep config error: ret=%d\n", ret);
        goto finish;
    }

    cfg_dump_gernerator_config(generator);
    ret = __generator_sweep(generator);
    if(ret != 0){
        fprintf(stderr, "__generator_sweep error: ret=%d\n", ret);
        goto finish;
    }

    //multitome
    memset(generator, 0, sizeof(generator_t));
    ret = cfg_get_generator_multitone_config(cfg, generator);
    if (ret != cfg_ok) {
        fprintf(stderr, "get multitone config error: ret=%d\n", ret);
        goto finish;
    }
    cfg_dump_gernerator_config(generator);
    ret = __generator_multitone(generator);
    if(ret != 0){
        fprintf(stderr, "__generator_multitone_ error: ret=%d\n", ret);
        goto finish;
    }

finish:
    cfg_exit(cfg);
    if(cfg){
        free(cfg);
    }
    if(generator){
        free(generator);
    }

    return ret;
}
