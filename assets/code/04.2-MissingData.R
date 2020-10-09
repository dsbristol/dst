################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/04.html

## Examples of outliers missing data for cyber security

## Read the data
source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

## Convert all features into their correct format, numeric or factor
conndataM=conndata
for(i in c(9,10,11,16:19)) conndataM[,i]=as.numeric(conndataM[,i])
for(i in c(7,8)) conndataM[,i]=as.factor(conndataM[,i])

## Outliers Example:
thist=hist(conndataM[,"duration"],breaks=101)

## Histogram with a logarithmic x-axis
png("../media/04.2-DurationOutliers.png",height=500,width=800)
plot(thist$mids,thist$density,log="y",type="b",
     xlab="duration",ylab="histogram density")
dev.off()

## Simply adding the threshold
png("../media/04.2-DurationOutliers2.png",height=500,width=800)
plot(thist$mids,thist$density,log="y",type="b",
     xlab="duration",ylab="histogram density")
abline(v=1200,col=2) # obvious threshold
dev.off()


## Demonstration of batch efect:
hist(conndataM[,"ts"],breaks=101)
conndataM[,"day"]=1 + (conndataM[,"ts"]>1331960000)
conndataM[,"logduration"]=log(conndataM[,"duration"])
lm1=lm(logduration~proto+service +ts +id.resp_p+day,
       data=conndataM[conndataM[,"duration"]<1200,])
summary(lm1)
## Look out for a "day" effect. Day 1 is not like Day 2.

###########
## Missing Data

## Mean imputation
conndataMmean=conndataM
conndataMmean[is.na(conndataMmean[,"logduration"]),
              "logduration"]=
    mean(na.omit(conndataMmean[,"logduration"]))

## Linear regression example of the differnce in the estimate
tdata=conndataMmean[conndataMmean[,"logduration"]<log(1200),]
lm2=lm(logduration~proto+service +ts +id.resp_p+day,
       data=tdata)
ts1=summary(lm1)
ts2=summary(lm2)

png("../media/04.2-MeanImputation.png",
    height=500,width=800)
par(xpd=TRUE)
plot(ts1$coefficients[-1,1],
     ts2$coefficients[-1,1],type="n",
     xlab="Coefficient (available case)",
     ylab="Coefficient (mean imputed)",bty="n")
abline(v=0,h=0,col="grey")
text(ts1$coefficients[-1,1],
     ts2$coefficients[-1,1],
     rownames(ts1$coefficients[-1,]))
dev.off()

## Conservative Imputation example
## Ask if a time interval completely contains another time interval
NetflowContains=function(a,b,tol=0){
    if(any(c(is.na(a),is.na(b))))return(NA)
    (a[1]<b[1]+tol) &
        ((a[2])>b[2]-tol)
}
testdata=conndataM[conndataM[,"id.orig_h"]=="192.168.202.76",]
testdata=data.frame(start=testdata[,"ts"],
                    end=rowSums(testdata[,c("ts","duration")]))

## Available case analysis
testrawmat=apply(testdata,1,function(x){
    apply(testdata,1,function(y){
        NetflowContains(x,y)
    })
})
## Conservative imputation analysis
testconsmat=apply(testdata,1,function(x){
    apply(testdata,1,function(y){
        NetflowContains(x,ifelse(is.na(y),0,y))
    })
})

## Compare the results of the available case vs conservative imputation approaches
library("knitr")
kable(table(unlist(testrawmat)))
kable(table(unlist(testconsmat)))
## Available case sees very few containing records. But the conservative imputation implies a great many could exist, if only we hadn't thrown them out for missing data.

## Define a plotting function to display events as time intervals
eventPlot=function(events,pch=c(19,4,NA),line.col=2,...){
    events=as.matrix(events)
    events=cbind(events,NA)
    indexes=cbind(1:dim(events)[1],1:dim(events)[1],NA)
    plot(as.vector(t(events)),as.vector(t(indexes)),pch=pch,las=1,
         ylab="Record index",xlab="Time")
    lines(as.vector(t(events)),as.vector(t(indexes)),col=line.col)
}
## NB The workshop does this for real records.

## Create fake data for demonstration
fakedata=matrix(c(0,5,
                  2,6,
                  3,NA,
                  4,12),
                ncol=2,
                byrow=T)
## Make the imputation cartoon
png("../media/04.2-ConservativeImputation.png",height=300,width=800)
par(cex=2,mar=c(4,4,1,1))
eventPlot(fakedata)
dev.off()

########################
## Nearest neighbour imputation
testcols=c("ts",
           "orig_ip_bytes","resp_ip_bytes",
           "orig_pkts","resp_pkts")

## Make a sensible space for a concept of a neighbour
testdata_all_scaled <- apply(conndataM[,testcols], 2, scale)
testindices=!is.na(conndataM[,"duration"])
completedata=conndataM[testindices,]
testdata_all.svd=svd(testdata_all_scaled[testindices,])

