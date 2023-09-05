################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/03.html

#################################
## Examples of Clustering
## nb Run 03.1 first!

## Restore 03.1 content
load(file="LatentSpacesOutput.RData")

## Apply K-means with 1-10 centres on the SVD
km.all.svd=lapply(1:10,function(i){
    km=kmeans(testdata_all.svd$u,centers=i,nstart=10)
})

## Repeat but on the raw data
km.all.raw=lapply(1:10,function(i){
    km=kmeans(testdata_all_scaled,centers=i,nstart=10)
})

## A function to carefully compute entropy, accounting for edge cases where p=0 and hence p log(p) is ill-defined
getentropy=function(x,cat=testdatacat_all){
    testtab=table(data.frame(cluster=x,cat=as.numeric(cat)))
    sum(apply(testtab,1,function(x){x=x[x>0];p=x/sum(x);sum(p*log(p))}))
}
sapply(km.all.svd,function(x)getentropy(x$cluster))

##
ptab=testtab/rowSums(testtab)
bestassignment=apply(ptab,1,max)
apply(ptab,1,function(p){p=p[p>0];sum(p*log(p))})

## Applying Gaussian-Mixture-model fitting using "mclust"
library("mclust")
mc.direct=mclustBIC(testdata.direct.svd$u) # fast 
mc.all=mclustBIC(testdata_all.svd$u,G=1:20) # fast enough (several minutes)

## Plot the diagnostics provided
png(paste0("../media/03.2.1-Clustering_mclust_diagnostics.png"),
    height=500,width=800)
plot(mc.all)
dev.off()

## Extract the best assignments from each of the models
mc.assignments=lapply(1:20,function(i){
    tmp=mclustModel(testdata_all.svd$u,mc.all,G=i)
    apply(tmp$z,1,which.max)
})

## K-Nearest Neighbours density-based clustering
library("dbscan")
# Get the set of nearest neighbours
test=kNNdist(testdata_all.svd$u, k = 5)
# Get the minimum distance for each point, and plot it
testmin=apply(test,1,min) 
plot(sort(testmin[testmin>1e-8]),log="xy")
abline(h=0.001) # we chose
abline(h=0.01) # would give bigger clusters
abline(h=0.0001) # would give smaller clusters
## Plotting the distance to neighbours
kNNdistplot(testdata_all.svd$u, k = 5)
## Actually running dbscan using a threshold learned above
dbscanres=dbscan(testdata_all.svd$u,0.001)

png(paste0("../media/03.2.2-Clustering_kmeans_svd.png"),height=1000,width=1600)
par(mfrow=c(2,5))
for(i in 1:10){
    plot(testdata_all.svd$u[,1],
         testdata_all.svd$u[,2],xlab="",axes=F,
         ylab="",
         col=km.all.svd[[i]]$cluster,pch=19,cex=0.5)
    title(main=paste("K=",i),cex.main=2)
}
dev.off()

png(paste0("../media/03.2.3-Clustering_mclust_svd.png"),height=1000,width=1600)
par(mfrow=c(2,5))
for(i in 1:10){
    plot(testdata_all.svd$u[,1],
         testdata_all.svd$u[,2],xlab="",axes=F,
         ylab="",
         col=mc.assignments[[i]],pch=19,cex=0.5)
    title(main=paste("K=",i),cex.main=2)
}
dev.off()

png(paste0("../media/03.2.4-Clustering_kmeans_raw.png"),height=1000,width=1600)
par(mfrow=c(2,5))
for(i in 1:10){
    plot(testdata_all.svd$u[,1],
         testdata_all.svd$u[,2],xlab="",axes=F,
         ylab="",main=paste("K=",i),
         col=km.all.raw[[i]]$cluster,pch=19,cex=0.5)
}
dev.off()

png(paste0("../media/03.2.5-Clustering_dbscan_svd.png"),height=500,width=800)
    plot(testdata_all.svd$u[,1],
         testdata_all.svd$u[,2],xlab="",
         ylab="",main=paste("K=46 + noise"),
         col=c("#66666666",rainbow(46))[dbscanres$cluster+1],pch=19,cex=0.5)
dev.off()
