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
      
      # choose the number of centers by numerical input box
      numericInput("nc", 
                   label = "Number of Clusters", 
                   value = 0),
      helpText("(0 to automaticlly detect the number of clusters)"),
      
      # choose the percentage for elbow criterion by slider input
      sliderInput("el", 
                   label = "Elbow Sensitivity", 
                   max=20,min=1,value=15),
      p("--------------------------------------------------------------------------"),
      a("code on github",href="https://github.com/talegari/clustering-tagged-data")
),
    mainPanel(
     
      plotOutput('myplot'),
      
      h3("Clusters( in table form)"),
      p("------------------------------------------------------------------------------------------------------------------------------------------------"),
      tableOutput('clusterinfo'),
            
      h3("Objects"),
      tableOutput('objects'),
      
      h3("Tags"),
      tableOutput('tags'),
      
      h3("Data"),
      helpText("First row represents objects and corresponding columns contain their respective tags"),
      tableOutput('data'),
      
      h2("How does it work"),
      p("------------------------------------------------------------------------------------------------------------------------------------------------"),
      "** The purpose is to find the clusters in tagged data. The data displayed gives the format of tagged data",
      a('(Download CSV file)',href='http://google.com'),
      br(),
      p("** You may explore the default data or upload your datain the above format. There is a radio button to swap the "),code("uploaded")," and ",code("default")," data. The default data examines some characteristics of animals. Please do not take this data seriously.",
      p("** Tagged data comprises of objects and their tags. "),code("To cluster")," radio button gives the option to cluster either objects or tags.",
      p(),
      "** The number of cluster is defaults to 0, where the app selects the the nunber of clusters by",a("Elbow criterion",href="https://en.wikipedia.org/wiki/Determining_the_number_of_clusters_in_a_data_set#The_Elbow_Method"),
      ".When number of clusters is set to 0, 'Elbow Sensitivity' may be changed. 'Elbow Sensitivity' measures percentages change in the ratio of 'between sum of squares' and 'total sum of squares' to decide the optimal number of clusters. Lower 'Elbow Sensitivity' usually results in higher number of clusters.",
      p("** Number of tags/objects not contained in the other is used as a distance measure for clustering objects/tags."),
      p("------------------------------------------------------------------------------------------------------------------------------------------------"),
      "Code for the App is hosted on ",a("github",href="https://github.com/talegari/clustering-tagged-data"),
      br(),
      "App is based on",a("analyzing tagged data project",href="https://github.com/talegari/analyzing-tagged-data"),
      p("------------------------------------------------------------------------------------------------------------------------------------------------")
    )
  )
))
