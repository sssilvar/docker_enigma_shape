#!/bin/bash

################################################################################

#Matlab

  #Edit the line below providing the path to your matlab binary file location
  #Be aware that the script works faster on Matlab varsions 2014a and below.

  #Example /usr/local/MATLAB/R2013a_client/bin/matlab 

  #----modify-this----  
   MatlabPath=/usr/local/MATLAB/R2016b/bin/matlab



#FreeSurfer
  #Edit the line below providing the path to your FreeSurfer home directory

  #EXAMPLE /usr/local/freesurfer-5.3.0_64bit

#----modify-this----  
   FREESURFER_HOME=/usr/local/freesurfer/


#################################################################################


export FREESURFER_HOME="$FREESURFER_HOME"
source $FREESURFER_HOME/SetUpFreeSurfer.sh

export LIBGL_ALWAYS_INDIRECT=1



called=$0
if [[ ${called:0:1} == "/" ]]; then
    hdir=${called%/*}
else
    hdir=`pwd`
    if [[ ${called/\//} != $called ]]; then # $called contains partial path
        called=${called%/*} #get rid of scriptname
        hdir=$hdir/$called
    fi
fi
export SCRIPTS_DIR=$hdir/scripts/
source $SCRIPTS_DIR/func.sh



function usage {
cat<<EOF

USAGE: 

$0 [OPTIONS]


Mandatory flags: 

     -s        [ Mesh file directory ending with "SUBJID/resliced_mesh_ROI.m". ]

     -f        [ FreeSurfer Directory. ]

     -g	       [ Path to the .csv file with subject id's]
     
     -o        [ Output directory. ]

     -n        [ List of ROI region comma separated; e.g. '17,26,49'. You can also enter 'All' 
                 to selected all of the ROIs. ]

     -r        [ Redo option, enter either '0' or '1'; redoing will only delete and regenerate 
                 the ".byu" files, the QC images will always get updated. ]

optional flags:

     -m        [ When using matlab version 2014b and above, you must turn this flag on for the script to function. ]

     -e        [ Do not overwrite previosly generated CSV files]
         
     -h        [ It will print out the script guide. ]



EXAMPLE:

$0 -s /Project_directory/ShapeAnalysis/SUBJID/resliced_mesh_ROI.m -f /Project_directory/FreeSurfer -g /Project_directory/AutoQA_prep/subjectfile/subjectlist.txt -o /Project_directory/ShapeAnalysis/QA -n 17,53 -r 0 -m

NOTE:
Please provide full paths to the required inputs. (i.e. /Project_directory/ShapeAnalysis/SUBJID/resliced_mesh_ROI.m)

EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

newMat='off'
overwrite=true

echo
while getopts :s:o:g:f:n:r:emh OPT; do
  case "$OPT" in
    s) meshpath="${OPTARG}"
       echo "Path to surface mesh: ${meshpath}";;
    f) fsdir="$OPTARG"
       echo "Freesurfer SUBJECTS_DIR: $fsdir";;
    o) outdir="$OPTARG"
       echo "QA Output base dir: $outdir";;
    g) subjectfile="$OPTARG"
       echo "Subject file: $subjectfile";;
    n) if [[ `echo "$OPTARG"` == 'All' ]]; then
         rois="10 11 12 13 17 18 26 49 50 51 52 53 54 58"
       else
         rois=( `echo "$OPTARG" | tr ',' ' '` )
       fi
       echo "QA-ing ROI numbers: ${rois[@]}";;
    r) redo="$OPTARG";;
    m) newMat='on';;
    e) overwrite=false;;
    h) usage
       exit 1;;
    ?) usage
       exit 1;;
  esac
done


############### Check Inputs ###############


#cheking inputed directories and options
if [[ ! -e $subjectfile ]]; then
  echo  -e "\n\nSubject file doesnt exist: $subjectfile"
  exit 1
fi

if [[ ! -d $fsdir ]]; then
  echo  -e "\n\nfsdir doesnt exist: $fsdir"
  exit 1
fi

if [[ -z $outdir ]]; then
  usage
  echo -e "Please set a QA output dir with (-o).\n\n"
  exit 1
fi

if [[ $redo -ne "0" ]] && [[ $redo -ne "1" ]];then
  usage
  echo -e "Please indicate the redo option as '1' or '0' with (-r).\n\n"
  exit 1
fi


#making necessary directories
indir=$outdir/flip_origin
qcdir=$outdir/quickcheck
mkdir -p $indir $qcdir


#checking meshes and T1s, and generating QA_status.csv file

if $overwrite; then
  echo -e "\n\nChecking for mesh surfaces for subjects in $subjectfile\n\n"


  lineNum=1
  echo "SubjID,T1" > $outdir/QA_Status.csv
  for roi in ${rois[@]}; do
    sed -i "${lineNum} s/$/,R${roi}/" $outdir/QA_Status.csv
  done
  flag=0
  for subj in `awk -F "," 'NR>1 {print $1}' $subjectfile`; do
    ((lineNum++))
    echo ${subj} >> $outdir/QA_Status.csv
    if [[ ! -e $fsdir/$subj/mri/orig.mgz ]]; then
      echo "Subject $subj Missing T1 $fsdir/$subj/mri/orig.mgz"
      sed -i "${lineNum} s/$/,0/" $outdir/QA_Status.csv
      flag=1
    else  
      sed -i "${lineNum} s/$/,1/" $outdir/QA_Status.csv
    fi
    for roi in ${rois[@]}; do
      mfile=`echo $meshpath | sed -e "s/SUBJID/$subj/g" -e "s/ROI/$roi/g"`
      if [[ ! -e $mfile ]]; then 
        echo "Subject $subj is missing surface mesh $mfile"
        sed -i "${lineNum} s/$/,0/" $outdir/QA_Status.csv
        flag=1
      else  
        sed -i "${lineNum} s/$/,1/" $outdir/QA_Status.csv
      fi
    done
  done




  lineNum=1
  for roi in ${rois[@]}; do
    echo "R${roi}," >> $outdir/QA_temp.csv
    for subj in `awk -F "," 'NR>1 {print $1}' $subjectfile`; do
      mfile=`echo $meshpath | sed -e "s/SUBJID/$subj/g" -e "s/ROI/$roi/g"`
      if [[ ! -e $mfile ]]; then 
        sed -i "${lineNum} s/$/${subj},/" $outdir/QA_temp.csv
      fi
    done
    ((lineNum++))
  done
  sed -i 's/,$//' $outdir/QA_temp.csv

  awk 'BEGIN {FS=OFS=","}
  {
  for (i=1;i<=NF;i++)
  {
   arr[NR,i]=$i;
   if(big <= NF)
    big=NF;
   }
  }

  END {
    for(i=1;i<=big;i++)
     {
      for(j=1;j<=NR;j++)
      {
       printf("%s%s",arr[j,i], (j==NR ? "" : OFS));
      }
      print "";
     }
  }' $outdir/QA_temp.csv > $outdir/QA_Failed_Subjects.csv

  rm $outdir/QA_temp.csv

fi

############### Generating '.byu' Files ###############


#converting mesh files into byu format
echo -e "\n\nConvert mesh to byu"
for subj in `awk -F "," 'NR>1 {print $1}' $subjectfile`; do
  for roi in ${rois[@]}; do
    mfile=`echo $meshpath | sed -e "s/SUBJID/$subj/g" -e "s/ROI/$roi/g"`
    if [[ -e $mfile ]]; then
      byufile=${mfile/.m/.byu}
      if [[ -e $byufile && $redo -eq 0 ]]; then
        echo "Subject ${subj} convert to byu already done: $byufile"
        continue
      fi
      if [[ -e $byufile && $redo -eq 1 ]]; then
        echo "Subject ${subj} old byu file being removed: $byufile"
        rm $byufile
      fi	
      cmd="ccbbm -mesh2byu $mfile $byufile"
      runcmd "$cmd"
    fi
  done
done


#generating flip origin and convetring T1
echo -e "\n\nFlip origin of byu surfaces for QA and convert T1 image to analyze"
for subj in `awk -F "," 'NR>1 {print $1}' $subjectfile`; do
  mkdir -p $indir/$subj
  for roi in ${rois[@]}; do
    mfile=`echo $meshpath | sed -e "s/SUBJID/$subj/g" -e "s/ROI/$roi/g"`
    if [[ -e $mfile ]]; then
      inbyu=${mfile/.m/.byu}
      outbyu=$indir/$subj/surface_$roi.byu
      if [[ -e $outbyu && $redo -eq 0 ]]; then
        echo "Subject ${subj} flip origin already done: $outbyu"
        continue
      fi
      if [[ -e $outbyu && $redo -eq 1 ]]; then
        echo "Subject ${subj} old flip origin being removed: $outbyu"
        rm $outbyu
      fi
      cmd="byuscale $inbyu -1 -1 -1 256 256 256 > $outbyu"
      runcmd "$cmd"
    fi
  done

  if [[ -e $indir/$subj/orig.img && $redo -eq 0 ]]; then
    echo "Subejct ${subj} image coversion already done: $indir/$subj/orig.img"
    continue
  fi
  if [[ -e $indir/$subj/orig.img && $redo -eq 1 ]]; then
    echo "Subject ${subj} old converted image being removed: $indir/$subj/orig.img"
    rm $indir/$subj/orig.img
  fi
  cmd="mri_convert $fsdir/$subj/mri/orig.mgz $indir/$subj/orig.img -ot analyze"
  runcmd "$cmd"

done


############## Making QC Images ###############

echo -e "\n\nMaking quickcheck snapshots"
pushd $indir > /dev/null
startdisplay 2>&1 > /dev/null

RGB=''
byu=''

for roi in ${rois[@]}; do

  byu="$byu,'"surface_$roi.byu"'"

  if [ $roi == '10' ] || [ $roi == '49' ]; then    # Color of the Thalamus is orange.
    RGB="$RGB,[1 0.6 0]"
  elif [ $roi == '11' ] || [ $roi == '50' ]; then  # Color of the Caudate is pink.
    RGB="$RGB,[0.89 0.37 0.89]"
  elif [ $roi == '12' ] || [ $roi == '51' ]; then  # Color of the putamen is cyan.
    RGB="$RGB,[0 1 1]"
  elif [ $roi == '13' ] || [ $roi == '52' ]; then  # Color of the Pallidum is green.
    RGB="$RGB,[0.3  0.8  0]"
  elif [ $roi == '17' ] || [ $roi == '53' ]; then  # Color of the hippocampus is gold.
    RGB="$RGB,[0.9 0.75 0]"
  elif [ $roi == '18' ] || [ $roi == '54' ]; then  # Color of the amygdala is red.
    RGB="$RGB,[1 0 0]"
  elif [ $roi == '26' ] || [ $roi == '58' ]; then  # Color of the accumbens is cream.
    RGB="$RGB,[0.98 0.9 0.73]"
  else                                             # Color of unknown ROIs is white.
    RGB="$RGB,[1 1 1]"
  fi

done

byu=${byu#","}
RGB=${RGB#","}

awk -F "," 'NR>1 {print $1}' $subjectfile >> $qcdir/subjects.txt

if [ $newMat == 'on' ]; then
  matlabCmd="addpath('$SCRIPTS_DIR/matlab'); multiSurfaceOverlayOnMri_script_v2('$qcdir/subjects.txt','orig.img',{$byu},'$qcdir',{$RGB},2,'png',2,1); exit"
else    
  matlabCmd="addpath('$SCRIPTS_DIR/matlab'); multiSurfaceOverlayOnMri_script('$qcdir/subjects.txt','orig.img',{$byu},'$qcdir',{$RGB},2,'png',2,1); exit"
fi


echo "$MatlabPath -softwareopengl -nodesktop -nosplash -r \"$matlabCmd\""
  $MatlabPath -softwareopengl -nodesktop -nosplash -r "$matlabCmd"

rm $qcdir/subjects.txt

for roi in ${rois[@]}; do
  mkdir $qcdir/ROI_$roi
  mv $qcdir/*$roi.png $qcdir/ROI_$roi
done

popd > /dev/null

stopdisplay 2>&1  > /dev/null

echo -e "\n\nAll of the quickcheck images for the entered ROIs have been generated.\n\n"




