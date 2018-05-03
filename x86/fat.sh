#########################################################################
# File Name: fat.sh
# Author: eric.xu
# mail: eric.xu@libratone.com.cn
# Created Time: 2017-12-06 13:11:44
#########################################################################
#!/system/bin/sh

export BIN_DIR=.
export DATA_DIR=.

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
    echo $#
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

    ${BIN_DIR}/audio_loop_test &
    echo "CmdOk"

    return 0
}

# kill LineInLoop
function LineInTestEnd()
{
    pkill audio_loop_test
    echo "CmdOk"
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
    duration=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record fDuration | awk -F : '{print $2}' |awk -F . '{print $1}'`
    volume=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record iVolume | awk -F : '{print $2}' |awk -F . '{print $1}'`
    channels=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record iChannels | awk -F : '{print $2}' |awk -F . '{print $1}'`
    samplerate=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_record iSampeRate | awk -F : '{print $2}' |awk -F . '{print $1}'`
    
    ${BIN_DIR}/audio_test $outfile -D 0 -d 1 -C -p 512 -r $samplerate -f 16 -c $channels -n 8 &
    
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
    retfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json tx_test tx_analyzer sRetFile | awk -F : '{print $2}'`
    if [ -f $recordfile ]; then 
        ${BIN_DIR}/sig_analyzer ${DATA_DIR}/dut_cfg.json 0
        if [ -f $retfile ]; then
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
    c_len=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record fDuration | awk -F : '{print $2}'`
    c_vol=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record iVolume | awk -F : '{print $2}' |awk -F . '{print $1}'`
    c_ch=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record iChannels | awk -F : '{print $2}' |awk -F . '{print $1}'`
    c_sr=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_record iSampeRate | awk -F : '{print $2}' |awk -F . '{print $1}'`

    p_file=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play sInFile | awk -F : '{print $2}'` 
    p_wait=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play fWaitSecs | awk -F : '{print $2}'`
    p_len=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play fPlaySecs | awk -F : '{print $2}'`
    p_vol=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play iVolume | awk -F : '{print $2}' |awk -F . '{print $1}'`
    p_ch=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play iChannels | awk -F : '{print $2}' |awk -F . '{print $1}'`
    p_sr=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${loop_type}_play iSampeRate | awk -F : '{print $2}' |awk -F . '{print $1}'`
    
    if [ -f $p_file ]; then
        ${BIN_DIR}/audio_test $c_file -D 0 -d 1 -C -p 512 -r $c_sr -f 16 -c $c_ch -n 8 &
        sleep $p_wait
        ${BIN_DIR}/audio_test $p_file -D 0 -d 0 -P -p 4096 -r $p_sr -f 16 -c $p_ch -n 6 &
        sleep $p_len
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
    retfile=`${BIN_DIR}/dut_paras ${DATA_DIR}/dut_cfg.json closed_loop ${1}_analyzer sRetFile | awk -F : '{print $2}'`
    if [ -f $recordfile ]; then
        if [ "$1" = "fr" ]; then 
            ${BIN_DIR}/sig_analyzer ${DATA_DIR}/dut_cfg.json 1
        else
            ${BIN_DIR}/sig_analyzer ${DATA_DIR}/dut_cfg.json 2
        fi
        if [ -f $retfile ]; then
            cat ${retfile}
            echo "CmdOk"
            return 0
        fi
    fi
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

