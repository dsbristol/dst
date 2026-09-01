################################
## Author: Dan Lawson (dan.lawson@bristol.ac.uk)
## Licence: GPLv3
## See https://dsbristol.github.io/dst/coursebook/01.html

## Examples applying Exploratory Data Analysis

data("mtcars")

apply(mtcars,2,range)

png("../media/01.2_EDA_pairs.png",height=500,width=800)
pairs(mtcars[,1:5])
dev.off()

##########################
table(mtcars[,c("vs","gear")])

summary(mtcars[,1:5])
##########################
library("knitr") # nice way to display tables
kable(table(mtcars[,c("vs","gear")]))

combined = table(mtcars$cyl, mtcars$gear)
combined

png("../media/01.2_EDA_boxplot.png",height=500,width=800)
par(mfrow=c(1,2))
boxplot(mpg~cyl,data=mtcars,notch=TRUE,xlab="Cylinders",ylab="MPG",main="Cars MPG by cylinders")
barplot(combined, main = "Cars distribution by gears and cylinders", 
        xlab = "Number of Gears",
        ylab= "Frequency", 
        col = rainbow(3), 
        legend = rownames(combined))
dev.off()

png("../media/01.2_EDA_ecdf.png",height=500,width=800)
plot(ecdf(mtcars$mpg))
dev.off()

png("../media/01.2_EDA_hist.png",height=500,width=800)
par(mfrow=c(1,2))
hist(mtcars$mpg,breaks=4,xlab="MPG",main="")
hist(mtcars$mpg,breaks=10,xlab="MPG",main="")
dev.off()

png("../media/01.2_EDA_density.png",height=500,width=800)
par(mfrow=c(1,2))
plot(density(as.numeric(mtcars$mpg)),xlab="MPG",main="density, bw=1")
plot(density(as.numeric(mtcars$mpg),bw = 0.5),xlab="MPG",main="density, bw=0.5")
dev.off()

png("../media/01.2_EDA_scatter.png",height=500,width=800)
plot(mtcars[,"hp"],mtcars[,"drat"],xlab="Horsepower",ylab="Rear axle ratio",main="Cars scatterplot")
dev.off()

## Two views of the engine/gear features
plot(ecdf(sort(occupationalStatus)),xlab="Occupational status pairs",ylab="Cumulative Frequency")
abline(v=sum(occupationalStatus)/100)


##########################
##########################
##########################
##########################
##########################
