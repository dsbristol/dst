################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/04.html

## Examples of non-parametric statistics for cyber security

## Read the data
source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

## Check how much data there is
hist(conndata$ts,breaks=24*60)

## Structuring data for Fourier transform (slow)
conndata_ts=data.frame(t=seq(min(conndata$ts),max(conndata$ts),by=1),x=0)
for(i in 1:dim(conndata)[1]){
    conndata_ts[ceiling(conndata[i,"ts"]-conndata_ts[1,"t"]),"x"] =
            conndata_ts[ceiling(conndata[i,"ts"]-conndata_ts[1,"t"]),"x"] + 1
}

## Fourier transform
# Not fast unless length(x)=2^k
myx=1:(2^floor(log2(dim(conndata)[1]))) 
conndata_fft=fft(conndata_ts[1:2^16,"x"])

## conndata_ts=rbind(conndata_ts,
##                   cbind(t=max(conndata_ts[,1])+1:
##                         2^ceiling(log2(dim(conndata_ts)[1]))-dim(conndata_ts)[1],
##                         x=0))

## Make the FFT plot
png("../media/04.1.1-Nonparametics-fft.png",height=500,width=800)
par(mfrow=c(2,1))
plot(conndata_ts[,"x"],type="l",xlab="Time bin (second)",ylab="Count",main="a) Time domain")
plot(abs(conndata_fft)^2,log="y",xlab="FFT index",ylab="Power = abs(FFT)^2",main="b) Frequency domain")
dev.off()

## Making test data for Hadamard transform
testfft=abs(conndata_fft)[1001:2000]
testfft[-1]>testfft

## Hadamard transform
if(!require("rje"))install.packages("rje")
library("rje") # provides fastHadamard function
fastHadamard(rep(0,8))
fastHadamard(c(1,0,1,0,1,0,1,0))
fastHadamard(c(1,0,0,0,1,0,0,0))

## Apply this to conndata
conndata_wt=fastHadamard(conndata_ts[1:2^16,"x"]>0)
conndata_wt1=fastHadamard(conndata_ts[1:2^16,"x"]>1)
conndata_wt10=fastHadamard(conndata_ts[1:2^16,"x"]>10)

## Make the WH transform plot
png("../media/04.1.1-Nonparametics-wt.png",height=500,width=800)
par(mfrow=c(3,1))
plot(abs(conndata_wt),log="",xlab="WT index",ylab="abs(WT)",main="a) Walsh-Hadamard transform of x>0",pch=19)
plot(abs(conndata_wt1),log="",xlab="WT index",ylab="abs(WT)",main="b) Walsh-Hadamard transform of x>1",pch=19)
plot(abs(conndata_wt10),log="",xlab="WT index",ylab="abs(WT)",main="c) Walsh-Hadamard transform of x>10",pch=19)
dev.off()


#######################
## A manual implementation of the Fast Walsh-Hadamard Transform
## Which aids in understanding
fwht=function(a){
    ##In-place Fast Walsh-Hadamard Transform of array a
    ## Requires length of 2^m for an integer m
    h = 1
    m=0
    while(h < length(a)){
        for(i in seq(1,length(a),by=h*2)){
            for(j in seq(i,i+h-1)){
                x = a[j]
                y = a[j+h]
                a[j] = x + y
                a[j+h] = x - y
            }
        }
        h = 2*h
        m=m+1
    }
    return(a/2^(m/2))
}
## Apply to some test cases
fwht(rep(1,64))
fwht(rep(c(0,1),64))
fwht(rep(c(1,0),64))
fwht(rep(c(1,0,0,0),64)[1:64])
fwht(rep(c(0,0,0,1),64)[1:64])

#################
## Apply density estimates to the Spectral decomposition from 03.1

## NB Bad practice to replicate code like this...
testdata=conndata[,c("orig_bytes","resp_bytes",
                     "orig_ip_bytes","resp_ip_bytes")]
testdata[testdata=="-"]=0
testdata[testdata=="0"]=0
for(i in 1:4) testdata[,i]=log10(as.numeric(testdata[,i])+1)
rownames(testdata)=NULL
testdata_all_scaled <- apply(testdata, 2, scale)
dim(testdata_all_scaled)
## [1] 226943      4
testdata_all.svd=svd(testdata_all_scaled)

## We need a grid of target locations at which we'll estimate the density
Xseq <- seq(-0.035, 0.0046, length.out=50)
Yseq <- seq(-0.009, 0.02, length.out=50)
Grid <- expand.grid(Xseq, Yseq)

