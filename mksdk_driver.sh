#!/bin/bash

EXE=(dut_paras)
SHAREDLIB=()
STATICLIB=()
INCLUDE="include"
SAMPLES="samples"
SCRIPTS="scripts"
DATA="data"
ROOT_PATH=../../../..

LUNCH_TARGET="zipp_mini"

ERRLOGFILE=./mksdk_error.log
rm -rf $ERRLOGFILE
exit_cmd()
{
	#recover_stdout_stderr;
	echo "Failed:please see $ERRLOGFILE for detail message!"
	exit -1
}

check_cmd()
{
	echo "$1"
	$1 2>>$ERRLOGFILE
	var=$?
	if [ 0 = $var ];then
	echo Successful
	echo
	else
	exit_cmd;
	fi
	
}

echo "executable: ${EXE[*]}"
echo "shared: ${SHAREDLIB[*]}"
echo "static: ${STATICLIB[*]}"
echo "Include: $INCLUDE"
cd $ROOT_PATH
echo "root path: `pwd`"
cd -

# check_cmd "ls -l $INCLUDE"

FULL_PATH=`pwd`
PROJECT_NAME=`/usr/bin/basename $FULL_PATH`
SDK_DIR_NAME=../../sdk/$PROJECT_NAME


exe_cnt=${#EXE[@]}
so_cnt=${#SHAREDLIB[@]}
a_cnt=${#STATICLIB[@]}


mkdir -p ./$SDK_DIR_NAME
rm -rf ./$SDK_DIR_NAME/doc/*
rm -rf ./$SDK_DIR_NAME/include/*
rm -rf ./$SDK_DIR_NAME/lib/*
rm -rf ./$SDK_DIR_NAME/bin/*
rm -rf ./$SDK_DIR_NAME/$SAMPLES/*
rm -rf ./$SDK_DIR_NAME/$SCRIPTS/*
rm -rf ./$SDK_DIR_NAME/$DATA/*
rm -rf ./$SDK_DIR_NAME/Android.mk

cp -rf $INCLUDE ./$SDK_DIR_NAME/
cp -rf $SAMPLES ./$SDK_DIR_NAME/
cp -rf $SCRIPTS ./$SDK_DIR_NAME/
cp -rf $DATA ./$SDK_DIR_NAME/

sed -e "s/delta2-module-name/$PROJECT_NAME/g" -e "s/delta2-sdk-name/./g" ./Doxyfile > ./$SDK_DIR_NAME/Doxyfile
# check_cmd "doxygen ./$SDK_DIR_NAME/Doxyfile 1>/dev/null"
cd ./$SDK_DIR_NAME
doxygen ./Doxyfile 1>/dev/null 2>$ERRLOGFILE
cd -



for file_name in ${EXE[*]}
do
	file_path=$ROOT_PATH/out/target/product/$LUNCH_TARGET/system/bin/$file_name
	if [ ! -f "$file_path" ]; then
		echo "$file_path is not exist!">>$ERRLOGFILE
		exit_cmd
	fi
    mkdir -p ./$SDK_DIR_NAME/bin
	cp -f $file_path ./$SDK_DIR_NAME/bin/

	file_path=$ROOT_PATH/out/target/product/$LUNCH_TARGET/symbols/system/bin/$file_name
	if [ ! -f "$file_path" ]; then
		echo "$file_path is not exist!">>$ERRLOGFILE
		exit_cmd
	fi

	mkdir -p ./$SDK_DIR_NAME/symbols/bin
	cp -f "$file_path" ./$SDK_DIR_NAME/symbols/bin/
done



for file_name in ${SHAREDLIB[*]}
do
	file_path=$ROOT_PATH/out/target/product/$LUNCH_TARGET/system/lib/$file_name.so
	if [ ! -f $file_path ]; then
		echo "$file_path is not exist!">>$ERRLOGFILE
		exit_cmd
	fi
    mkdir -p ./$SDK_DIR_NAME/lib
	cp -f "$file_path" ./$SDK_DIR_NAME/lib/

	file_path=$ROOT_PATH/out/target/product/$LUNCH_TARGET/symbols/system/lib/$file_name.so
	if [ ! -f $file_path ]; then
		echo "$file_path is not exist!">>$ERRLOGFILE
		exit_cmd
	fi
	mkdir -p ./$SDK_DIR_NAME/symbols/lib
	cp -f "$file_path" ./$SDK_DIR_NAME/symbols/lib/
done

for file_name in ${STATICLIB[*]}
do
	file_path=$ROOT_PATH/out/target/product/$LUNCH_TARGET/obj/STATIC_LIBRARIES/${file_name}_intermediates/$file_name.a
	if [ ! -f $file_path ]; then
		echo "$file_path is not exist!">>$ERRLOGFILE
		exit_cmd
	fi
    mkdir -p ./$SDK_DIR_NAME/lib
	file_name_sub=`echo $file_name|cut -d "." -f1`
	cp -f $file_path ./$SDK_DIR_NAME/lib/
done


sed -e "s/exexx_bin/${EXE[*]}/g" -e "s/libxx_so/${SHAREDLIB[*]}/g" -e "s/libxx_a/${STATICLIB[*]}/g" ./Android.mk-Template > ./$SDK_DIR_NAME/Android.mk

exit 0
