################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/05.html

## Examples of non-parametric statistics for cyber security

## Read the data
source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")


conndataC=conndata[,c("service","duration","orig_bytes",
                      "resp_bytes","orig_ip_bytes","resp_ip_bytes")]
conndataC=conndataC[!apply(conndataC,1,function(x)any(x=="-")),]
for(i in c(2:6)) conndataC[,i]=log(1+as.numeric(conndataC[,i]))
for(i in c(1)) conndataC[,i]=as.factor(conndataC[,i])
conndataC[,"http"]=as.numeric(conndataC[,"service"]!="http")
conndataC=conndataC[,-1]

##################################
## This is a very manual way to make ROC curves
## See the solution using PRROC
## Its not much less manual but at least makes PR curves too

## Useful libraries: pROC is for making ROC (receiver-operator curives), whilst MASS is for classification algorithms
library("MASS")
library("pROC")

set.seed(1)
set1=sample(1:dim(conndataC)[1],3000)
train=conndataC[set1,]
test=conndataC[-set1,]

train0=train[,c("duration","resp_ip_bytes","http")]
test0=test[,c("duration","resp_ip_bytes","http")]

### Logistic
logisticmodel <- glm(http ~.,family=binomial(link='logit'),data=train)
logisticpred0 <- predict(logisticmodel,newdata=test,type='response')
logisticpred <- ifelse(logisticpred0 > 0.5,1,0)
logisticres=data.frame(truth=test$http,pred=logisticpred,pred0=logisticpred0)
logisticroc=roc(truth~pred0,data=as.data.frame(logisticres))

testm=cbind(test,pred=logisticpred0)
testm=testm[order(testm$pred),]
testm$rank=(1:dim(testm)[1])/dim(testm)[1]

png(file="../media/05.1-ClassificationScore.png",height=5*72,width=12*72)
plot(1-testm$rank,testm$pred,col=1+testm$http,pch=19,cex=0.2,
     xlab="Rank Order",
     ylab="Prediction score")
points((1-testm$rank)[testm$http==1],
       testm$pred[testm$http==1],
       col=(1+testm$http)[testm$http==1],
       pch=4)
abline(v=c(0.01,0.11,0.15))
dev.off()

### Linear Discriminant Analysis

ldamodel=lda(http~.,data=train)
ldapred0=predict(ldamodel,newdata=test,type='response')$posterior[,1]
ldapred <- ifelse(ldapred0 > 0.5,1,0)
ldares=data.frame(truth=test$http,pred=1-ldapred,pred0=1-ldapred0)
ldaroc=roc(truth~pred0,data=as.data.frame(ldares))

### Support Vector Machine
library(e1071)
svmmodel=svm(http~.,data=train,kernel="linear")
svmpred0=predict(svmmodel,newdata=test,type='response')
svmpred <- ifelse(svmpred0 > 0.5,1,0)
svmres=data.frame(truth=test$http,pred=svmpred,pred0=svmpred0)
svmroc=roc(truth~pred0,data=as.data.frame(svmres))

svmrmodel=svm(http~.,data=train,kernel="radial")
svmrpred0=predict(svmrmodel,newdata=test,type='response')
svmrpred <- ifelse(svmrpred0 > 0.5,1,0)
svmrres=data.frame(truth=test$http,pred=svmrpred,pred0=svmrpred0)
svmrroc=roc(truth~pred0,data=as.data.frame(svmrres))

## svmpmodel=svm(http~.,data=train,kernel="polynomial")
## svmppred0=predict(svmpmodel,newdata=test,type='response')
## svmppred <- ifelse(svmppred0 > 0.5,1,0)
## svmpres=data.frame(truth=test$http,pred=svmppred,pred0=svmppred0)
## svmproc=roc(truth~pred0,data=as.data.frame(svmpres))

## Some exploration: just show the number of support vectors
print(svmmodel)
print(svmrmodel)

