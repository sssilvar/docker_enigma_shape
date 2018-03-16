#!/bin/bash
#$ -S /bin/bash
#$ -o --top_level_log-- -j y  ###### Path to your own log file directory 
# /ifs/loni/faculty/thompson/four_d/disaev/la2/ENIGMA_SZ/log

#----Wrapper for shape version of mass_uv_regr.R script.
#----See readme to change the parameters for your data
#-Dmitry Isaev
#-Boris Gutman
#-Neda Jahanshad
# Beta version for testing on sites.
#-Imaging Genetics Center, Keck School of Medicine, University of Southern California
#-ENIGMA Project, 2015
# enigma@ini.usc.edu 
# http://enigma.ini.usc.edu
#-----------------------------------------------

#---Section 1. Script directories
scriptDir=--script_directory-- #/ifs/loni/faculty/thompson/four_d/disaev/la2/ENIGMA_SZ/FIDMAG/script
resDir=--results_directory-- #/ifs/loni/faculty/thompson/four_d/disaev/la2/ENIGMA_SZ/FIDMAG/res
logDir=--low_level_log_directory-- #/ifs/loni/faculty/thompson/four_d/disaev/la2/ENIGMA_SZ/FIDMAG/log

if [ ! -d $scriptDir ]
then
   mkdir -p $scriptDir
fi

if [ ! -d $resDir ]
then
   mkdir -p $resDir
fi

if [ ! -d $logDir ]
then
   mkdir -p $logDir
fi


#---Section 2. Configuration variables-----

SITE="--cohort_name--" #"FIDMAG"
DATADIR="--shape_output_directory--" #"/ifs/loni/faculty/thompson/four_d/Artemis/Shape/ENIGMA_SZ/FIDMAG/FIDMAG_output"
SUBJECTS_COV="--covariates_file--" #"/ifs/loni/faculty/thompson/four_d/Artemis/Shape/ENIGMA_SZ/FIDMAG/FIDMAG_covariates_FS.csv"
EXCLUDE_FILE="--exclude_file--" #"/ifs/loni/faculty/thompson/four_d/disaev/la2/ENIGMA_SZ/FIDMAG/misc/QA_Status.csv"

RUN_ID="--model_list_id--"  #"ENIGMA_SCHIZO_SHAPE1"
CONFIG_PATH="--config_link--"  #"https://docs.google.com/spreadsheets/d/1-ThyEvz1qMOlEOrm2yM86rD_KABr_YE4yqYmHogaQg0"
ROI_LIST=("10" "11" "12" "13" "17" "18" "26" "49" "50" "51" "52" "53" "54" "58")
#EXCLUDE_FILE=""
QA_LEVEL=2
SHAPE_METR_PREFIX=""

Nnodes=${#ROI_LIST[@]} 	#Set number of nodes to the length of ROI list
#Nnodes=1		#Set number of nodes to 1 if running without qsub

#---Section 3. DO NOT EDIT. some additional processing of arbitrary variables
if [ "$EXCLUDE_FILE" != "" ]; then
	EXCLUDE_STR="-exclude_path $EXCLUDE_FILE"
else
	EXCLUDE_STR=""
fi

if [ "$SHAPE_METR_PREFIX" != "" ]; then
	SHAPE_METR_PREFIX_STR="-shape_prefix $SHAPE_METR_PREFIX"
else
	SHAPE_METR_PREFIX_STR=""
fi


#---Section 4. DO NOT EDIT. qsub variable ---
#cur_roi=${ROI_LIST[${SGE_TASK_ID}-1]}  
Nroi=${#ROI_LIST[@]}	
if [ $Nnodes == 1 ]
then
	SGE_TASK_ID=1
fi
NchunksPerTask=$((Nroi/Nnodes))
start_pt=$(($((${SGE_TASK_ID}-1))*${NchunksPerTask}+1))
end_pt=$((${SGE_TASK_ID}*${NchunksPerTask}))

if [ "$SGE_TASK_ID" == "$Nnodes" ]
then
end_pt=$((${Nroi}))
fi

#---Section 5. R binary
#Rbin=/usr/local/R-2.9.2_64bit/bin/R
Rbin=--R_binary-- #/usr/local/R-3.1.3/bin/R

#---Section 6. DO NOT EDIT. Running the R script
cd $scriptDir
echo "CHANGING DIRECTORY into $scriptDir"

OUT=log.txt
touch $OUT
for ((i=${start_pt}; i<=${end_pt};i++));
do
	cur_roi=${ROI_LIST[$i-1]}  

	cmd="${Rbin} --no-save --slave --args\
			${RUN_ID}\
			${SITE} \
			${DATADIR} \
			${logDir} \
			${resDir}
			${SUBJECTS_COV} \
			${cur_roi} \
			${CONFIG_PATH} \
			${QA_LEVEL} \
			${EXCLUDE_STR} \
			${SHAPE_METR_PREFIX_STR} \
			<  ${scriptDir}//mass_uv_regr.R
		"
	echo $cmd
	echo $cmd >> $OUT
	eval $cmd
done
