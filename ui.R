library(shiny)
####daty tylko dostepne w pliku wsadowym !!
### zalacz kilka plikow wsadowych
### wez pokaz wszystkie przyciski dopiero jak sie zaladuja dane

shinyUI(fluidPage(
  titlePanel(title =h2("Analiza koszykowa", align ='center')),
  sidebarLayout(
    sidebarPanel(
      # wgrywanie pliku
      fileInput("paragony",
                "Wgraj plik z lista paragonow", 
                accept = ".csv"),  # moze multiplefile
      # text pomocniczy
      helpText("Przeslij tylko paragony z min 2 szt.",
               br(),
               "Wymagany format: Data ('yyyy-mm-dd'), NrParagonu, Produkt"),
      
      # przyciski odswiezania raportu
      actionButton("run",label = "Oblicz"),
      actionButton("run1",label = "Wyswietl"),
      
      
      # zakres dat
      uiOutput("zakres_dat"),
      br(),
      p(HTML("<b> PARAMETRY TWORZENIA REGUL: </b>")),
      
      # poziom wsparcia reguly
      uiOutput("support"),
      
      # poziom confidence
      uiOutput("confidence"),
      
      # wybor ile regul ma wyswietlac
      uiOutput("ilosc_regul"),
      
      # sposob sortowania regul
      uiOutput("sortowanie"),
    
      # pobranie produktow z zaladowanego pliku
      uiOutput("produkt"),
      
      br(),
  
      #p("Parametry wykresu czestosci wystepowania:"),
      #numericInput("TopN",
      #            "Ilosc najpopularniejszych produktow",
      #             value = 15),
      width = 3),
    
    mainPanel(tabsetPanel(type="tabs",
                          tabPanel("Reguly", tableOutput("reguly"),
                                             visNetworkOutput("reguly_wykres")),
                          tabPanel("Wykres czestosci", plotOutput("frequency",width = "100%", height = "600px")),
                          tabPanel("Podsumowanie zbioru", verbatimTextOutput("summary")),
                          tabPanel("Objasnienia", verbatimTextOutput("Objasnienia"))
    )))))