elink.call <-
function(class.ids,path.to.julia=getwd(),elink_path=system.file("exec",package = "PopR")){

 write.matrix(file='class_ids.csv',class.ids,sep=',')

  if (.Platform$OS.type == "unix")
    {
      exec=file.path(path.to.julia,'./julia')
  } else
    {
      exec=file.path(path.to.julia,'julia/julia.bat')
  }    
 
  command=paste(exec,file.path(elink_path,'elink.jl'),getwd())
  system(command)
  
  link <- read.csv("linkages.csv",header=F)
 # this shouldn't be necessary !
 # link <- link[order(link[,3]),]
  list(tree=link)
}
