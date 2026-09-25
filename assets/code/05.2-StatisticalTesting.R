################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/05.html

#################################
## Figures for Lecture 05.2: Modern Machine Learning Testing
## Run from the "code" directory; figures are written to ../media/

library("randomForest")

set.seed(1)
col0=grey(0.5)
col1="#D62728"
colband="#DCE9F5"

#################################
## Figure 1: A Monte-Carlo test using a classifier as the test statistic
## Two samples with identical marginals (every feature is N(0,1))
## but different dependence: in sample 1, features 1 and 2 are correlated.

n=200 # per sample
p=5
X0=matrix(rnorm(n*p),ncol=p)
X1=matrix(rnorm(n*p),ncol=p)
X1[,2]=0.8*X1[,1] + sqrt(1-0.8^2)*X1[,2]
X=rbind(X0,X1)
y=factor(rep(0:1,each=n))

## Classical tests look at one feature at a time, and see nothing
ttest.p=apply(X,2,function(x) t.test(x[y==0],x[y==1])$p.value)
round(ttest.p,2)

## The test statistic: out-of-bag accuracy of a random forest.
## OOB predictions are out-of-sample, so no separate test set is needed.
Tstat=function(y,X) 1-tail(randomForest(X,y,ntree=200)$err.rate[,"OOB"],1)
T0=Tstat(y,X)
Tnull=replicate(199,Tstat(sample(y),X)) # permuting labels imposes H0
pval=(1+sum(Tnull>=T0))/(1+length(Tnull))

png("../media/05.2-MC-Classifier.png",height=5*72,width=12*72)
par(mfrow=c(1,2),mar=c(4.5,4.5,3,1),cex=1.2)
plot(X[,1],X[,2],pch=19,cex=0.7,col=ifelse(y==1,col1,col0),
     xlab="Feature 1",ylab="Feature 2",asp=1,
     main=sprintf("t-test p-values: %.2f, %.2f",ttest.p[1],ttest.p[2]))
legend("topleft",c("Sample 0","Sample 1"),pch=19,col=c(col0,col1),bg="white",cex=0.8)
hist(Tnull,breaks=seq(0.3,0.8,by=0.0125),col=grey(0.85),border="white",
     xlim=range(c(Tnull,T0,0.4,0.7)),xlab="Out-of-bag accuracy",
     main=sprintf("Permutation test: p = %.3f",pval))
abline(v=T0,col=col1,lwd=3)
text(T0,par("usr")[4]*0.9,"Observed",pos=2,col=col1)
dev.off()

#################################
## Figure 2: Testing after selection
## Under the null, choose the feature most correlated with y, then test it.
## Using the same data for both gives invalid p-values; splitting fixes this.

nsim=2000
n=100
p=50
psel=t(replicate(nsim,{
    X=matrix(rnorm(n*p),ncol=p)
    y=rnorm(n)
    half=1:(n/2)
    ## Naive: select and test on all the data
    best=which.max(abs(cor(X,y)))
    naive=cor.test(X[,best],y)$p.value
    ## Split: select on the first half, test on the second
    best=which.max(abs(cor(X[half,],y[half])))
    split=cor.test(X[-half,best],y[-half])$p.value
    c(naive=naive,split=split)
}))
colMeans(psel<0.05) # Type I error rates at the 5% level

png("../media/05.2-SelectionPvalues.png",height=5*72,width=12*72)
par(mfrow=c(1,2),mar=c(4.5,4.5,3,1),cex=1.2)
breaks=seq(0,1,by=0.05)
hist(psel[,"naive"],breaks=breaks,col=col1,border="white",xlab="p-value",
     main=sprintf("Select and test on same data\n%.0f%% rejected at 5%% level",
                  100*mean(psel[,"naive"]<0.05)))
abline(h=nsim/length(breaks[-1]),lty=2)
hist(psel[,"split"],breaks=breaks,col=grey(0.6),border="white",xlab="p-value",
     main=sprintf("Select on one half, test on the other\n%.0f%% rejected at 5%% level",
                  100*mean(psel[,"split"]<0.05)))
abline(h=nsim/length(breaks[-1]),lty=2)
dev.off()

#################################
## Figure 3: Split conformal prediction intervals around a random forest
## The noise increases with x, so a constant-width interval has 90% coverage
## on average, but not at every x.

alpha=0.1
simdata=function(n){
    x=runif(n,0,10)
    data.frame(x=x,y=sin(x)*3 + rnorm(n,0,0.2+0.3*x))
}
dat=simdata(1000)
test=simdata(5000)

