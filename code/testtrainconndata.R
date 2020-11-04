## This R script reads data:
## The Bro log data from [Secrepo](http://www.secrepo.com/Datasets%20Description/HTML_Bro_log_1/conn.html):
## assigns headers to it and makes a useful subset for

source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

## Get only 6 fields
conndataC=conndata[,c("service","duration","orig_bytes",
                      "resp_bytes","orig_ip_bytes","resp_ip_bytes")]
## Remove missing data
conndataC=conndataC[!apply(conndataC,1,function(x)any(x=="-")),]
## Log scale where appropriate
for(i in c(2:6)) conndataC[,i]=log(1+as.numeric(conndataC[,i]))
## Make a binary variable for whether the record is http
for(i in c(1)) conndataC[,i]=as.factor(conndataC[,i])
conndataC[,"http"]=as.numeric(conndataC[,"service"]!="http")
## Remove the "service" flag from which this is constructed
conndataC=conndataC[,-1]

## Make a test/train split
set.seed(1)
set1=sample(1:dim(conndataC)[1],floor(dim(conndataC)[1]/2))
train=conndataC[set1,]
test=conndataC[-set1,]

## Write these to file
write.csv(test,file="conndataC_test.csv")
write.csv(train,file="conndataC_train.csv")
