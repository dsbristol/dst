################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/02.html

## Examples applying statistical testing to cyber secirity data

################################
## Read the data
source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

###########
## 02.2.1-StatisticalTesting-ClassicalTesting

## Extract TCP and UDP packet sizes
tcpsize=conndata[conndata[,"proto"]=="tcp","orig_bytes"]
udpsize=conndata[conndata[,"proto"]=="udp","orig_bytes"]
ftpsize=conndata[conndata[,"service"]=="ftp","orig_bytes"]

## Convert and omit missing data
tcpsize=as.numeric(tcpsize[tcpsize!="-"])
udpsize=as.numeric(udpsize[udpsize!="-"])
ftpsize=as.numeric(ftpsize[ftpsize!="-"])
tcpsize=tcpsize[tcpsize>0]
udpsize=udpsize[udpsize>0]
ftpsize=ftpsize[ftpsize>0]

## Do the test
mu=mean(log(tcpsize))
t.test(log(udpsize),mu=mu)$p.value
t.test(log(ftpsize),mu=mu)$p.value

muudp=mean(log(udpsize))
t.test(log(ftpsize),mu=muudp)$p.value

## Plotting the histograms of sizes using standardized breakpoints
png("../media/02.2.1_Testing_histogram.png",height=500,width=800)
par(mfrow=c(3,1))
breaks=seq(-1,22,length.out=50)
hist(log(tcpsize),breaks=breaks)
abline(v=mu,col=2)
hist(log(udpsize),breaks=breaks)
abline(v=mu,col=2)
hist(log(ftpsize),breaks=breaks)
abline(v=mu,col=2)
dev.off()

############
## 02.2.2-StatisticalTesting-Empirical

## Permutation test example of permutations
set.seed(1)
n = 5
x = seq(0,20,length=n)
x
x[sample.int(n)]
x[sample.int(n)]

## Permutation test for size differences
tcpudp=c(tcpsize,udpsize)
n1=length(tcpsize)
n2=length(udpsize)
myteststatistic=function(x,n1,n2){
	mean(x[1:n1]) - mean(x[n1+(1:n2)])}
tobs=myteststatistic(tcpudp,n1,n2)
trep=sapply(1:10000,function(i){
	xrep=sample(tcpudp)
	myteststatistic(xrep,n1,n2)
})
mean(tobs<=trep)
# 0

png("../media/02.2.2_Testing_Permutation_TCPUDPdifference.png",height=500,width=800)
hist(tcpudpdiffs,breaks=101,xlab="Size Difference",ylab="Frequency",main="Permuting TCP-UDP difference")
abline(v=tcpudpdiff,col=2)
legend("topleft",legend=c("10000 permutations","Observation"),text.col=c(1,2))
dev.off()

## Comparing UDP and FTP
muudp=mean(log(udpsize))
t.test(log(ftpsize),mu=muudp)$p.value
## 0.003375621

muftp=mean(log(ftpsize))
t.test(log(udpsize),mu=muftp)$p.value
## 3.308383e-124

## Permutation test
set.seed(1)
ftpudp=c(ftpsize,udpsize)
n1=length(ftpsize)
n2=length(udpsize)
ftpudpobs=myteststatistic(ftpudp,n1,n2)
ftpudprep=sapply(1:10000,function(i){
	xrep=sample(ftpudp)
	myteststatistic(xrep,n1,n2)
})
mean(ftpudpobs<=ftpudprep)
## 0.3315

## Make the FTP/UDP comparison plot
png("../media/02.2.2_Testing_Permutation_FTPUDPdifference.png",height=500,width=800)
hist(ftpudpdiffs,breaks=101,xlab="Size Difference",ylab="Frequency",main="Permuting FTP-UDP difference")
abline(v=ftpudpdiff,col=2)
legend("topleft",legend=c("10000 permutations","Observation"),text.col=c(1,2))
dev.off()