## Get the Kernel density estimate for a range of bandwidths
hlist=c(0.0002,0.001,0.002,0.005,0.01,0.1)
kdelist=lapply(hlist,function(h){
    mykde <- kde(testdata_all.svd$u[,1:2], Grid, h)
    mykdem=matrix(mykde,nrow=length(Xseq),ncol=length(Yseq))
})

## Plot the KDE
png("../media/04.1.2-Nonparametrics-kdeDensityEst.png",height=500,width=800)
par(mfrow=c(2,3))
for(i in 1:6){
    image(Xseq,Yseq,log(1+kdelist[[i]]),
          xlab="PC1",ylab="PC2",
          main=paste("kde Density estimator, h=",
                     hlist[i]))
    points(testdata_all.svd$u[,1:2],pch=19,
           cex=0.5,col="#00000022")
}
dev.off()

## Repeat but insisting that only unique data are retained
## Note that however well this may or may not work, it is rather arbitrary in meaning!
kdelist2=lapply(hlist,function(h){
    mykde <- kde(unique(testdata_all.svd$u)[,1:2], Grid, h)
    mykdem=matrix(mykde,nrow=length(Xseq),ncol=length(Yseq))
})

## Plot the KDE for unique data
png("../media/04.1.2-Nonparametrics-kdeDensityEstUnique.png",height=500,width=800)
par(mfrow=c(2,3))
for(i in 1:6){
    image(Xseq,Yseq,log(1+kdelist2[[i]]),
          xlab="PC1",ylab="PC2",
          main=paste("kde Density estimator, h=",
                     hlist[i]))
    points(testdata_all.svd$u[,1:2],pch=19,
           cex=0.5,col="#00000022")
}
dev.off()

##############################################
## 4.1.2

## The TDA library provides knnDE
## NB TDA = Topological Data Analysis which does much more than this. Its a mine of interesting mathematical ideas for data analysis.
library("TDA")

## Scan over the number of Neighbours
klist=c(1,5,10,50,100,500)
knnlist=lapply(klist,function(k){
    KNN <- knnDE(testdata_all.svd$u[,1:2], Grid, k)
    KNNm=matrix(KNN,nrow=length(Xseq),ncol=length(Yseq))
})


## Plot the K-nearest Neighbour density estimat
png("../media/04.1.2-Nonparametrics-knnDensityEst.png",height=500,width=800)
par(mfrow=c(2,3))
for(i in 1:6){
    image(Xseq,Yseq,log(knnlist[[i]]),
          xlab="PC1",ylab="PC2",
          main=paste("kNN Density estimator",
                     k=klist[i]))
    points(testdata_all.svd$u[,1:2],pch=19,
           cex=0.5,col="#00000022")
}
dev.off()

## Make a test dataset for example purposes
set.seed(1)
myindex=sample(1:dim(testdata)[1],2000)
testdata_sample=testdata[myindex,]
## And categories, for plotting purposes
testdatacat=as.factor(paste(conndata[,"proto"],
                            conndata[,"service"],sep="_"))[myindex]

## Now we do kernel PCA with kernlab
## We explore different kernels
if(!require("kernlab"))install.packages("kernlab")
library("kernlab")
kpcvanilla=kpca(~.,data=testdata_sample,kernel="vanilladot",kpar=list(),features=4)
kpc=kpca(~.,data=testdata_sample,kernel="rbfdot",kpar=list(sigma=0.02),features=4)
kpclaplace=kpca(~.,data=testdata_sample,kernel="laplacedot",kpar=list(),features=10)
kpcpoly=kpca(~.,data=testdata_sample,kernel="polydot",kpar=list(),features=10)

## Always wise to plot the eigenvalues
plot(kpc@eig)
plot(kpclaplace@eig)
plot(kpcpoly@eig)

## Plot the kernel PCA results
png("../media/04.1.3-Nonparametrics-kpca.png",height=500,width=800)
par(mfrow=c(2,2))
plot(rotated(kpcvanilla),col=as.integer(testdatacat),pch=19,
          xlab="1st Principal Component",ylab="2nd Principal Component",main="Vanilla")
plot(rotated(kpclaplace),col=as.integer(testdatacat),pch=19,
          xlab="1st Principal Component",ylab="2nd Principal Component",main="Laplace")
plot(rotated(kpc),col=as.integer(testdatacat),pch=19,
          xlab="1st Principal Component",ylab="2nd Principal Component",main="Radial")
plot(rotated(kpcpoly),col=as.integer(testdatacat),pch=19,
          xlab="1st Principal Component",ylab="2nd Principal Component",main="Polynomial")
dev.off()
