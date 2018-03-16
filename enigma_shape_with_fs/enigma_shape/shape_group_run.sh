#!/bin/bash
#$ -S /bin/bash
#$ -o /ifshome/$USER/log -j y

# These can also be included in the bash file
# download ENGIMA_SHAPE package
# unzip

groupfile=$1
runFS=$2
outDirectory=$3

#echo $groupfile

####### Lets define variables!! ###########
#####################################################
####### Start user defined variables ###########
 


## Path to FreeSurfer Binary
#----modify-this----  
# FS=/usr/local/freesurfer/
#FS=/usr/local/freesurfer-5.3.0_64bit/
FS_binary=${FS}bin/

## directory where you've downloaded and stored all the shape stuff, containing MedialDemonsShared folder
#----modify-this----  
runDirectory=${ENIGMA_SHAPE_DIR}
#runDirectory=/ifshome/bgutman/


####### End of user defined variables ###########
###################################################
## do not change setROIs, this will allow you to create them all in one go!

setROIS="10 11 12 13 17 18 26 49 50 51 52 53 54 58"

#setROIS="26 58" 
#for testing only



function usage {
cat<<EOF

USAGE: 

$0 [list of subject ids] [Freesurfer results directory] [Shape output directory]



EXAMPLE:

$0 /home/data/lschmaal/testshape/test_VUms.csv /home/data/lschmaal/testshape/Freesurfer/  /home/data/lschmaal/testshape/shape_output_all

NOTE:
Please provide full paths to the required inputs. (i.e. /home/data/lschmaal/testshape/Freesurfer/)

The list of subjects can also be a csv file with possibly other data. 
The subject id column must be the first column. 
If it has headers, the subject id column must have header "id" or "SubjID"

EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi






cmd="export FREESURFER_HOME=${FS}"
echo $cmd
eval $cmd
        

for subject in `cut -d',' -f1 ${groupfile}` ; do

	echo $subject
	
	if [ ${subject} = "id" ]; then
    		continue
    		
    	elif [ ${subject} = "SubjID" ]; then
    		continue 
    	
	else

#for (( i=0; i<${#SUBJECT[@]}; i++ )); do
	
		#subject=${SUBJECT[$i]}
		mkdir -p ${outDirectory}/${subject}/

		cmd="perl ${runDirectory}/MedialDemonsShared/bin/Medial_Demons_shared.pl ${runFS}/${subject}/mri/aseg.mgz ${setROIS} ${outDirectory}/${subject}/ ${runDirectory}/MedialDemonsShared $FS_binary"

		echo $cmd
		echo $cmd > ${outDirectory}/${subject}/run_notes.txt
		eval $cmd >> ${outDirectory}/${subject}/run_notes.txt
	fi

done


filename=$(basename "${groupfile}")
#echo ${filename}
extension="${filename##*.}"
#echo ${extension}
filename="${filename%.*}"
#echo ${filename}


cmd="${runDirectory}/MedialDemonsShared/bin/raw_list2CSV_matrix ${outDirectory}/${filename}_LogJacs.csv ${runDirectory}/MedialDemonsShared/atlas GOF ${setROIS} LogJacs resliced_mesh ${groupfile} ${outDirectory}"
echo $cmd
eval $cmd

cmd="${runDirectory}/MedialDemonsShared/bin/raw_list2CSV_matrix ${outDirectory}/${filename}_thick.csv ${runDirectory}/MedialDemonsShared/atlas GOF ${setROIS} thick resliced_mesh ${groupfile} ${outDirectory}"
echo $cmd
eval $cmd