png(file="../media/05.1-ClassificationROC_only.png",height=8*72,width=12*72)
par(mfrow=c(1,2))
for(xmax in c(1,0.05)){
    plot(1-logisticroc$specificities,logisticroc$sensitivities,type="l",
         xlab="False Positive Rate",ylab="True Positive Rate",xlim=c(0,xmax),col=2)
    lines(1-ldaroc$specificities,ldaroc$sensitivities,col=3)
    lines(1-svmroc$specificities,svmroc$sensitivities,col=4)
    lines(1-svmrroc$specificities,svmrroc$sensitivities,col=4,lty=2)
    abline(a=0,b=1)
    if(xmax==1){
        legend("bottomright",c("Logistic","LDA","SVM (linear)","SVM (radial)"),
               text.col=c(2,3,4,4),col=c(2,3,4,4),lty=c(1,1,1,2),bty="n")
    }
}
dev.off()


library("PRROC")

logisticpr<-pr.curve(logisticres$pred0[logisticres$truth==0],
             logisticres$pred0[logisticres$truth==1],
             curve=TRUE)
logisticroc2<-roc.curve(logisticres$pred0[logisticres$truth==0],
               logisticres$pred0[logisticres$truth==1],
               curve=TRUE)
ldapr<-pr.curve(ldares$pred0[ldares$truth==0],
                ldares$pred0[ldares$truth==1],
                curve=TRUE)
ldaroc2<-roc.curve(ldares$pred0[ldares$truth==0],
                   ldares$pred0[ldares$truth==1],
                   curve=TRUE)
svmpr<-pr.curve(svmres$pred0[svmres$truth==0],
             svmres$pred0[svmres$truth==1],
             curve=TRUE)
svmroc2<-roc.curve(svmres$pred0[svmres$truth==0],
               svmres$pred0[svmres$truth==1],
               curve=TRUE)
svmrpr<-pr.curve(svmrres$pred0[svmrres$truth==0],
             svmrres$pred0[svmrres$truth==1],
             curve=TRUE)
svmrroc2<-roc.curve(svmrres$pred0[svmrres$truth==0],
               svmrres$pred0[svmrres$truth==1],
               curve=TRUE)

png(file="../media/05.1-ClassificationROC_PR.png",height=8*72,width=12*72)
par(mfrow=c(1,3))
for(xmax in c(1,0.05)){
    plot(logisticroc2$curve[,2],logisticroc2$curve[,1],type="l",
         xlab="False Positive Rate",ylab="True Positive Rate",xlim=c(0,xmax),col=2)
    lines(ldaroc2$curve[,2],ldaroc2$curve[,1],col=3)
    lines(svmroc2$curve[,2],svmroc2$curve[,1],col=4)
    lines(svmrroc2$curve[,2],svmrroc2$curve[,1],col=4,lty=2)
    abline(a=0,b=1)
    if(xmax==1){
        legend("bottomright",c("Logistic","LDA","SVM (linear)","SVM (radial)"),
               text.col=c(2,3,4,4),col=c(2,3,4,4),lty=c(1,1,1,2),bty="n")
    }
}
plot(logisticpr$curve[,1],logisticpr$curve[,2],type="l",ylim=c(0,1),
     xlab="Recall",ylab="Precision",col=2,log="")
lines(ldapr$curve[,1],ldapr$curve[,2],col=3)
lines(svmpr$curve[,1],svmpr$curve[,2],col=4)
lines(svmrpr$curve[,1],svmrpr$curve[,2],col=4,lty=2)
lines(guesspr$curve[,1],guesspr$curve[,2],col=1)
legend("bottomright",c("Logistic","LDA","SVM (linear)","SVM (radial)","Guess"),
       text.col=c(2,3,4,4,1),col=c(2,3,4,4,1),lty=c(1,1,1,2,1),bty="n")
dev.off()

p=mean(logisticres$truth)
test=runif(length(logisticres$truth))
guesspr<-pr.curve(test[logisticres$truth==1],
                   test[logisticres$truth==0],
                   curve=TRUE)
################
## Simple plots for illustration
## Using 2 predictors only
### Logistic

logistic2dmodel <- glm(http ~.,family=binomial(link='logit'),data=train0)
logistic2dpred0 <- predict(logistic2dmodel,newdata=test0,type='response')
logistic2dpred <- ifelse(logistic2dpred0 > 0.5,1,0)
logistic2dres=data.frame(truth=test0$http,pred=logistic2dpred,pred0=logistic2dpred0)
logistic2droc=roc(truth~pred0,data=as.data.frame(logistic2dres))

### Linear Discriminant Analysis

