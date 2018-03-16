#!/bin/bash

#----Script to configure template R script wrappers and data transforms for your data.
#----Required before running statistical models on vertex-wise shape measures
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

####--Section 1. This should be edited each time a new study is run--#######

cohort=NESDA							#Cohort name (must be unique, but the name is up to you)
fsdir=/home/data/lschmaal/testshape/subjects			#FreeSurfer output directory
covariates=/home/data/lschmaal/testshape/Covariates2.csv	#Covariates files
outdir=/home/data/lschmaal/testshape/shape_output_all		#Shape output directory
exclude_file=/home/data/lschmaal/testshape/NESDA_toy_QA.csv	#Visual quality check score

####--Section 2. This should be edited only once when first placing the R scripts on your system--#######

demons_dir=/home/data/lschmaal/testshape/MedialDemonsShared		#Shape program directory
Rscript_dir=/home/data/lschmaal/testshape/MedialDemonsShared/Rscripts	#Rscript directory
R_binary=/home/common/applications/R/R-3.2.2/bin/R			#R binary

###########--Section 3. Only change this if your results will never be part of a meta-analysis--############
####--(i.e. you are running your own linear models) OR we (a.k.a. "ENIGMA team") tell you to change it--####

model_list=ENIGMA_MDD_SHAPE1
config_link=https://docs.google.com/spreadsheets/d/1-ThyEvz1qMOlEOrm2yM86rD_KABr_YE4yqYmHogaQg0


####--DO NOT EDIT BELOW THIS LINE--#######


top_log_uni=${outdir}/log1
top_log_bil=${outdir}/log2

log_dir_uni=${outdir}/stats_unilateral_log
log_dir_bil=${outdir}/stats_bilateral_log

res_dir_uni=${outdir}/stats_unilateral
res_dir_bil=${outdir}/stats_bilateral


perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1'\
 ${Rscript_dir}/mass_uv_regr_IGC_shapes_template.sh > ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 
perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1'\
 ${Rscript_dir}/mass_uv_regr_IGC_shapes_template.sh > ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--top_level_log--|${log_dir_uni}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--top_level_log--|${log_dir_bil}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
  
 sed -i "s|\--script_directory--|${Rscript_dir}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--script_directory--|${Rscript_dir}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--results_directory--|${outdir}/stats_unilateral|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--results_directory--|${outdir}/stats_bilateral|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--low_level_log_directory--|${outdir}/stats_uni_logs|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--low_level_log_directory--|${outdir}/stats_bil_logs|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--cohort_name--|${cohort}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--cohort_name--|${cohort}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh

 sed -i "s|\--shape_output_directory--|${outdir}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--shape_output_directory--|${outdir}/bilat_shape|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
  
 sed -i "s|\--covariates_file--|${outdir}/Covariates_vols.csv|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--covariates_file--|${outdir}/Covariates_bilat.csv|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 #sed -i "s|\--exclude_file--|${exclude_file}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh # changed 8/9/2016
 sed -i "s|\--exclude_file--|${outdir}/QA_status_unix.csv|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--exclude_file--|${outdir}/QA_status_bilat.csv|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--R_binary--|${R_binary}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--R_binary--|${R_binary}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--model_list_id--|${model_list}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--model_list_id--|${model_list}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 sed -i "s|\--config_link--|${config_link}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 sed -i "s|\--config_link--|${config_link}|" ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh

 
 chmod 777 ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_uni.sh
 chmod 777 ${outdir}/mass_uv_regr_IGC_shapes_${cohort}_bil.sh
 
 
###################################################
#######NEXT ADAPT THE CONCATENATE SCRIPT###########
###################################################
 
 perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1'\
 ${Rscript_dir}/concat_mass_uv_regr_template.sh > ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 
 perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1'\
 ${Rscript_dir}/concat_mass_uv_regr_template.sh > ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh 
 
 sed -i "s|\--script_directory--|${Rscript_dir}|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--script_directory--|${Rscript_dir}|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 sed -i "s|\--results_directory--|${outdir}/stats_unilateral|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--results_directory--|${outdir}/stats_bilateral|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 sed -i "s|\--low_level_log_directory--|${outdir}/stats_uni_logs|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--low_level_log_directory--|${outdir}/stats_bil_logs|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 sed -i "s|\--cohort_name--|${cohort}|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--cohort_name--|${cohort}|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 sed -i "s|\--R_binary--|${R_binary}|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--R_binary--|${R_binary}|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 sed -i "s|\--model_list_id--|${model_list}|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--model_list_id--|${model_list}|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
  
 sed -i "s|\--config_link--|${config_link}|" ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 sed -i "s|\--config_link--|${config_link}|" ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 chmod 777 ${outdir}/concat_mass_uv_regr_${cohort}_uni.sh
 chmod 777 ${outdir}/concat_mass_uv_regr_${cohort}_bil.sh
 
 
  ########################################################
  #######HERE ADAPT THE COLLECT STATISTICS FILE###########
  ########################################################
 
 perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1'\
 ${Rscript_dir}/collect_shape_stats.sh > ${outdir}/collect_shape_stats_${cohort}.sh
 
  sed -i "s|\--shape_output_directory--|${outdir}|" ${outdir}/collect_shape_stats_${cohort}.sh
  sed -i "s|\--concatenate_script_unilat--|${outdir}/concat_mass_uv_regr_${cohort}_uni.sh|" ${outdir}/collect_shape_stats_${cohort}.sh
  sed -i "s|\--concatenate_script_bilat--|${outdir}/concat_mass_uv_regr_${cohort}_bil.sh|" ${outdir}/collect_shape_stats_${cohort}.sh
  sed -i "s|\--model_list_id--|${model_list}|" ${outdir}/collect_shape_stats_${cohort}.sh
  sed -i "s|\--cohort_name--|${cohort}|" ${outdir}/collect_shape_stats_${cohort}.sh
  
  chmod 777 ${outdir}/collect_shape_stats_${cohort}.sh
  

 ##########################################################################
 #######NOW ADAPT THE WRITE_VOLS/COMPUTE BILATERAL MEASURES FILE###########
 ##########################################################################
 
 perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1'\
 ${Rscript_dir}/configure_data_template.sh > ${outdir}/configure_data_${cohort}.sh
 
 sed -i "s|\--freesurfer_output--|${fsdir}|" ${outdir}/configure_data_${cohort}.sh
 sed -i "s|\--covariates_file--|${covariates}|" ${outdir}/configure_data_${cohort}.sh
 sed -i "s|\--shape_output_directory--|${outdir}|" ${outdir}/configure_data_${cohort}.sh
 sed -i "s|\--demons_dir--|${demons_dir}|" ${outdir}/configure_data_${cohort}.sh
 sed -i "s|\--exclude_file--|${exclude_file}|" ${outdir}/configure_data_${cohort}.sh
 
 chmod 777 ${outdir}/configure_data_${cohort}.sh
 
 # ${outdir}/configure_data_${cohort}.sh