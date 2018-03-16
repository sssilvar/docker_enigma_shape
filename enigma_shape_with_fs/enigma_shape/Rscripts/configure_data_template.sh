#!/bin/bash

#----Script to add FreeSurfer volume data to Covariates files and create bilateral shape measures
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

fsdir=--freesurfer_output-- #/ifs/loni/faculty/thompson/four_d/Artemis/Shape/ENIGMA_SZ/FIDMAG/FIDMAG_FS			#FreeSurfer output directory
covariates=--covariates_file-- #/ifs/loni/faculty/thompson/four_d/Artemis/Shape/ENIGMA_SZ/FIDMAG/Covariates.csv		#Covariates files
outdir=--shape_output_directory-- #/ifs/loni/faculty/thompson/four_d/Artemis/Shape/ENIGMA_SZ/FIDMAG/FIDMAG_output	#Shape output directory
demons_dir=--demons_dir-- #/ifshome/bgutman/MedialDemons4grid								#Shape program directory
exclude_file=--exclude_file-- #/ifs/loni/faculty/thompson/four_d/Artemis/Shape/ENIGMA_SZ/FIDMAG/QA_Status.csv		#QA rating file

#awk '{ gsub("\r", "\n"); print $0;}' ${covariates} > ${outdir}/Covariates_unix1.csv
#tr -d '\015' <${outdir}/Covariates_unix1.csv >${outdir}/Covariates_unix.csv

perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1' ${covariates} > ${outdir}/Covariates_unix.csv
perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1' ${exclude_file} > ${outdir}/QA_status_unix.csv


echo "`awk -F "," 'NR==1 {print $1}' ${outdir}/Covariates_unix.csv`,ROI10,ROI49,ROI11,ROI50,ROI12,\
ROI51,ROI13,ROI52,ROI17,ROI53,ROI18,ROI54,ROI26,ROI58,ICV" > ${outdir}/tmp_vol1.csv

echo "`awk -F "," 'NR==1 {print $1}' ${outdir}/Covariates_unix.csv`,ROI10,ROI49,ROI11,ROI50,ROI12,\
ROI51,ROI13,ROI52,ROI17,ROI53,ROI18,ROI54,ROI26,ROI58,ICV" > ${outdir}/tmp_vol2.csv

#echo "Lthal,Rthal,Lcaud,Rcaud,Lput,Rput,Lpal,Rpal,Lhippo,Rhippo,Lamyg,Ramyg,Laccumb,Raccumb,ICV" > ${outdir}/tmp_vol.csv


roi="10 49 11 50 12 51 13 52 17 53 18 54 26 58"

l=0;
for roi_id in ${roi}; 
do
	roi2[l]=${roi_id}
	l=$((l+1));		
done