lda2dmodel=lda(http~.,data=train0)
lda2dpred0=predict(lda2dmodel,newdata=test0,type='response')$posterior[,1]
lda2dpred <- ifelse(lda2dpred0 > 0.5,1,0)
lda2dres=data.frame(truth=test0$http,pred=lda2dpred,pred0=lda2dpred0)
lda2droc=roc(truth~pred0,data=as.data.frame(lda2dres))

### Support Vector Machine
library(e1071)
svm2dmodel=svm(http~.,data=train0,kernel="linear")
svm2dpred0=predict(svm2dmodel,newdata=test0,type='response')
svm2dpred <- ifelse(svm2dpred0 > 0.5,1,0)
svm2dres=data.frame(truth=test0$http,pred=svm2dpred,pred0=svm2dpred0)
svm2droc=roc(truth~pred0,data=as.data.frame(svm2dres))

svm2drmodel=svm(http~.,data=train0,kernel="radial")
svm2drpred0=predict(svm2drmodel,newdata=test0,type='response')
svm2drpred <- ifelse(svm2drpred0 > 0.5,1,0)
svm2drres=data.frame(truth=test0$http,pred=svm2drpred,pred0=svm2drpred0)
svm2drroc=roc(truth~pred0,data=as.data.frame(svm2drres))



make.grid = function(x, n = 75) {
  grange = apply(x, 2, range)
  x1 = seq(from = grange[1,1], to = grange[2,1], length = n)
  x2 = seq(from = grange[1,2], to = grange[2,2], length = n)
  ret=expand.grid(X1 = x1, X2 = x2)
  colnames(ret)=colnames(x)
  ret
}
traingrid = make.grid(train0[,1:2])

svm2dgrid0 = predict(svm2dmodel, traingrid)
svm2dgrid = svm2dgrid0>0

svm2drgrid0 = predict(svm2drmodel, traingrid)
svm2drgrid = svm2drgrid0>0

logistic2dgrid0 = predict(logistic2dmodel, traingrid)
logistic2dgrid = logistic2dgrid0>0

plot(traingrid, col = c("orange","cyan")[1+as.numeric(logistic2dgrid)], pch = 20, cex = .5) #,xlim=c(0,1),ylim=c(6,12))
points(train0[,1:2], col = c("red","blue")[train0[,3] + 1], pch = 19,cex=1)
#points(train0[logistic2dmodel$index,1:2], pch = 5, cex = 1)

plot(traingrid, col = c("orange","cyan")[1+as.numeric(svm2dgrid)], pch = 20, cex = .5)#,xlim=c(0,1),ylim=c(6,12))
points(train0[,1:2], col = c("red","blue")[train0[,3] + 1], pch = 19,cex=1)
#points(train0[svm2dmodel$index,1:2], pch = 5, cex = 1)

plot(traingrid, col = c("orange","cyan")[1+as.numeric(svm2drgrid)], pch = 20, cex = .5)
points(train0[,1:2], col = c("red","blue")[train0[,3] + 1], pch = 19,cex=1)
points(train0[svm2dmodel$index,1:2], pch = 5, cex = 1)

###
par(mfrow=c(1,2))
for(xmax in c(1,0.05)){
    plot(1-logistic2droc$specificities,logistic2droc$sensitivities,type="l",
         xlab="False Positive Rate",ylab="True Positive Rate",xlim=c(0,xmax),col=2)
    lines(1-lda2droc$specificities,lda2droc$sensitivities,col=3)
    lines(1-svm2droc$specificities,svm2droc$sensitivities,col=4)
    lines(1-svm2drroc$specificities,svm2drroc$sensitivities,col=4,lty=2)
    abline(a=0,b=1)
    if(xmax==1){
        legend("bottomright",c("Logistic","LDA","SVM (linear)","SVM (radial)"),
               text.col=c(2,3,4,4),col=c(2,3,4,4),lty=c(1,1,1,2),bty="n")
    }
}

##

misClasificError <- mean(logisticpred != test$http)
print(paste('Accuracy',1-misClasificError))


###############################
## Simulated examples for class

n=100;k=2;n0=n/2
set.seed(2)
x=data.frame(x1=runif(n),x2=rbeta(n,3,1))

