################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/05.html

#################################
## Figures for Lecture 05.1: Anomaly Detection
## Run from the "code" directory; figures are written to ../media/

library("MASS")     # cov.rob, for the Minimum Covariance Determinant
library("e1071")    # svm, for the one-class SVM
library("isotree")  # isolation.forest
library("dbscan")   # kNN, fast nearest-neighbour search

set.seed(1)
col.normal=grey(0.5)
col.anom="#D62728"

#################################
## Figure 1: Point, contextual and collective anomalies

## (a) Point anomaly: a Gaussian blob with one far-away point
xa=cbind(rnorm(200),rnorm(200))
xa.anom=c(3.8,3.8)

## (b) Contextual anomaly: seasonal temperature, with a summer-like value in winter
weeks=1:156
temp=10 + 8*sin(2*pi*(weeks-13)/52) + rnorm(length(weeks),0,1.5)
temprange=range(temp)
tb.anom=which.min(temp[60:90])+59 # a week in the second winter
temp[tb.anom]=16

## (c) Collective anomaly: a periodic "heartbeat" signal that goes flat for a while
tc=1:400
beat=function(t) exp(-((t %% 25)-5)^2/2)*3 - exp(-((t %% 25)-9)^2/4)
sig=beat(tc) + 0.4*sin(2*pi*tc/25) + rnorm(length(tc),0,0.1)
flat=221:270
sig[flat]=0.3 + rnorm(length(flat),0,0.1)

png("../media/05.1-AD-Types.png",height=5*72,width=15*72)
par(mfrow=c(1,3),mar=c(4,4,3,1),cex=1.2)
plot(xa,pch=19,col=col.normal,xlab="Feature 1",ylab="Feature 2",
     xlim=c(-3,4.5),ylim=c(-3,4.5),main="(a) Point")
points(xa.anom[1],xa.anom[2],pch=19,col=col.anom)
points(xa.anom[1],xa.anom[2],cex=4,lwd=2,col=col.anom)

plot(weeks,temp,type="l",col=col.normal,xlab="Week",ylab="Temperature",
     main="(b) Contextual")
abline(h=temprange,lty=2)
points(tb.anom,temp[tb.anom],pch=19,col=col.anom)
points(tb.anom,temp[tb.anom],cex=4,lwd=2,col=col.anom)
text(0,temprange[2],"Global range",adj=c(0,1.5),cex=0.8)

plot(tc,sig,type="n",xlab="Time",ylab="Signal",main="(c) Collective")
rect(min(flat),par("usr")[3],max(flat),par("usr")[4],
     col=adjustcolor(col.anom,0.15),border=NA)
lines(tc,sig,col=col.normal)
lines(flat,sig[flat],col=col.anom,lwd=2)
dev.off()

#################################
## Figure 2: The general recipe as a flow diagram

png("../media/05.1-AD-Pipeline.png",height=4*72,width=15*72)
par(mar=c(0,0,0,0),cex=1.3)
plot(NA,xlim=c(0,15),ylim=c(0,4),axes=FALSE,xlab="",ylab="")
boxes=list("Data",
           expression(atop("Model of normal",hat(f))),
           expression(atop("Score",s(x))),
           expression(atop("Threshold",s(x)>tau)),
           "Flagged points",
           "Investigate")
bx=seq(1.25,13.75,length.out=length(boxes))
bw=0.95; by=2.6; bh=0.7
for(i in seq_along(boxes)){
    rect(bx[i]-bw,by-bh,bx[i]+bw,by+bh,
         col=ifelse(i==length(boxes),adjustcolor(col.anom,0.2),grey(0.93)),
         border=grey(0.3),lwd=2)
    text(bx[i],by,boxes[[i]])
    if(i<length(boxes)) arrows(bx[i]+bw,by,bx[i+1]-bw,by,length=0.12,lwd=2)
}
## Feedback loop from investigation back to the model
fy=0.9
segments(bx[6],by-bh,bx[6],fy,lwd=2,col=col.anom)
segments(bx[6],fy,bx[2],fy,lwd=2,col=col.anom)
arrows(bx[2],fy,bx[2],by-bh,length=0.12,lwd=2,col=col.anom)
text(mean(bx[c(2,6)]),fy,"Remove confirmed errors, refit",pos=1,col=col.anom)
dev.off()

#################################
## Figure 3: Comparing detectors on toy datasets
## An R version of scikit-learn's plot_anomaly_comparison.py:
## each dataset is 85% inliers plus 15% uniform outliers, and every method
## flags the 15% of training points with the highest anomaly scores.

n=300
contamination=0.15
n.out=round(n*contamination)
n.in=n-n.out

make_moons=function(n){
    n1=floor(n/2); n2=n-n1
    t1=runif(n1,0,pi); t2=runif(n2,0,pi)
    x=rbind(cbind(cos(t1),sin(t1)),cbind(1-cos(t2),0.5-sin(t2)))
    x+matrix(rnorm(2*n,0,0.05),ncol=2)
}
inliers=list(
    "Single Gaussian"=matrix(rnorm(2*n.in,0,0.5),ncol=2),
    "Two Gaussians,\ndifferent spread"=rbind(
        matrix(rnorm(2*floor(n.in/2),0,0.4),ncol=2)+2,
        matrix(rnorm(2*ceiling(n.in/2),0,1.2),ncol=2)-2),
    "Two moons"=4*(make_moons(n.in)-matrix(c(0.5,0.25),n.in,2,byrow=TRUE)),
    "Uniform"=matrix(14*(runif(2*n.in)-0.5),ncol=2)
)
datasets=lapply(inliers,function(x) rbind(x,matrix(runif(2*n.out,-6,6),ncol=2)))