## Allow mapping into the space
mapIntoSVD=function(X,svd){
    Dinv=diag(1/svd$d)
    X %*% svd$v %*% Dinv
}
## Put data into the space
test=mapIntoSVD(testdata_all_scaled[testindices,],testdata_all.svd) # the data used to make the space, for testing
newpos=mapIntoSVD(testdata_all_scaled[!testindices,],testdata_all.svd) # the rest of the data

# RANN is a library that allows some useful neighbour estimation algorithms
if(!require("RANN")) install.packages("RANN")
library("RANN")
## make the nearest neighbourhood for each new point
nnres=nn2(test[,1:3],newpos[,1:3],k=5)

## Impute records via their 5-neighourhood
imputedduration=apply(nnres$nn.idx,1,function(x){
    mean(completedata[x,"duration"])
})

## Put that into the data frame
imputeddataNN=conndataM
imputeddataNN[is.na(conndataM[,"duration"]),"duration"]=imputedduration
imputeddataNN[,"logduration"]=log(imputeddataNN[,"duration"])

## Plot the duration results
tdataNN=imputeddataNN[imputeddataNN[,"logduration"]<log(1200),]
lm3=lm(logduration~proto+service +ts +id.resp_p+day,
       data=tdataNN)
ts3=summary(lm3)
cor(ts1$coefficients[-1,1],ts2$coefficients[-1,1])
cor(ts1$coefficients[-1,1],ts3$coefficients[-1,1])
cor(ts3$coefficients[-1,1],ts2$coefficients[-1,1])

png("../media/04.2-NNImputation.png",
    height=500,width=800)
par(xpd=TRUE)
plot(ts1$coefficients[-1,1],
     ts3$coefficients[-1,1],type="n",
     xlab="Coefficient (available case)",
     ylab="Coefficient (NN imputed)",bty="n")
abline(v=0,h=0,col="grey")
text(ts1$coefficients[-1,1],
     ts3$coefficients[-1,1],
     rownames(ts1$coefficients[-1,]))
dev.off()

## Plot the observed against the predicted data for all data points
lm1pred=predict(lm1,newdata=conndataM)
plot(exp(conndataM[,"logduration"]),exp(lm1pred),
     log="xy")
abline(a=0,b=1)
## Conclusion: it is far from great...

## Examine the duration missingness as a function of protocol
library("knitr")
mtab=table(data.frame(
    missingduration=is.na(conndataM[,"duration"]),
    proto=conndataM[,"proto"]))
kable(apply(mtab,2,function(x)x/sum(x)))
## Not missing at random

#############################
#############################
#############################
# Extra stuff:
## This section didn't make it into the workshop

## Testing for long durarions by making 3 different models using different link functions.
conndataM[,"longduration"]=conndataM[,"duration"]>=0.011
lm2=lm(longduration~proto+service +ts +id.resp_p,data=conndataM)
lm2pred=predict(lm2,newdata=conndataM)
longpred2=cbind(longduration=conndataM[,"longduration"],
                pred=lm2pred)

lm3 <- glm(longduration ~proto+service +ts +id.resp_p,
           family=binomial(link='logit'),data=conndataM)
lm3pred=predict(lm3,newdata=conndataM)
longpred3=cbind(longduration=conndataM[,"longduration"],
                pred=lm3pred)

longpredlist2=lapply(c(0,1),function(x)
    longpred2[longpred2[,"longduration"]==x,"pred"])
names(longpredlist2)=c("short","long")

longpredlist3=lapply(c(0,1),function(x)
    longpred3[longpred3[,"longduration"]==x,"pred"])
names(longpredlist3)=c("short","long")

## Making performance curves
## ROC curves are essential, we cover them in workshops
library("pROC")
roc2=roc(longduration~pred,data=as.data.frame(longpred2))
roc3=roc(longduration~pred,data=as.data.frame(longpred3))

plot(1-roc2$specificities,roc2$sensitivities,type="l",
     xlab="False Positive Rate",ylab="True Positive Rate")
lines(1-roc3$specificities,roc3$sensitivities,col=2)
legend("bottomright",c("lm(longduration~.)","glm(longduration~.),link=\"logit\""),
       text.col=1:2,bty="n")

boxplot(longpredlist3)

## Make this good
thist2=hist(conndataM[conndataM[,"duration"]<1200,"duration"],breaks=101)
thist3=hist(conndataM[conndataM[,"duration"]<1,"duration"],breaks=101)

plot(thist$mids,thist$density,log="y",type="b",
     xlab="duration",ylab="histogram density")
plot(thist2$mids,thist2$density,log="y",type="b",
     xlab="duration",ylab="histogram density")

table(conndataM[,"duration"]<0.011)