simscore=function(x){
    ret=0.8+0.3*x[1]-0.6*x[2]+0.2*x[2]^2-0.3*x[1]^2
    ret[ret<0.5]=0
    ret[ret>0.5]=1
    return(ret)
}
corners=matrix(c(0,0,
                 0,1,
                 1,0,
                 1,1),ncol=2,byrow=T)
apply(corners,1,simscore)
y0=apply(x,1,simscore)
set.seed(2)
y=rbinom(n,1,y0)
xgrid = make.grid(x)

simtrain=x[1:n0,]
simtrain$y=y[1:n0]

simtest=x[n0+1:n0,]
simtest$y=y[n0+1:n0]

simmodelgrid0=apply(xgrid,1,simscore)
simmodelgrid=simmodelgrid0>0.5

## logistic regression
simlogisticmodel=glm(y ~.,family=binomial(link='logit'),data=simtrain)
simlogisticpred0=predict(simlogisticmodel,newdata=simtest,type='response')
simlogisticpred <- ifelse(simlogisticpred0 > 0.5,1,0)
simlogisticgrid0 = predict(simlogisticmodel, xgrid)
simlogisticgrid = simlogisticgrid0>0.5

## KNN
library("class")
simknnpred=knn(simtrain[,1:2], simtest[,1:2], simtrain$y, k = 5, prob=FALSE)
simknngrid=as.numeric(knn(simtrain[,1:2],xgrid,simtrain$y,k=5,prob=FALSE))-1
simknnpred=knn(simtrain[,1:2], simtrain[,1:2], simtrain$y, k = 5, prob=FALSE)

## lda regression
simldamodel=lda(y ~.,data=simtrain)
simldapred0=predict(simldamodel,newdata=simtest,type='response')$posterior[,2]
simldapred <- ifelse(simldapred0 > 0.5,1,0)
simldagrid0 = predict(simldamodel, xgrid)$posterior[,2]
simldagrid = simldagrid0>0.5

## svm
simsvmmodel=svm(y~., data=simtrain,kernel="linear")
## simsvmmodel_tune <- tune(svm, train.x=simtrain[,1:2],
##                          train.y=simtrain$y, 
##                          kernel="linear",
##                          ranges=list(cost=10^(-1:2),
##                                      gamma=c(.5,1,2)))
## simsvmmodel=svm(y~., data=simtrain,kernel="linear",
##                 cost=simsvmmodel_tune$best.parameters$cost,
##                 gamma=simsvmmodel_tune$best.parameters$gamma)
#tolerance=1e-8, kernel="linear",cost=10,scale=FALSE,shrinking=FALSE)
simsvmpred0=predict(simsvmmodel,newdata=simtest,type='response')
simsvmpred <- ifelse(simsvmpred0 > 0.5,1,0)
simsvmgrid0 = predict(simsvmmodel, xgrid)
simsvmgrid = simsvmgrid0>0.5


## svmr
simsvmrmodel=svm(y~., data=simtrain,kernel="radial")
simsvmrmodel_tune <- tune(svm, train.x=simtrain[,1:2],
                         train.y=simtrain$y, 
                         kernel="radial",
                         ranges=list(cost=10^(-1:2),
                                     gamma=c(.5,1,2)))
simsvmrmodel=svm(y~., data=simtrain,kernel="radial",
                cost=simsvmrmodel_tune$best.parameters$cost,
                gamma=simsvmrmodel_tune$best.parameters$gamma)
simsvmrpred0=predict(simsvmrmodel,newdata=simtest,type='response')
simsvmrpred <- ifelse(simsvmrpred0 > 0.5,1,0)
simsvmrgrid0 = predict(simsvmrmodel, xgrid)
simsvmrgrid = simsvmrgrid0>0.5

par(mfrow=c(2,3))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)

## LOGISTIC
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simlogisticgrid)], pch = 20, cex = .5,main="Logistic Regression")
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)

## KNN
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simknngrid)], pch = 20, cex = .5,main="K-Nearest Neighbours (K=5)")
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)

## LDA
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simldagrid)], pch = 20, cex = .5,main="Linear Discriminant Analysis (LDA)")
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)

## SVM
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simsvmgrid)], pch = 20, cex = .5,main="Support Vector Machine (SVM; Linear)")
points(simtrain[simsvmmodel$index,1:2], pch = 5, cex = 1.5)
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)

