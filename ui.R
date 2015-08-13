library(shiny)

shinyUI(fluidPage(
  titlePanel("Finding clusters in tagged data"),
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      
      # radio button for new input
      radioButtons("choosedata", label = "Choose the Dataset:",choices = list("default","uploaded"),selected ="default"),
      
      # radio button for object or tag
      radioButtons("classify", label = "To Cluster:",choices = list("object", "tag"),selected = "object"),
      
      # check box input for 'under the hood'
      checkboxInput("underTheHood",label ="Under the hood",value=FALSE),
      conditionalPanel(
        condition="input.underTheHood==true",
      # choose the number of centers by numerical input box
      numericInput("nc", 
                   label = "Number of Clusters", 
                   value = 0),
      helpText("(0 to automaticlly detect the number of clusters)"),
      
      # radio button to assign weights
      radioButtons("includeWeights", label = "Weights:",choices = list("equal", "unequal"),selected = "equal"),
      
      # conditional input if weights are unequal
      conditionalPanel(
        condition = "input.includeWeights=='unequal'",
        # choose the weight using slider input
        sliderInput("exactWeight", 
                    label = "Choose the value of Weight", 
                    max=100,min=2,value=2),
        uiOutput('weightBoxes')),
      
      # choose the percentage for elbow criterion by slider input
      sliderInput("el", 
                  label = "Elbow Sensitivity", 
                  max=20,min=1,value=15)
      ), # end of conditional input
      p("-------------------"),
      a("code on github",href="https://github.com/talegari/clustering-tagged-data")
),
    mainPanel(
     
      plotOutput('myplot'),
      
      h3("Clusters( in table form)"),
      p(),
      tableOutput('clusterinfo'),
            
      h3("Objects"),
      tableOutput('objects'),
      
      h3("Tags"),
      tableOutput('tags'),
      
      h3("Data"),
      helpText("First row represents objects and corresponding columns contain their respective tags"),
      tableOutput('data'),
      
      h2("How does it work"),
      p(),
      "** The purpose is to find the clusters in tagged data. The data displayed gives the format of tagged data",a('(Download CSV file)',href='http://google.com'),
      p(),
      "** You may explore the default data or upload your datain the above format. There is a radio button to swap the ",code("uploaded")," and ",code("default")," data. The default data examines some characteristics of animals. Please do not take this data seriously.",
      p(),
      "** Tagged data comprises of objects and their tags. ",code("To cluster")," radio button gives the option to cluster either objects or tags.",
      p(),
      "** Selecting ",code('Under the hood')," opens up the following options:",
      p(),
      "** The number of cluster is defaults to 0, where the app selects the the nunber of clusters by",a("Elbow criterion",href="https://en.wikipedia.org/wiki/Determining_the_number_of_clusters_in_a_data_set#The_Elbow_Method"),
      ".When number of clusters is set to 0, 'Elbow Sensitivity' may be changed. 'Elbow Sensitivity' measures percentages change in the ratio of 'between sum of squares' and 'total sum of squares' to decide the optimal number of clusters. Lower 'Elbow Sensitivity' usually results in higher number of clusters.",
      p(),
      "** Weight can be assigned to object/tag by selecting the respective check box and assigning the weight by moving the slider. Suppose while clustering objects in default data, we assign weight=3 to ",code('claw')," . It ends up putting ",code('cat')," and ",code('tiger')," in the same cluster(as opposed to the default ",code("kmcluster('taggeddataset.csv')")," where ",code('cat')," and ",code('tiger')," were in different clusters). The weights are associated with the tags(totally 12 in this default example) of the data. We give a weight of 3 to the first tag(which happens to be ",code('claw'),") and a default of 1 to the rest of the tags(1 is automatically padded at the end). As only ",code('cat')," and ",code('tiger')," share the common tag ",code('claw'),", the higher weight for ",code('claw')," over weighs other dissimilarities and puts them in the same cluster.",
      p(),
      p("** Number of tags/objects not contained in the other is used as a distance measure for clustering objects/tags."),
      p("---------------------------------------------------------"),
      "Code for the App is hosted on ",a("github",href="https://github.com/talegari/clustering-tagged-data"),
      br(),
      "App is based on",a("analyzing tagged data project",href="https://github.com/talegari/analyzing-tagged-data"),
      p("---------------------------------------------------------")
    )
  )
))