#########################################################################
# File Name: fat.sh
# Author: eric.xu
# mail: eric.xu@libratone.com.cn
# Created Time: 2017-12-06 13:11:44
#########################################################################
#!/system/bin/sh

export BIN_DIR=/system/bin
export DATA_DIR=/data

function __envCheck()
{
    if [ -f ${DATA_DIR}/dut_cfg.json ] && [ -f ${BIN_DIR}/sig_analyzer ] && [ -f ${BIN_DIR}/sig_generator ] && [ -f ${BIN_DIR}/audio_test ] && [ -f ${BIN_DIR}/audio_loop_test ]; then
        return 0
    fi

    return 1
}

# copy configuration file to /data from udisk
function CfgCp()
{
    mount -t vfat /dev/block/vold/8\:1 /storage
    sync
    sleep 1
    if [ $# -eq 1 ] && [ -f $1 ]; then
        cp $1 ${DATA_DIR}/dut_cfg.json
        if [ -f ${DATA_DIR}/dut_cfg.json ]; then
            echo "CmdOk"
            return 0
        fi
    fi

    echo "CmdFail"
    return 1
}

# switch to LineIn and start LineInLoop program
function LineInTestStart()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi

    vol=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json line_in iVolume | awk -F : '{print $2}'` 
    #${BIN_DIR}/tinymix -D 0 2 $vol
    ${BIN_DIR}/testdsp -f 5#1 -v ${vol}
    #${BIN_DIR}/audio_loop_test -C 1 -P 0 -d 0 -p 4096 -r 48000 -f 16 -c 2 -n 4&
    ${BIN_DIR}/audio_test /data/tmp_loop_test -D 0 -d 0 -P -p 4096 -r 48000 -f 16 -c 2 -n 6 -l 1&
    sleep 0.2
    ${BIN_DIR}/audio_test /data/tmp_loop_test -D 1 -d 0 -C -p 4096 -r 48000 -f 16 -c 2 -n 4 -l 1&

    echo "CmdOk"
    return 1
}

# kill LineInLoop
function LineInTestEnd()
{
    echo "CmdOk"
    #ps audio_ |awk '{print $2}'| busybox xargs kill -9
    pkill audio_test
    return 0
}

# Tx start, get the record parameters, and start record
function TxStart()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi

    #get parameters
    outfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record sOutFile | awk -F : '{print $2}'` 
    #duration=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record fDuration | awk -F : '{print $2}' |awk -F . '{print $1}'`
    vol=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record iVolume | awk -F : '{print $2}' |awk -F . '{print $1}'`
    #channels=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record iChannels | awk -F : '{print $2}' |awk -F . '{print $1}'`
    #samplerate=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record iSampeRate | awk -F : '{print $2}' |awk -F . '{print $1}'`
     
    ${BIN_DIR}/tinymix -D 2 1 $vol
    ${BIN_DIR}/tinymix -D 2 2 $vol
    ${BIN_DIR}/tinymix -D 2 3 $vol
    ${BIN_DIR}/audio_test $outfile -D 2 -d 0 -C -p 512 -r 16000 -f 16 -c 8 -n 8 &
    
    echo "CmdOk"

    return 0
}

# Tx end, end record
function TxEnd()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi
    pkill audio_test

    echo "CmdOk"

    return 0
}

# Tx analyzer 
function TxCheck()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi
    recordfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_analyzer sInFile | awk -F : '{print $2}'` 
    retfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_analyzer sRetTxFile | awk -F : '{print $2}'`
    if [ -f $recordfile ]; then 
        ${BIN_DIR}/sig_analyzer ${DATA_DIR}/dut_cfg.json 0
        if [ -f $retfile ]; then
            echo "txRet:"
            cat ${retfile}
            echo "CmdOk"
            return 0
        fi
    fi
    
    echo "CmdFail"
    return 1
}

#TxCp, copy Tx record file to udisk
function TxCp()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi
    dstfile=$1
    recordfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record sOutFile | awk -F : '{print $2}'` 

    if ! [ -d ${dstfile%/*} ]; then
        mkdir -p ${dstfile%/*}
    fi

    if [ -f $recordfile ]; then
        cp $recordfile $dstfile
        if [ -f $recordfile ]; then
           echo "CmdOk"
           return 0
       fi 
    fi

    echo "CmdFail"
    return 1
}


function __Loop()
{
    loop_type=$1

    #get parameters
    c_file=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record sOutFile | awk -F : '{print $2}'` 
    #c_len=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record fDuration | awk -F : '{print $2}'`
    c_vol=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record iVolume | awk -F : '{print $2}' |awk -F . '{print $1}'`
    #c_ch=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record iChannels | awk -F : '{print $2}' |awk -F . '{print $1}'`
    #c_sr=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record iSampeRate | awk -F : '{print $2}' |awk -F . '{print $1}'`

    p_file=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play sInFile | awk -F : '{print $2}'` 
    p_wait=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json global_paras fLagSecs | awk -F : '{print $2}'`
    #p_len=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play fPlaySecs | awk -F : '{print $2}'`
    p_vol=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play iVolume | awk -F : '{print $2}' |awk -F . '{print $1}'`
    #p_ch=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play iChannels | awk -F : '{print $2}' |awk -F . '{print $1}'`
    #p_sr=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play iSampeRate | awk -F : '{print $2}' |awk -F . '{print $1}'`
    
    ${BIN_DIR}/testdsp -f 5#1 -v ${p_vol}
    #${BIN_DIR}/tinymix -D 0 2 $p_vol
    ${BIN_DIR}/tinymix -D 2 1 $c_vol
    ${BIN_DIR}/tinymix -D 2 2 $c_vol
    ${BIN_DIR}/tinymix -D 2 3 $c_vol
    if [ -f $p_file ]; then
        ${BIN_DIR}/audio_test $c_file -D 2 -d 0 -C -p 512 -r 16000 $ -f 16 -c 8 -n 8 &
        sleep $p_wait
        #${BIN_DIR}/audio_test $p_file -D 0 -d 0 -P -p 4096 -r 16000 -f 16 -c 2 -n 6
        ${BIN_DIR}/fatplayer ${p_file}
        pkill audio_test
        if [ -f $c_file ]; then
           return 0
        fi
    fi 

    return 1
}

