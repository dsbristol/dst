##
png("../media/09.1-Activation.png",height=800,width=1200)
par(mfrow=c(1,1),cex=3,mar=c(2,2,1,1))
x=seq(-10,10,by=0.05)
plot(c(-10,10),c(-0.2,4),type="n",xlab="",ylab="",axes=FALSE)
title(xlab="input y",ylab="output f(y)",line=0)
abline(h=0,lwd=2)
abline(v=0,lwd=2)
a1=function(x)(1+tanh(x))/2
a2=function(x)(1/(1+exp(-x)))
a3=function(x){ifelse(x<=0,0,1)}
a4=function(x){ifelse(x<=0,0,x/2.5)}
a5=function(x){x/(1+exp(-x/2))/2}
lines(x,a1(x),col=2,lwd=4)
lines(x,a2(x),col=3,lwd=4)
lines(x,a3(x),col=4,lwd=4)
lines(x,a4(x),col=5,lwd=4)
lines(x,a5(x),col=6,lwd=4)
legend("topleft",
       legend=c("tanh","logistic","step function","ReLU","Swish"),
       text.col=2:6,cex=1.5,lwd=4,lty=1,col=2:5,bty="n")
dev.off()

##a1a=function(x)(1/2+1/2*(exp(x)-exp(-x))/(exp(x)+exp(-x)))
