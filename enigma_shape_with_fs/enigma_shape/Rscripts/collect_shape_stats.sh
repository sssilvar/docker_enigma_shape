#!/bin/bash

#----Script to collect vertex-wise shape group-level statistics after they have been computed
#----See readme to change the parameters for your data
#-Boris Gutman
#-Dmitry Isaev
#-Neda Jahanshad
# Beta version for testing on sites.
#-Imaging Genetics Center, Keck School of Medicine, University of Southern California
#-ENIGMA Project, 2015
# enigma@ini.usc.edu 
# http://enigma.ini.usc.edu
#-----------------------------------------------

outdir=--shape_output_directory--
#config_script=--config_script_for_stats--
Rscript_concatenate_uni=--concatenate_script_unilat--
Rscript_concatenate_bil=--concatenate_script_bilat--
model_list=--model_list_id--
cohort=--cohort_name--


res_dir_uni=${outdir}/stats_unilateral
res_dir_bil=${outdir}/stats_bilateral

tar_uni=${outdir}/shape_stats_2send_${model_list}_${cohort}_uni.tar.gz
tar_bil=${outdir}/shape_stats_2send_${model_list}_${cohort}_bil.tar.gz


${Rscript_concatenate_uni} > /dev/null
${Rscript_concatenate_bil} > /dev/null


tar cvzf ${tar_uni}  ${res_dir_uni}/${model_list}_ALL_*_${cohort}.csv ${res_dir_uni}/${model_list}_*_NUM.RData\
 ${res_dir_uni}/${model_list}_*_METRICS*.RData ${res_dir_uni}/${model_list}_*_COVARIATES.RData

tar cvzf ${tar_bil} ${res_dir_bil}/${model_list}_ALL_*_${cohort}.csv ${res_dir_bil}/${model_list}_*_NUM.RData\
 ${res_dir_bil}/${model_list}_*_METRICS*.RData ${res_dir_bil}/${model_list}_*_COVARIATES.RData