## SVM radial
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simsvmrgrid)], pch = 20, cex = .5,main="Support Vector Machine (SVM; Radial)")
points(simtrain[simsvmrmodel$index,1:2], pch = 5, cex = 1.5)
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)

######################
## Plots for class:
##pdf("../media/05.1-ClassificationTruth.pdf",height=6,width=6,bg="white")
png("../media/05.1-ClassificationTruth.png",height=6*72,width=6*72,bg="white")
par(mfrow=c(1,1))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
legend("bottomright",text.col=c("red","blue","red","blue") ,col=c("red","blue","red","blue"),pch=c(19,19,4,4),legend=c("Y=0 (train)","Y=1 (train)","Y=0 (test)","Y=1 (test)"))
dev.off()

############### Logistic
##pdf("../media/05.1-ClassificationLogistic.pdf",height=6,width=12,bg="white")
png("../media/05.1-ClassificationLogistic.png",height=6*72,width=12*72,bg="white")
par(mfrow=c(1,2))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
legend("bottomright",text.col=c("red","blue","red","blue") ,col=c("red","blue","red","blue"),pch=c(19,19,4,4),legend=c("Y=0 (train)","Y=1 (train)","Y=0 (test)","Y=1 (test)"))

## LOGISTIC
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simlogisticgrid)], pch = 20, cex = .5,main="Logistic Regression")
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
dev.off()

############### KNN
##pdf("../media/05.1-ClassificationKnn.pdf",height=6,width=12,bg="white")
png("../media/05.1-ClassificationKnn.png",height=6*72,width=12*72,bg="white")
par(mfrow=c(1,2))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
legend("bottomright",text.col=c("red","blue","red","blue") ,col=c("red","blue","red","blue"),pch=c(19,19,4,4),legend=c("Y=0 (train)","Y=1 (train)","Y=0 (test)","Y=1 (test)"))

## KNN
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simknngrid)], pch = 20, cex = .5,main="K-Nearest Neighbours (K=5)")
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
dev.off()


############### Lda
##pdf("../media/05.1-ClassificationLda.pdf",height=6,width=12,bg="white")
png("../media/05.1-ClassificationLda.png",height=6*72,width=12*72,bg="white")
par(mfrow=c(1,2))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
legend("bottomright",text.col=c("red","blue","red","blue") ,col=c("red","blue","red","blue"),pch=c(19,19,4,4),legend=c("Y=0 (train)","Y=1 (train)","Y=0 (test)","Y=1 (test)"))

## LDA
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simldagrid)], pch = 20, cex = .5,main="Linear Discriminant Analysis (LDA)")
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
dev.off()


############### SVM
##pdf("../media/05.1-ClassificationSvm.pdf",height=6,width=12,bg="white")
png("../media/05.1-ClassificationSvm.png",height=6*72,width=12*72,bg="white")
par(mfrow=c(1,2))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
legend("bottomright",text.col=c("red","blue","red","blue") ,col=c("red","blue","red","blue"),pch=c(19,19,4,4),legend=c("Y=0 (train)","Y=1 (train)","Y=0 (test)","Y=1 (test)"))

## SVM
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simsvmgrid)], pch = 20, cex = .5,main="Support Vector Machine (SVM; Linear)")
points(simtrain[simsvmmodel$index,1:2], pch = 5, cex = 1.5)
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
dev.off()


############### SVM
##pdf("../media/05.1-ClassificationSvmRadial.pdf",height=6,width=12,bg="white")
png("../media/05.1-ClassificationSvmRadial.png",height=6*72,width=12*72,bg="white")
par(mfrow=c(1,2))
## Truth
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Truth")
points(simtrain[,1:2], col = c("red","blue")[simtrain$y + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
legend("bottomright",text.col=c("red","blue","red","blue") ,col=c("red","blue","red","blue"),pch=c(19,19,4,4),legend=c("Y=0 (train)","Y=1 (train)","Y=0 (test)","Y=1 (test)"))

## SVM
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simsvmrgrid)], pch = 20, cex = .5,main="Support Vector Machine (SVM; Radial)")
points(simtrain[simsvmrmodel$index,1:2], pch = 5, cex = 1.5)
points(simtrain[,1:2], col = c("red","blue")[as.numeric(simtrain[,3]) + 1], pch = 19,cex=1)
points(simtest[,1:2], col = c("red","blue")[simtest$y + 1], pch = 4,cex=1)
dev.off()

