#getting the required R file from github repository
library("RCurl")
source("https://raw.githubusercontent.com/talegari/clustering-tagged-data/master/backbone.R")

shinyServer(function(input, output) {
      csvData <- reactive({
        switch(input$choosedata,
           "uploaded"=read.csv(input$file1$datapath,fill=T,colClasses='character'),
             "default"=read.csv(text=getURL("https://raw.githubusercontent.com/talegari/analyzing-tagged-data/master/taggeddataset.csv"),fill=T,colClasses='character'))
      })
      
      # display something to test
      #output$test <- renderText({csvData()})
      
      # display of data
      output$data <- renderTable({csvData()})
  
      # display of k means clustering
      output$myplot <- renderPlot({
        ko <- kmcluster_shiny(csvData(),toclassify=input$classify,nc=input$nc,elbow=input$el,weights=ws())
        mydat <- data.frame(names=names(sort(ko$cluster)),clustnums=sort(ko$cluster))
        rownames(mydat) <- NULL
        # plot part
        ggplot()+ geom_bar(data=mydat, aes(x=factor(names,levels=names),y=1), stat="identity",fill=factor(mydat$clustnums))+ coord_flip()+ geom_text(data=mydat, aes(x=factor(names,levels=names), y=1, label=names),color="white",hjust=1)+ labs(x="",y="")+ theme_bw()+ theme(axis.ticks = element_blank(), axis.text.x = element_blank(),axis.text.y = element_blank())
      })
      
      # display clusters as text
      output$clusterinfo <- renderTable({
        ko <- kmcluster_shiny(csvData(),toclassify=input$classify,nc=input$nc,elbow=input$el,weights=ws())
        df <- data.frame(name=names(ko$cluster),cluster_number=ko$cluster,row.names=NULL)
        sorted <- df[order(df$cluster_number),]
        rownames(sorted) <- NULL
        sorted
        })
      
      # display objects
      output$objects <- renderTable({
        objects <- longdat_shiny(csvData())[,1] %>% unique %>% as.character %>% sort
        data.frame(objects) %>% t
        })
      
      # display tags
      output$tags <- renderTable({
        tags <- longdat_shiny(csvData())[,2] %>% unique %>% as.character %>% sort
        data.frame(tags) %>% t
        })

      # create numeric input boxes for weights
      output$weightBoxes <- renderUI({
        if(input$includeWeights=='unequal')
          {
            if(input$classify=='object')
              {
              tags <- longdat_shiny(csvData())[,2] %>% unique %>% as.character %>% sort
                checkboxGroupInput("emph", "Select tags:",as.character(tags))
              }
            else
              {
                objects <- longdat_shiny(csvData())[,1] %>% unique %>% as.character %>% sort
                checkboxGroupInput("emph", "Select objects:",as.character(objects))
              }
          }
      })
      
      # check reactive status of includeWeights
      we <- reactive({ifelse(input$includeWeights=='equal',1,0)})
      
      # get weights from 'emph'
      ws <- reactive({
              if(we()==0)
                {
                  if(input$classify=='object')
                    {
                      tags <- longdat_shiny(csvData())[,2] %>% unique %>% as.character %>% sort
                      weightScore <- rep(1,length(tags))
                      names(weightScore) <- tags
                      weightScore[as.character(input$emph)] <- as.integer(input$exactWeight)
                    }
                  else
                    {
                      objects <- longdat_shiny(csvData())[,1] %>% unique %>% as.character %>% sort
                      weightScore <- rep(1,length(objects))
                      names(weightScore) <- objects
                      weightScore[as.character(input$emph)] <- as.integer(input$exactWeight)
                    }
                }
              else
                {
                  weightScore <- 1
                }
              return(weightScore)
          })
})