# loop test, dut play and record itself
function LoopStart()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi
    
    #generator signals
    ${BIN_DIR}/sig_generator ${DATA_DIR}/dut_cfg.json

    #fr play record
    __Loop fr
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi
    
    #ncd play record
    __Loop ncd
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi

    echo "CmdOk"
    return 0
}

#LoopCheck 
function LoopCheck()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi
    
    if [ "$1" != "fr" ] && [ "$1" != "ncd" ]; then
        echo "CmdFail"
        return 1
    fi

    recordfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${1}_analyzer sInFile | awk -F : '{print $2}'` 
    if [ -f $recordfile ]; then
        if [ "$1" = "fr" ]; then 
            retfrfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${1}_analyzer sRetFrFile | awk -F : '{print $2}'`
            retthdfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${1}_analyzer sRetThdFile | awk -F : '{print $2}'`
            ${BIN_DIR}/sig_analyzer ${DATA_DIR}/dut_cfg.json 1
            if [ -f ${retfrfile} ] && [ -f ${retthdfile} ]; then
                echo "frRetFr:"
                cat ${retfrfile} 
                echo "frRetThd:"
                cat ${retthdfile}
                echo "CmdOk"
                return 0
            fi
        else
            retncdfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${1}_analyzer sRetNcdFile | awk -F : '{print $2}'`
            ${BIN_DIR}/sig_analyzer ${DATA_DIR}/dut_cfg.json 2
            if [ -f ${retncdfile} ]; then
                echo "ncdRet:"
                cat ${retncdfile} 
                echo "CmdOk"
                return 0
            fi
        fi
    fi

    echo "CmdFail"
}

#copy rf ncd record file to udisk
function LoopCp()
{
    __envCheck
    if [ "$?" = "1" ]; then
        echo "CmdFail"
        return 1
    fi

    dstfile=$1
    fr_c_file=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop fr_record sOutFile | awk -F : '{print $2}'` 
    ncd_c_file=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ncd_record sOutFile | awk -F : '{print $2}'` 

    if ! [ -d ${dstfile%/*} ]; then
        mkdir -p ${dstfile%/*}
    fi
    
    dstfile=${dstfile%.*}
    if [ -f $fr_c_file ] && [ -f $ncd_c_file ]; then
        cp $fr_c_file ${dstfile}_fr.wav
        cp $ncd_c_file ${dstfile}_ncd.wav
        if [ -f ${dstfile}_fr.wav ] && [ -f ${dstfile}_ncd.wav ]; then
           echo "CmdOk"
           return 0
       fi 
    fi

    echo "CmdFail"
    return 1
}

function LedTest()
{
    echo "CmdOk"
    ${BIN_DIR}/led_test all 255
    echo "CmdOk"
    return 0
}

function LedTestEnd()
{
    ${BIN_DIR}/led_test all 0
    echo "CmdOk"
    return 0
}


function TouchTest()
{
    val=`cat /sys/devices/11060000.i2c/i2c-1/1-0008/control/sepres_regs`
    if [ "$val" = "" ]; then
        val="ffff"
    else
        val=`echo $val|awk '{print $3$4}'`
    fi
    echo MASK: $val
    echo "CmdOk"
    return 0
}

function ScanI2c()
{
    pass=0
    all=0
    for file in `ls /sys/bus/i2c/devices`; do
        if [ "${file%-*}" == "i2c" ]; then
            continue
        fi
        name=`cat /sys/bus/i2c/devices/$file/name`
        online=`cat /sys/bus/i2c/devices/$file/online`
        echo "$name($file)=$online"
        ((all+=1))
        if [ "$online" = "1" ]; then
            ((pass+=1))
        fi
    done

    if [ "$all" = "$pass" ]; then
        echo "CmdOk"
        return 0
    fi
    echo "CmdFail $pass/$all"
    return 1
}

function BatteryPercent()
{
    levl=95
    
    if [ -f /sys/class/power_supply/battery/capacity ]; then
        levl=`cat /sys/class/power_supply/battery/capacity`
    fi
    echo "percent:"${levl} 
    echo "CmdOk"
    return 0
}

function PowerAll()
{
    echo "CmdOk"
}

function SinglePlayStart()
{
    echo "CmdOk"
}

function SinglePlayEnd()
{
    echo "CmdOk"
}
