#!/bin/bash
if [  $# -ne 3 ];then
    echo "parameter count is error! use $0 [mix wav file path] [clean wav file path] [est wav file path]"
   exit 0
fi
mix_wav_file_path=$1
clean_wav_file_path=$2
est_wav_file_path=$3
matlab_run_file_path=matlab_run_hupeng.m
cat > $matlab_run_file_path <<EOF
addpath(genpath(pwd))
test_metric('$clean_wav_file_path', '$mix_wav_file_path', '$est_wav_file_path')
EOF
matlab -nodesktop -nosplash -nojvm -r "run ./$matlab_run_file_path;quit;"