## Split the data: fit the model on one half, calibrate on the other
idx=sample(nrow(dat))
tr=idx[1:500]; cal=idx[501:1000]
fit=randomForest(y~x,data=dat[tr,],nodesize=40)
s=abs(dat$y[cal]-predict(fit,dat[cal,]))        # conformity scores
q=sort(s)[ceiling((length(cal)+1)*(1-alpha))]   # conformal quantile

pred=predict(fit,test)
covered=abs(test$y-pred)<=q
mean(covered) # at least 1-alpha

## Coverage within bins of x
bins=cut(test$x,breaks=0:10)
bincover=tapply(covered,bins,mean)

png("../media/05.2-Conformal.png",height=5*72,width=12*72)
par(mfrow=c(1,2),mar=c(4.5,4.5,3,1),cex=1.2)
xg=data.frame(x=seq(0,10,length.out=400))
pg=predict(fit,xg)
plot(test$x[1:1000],test$y[1:1000],type="n",xlab="x",ylab="y",
     main=sprintf("90%% conformal interval: coverage %.1f%%",100*mean(covered)))
polygon(c(xg$x,rev(xg$x)),c(pg-q,rev(pg+q)),col=colband,border=NA)
points(test$x[1:1000],test$y[1:1000],pch=19,cex=0.4,
       col=ifelse(covered[1:1000],col0,col1))
lines(xg$x,pg,lwd=2,col="#1F4E79")
barplot(bincover,names.arg=1:10-0.5,col=grey(0.75),border="white",ylim=c(0,1),
        xlab="x (bin centre)",ylab="Coverage",main="Coverage is marginal, not conditional")
abline(h=1-alpha,col=col1,lwd=2,lty=2)
dev.off()

#################################
## Figure 4 (Portfolio 05.2.1): Towards conditional coverage
## Normalised (locally weighted) conformal: divide each residual by an estimate
## of its typical size, sigma(x), so the interval widens where noise is larger.

## sigma(x): a second forest, fitted to the out-of-bag absolute residuals
dat.tr=dat[tr,]
dat.tr$absres=abs(dat.tr$y-fit$predicted)
sfit=randomForest(absres~x,data=dat.tr,nodesize=40)

s.norm=abs(dat$y[cal]-predict(fit,dat[cal,]))/predict(sfit,dat[cal,])
q.norm=sort(s.norm)[ceiling((length(cal)+1)*(1-alpha))]

sig.test=predict(sfit,test)
covered.norm=abs(test$y-pred)<=q.norm*sig.test
mean(covered.norm)
bincover.norm=tapply(covered.norm,bins,mean)

png("../media/05.2.1-ConformalAdaptive.png",height=5*72,width=12*72)
par(mfrow=c(1,2),mar=c(4.5,4.5,3,1),cex=1.2)
sg=predict(sfit,xg)
plot(test$x[1:1000],test$y[1:1000],type="n",xlab="x",ylab="y",
     main=sprintf("Normalised conformal: coverage %.1f%%",100*mean(covered.norm)))
polygon(c(xg$x,rev(xg$x)),c(pg-q.norm*sg,rev(pg+q.norm*sg)),col=colband,border=NA)
points(test$x[1:1000],test$y[1:1000],pch=19,cex=0.4,
       col=ifelse(covered.norm[1:1000],col0,col1))
lines(xg$x,pg,lwd=2,col="#1F4E79")
barplot(rbind(bincover,bincover.norm),beside=TRUE,names.arg=1:10-0.5,
        col=c(grey(0.8),"#1F4E79"),border="white",ylim=c(0,1.15),
        xlab="x (bin centre)",ylab="Coverage",main="Coverage by region",
        legend.text=c("Standard","Normalised"),
        args.legend=list(x="top",horiz=TRUE,bty="n",cex=0.8))
abline(h=1-alpha,col=col1,lwd=2,lty=2)
dev.off()

#################################
## Figure 5 (Portfolio 05.2.1): How much calibration data?
## Conditional on the calibration set, the coverage of split conformal is
## random, with a Beta(n+1-l, l) distribution where l = floor((n+1)*alpha).

png("../media/05.2.1-ConformalCalibrationSize.png",height=5*72,width=8*72)
par(mar=c(4.5,4.5,3,1),cex=1.2)
cv=seq(0.7,1,length.out=1000)
ns=c(20,100,1000)
cols=c(grey(0.6),col1,"#1F4E79")
dens=sapply(ns,function(n){
    l=floor((n+1)*alpha)
    dbeta(cv,n+1-l,l)
})
matplot(cv,dens,type="l",lty=1,lwd=3,col=cols,xlab="Coverage on future data",
        ylab="Density",main="Coverage given one calibration set (target 90%)")
abline(v=1-alpha,lty=2)
legend("topleft",paste("n =",ns),lwd=3,col=cols,bty="n")
dev.off()
