#!/bin/bash

LOG=`pwd`/surface_qa_`date +%y%m%d`.log
ERRLOG=`pwd`/surface_qa_`date +%y%m%d`.err

startdisplay(){
if [[ -z $DISPLAY ]]; then
   #starting a vnc session
   TMP_VNC_OUT=/tmp/TMP_VNC_OUT.$$.txt
   vncserver &> $TMP_VNC_OUT
   VNC_DISPLAY_NUM=`grep -i desktop $TMP_VNC_OUT | sed 's/.*\([0-9][0-9]*\)/\1/'`
   rm -f $TMP_VNC_OUT
   export DISPLAY=:$VNC_DISPLAY_NUM
fi
}
stopdisplay(){
if [[ ! -z $VNC_DISPLAY_NUM ]]; then
   #closing the vnc session
   vncserver -kill :$VNC_DISPLAY_NUM &> /dev/null
   unset DISPLAY
   unset VNC_DISPLAY_NUM
fi
}
runcmd(){
  cmd="$@"
  echo $cmd | tee -a $LOG
  eval $cmd 2>&1 | tee -a $LOG
  result=${PIPESTATUS[0]}
  if [[ $result -ne 0 && -z `echo $cmd | egrep '(byureorder|byucat|byuscale|computeavgraw|compdisp)'` ]]; then
    echo "$cmd exited with status $result" | tee -a $ERRLOG
  fi
}
export PATH=$SCRIPTS_DIR/bin:$PATH


