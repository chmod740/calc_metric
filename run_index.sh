#!/bin/bash
if [  $# -ne 2 ];then
    echo "parameter count is error! use $0 [wav_file_index_path],[output_file_path] $\n echo line of [wav_file_index_path] file format as [clean wav file path] [mix wav file path] [est wav file path]"
   exit 0
fi
index_file_path=$1
output_file_path=$2
matlab_run_file_path=matlab_run_hupeng_2.m
cat > $matlab_run_file_path <<EOF
addpath(genpath(pwd))
test_metrics('$index_file_path', '$output_file_path')
EOF
matlab -nodesktop -nosplash -nojvm -r "run ./$matlab_run_file_path;quit;"