## Local Outlier Factor, written out to match the slide definitions.
## Returns a scoring function so that it can be applied to new points (the grid).
lof_fit=function(X,k=20){
    nn=kNN(X,k)
    kdist=nn$dist[,k]
    lrd=function(id,d) 1/rowMeans(pmax(matrix(kdist[id],nrow(id)),d))
    lrd.train=lrd(nn$id,nn$dist)
    function(Z,train=FALSE){
        q=if(train) nn else kNN(X,k,query=Z)
        rowMeans(matrix(lrd.train[q$id],nrow(q$id)))/lrd(q$id,q$dist)
    }
}

## Each method takes the training data and returns a function that scores
## new points, with larger meaning more anomalous.
methods=list(
    "Robust covariance"=function(X){
        mcd=cov.rob(X,method="mcd")
        function(Z,train=FALSE) mahalanobis(Z,mcd$center,mcd$cov)
    },
    "One-class SVM"=function(X){
        fit=svm(X,type="one-classification",kernel="radial",
                nu=contamination,gamma=0.1)
        function(Z,train=FALSE)
            -as.numeric(attr(predict(fit,Z,decision.values=TRUE),"decision.values"))
    },
    "Isolation Forest"=function(X){
        fit=isolation.forest(X,ntrees=200,ndim=1,nthreads=1)
        function(Z,train=FALSE) predict(fit,Z)
    },
    "Local Outlier Factor"=function(X) lof_fit(X,k=20),
    "kNN distance"=function(X){
        k=10
        function(Z,train=FALSE){
            if(train) kNN(X,k)$dist[,k] else kNN(X,k,query=Z)$dist[,k]
        }
    }
)

gx=seq(-7,7,length.out=150)
grid=as.matrix(expand.grid(gx,gx))

png("../media/05.1-AD-Comparison.png",height=13*72,width=16*72)
par(mfrow=c(length(datasets),length(methods)),mar=c(0.5,0.5,0.5,0.5),
    oma=c(0,11,3,0))
for(i in seq_along(datasets)){
    X=datasets[[i]]
    for(j in seq_along(methods)){
        score=methods[[j]](X)
        s.train=score(X,train=TRUE)
        tau=quantile(s.train,1-contamination)
        s.grid=matrix(score(grid),length(gx))
        flagged=s.train>tau
        plot(NA,xlim=range(gx),ylim=range(gx),axes=FALSE,xlab="",ylab="",asp=1)
        .filled.contour(gx,gx,s.grid,levels=c(min(s.grid),tau,max(s.grid)),
                        col=c("#DCE9F5","white"))
        contour(gx,gx,s.grid,levels=tau,drawlabels=FALSE,add=TRUE,
                lwd=2,col="#1F4E79")
        points(X,pch=19,cex=0.7,col=ifelse(flagged,col.anom,col.normal))
        box(col=grey(0.6))
        if(i==1) mtext(names(methods)[j],side=3,line=0.5,cex=1.1)
        if(j==1) mtext(names(datasets)[i],side=2,line=1,cex=1.1,las=1,adj=1)
    }
}
dev.off()

#################################
## Figure 4: ROC versus Precision-Recall at 0.5% prevalence
## Scores from a hypothetical detector: normal ~ N(0,1), anomalies ~ N(2.5,1)

n.norm=20000
n.anom=100
s=c(rnorm(n.norm),rnorm(n.anom,2.5,1))
y=c(rep(0,n.norm),rep(1,n.anom))

o=order(s,decreasing=TRUE)
y.o=y[o]
tpr=c(0,cumsum(y.o)/n.anom)
fpr=c(0,cumsum(1-y.o)/n.norm)
precision=cumsum(y.o)/seq_along(y.o)
auc=sum(diff(fpr)*(head(tpr,-1)+tail(tpr,-1))/2)
ap=mean(precision[y.o==1])
## Precision at the threshold that catches 80% of anomalies
i80=which(tpr[-1]>=0.8)[1]
p80=precision[i80]

png("../media/05.1-AD-ROCvsPR.png",height=6*72,width=12*72)
par(mfrow=c(1,2),mar=c(4.5,4.5,3,1),cex=1.2)
plot(fpr,tpr,type="l",lwd=2,xlab="False positive rate",ylab="True positive rate (recall)",
     main=sprintf("ROC: AUC = %.2f",auc),xaxs="i",yaxs="i")
abline(0,1,lty=2,col=col.normal)
points(fpr[i80+1],tpr[i80+1],pch=19,col=col.anom,cex=1.3)

plot(tpr[-1],precision,type="l",lwd=2,xlab="Recall",ylab="Precision",
     main=sprintf("Precision-Recall: AP = %.2f",ap),xlim=c(0,1),ylim=c(0,1),xaxs="i",yaxs="i")
abline(h=n.anom/(n.anom+n.norm),lty=2,col=col.normal)
text(0.02,n.anom/(n.anom+n.norm),"Base rate",adj=c(0,-0.5),col=col.normal)
points(tpr[i80+1],p80,pch=19,col=col.anom,cex=1.3)
segments(tpr[i80+1],p80,0.9,0.35,col=col.anom)
text(0.9,0.35,sprintf("80%% recall:\n%.0f%% of flags are false alarms",100*(1-p80)),
     adj=c(0.8,-0.2),col=col.anom,cex=0.9)
dev.off()
