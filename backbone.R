# contents of vistagdata for shiny

# a function to load necessary packages
loadpackages <- function()
{
  loaddata <- lapply(c("dplyr","ggplot2","reshape2","RCurl"),suppressPackageStartupMessages(require),character.only=T)
  rm(loaddata)
}
loadpackages()

# pad a integer vector on left or right to get a desired length
pad <- function(integerVector,finalLength,padwith=0,side=1)
{
  ifelse(finalLength>=length(integerVector),
         appendLength <- finalLength-length(integerVector),
         stop('finalLength is smaller than length of integerVector')
        )
  
  if(appendLength>0)
    {
      ifelse(side==1,
        returnVector <- c(integerVector,rep(padwith,appendLength)),
        returnVector <- c(rep(padwith,appendLength),integerVector)
            )
    }
  else
    {
      returnVector <- integerVector    
    }
  returnVector
}

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
incdat_shiny <- function(csv,toclassify="object",weights=1)
{
  # sanity check on weights
  # check whether weights are numeric or integer
  if(class(weights)!='numeric' & class(weights)!='integer')
    {stop('class of weights vector should be either numeric or integer')}
  # checks whether the weights are non-negative
  if(any(weights<0))
    {stop('weights should be non-negative')}
  
  dat <- csv %>% longdat_shiny(toclassify=toclassify)
  # get inclusion df based on 'toclassify'
  ifelse(toclassify=="object",
         incd <- dcast(dat,object~tag),
         incd <- dcast(dat,tag~object))
  incd[is.na(incd)] <- 0         # set NA's to 0
  rowNames <- incd[,1]     
  incd <- incd[,-1]              # and delete it
  
  # set 'num' to length of number of tags/objects
  if(toclassify=='object')
  {
    # length of tags
    num <- longdat_shiny(csv)[,2] %>% unique %>% as.character %>% length
  }
  else
  {
    # length of objects
    num <- longdat_shiny(csv)[,1] %>% unique %>% as.character %>% length
  }
  
  # pad the weights
  w <- pad(integerVector=weights,finalLength=num,padwith=1)
  
  # inclusion matrix with weights
  incd <- apply(as.matrix(incd),1,function(x){x*w}) %>% t
  rownames(incd) <- rowNames
  incd
}

# kmeans clustering takes incdata
kmcluster_shiny <- function(csv,toclassify="object",nc=0,ns=50,elbow=15,weights=1)
{
  dat <- csv %>% incdat_shiny(toclassify=toclassify,weights=weights)
  
  ifelse(toclassify=="object",
         maxclusters <- longdat_shiny(csv)[,1] %>% unique %>% as.character %>% length, 
         maxclusters <- longdat_shiny(csv)[,2] %>% unique %>% as.character %>% length)
  
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
    
	# vector with change in variance
    varper <- sapply(2:maxclusters,variancefun) %>% ppchange
    nc <- ifelse(length(which(!varper>elbow))==0,
                 na.omit(varper) %>% as.numeric %>% length,
                 which(!varper>elbow)[1])
  }
  
  suppressMessages(kmeans(x=as.matrix(dat),centers=nc,nstart=10)) %>% return
}
