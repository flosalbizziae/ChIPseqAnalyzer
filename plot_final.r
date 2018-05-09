Args <- commandArgs()
featurelist<-Args[6]
files<-read.table(featurelist,header=F,sep="\t")
colnames(files)<-c("DIR","FEATURE","SAMPLE")
#for png plot
#w=1000
#h=500
#for postscript plot
w=10
h=3
lightblue='#66B2FF'
n_feature=length(files[,1])
postscript(paste(featurelist,".eps",sep=""),width=w, height=h)
#png(paste(featurelist,".png",sep=""),width=w, height=h)
plot(w,h, type='n', xaxt='n',yaxt='n',xlab='',ylab=paste('High Confident ',files[1,3],' Peaks',sep=''),xlim=c(0,w),ylim=c(0,h),xaxs="i",yaxs="i",mgp=c(1,1,0))
tck_vec<-c()
feature_vec<-c()
for(i in 1:n_feature){
	if(i>1){
		abline(v=(i-1)*(w/n_feature),lty=4,col=lightblue)
		
	}
	tck_vec[i]=(i-0.5)*(w/n_feature)
	feature_vec[i]=h*1.04
}
axis(1,at=tck_vec,labels=F,pos=0,tck=0.01)
lab_vc<-c(0,(tck_vec[2]-0.5*(w/n_feature)))
axis(1,at=lab_vc,labels=c("-50kb","+50kb"),pos=0,tck=0)
axis(3,at=tck_vec,labels=files$FEATURE,tck=0)

purple<-"#7171C6"
dis=50000
for(i in 1:n_feature){
	data<-read.table(as.character(files[i,1]),header=F,sep="\t")
    #n<-length(data[,1])
    n<-max(data[,1])
	y<-c()
	x<-c()
	for(j in 1:length(data[,1])){
        y[j]=data[j,1]*(h/n)
        #y[j]=j*(h/n)
		x[j]=tck_vec[i]+data[j,2]*(tck_vec[1]/dis)
	}
    #points(x,y,pch="-",cex=0.5,col=purple)
    points(x,y,pch=".",cex=0.5,col=purple)
}

dev.off()

