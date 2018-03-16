#read in data
qa<-read.csv("Hubin_SZ_fails.csv",stringsAsFactors=F)
status<-read.csv("QA_Status.csv",stringsAsFactors=F) #generated from AutoQA script

#set all to pass
status[,2:ncol(status)]<-3

#match column names - only needed if the headers have the form ROI_10, ROI_11, etc. 
#should be commented or modified otherwise - expects to match to R10, R11, etc.
colnames(qa)<-gsub("OI_","",colnames(qa))

#find subjects listed in qa as failed and set the relevant cell to 1
for (i in 1:ncol(qa)){
  roi<-colnames(qa)[i]
  for (j in 1:nrow(qa)){
    targ<-qa[j,i]
    if (!is.na(targ) && targ != "") {
      status[status$SubjID==targ,c(roi)]<-1
    }
  }
}
#overwrite dummy QA list
write.csv(status,"QA_Status_Hubin.csv",row.names=F,quote=F)
