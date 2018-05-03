1. 配置文件使用json格式
2. 源码目录结构
.
├── Android.mk
├── Android.mk-Template
├── cJSON.c
├── cJSON.o
├── Doxyfile
├── include
│   └── cJSON.h
├── jsonTest
├── LICENSE
├── Makefile
├── mksdk.sh
├── README
├── samples
│   ├── Android.mk
│   ├── test1.json
│   ├── test2.json
│   ├── test3.json
│   ├── test4.json
│   ├── test5.json
│   ├── test.c
│   └── test.o
└── tests
    ├── Android.mk
    ├── cfgparse.c              #配置文件解析
    ├── cfgparse.h
    ├── cfgparse.o
    ├── egg2_es1_dut_cfg.json   #json配置文件
    ├── Makefile
    ├── sig_analyzer 
    ├── sig_analyzer.c          #sig_analyzer 源码          
    ├── sig_analyzer.o
    ├── sig_generator
    ├── sig_generator.c         #sig_generator 源码
    └── sig_generator.o

3.算法或者声学同事编辑tests目录下的文件，生成 sig_generator  和 sig_analyzer 两个应用程序.
  软件我们这边shell脚本调用这两个应用程序的方式为：
  sig_generator /data/egg2_es1_dut.json 调用之后将生成两个信号文件
  sig_analyzer /data/egg2_es1_dut.json 1 分析fr录音文件，并将分析结果存放在sRetFile项指定的文件里。

4. build
   cd tests
 4.1 linux编译
   简单修改Makefile
   make
 4.2 Android 编译
   简单修改Android.mk
   mm

5. 有问题及时沟通，软件这边就按照这个接口来同步写脚本了。