S=0;
for subj_id in `awk -F "," 'NR>1 {print $1}' ${outdir}/Covariates_unix.csv`; do
	i=0
	S=$((S+1))
	echo -en "\r on Subject $S, id: ${subj_id}"
	
	printf "%s,"  "${subj_id}" >> ${outdir}/tmp_vol1.csv
	printf "%s,"  "${subj_id}" >> ${outdir}/tmp_vol2.csv
	
	####--this part makes a tmp volumes file--######
	
	for x in Left-Thalamus-Proper Right-Thalamus-Proper Left-Caudate Right-Caudate Left-Putamen Right-Putamen Left-Pallidum Right-Pallidum\
	 Left-Hippocampus Right-Hippocampus Left-Amygdala Right-Amygdala Left-Accumbens-area Right-Accumbens-area; do
		vol[i]=`grep  ${x} ${fsdir}/${subj_id}/stats/aseg.stats | awk '{print $4}'`
		#vol[i]=`grep  ${x} ${fsdir}/${subj_id}/mri/aseg.stats | awk '{print $4}'`
		printf "%g," ${vol[i]} >> ${outdir}/tmp_vol1.csv 
		i=$((i+1))		
	done
	
	cur_dir=${outdir}/bilat_shape/${subj_id}
	
	cmd="mkdir -p ${cur_dir}"
	#echo ${cmd}
	${cmd}
	
	####--this part makes a tmp bilateral volumes file and computes bilateral shape features--######
	
	for ((j=0; j<14; j=$((j+2))));
	do		
		k=$((j+1))		
		y=`awk '{printf("%.2f\n",($1+$2)/2)}' <<<" ${vol[j]} ${vol[k]} "`
		printf "%g,%g," $y $y >> ${outdir}/tmp_vol2.csv		
	
		
		${demons_dir}/bin/raw_operations  -add -float ${outdir}/${subj_id}/LogJacs_${roi2[j]}.raw ${outdir}/${subj_id}/LogJacs_${roi2[k]}.raw ${cur_dir}/LogJacs_${roi2[k]}_.raw > /dev/null #>> ${outdir}/notes.txt
		${demons_dir}/bin/raw_operations   -multiply_num 0.5 -float  ${cur_dir}/LogJacs_${roi2[k]}_.raw ${cur_dir}/LogJacs_${roi2[k]}.raw > /dev/null #>> ${outdir}/notes.txt

		${demons_dir}/bin/raw_operations  -subtract -float ${outdir}/${subj_id}/LogJacs_${roi2[j]}.raw ${outdir}/${subj_id}/LogJacs_${roi2[k]}.raw ${cur_dir}/LogJacs_${roi2[j]}_.raw > /dev/null #>> ${outdir}/notes.txt
		${demons_dir}/bin/raw_operations  -multiply -float ${cur_dir}/LogJacs_${roi2[j]}_.raw ${cur_dir}/LogJacs_${roi2[j]}_.raw ${cur_dir}/LogJacs_${roi2[j]}__.raw > /dev/null #>> ${outdir}/notes.txt
		${demons_dir}/bin/raw_operations  -root -float ${cur_dir}/LogJacs_${roi2[j]}__.raw ${cur_dir}/LogJacs_${roi2[j]}.raw > /dev/null #>> ${outdir}/notes.txt
	
		rm ${cur_dir}/LogJacs_${roi2[k]}_.raw
		rm ${cur_dir}/LogJacs_${roi2[j]}_.raw
		rm ${cur_dir}/LogJacs_${roi2[j]}__.raw
		
		${demons_dir}/bin/raw_operations  -add -float ${outdir}/${subj_id}/thick_${roi2[j]}.raw ${outdir}/${subj_id}/thick_${roi2[k]}.raw ${cur_dir}/thick_${roi2[k]}_.raw > /dev/null #>> ${outdir}/notes.txt
		${demons_dir}/bin/raw_operations   -multiply_num 0.5 -float  ${cur_dir}/thick_${roi2[k]}_.raw ${cur_dir}/thick_${roi2[k]}.raw > /dev/null #>> ${outdir}/notes.txt
	
		${demons_dir}/bin/raw_operations  -subtract -float ${outdir}/${subj_id}/thick_${roi2[j]}.raw ${outdir}/${subj_id}/thick_${roi2[k]}.raw ${cur_dir}/thick_${roi2[j]}_.raw > /dev/null #>> ${outdir}/notes.txt
		${demons_dir}/bin/raw_operations  -multiply -float ${cur_dir}/thick_${roi2[j]}_.raw ${cur_dir}/thick_${roi2[j]}_.raw ${cur_dir}/thick_${roi2[j]}__.raw > /dev/null #>> ${outdir}/notes.txt
		${demons_dir}/bin/raw_operations  -root -float ${cur_dir}/thick_${roi2[j]}__.raw ${cur_dir}/thick_${roi2[j]}.raw > /dev/null #>> ${outdir}/notes.txt
	
		rm ${cur_dir}/thick_${roi2[k]}_.raw
		rm ${cur_dir}/thick_${roi2[j]}_.raw
		rm ${cur_dir}/thick_${roi2[j]}__.raw
		
	done
		
	ICVol=`cat ${fsdir}/${subj_id}/stats/aseg.stats | grep IntraCranialVol | awk -F, '{print $4}'`
	#ICVol=`cat ${fsdir}/${subj_id}/mri/aseg.stats | grep IntraCranialVol | awk -F, '{print $4}'`
	
	printf "%g" $ICVol >> ${outdir}/tmp_vol1.csv
	printf "%g" $ICVol >> ${outdir}/tmp_vol2.csv
	
	echo "" >> ${outdir}/tmp_vol1.csv
	echo "" >> ${outdir}/tmp_vol2.csv
	
	
done

sed -i "s|\,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA|" ${outdir}/tmp_vol1.csv
sed -i "s|\,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA|" ${outdir}/tmp_vol2.csv

join -t, ${outdir}/Covariates_unix.csv ${outdir}/tmp_vol1.csv > ${outdir}/Covariates_vols.csv
join -t, ${outdir}/Covariates_unix.csv ${outdir}/tmp_vol2.csv > ${outdir}/Covariates_bilat.csv

