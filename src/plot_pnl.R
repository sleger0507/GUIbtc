plot_results(c("Dummy11_simon","Dummy12_simon","Dummy21_simon","Dummy22_simon"))


#library("plyr")
folder="/Users/simonleger/Documents/Code/Python/PycharmProjects/results/Logs"
#folder="/Users/Pierre/Documents/btc/Logs"

plot_results <- function(files,fold=folder,feesPercent=0.015){
  readDataPerso <- function(x){
    file_to_study=paste(fold,"/log_info_pf_",x,".csv",sep="")
    print(paste("analysing file",file_to_study))
    if(file.size(file_to_study)) 
    {
      dataFrame<-read.csv(file_to_study,sep=";")
      dataFrame$DTime <- strptime(paste(dataFrame$Day,dataFrame$Time), "%Y-%m-%d %H:%M:%OS")
      dataFrame$PnLNetFees <- dataFrame$PnL - feesPercent * dataFrame$Volume * dataFrame$AvgPrice / 100
      dataFrame<-split( dataFrame , f = dataFrame$Instrument )
    }
  }
  res <- lapply(files, readDataPerso )
  fullLength=length(res[[1]])
  m <- matrix(c(1:(4*fullLength),4*fullLength+1,4*fullLength+1,4*fullLength+1,4*fullLength+1),nrow = fullLength + 1,ncol = 4,byrow = TRUE)
  percentLegend=(1 - 1/(2*fullLength))/fullLength
  layout(mat = m,heights = c(rep(percentLegend,fullLength),1/(2*fullLength)))
  par(mar=c(2,1.5,1,1))
  #par( mfcol = c( length(res[[1]]) , 3 ))
  colors=c("brown","blue","black","red","green","yellow","purple","orange","pink")
  get_color <- function(i) {colors[i%%(length(colors) + 1) + 1]}
  if(length(res) < 1) return
  for (i in c(1:length(res[[1]])))
  {
    xaxis=c(min(res[[1]][[i]]$DTime),max(res[[1]][[i]]$DTime))
    PnLaxis=c(Inf,-Inf)
    Posaxis=c(Inf,-Inf)
    AvgPriceaxis=c(Inf,-Inf)
    Volaxis=c(Inf,-Inf)
    for (j in 1:length(res))
    {
      d=res[[j]][[i]]
      xaxis[1]=min(xaxis[1],d$DTime)
      xaxis[2]=max(xaxis[2],d$DTime)
      PnLaxis[1]=min(PnLaxis[1],d$PnLNetFees)
      PnLaxis[2]=max(PnLaxis[2],d$PnLNetFees)
      Posaxis[1]=min(Posaxis[1],d$NetPose)
      Posaxis[2]=max(Posaxis[2],d$NetPose)
      AvgPriceaxis[1]=min(AvgPriceaxis[1],d$AvgPrice)
      AvgPriceaxis[2]=max(AvgPriceaxis[2],d$AvgPrice)
      Volaxis[1]=min(Volaxis[1],d$Volume)
      Volaxis[2]=max(Volaxis[2],d$Volume)
    }
    
    d=res[[1]][[i]]
    plot (xaxis,PnLaxis,type="n", main = paste(names(res[[1]])[i],"PnL",sep='_'))
    lines(d$DTime,d$PnLNetFees,type="l",col=get_color(1))
    if(length(res) > 1)
    {
      for(j in c(2:length(res)))
      {
        d=res[[j]][[i]]
        lines(d$DTime,d$PnLNetFees,type="l",col=get_color(j))
      }
    }
    d=res[[1]][[i]]
    plot (xaxis,Posaxis,type="n", main = paste(names(res[[1]])[i],"Pos",sep='_'))
    lines(d$DTime,d$NetPose,type="l",col=get_color(1))
    if(length(res) > 1)
    {
      for(j in c(2:length(res)))
      {
        d=res[[j]][[i]]
        lines(d$DTime,d$NetPose,type="l",col=get_color(j))
      }
    }
    d=res[[1]][[i]]
    plot (xaxis,AvgPriceaxis,type="n", main = paste(names(res[[1]])[i],"avgPrice",sep='_'))
    lines(d$DTime,d$AvgPrice,type="l",col=get_color(1))
    if(length(res) > 1)
    {
      for(j in c(2:length(res)))
      {
        d=res[[j]][[i]]
        lines(d$DTime,d$AvgPrice,type="l",col=get_color(j))
      }
    }
    d=res[[1]][[i]]
    plot (xaxis,Volaxis,type="n", main = paste(names(res[[1]])[i],"Vol",sep='_'))
    lines(d$DTime,d$Volume,type="l",col=get_color(1))
    if(length(res) > 1)
    {
      for(j in c(2:length(res)))
      {
        d=res[[j]][[i]]
        lines(d$DTime,d$Volume,type="l",col=get_color(j))
      }
    }
  }
  plot(1, type = "n", axes=FALSE, xlab="", ylab="")
  legend(x = "top",inset = 0,
         legend = files, 
         col = get_color(c(1:length(res))), lwd=5, cex=.5, horiz = TRUE)
}