#################################
## SVM illustration

simlogistictrain0=predict(simlogisticmodel,newdata=simtrain,type='response')
simlogistictrain <- ifelse(simlogistictrain0 > 0.5,1,0)

simtrain2=simtrain[simtrain$y==simlogistictrain,]
simlogistictrain2=simlogistictrain[simtrain$y==simlogistictrain]
v1=simtrain2[simlogistictrain2==1,][which.max(simtrain2[simlogistictrain2==1,2]),1:2]
v2=simtrain2[simlogistictrain2==0,][which.min(simtrain2[simlogistictrain2==0,2]),1:2]
tdata=as.data.frame(rbind(v1,v2))
tlm=lm(x2 ~ x1,data=tdata)$coeff

dist2d <- function(a,b,c) {
 v1 <- b - c
 v2 <- a - b
 m <- cbind(v1,v2)
 d <- abs(det(m))/sqrt(sum(v1*v1))
 d
}
margin2d <- function(tlm,margin) {
    cos(atan(tlm[2]/tlm[1]))*margin
}
sampleperfect=function(n,y,baseline,eps=c(0.1,0.1)){
    trylines=t(sapply(1:n,function(i){
        baseline+rnorm(2,0,eps)
    }))
    tscore=apply(trylines,1,function(x){
        tpred=(x[1]+x[2]*y[,1]<=y[,2])==0
        mean(tpred==y[,3])
    })
    res=trylines[tscore==1,,drop=FALSE]
    tmargin=apply(res,1,function(x){
        min(apply(y[,1:2],1,function(y)dist2d(y,
                                              c(0,x[1]),
                                              c(1,x[1]+x[2]) )))
    })
    list(res=res,
         margin=tmargin,
         best=res[which.max(tmargin),],
         bestmargin=max(tmargin),
         trylines=trylines,
         tscore=tscore)
}
simclass=sampleperfect(10000,simtrain2,tlm)

dist2d(c(0,1),
       c(0,0),
       c(1,1)
       )

toysvm=svm(y~.,data=simtrain2,kernel="linear",cost=10)
toysvmgrid0 = predict(toysvm, xgrid)
toysvmgrid = toysvmgrid0>0.5

##pdf("../media/05.1-ClassificationChoices.pdf",height=6,width=6,bg="white")
png("../media/05.1-ClassificationChoices.png",height=6*72,width=6*72,bg="white")
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Sampled Classifiers",type="n",ylim=c(0.5,1))
apply(head(simclass$res),1,function(x) abline(a=x[1],b=x[2],col="green"))
points(simtrain2[,1:2], col = c("red","blue")[simtrain2$y + 1], pch = 19,cex=1)
dev.off()

##pdf("../media/05.1-ClassificationSVMoptima.pdf",height=6,width=6,bg="white")
png("../media/05.1-ClassificationSVMoptima.png",height=6*72,width=6*72,bg="white")
plot(xgrid, col = c("orange","cyan")[1+as.numeric(simmodelgrid)], pch = 20, cex = .5,main="Maximum margin classifier",type="n",ylim=c(0.5,1))
abline(a=simclass$best[1],b=simclass$best[2])
abline(a=simclass$best[1]+tmargin,b=simclass$best[2],col="grey")
abline(a=simclass$best[1]-tmargin,b=simclass$best[2],col="grey")
points(simtrain2[,1:2], col = c("red","blue")[simtrain2$y + 1], pch = 19,cex=1)
dev.off()

##pdf("../media/05.1-ClassificationSVMnotworking.pdf",height=6,width=6,bg="white")
png("../media/05.1-ClassificationSVMnotworking.png",height=6*72,width=6*72,bg="white")
plot(xgrid, col = c("orange","cyan")[1+as.numeric(toysvmgrid)], pch = 20, cex = .5,main="SVM QP claimed solution",ylim=c(0.5,1))
points(simtrain2[,1:2], col = c("red","blue")[simtrain2$y + 1], pch = 19,cex=1)
dev.off()

tmargin=margin2d(simclass$best,simclass$bestmargin)
