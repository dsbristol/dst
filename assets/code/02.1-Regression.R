
################################
## Read the data
source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

################################
## Regression & Correlation session

## Restrict to TCP
conndata2=conndata[conndata[,"proto"]=="tcp",]

## Make data frames of the number of packets and bytes in raw and logged form
tdf=conndata2[,c('orig_pkts','orig_ip_bytes')]
tdfl=log10(conndata2[,c('orig_pkts','orig_ip_bytes')]+1) ## A useful transformation for postiive data!

## How to run a linear model
tlm=lm(orig_ip_bytes~orig_pkts,data=tdf)
tlml=lm(orig_ip_bytes~orig_pkts,data=tdfl)

## Make a dataset for prediction
newdata=data.frame(orig_pkts=seq(1,100000,by=1000))
newdatal=log10(newdata+1)

## Make the EDA regression plot
png("../media/02.1.1-LinearRegressionNeedsEDA.png",height=400,width=700)
par(mfrow=c(1,2))
plot(tdf,xlab="Number of packets",ylab="Data volume",main="a) Scatter plot (conndata)")
lines(cbind(newdata$orig_pkts,
            predict(tlm,newdata=newdata)),
      col="blue")
plot(tdfl,log="",xlab="Number of packets (log scale)",ylab="Data volume (log scale)",main="b) Scatter plot (log scale) (conndata)")
lines(cbind(newdatal$orig_pkts,
            predict(tlml,newdata=newdatal)),
      col="blue")
dev.off()

## Correlation
conncor1=c(linear=cor(conndata2[,'orig_pkts'],conndata2[,'orig_ip_bytes']),
  log=cor(log(1+conndata2[,'orig_pkts']),log(1+conndata2[,'orig_ip_bytes'])))
library("knitr")
kable(conncor1)

## Make a dataframe that includes both directions of data transfer
conndatasize=conndata2[,c('orig_pkts','resp_pkts','orig_bytes','resp_bytes')]
conndatasize=conndatasize[!apply(conndatasize,1,function(x)any(x=="-")),]
for(i in 1:dim(conndatasize)[2])
    conndatasize[,i]=as.integer(conndatasize[,i])
cordatasize=cor(conndatasize)
kable(cordatasize)

## Make a heatmap of the correlation data
library(DT)
library(RColorBrewer)
cuts=seq(0,1,length.out=101)[-1]
colors=colorRampPalette(brewer.pal(9,'Blues'))(101)
datatable(cordatasize) %>%
  formatStyle(columns = rownames(cordatasize), 
              background = styleInterval(cuts[1:60],colors[1:61]))


###############################
## Regression

## First we want to make a wider dataset that includes new features: the service as a faactor and the average sizes
conndatasize2=conndata2[,c('orig_pkts','resp_pkts','orig_bytes','resp_bytes','service')]
conndatasize2=conndatasize2[!apply(conndatasize2,1,function(x)any(x=="-")),]
for(i in 1:4)
    conndatasize2[,i]=as.integer(conndatasize2[,i])
conndatasize2$orig_avg_size=conndatasize2$orig_bytes/conndatasize2$orig_pkts
conndatasize2$resp_avg_size=conndatasize2$resp_bytes/conndatasize2$resp_pkts
conndatasize2[,'service']=as.factor(conndatasize2[,'service'])
for(i in 1:4)
    conndatasize2[,i]=log(1+conndatasize2[,i])

## Make an all-vs-all plot of the numeric features, annotated by service
pairs(~orig_avg_size + orig_pkts +
          orig_bytes + resp_avg_size ,
      data=log(conndatasize2[,c(1:4,6:7)]),
      col=conndatasize2$service,pch=4)

## Correlate numerical variables
cor(conndatasize2[,c(1:4,6:7)]) %>% round(digits=2) %>% kable

## Final linear models
## As discussed in the slides
lm(orig_avg_size~resp_avg_size+orig_pkts+
       orig_bytes,data=conndatasize2) %>% summary
lm(orig_avg_size~resp_avg_size+orig_pkts+
       orig_bytes+service,data=conndatasize2) %>% summary

## Showing that  the resp_avg_size is hard to predict
lm(resp_avg_size~service,data=conndatasize2) %>% summary

lm(resp_avg_size~.,data=conndatasize2) %>% summary
lm(orig_avg_size~.,data=conndatasize2) %>% summary

