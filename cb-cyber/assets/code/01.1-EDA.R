################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/02.html

## Examples applying Exploratory Data Analysis to cyber secirity data

source("https://raw.githubusercontent.com/dsbristol/dst/master/code/loadconndata.R")

##########################
table(conndata2[,c("service","id.resp_p")])

##########################
library("knitr") # nice way to display tables
kable(table(conndata[,c("proto","service")]))

##########################
## Boxplot-like summary
mat <- cbind(Uni05 = (1:100)/21, Norm = rnorm(100),
	`5T` = rt(100, df = 5), Gam2 = rgamma(100, shape = 2))
summary(mat)

##########################
png("../media/01.2_EDA_boxplot.png",height=500,width=800)
boxplot(mat) # directly, calling boxplot.matrix()
dev.off()

##########################
ports=conndata[,"id.orig_p"]
png("../media/01.2-EDA_port_edf.png",height=500,width=800)
plot(sort(ports),1:length(ports)/length(ports),
  type="s",ylim=c(0,1),
  main = c("Port Frequency Visualisation"),
  sub=("Empiricial Cumulative Distribution Function"),
  xlab=c("Port Number"),ylab=c("cumulative fraction"))
dev.off()


##########################
library("knitr")
cyber=table(conndata[,c("proto","service")])
kable(cyber)

##########################
## Barplot
png("../media/01.2_EDA_barplot.png",height=500,width=800)
barplot(sort(1+cyber["tcp",],decreasing=T),
        log="y",col=rainbow(10),las=2)
dev.off()

##########################
## Segmented Barplot
cyber2=cyber[-1,-1]
png("../media/02_EDA_segmentedbarplot.png",height=500,width=800)
par(mfrow=c(1,2))
barplot(cyber2,legend=rownames(cyber2),las=2,
        col=c("red","blue"),log="",
        args.legend=list(x="topright"))
barplot(t(cyber2),legend=colnames(cyber2),
        col=rainbow(8))
dev.off()

##########################
chisq.test(cyber)
apply(cyber,2,chisq.test)

##########################
## gplots adds a scale and doesn't scale by default
library("gplots")
png("../media/01.2_EDA_heatmap2.png",height=500,width=800)
heatmap.2(log(1+cyber),margins =c(9,15),trace="none")
dev.off()

##########################
## datatable creates HTML version of data
library(DT)
cuts=c(1,50,200,1000,10000)
colors=c("white", "lightblue","blue","magenta","purple","red")
datatable(t(unclass(cyber))) %>%
  formatStyle(columns = rownames(cyber), 
              background = styleInterval(cuts,colors))
## You have to screenshot it to get the image
## in the slides.

##########################
## Histogram
tcpduration=conndata[conndata[,'proto']=="tcp",'duration']
tcpduration=tcpduration[tcpduration!="-"]
tcpduration=as.numeric(tcpduration)
png("../media/01.2_EDA_historgram.png",height=500,width=800)
hist(log(tcpduration),breaks=20,probability=TRUE,col="red")
dev.off()

##########################
matrix(head(sort(names(table(tcpduration))),12),
             nrow=3)
names(table(tcpduration)) %>% sort %>% head(n=12) %>% matrix(nrow=3)

##########################
## ECDF
ports=conndata[,"id.orig_p"]
## Manually:
#png("../media/02_EDA_port_edf.png",height=500,width=800)
plot(sort(ports),1:length(ports)/length(ports),
  type="s",ylim=c(0,1),
  main = c("Port Frequency Visualisation"),
  sub=("Empiricial Cumulative Distribution Function"),
  xlab=c("Port Number"),ylab=c("cumulative fraction"))
#dev.off()
## Easier:
plot(ecdf(ports))

##########################
## Survival
tecdf=ecdf(log(tcpduration)) ## tecdf is a function!
tx=sort(log(unique(tcpduration)))
tsurvival=data.frame(x=exp(tx),y=1-tecdf(tx))
png("../media/01.2_EDA_duration_survival.png",height=500,width=800)
plot(tsurvival,type="s",log="xy",
     xlab="Duration (Seconds)",
     ylab="Proportion as long or longer")
dev.off()


##########################
## Scatterplot
servicefactor=as.factor(conndata2[,'service'])
mycols=rainbow(length(levels(servicefactor)))
mycols[1]="#AAAAAAFF" # RRGGBBAA (Red Green Blue Alpha)
png("../media/01.2_EDA_scatterplot.png",height=500,width=800)
plot(conndata2[,'orig_pkts'],conndata2[,'orig_ip_bytes'],
     log="xy",pch=4,col=mycols[servicefactor],
     xlab="Number of packets of data",ylab="Total amount of data")
legend("bottomright",legend=levels(servicefactor),text.col=mycols)
dev.off()
