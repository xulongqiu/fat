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

int main(int argc, char* argv[])
{
    cfg_file_t* cfg = NULL;
    int ret = 0;
    float val = 0.0;
    char buf[128] = {0};

    if (argc < 3) {
        fprintf(stderr, "Usage: %s cfgfile.json [node] key\n", argv[0]);
        return -1;
    }

    cfg = (cfg_file_t*)malloc(sizeof(cfg_file_t));

    if (!cfg) {
        fprintf(stderr, "no mem malloc for cfg_file_t\n");
        return -1;
    }
    
    ret = cfg_init(argv[1], cfg);
    if (ret != cfg_ok) {
        fprintf(stderr, "cfg_init error: ret=%d\n", ret);
        goto finish;
    }
    
    ret = cfg_normal_get(cfg, argc - 2, &argv[2], buf, 128);
    if(ret == 0){
        fprintf(stdout, "value:%s\n", buf); 
    }
finish:
    cfg_exit(cfg);
    if(cfg){
        free(cfg);
    }

    return ret;
}
