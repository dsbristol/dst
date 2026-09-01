################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/02.html

## Examples of applied regression

library("knitr")

################################
## Read the data
data("mtcars")

################################
## Regression & Correlation session

## How to run a linear model
tlm=lm(mpg~hp,data=mtcars)
summary(tlm)

mtcarsl=log10(mtcars)
tlml=lm(mpg~hp,data=mtcarsl)
newdata=data.frame(hp=seq(50,max(mtcars$hp),length.out=10))
newdatal=log10(newdata)

## Make the EDA regression plot
png("../media/02.1.1-LinearRegressionNeedsEDA.png",height=400,width=700)
par(mfrow=c(1,2))
plot(mtcars[,c("hp","mpg")],xlab="Horsepower",ylab="Miles(US) gallon",main="a) Scatter plot (mtcars MPG~HP)")
lines(cbind(newdata$hp,
            predict(tlm,newdata=newdata)),
      col="blue")
plot(mtcarsl[,c("hp","mpg")],xlab="log10(Horsepower)",ylab="log10(Miles(US) gallon)",main="b) Log-scale Scatter plot (mtcars MPG~HP)")
lines(cbind(newdatal$hp,
            predict(tlml,newdata=newdatal)),
      col="blue")
dev.off()

## Correlation
conncor1=c(linear=cor(mtcars[,c("hp","mpg")])[1,2],
  log=cor(log10(mtcars[,c("hp","mpg")]))[1,2])
kable(conncor1)

## Correlation of a data frame
mtcars2=mtcars[,c('mpg','cyl','hp','wt')]
cormtcars2=cor(mtcars2)
kable(cormtcars2)

## Fancy Data Table with conditional color
library(DT)
library(RColorBrewer)
cuts=seq(-1,1,length.out=101)[-1]
colors=colorRampPalette(brewer.pal(9,'Blues'))(201)[50:150]
datatable(cormtcars2) %>%
  formatStyle(columns = rownames(cormtcars2), 
              background = styleInterval(cuts,colors))
## NB I had to screenshot this for the slides


###############################
## Regression

## Make an all-vs-all plot of the numeric features, annotated by automatic status
pairs(~mpg + cyl + hp + wt ,
      data=(mtcars2),
      col=mtcars$am,pch=4)

## Correlate numerical variables
cor(conndatasize2[,c(1:4,6:7)]) %>% round(digits=2) %>% kable

## Final linear models
## As discussed in the slides
lm(mpg ~ cyl + hp + wt,data=mtcars) %>% summary

