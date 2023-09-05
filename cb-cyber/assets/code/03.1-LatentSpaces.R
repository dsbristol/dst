################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/03.html

## Examples of SVD/PCA for cyber security

################################
## Read the data
source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

## Make a 4 column dataset and log-transform
testdata=conndata[,c("orig_bytes","resp_bytes",
                     "orig_ip_bytes","resp_ip_bytes")]
testdata[testdata=="-"]=0
testdata[testdata=="0"]=0
for(i in 1:4) testdata[,i]=log10(as.numeric(testdata[,i])+1)
rownames(testdata)=NULL

## Make a test dataset for example purposes
set.seed(1)
myindex=sample(1:dim(testdata)[1],2000)
testdata_sample=testdata[myindex,]
## And categories, for plotting purposes
testdatacat=as.factor(paste(conndata[,"proto"],
                            conndata[,"service"],sep="_"))[myindex]

## The direct (naive) way to standardize
testdata_scaled <- apply(testdata_sample, 2, scale)

## But we need to standardize *samples*
testdata_t=t(testdata_scaled)
testdata_t_scaled <- apply(testdata_t, 2, scale)

## Different ways to compute Spectral decompositions
testdata.cov <- cov(testdata_t_scaled) # Make a 2000 x 2000 covariance matrix
testdata.eigen <- eigen(testdata.cov) # Eigen-decomposition
testdata.cov.svd <- svd(testdata.cov) # SVD

# Faster: SVD on the original data matrix
testdata.svd <- svd(testdata_t_scaled)
testdata.prcomp <- prcomp(testdata_t_scaled)

## Version where everything is scaled correctly
png("../media/03.1.1-EigenExample.png",height=500,width=800)
par(mfrow=c(1,3))
plot(testdata.eigen$vectors[,1],
     testdata.eigen$vectors[,2],xlab="PC1",ylab="PC2",main="eigen(cov(X))$vectors",
     col=as.numeric(testdatacat),pch=19)
plot(-testdata.cov.svd$u[,1],
     -testdata.cov.svd$u[,2],xlab="-PC1",ylab="PC2",main="svd(cov(X))$u",
     col=as.numeric(testdatacat),pch=19)
plot(-testdata.svd$v[,1],
     -testdata.svd$v[,2],xlab="-PC1",ylab="-PC2",main="svd(X)$v",
     col=as.numeric(testdatacat),pch=19)
dev.off()

## Version where we do not scale
testdata.direct.svd <- svd(testdata_scaled)
png("../media/03.1.2-SVDscaling.png",height=500,width=800)
par(mfrow=c(1,2))
plot(-testdata.direct.svd$u[,1],
     -testdata.direct.svd$u[,2],
     xlab="-PC1",ylab="-PC2",main="svd(Xraw)$u",
     col=as.numeric(testdatacat),pch=19)
plot(-testdata.svd$v[,1],
     -testdata.svd$v[,2],xlab="-PC1",
     ylab="-PC2",main="svd(X)$v",
     col=as.numeric(testdatacat),pch=19)
dev.off()

## Now we know how to scale things, lets apply it to the entire dataset

testdata_all_scaled <- apply(testdata, 2, scale)
dim(testdata_all_scaled)
## [1] 226943      4
testdata_all.svd=svd(testdata_all_scaled)

## Categories for plotting
testdatacat_all <-
    as.factor(paste(conndata[,"proto"],
                    conndata[,"service"],sep="_"))

## Plot for the larger SVD
png("../media/03.1.3-SVDlarger.png",height=500,width=800)
par(mfrow=c(1,2))
plot(testdata_all.svd$u[,1],
     testdata_all.svd$u[,2],
     xlab="PC1",ylab="PC2",main="svd(X)$u (226943 datapoints)",
     col=as.numeric(testdatacat_all),pch=19,cex=0.5)
plot(-testdata.direct.svd$u[,1],
     -testdata.direct.svd$u[,2],xlab="-PC1",
     ylab="-PC2",main="svd(X)$u (2000 datapoints)",
     col=as.numeric(testdatacat),pch=19,cex=0.5)
dev.off()

## What are the eigenvalues?
round(testdata.eigen$values[1:4],8)
round(((testdata.svd$d)^2)/3,8) 
## Identical 

## Plotting the eigenvalues
png("../media/03.1.4-VarianceExplained.png",height=500,width=800)
par(cex=1.5)
plot(c(1,4),c(0,1),ylim=c(0,1),xlim=c(1,4),xlab="PC",ylab="Proportion of variance explained",type="n")
lines((testdata_all.svd$d^2)/sum(testdata_all.svd$d^2))
lines((testdata.direct.svd$d^2)/sum(testdata.direct.svd$d^2),col=2)
lines((testdata.svd$d^2)/sum(testdata.svd$d^2),col=3)
legend("topright",legend=c("All data, SVD(X)","Small data, SVD(X)","Small data, SVD(cov(standardized X))"),lty=1,col=1:3)
dev.off()

###############
## prcomp does the same thing as eigen:
testdata.cov.prcomp <- prcomp(testdata.cov)
testdata_all.prcomp <- prcomp(testdata_all_scaled)
round(colMeans(testdata_scaled),digits=10)
apply(testdata_scaled,2,sd)

## Save the data for the 03.2 code
save(testdata.direct.svd,testdata_all.svd,
     testdata_all_scaled,testdatacat_all,
     file="LatentSpacesOutput.RData")