sed -i "0,/id/ s/`awk -F "," 'NR==1 {print $1}' ${outdir}/Covariates_unix.csv`/SubjID/" ${outdir}/Covariates_vols.csv
sed -i "0,/id/ s/`awk -F "," 'NR==1 {print $1}' ${outdir}/Covariates_unix.csv`/SubjID/" ${outdir}/Covariates_bilat.csv



####--this part makes another QA rating file for bilateral use, setting the miminum score for L and R hemi's--######


#perl -pe 'if ( s/\r\n?/\n/g ) { $f=1 }; if ( $f || ! $m ) { s/([^\n])\z/$1\n/ }; $m=1' ${exclude_file} > ${outdir}/QA_status_unix.csv 
#already done above

#######fixing small problem in QA header########
#bad_QA_header1="R10,R11,R12,R13,R17,R18,R26,R49,R50,R51,R52,R53,R54,R58"
#bad_QA_header2="ROI_10,ROI_11,ROI_12,ROI_13,ROI_17,ROI_18,ROI_26,ROI_49,ROI_50,ROI_51,ROI_52,ROI_53,ROI_54,ROI_58"
#good_QA_header="ROI10,ROI11,ROI12,ROI13,ROI17,ROI18,ROI26,ROI49,ROI50,ROI51,ROI52,ROI53,ROI54,ROI58"

#sed -i "s|\${bad_QA_header1}|${good_QA_header}|" ${outdir}/QA_status_unix.csv
#sed -i "s|\${bad_QA_header2}|${good_QA_header}|" ${outdir}/QA_status_unix.csv

sed -i "s|\R10,R11,R12,R13,R17,R18,R26,R49,R50,R51,R52,R53,R54,R58|ROI10,ROI11,ROI12,ROI13,ROI17,ROI18,ROI26,ROI49,ROI50,ROI51,ROI52,ROI53,ROI54,ROI58|" ${outdir}/QA_status_unix.csv
sed -i "s|\ROI_10,ROI_11,ROI_12,ROI_13,ROI_17,ROI_18,ROI_26,ROI_49,ROI_50,ROI_51,ROI_52,ROI_53,ROI_54,ROI_58|ROI10,ROI11,ROI12,ROI13,ROI17,ROI18,ROI26,ROI49,ROI50,ROI51,ROI52,ROI53,ROI54,ROI58|" ${outdir}/QA_status_unix.csv
################################################

for ((j=1; j<15; j=$((j+1))));
do
	QA_orig[j]=0;
	QA[j]=0;
done

ind=0;
while IFS=, read SubjID T1 ROI 
#ROI11 ROI12 ROI13 ROI17 ROI18 ROI26 ROI49 ROI50 ROI51 ROI52 ROI53 ROI54 ROI58

do	
	
	if [ $ind \< 1 ]; then	
		printf "%s,%s" $SubjID $T1 > ${outdir}/QA_status_bilat.csv
		printf ",%s" $ROI >> ${outdir}/QA_status_bilat.csv		
	else
		printf "%s,%s" $SubjID $T1 >> ${outdir}/QA_status_bilat.csv
	
		j=1
		for eval in $(echo $ROI | sed "s/,/ /g")
		do
			QA_orig[j]=$eval
			j=$((j+1))
		done

		for ((j=1; j<8; j=$((j+1))));
		do	
		    j_bil=$((j+7)) 
		    QA_L=${QA_orig[j]}
		    QA_R=${QA_orig[j_bil]}	    		
		#    echo "${QA_L}, ${QA_R}"	    		

		    if [ $QA_L \< $QA_R ]; then
			QA[j_bil]=${QA_L}  
			QA[j]=${QA_L}
		    else
			QA[j_bil]=${QA_R}  
			QA[j]=${QA_R}       
		    fi
		done	
		
		for ((j=1; j<15; j=$((j+1))));
		do
			printf ",%g" ${QA[j]} >> ${outdir}/QA_status_bilat.csv
		done
	fi  
       
        echo "" >> ${outdir}/QA_status_bilat.csv        
       
       ind=$((ind+1))
done < ${outdir}/QA_status_unix.csv



#rm ${outdir}/QA_status_unix.csv
rm ${outdir}/tmp_vol1.csv
rm ${outdir}/tmp_vol2.csv
rm ${outdir}/Covariates_unix.csv
#rm ${outdir}/notes.txt

echo ""