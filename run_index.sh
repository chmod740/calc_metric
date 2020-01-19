#!/bin/bash
if [  $# -ne 1 ];then
    echo "parameter count is error! use $0 [wav_file_index_path]\n echo line of this file format as [clean wav file path] [mix wav file path] [est wav file path]"
   exit 0
fi
index_file_path=$1
matlab_run_file_path=matlab_run_hupeng_2.m
cat > $matlab_run_file_path <<EOF
addpath(genpath(pwd))
test_metrics('$index_file_path')
EOF
matlab -nodesktop -nosplash -nojvm -r "run ./$matlab_run_file_path;quit;"
