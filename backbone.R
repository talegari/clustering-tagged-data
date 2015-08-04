# contents of vistagdata for shiny

# a function to load necessary packages
loadpackages <- function()
{
  loaddata <- lapply(c("dplyr","ggplot2","reshape2","RCurl"),suppressPackageStartupMessages(require),character.only=T)
  rm(loaddata)
}
loadpackages()

# convert wide data to long data format

longdat_shiny <- function(csv,toclassify="object")
{ 
  
  dat <- csv
  
  # to return a df with object, tag and a value(1) column
  objtag <- melt(t(dat))[,c(1,3)]
  colnames(objtag) <- c("object","tag")
  objtag$value <- rep(1,dim(objtag)[1])    # for a later dcast
  
  # discard values of empty objects and empty tags
  objtag <- subset(objtag,objtag$tag!="")
  objtag <- subset(objtag,objtag$object!="")
  
  # ordering wrt 'toclassify'
  ifelse(toclassify=="object",               
         objtago <- order(objtag$object,objtag$tag),
         objtago <- order(objtag$tag,objtag$object))
  objtag <- objtag[objtago,]
  return(objtag)  
}

# get inclusion matrix from longdata
incdat_shiny <- function(csv,toclassify="object")
{
  
  dat <- csv %>% longdat_shiny
  # get inclusion df based on 'toclassify'
  ifelse(toclassify=="object",incd <- dcast(dat,object~tag),incd <- dcast(dat,tag~object))
  incd[is.na(incd)] <- 0         # set NA's to 0
  rownames(incd) <- incd[,1]     # set first column as rownames
  incd <- incd[,-1]              # and delete it
  return(incd)
}

# kmeans clustering takes incdata
kmcluster_shiny <- function(csv,toclassify="object",nc=0,ns=50,elbow=15)
{
  dat <- csv %>% incdat_shiny(toclassify=toclassify)
  
  ifelse(toclassify=="object",
         maxclusters <- csv %>% colnames %>% length, 
         maxclusters <- longdat_shiny(csv)[,2] %>% unique %>% length)
  
  if(nc==0)
  {
    
    ppchange <- function(vec) # percentage change
    {
      sapply(2:length(vec),function(x){((vec[x]-vec[x-1])/vec[x-1])*100})
    }
    
    variancefun <-  function(noc) # variance explained by kmeans
    {
      out <- tryCatch(
        {
          kmeansobj <- suppressMessages(kmeans(x=as.matrix(dat),centers=noc,nstart=ns))
          (kmeansobj$betweenss/kmeansobj$totss)*100
        },
      error=function(cond){return(NA)}
      ) # end of tryCatch
      return(out)
    } # end of variance fun
    
    varper <- sapply(2:maxclusters,variancefun) %>% ppchange
    nc <- ifelse(length(which(!varper>elbow))==0,
                 na.omit(varper) %>% as.numeric %>% length,
                 which(!varper>elbow)[1])
  }
  
  suppressMessages(kmeans(x=as.matrix(dat),centers=nc,nstart=10)) %>% return
}
