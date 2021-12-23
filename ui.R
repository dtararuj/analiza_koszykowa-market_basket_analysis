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
      
      # przyciski odswiezania raportu
      actionButton("run",label = "Oblicz"),
      actionButton("run1",label = "Wyswietl"),
      
      # text pomocniczy
      helpText("Przeslij tylko paragony z min 2 szt.",
               br(),
               "Wymagany format: Data ('yyyy-mm-dd'), NrParagonu, Produkt"),
      # zakres dat
      uiOutput("zakres_dat"),
      br(),
      p(HTML("<b> Parametry tworzenia regul </b>")),
      br(),
      # Wybor poziomu wsparcia reguly
      sliderInput("support",
                  "Minimalny poziom wsparcia reguly:",
                  min = 0.0001,
                  max = 0.2,
                  value = 0.002,
                  step = 0.0001),
      
      # Wybor poziomu wsparcia reguly
      sliderInput("confidence",
                  "Prawdop. dobrania jako druga szt.:",
                  min = 0.1,
                  max = 1,
                  value = 0.3,
                  step = 0.05),
      
      # wybor ile regul ma wyswietlac
      numericInput("ilosc_regul",
                   "Ile regul wyswietlic:",
                   value = 5),
      
      # sposob sortowania regul
      selectInput("sortowanie",
                   "Sortowanie regul wg:",
                   c("confidence","lift","support"),
                   selected = "confidence"),
      
      # pobranie produktow z zaladowanego pliku
      uiOutput("produkt"),
      
      br(),
  
      p("Parametry wykresu czestosci wystepowania:"),
      numericInput("TopN",
                   "Ilosc najpopularniejszych produktow",
                   value = 10),
      width = 3),
    
    mainPanel(tabsetPanel(type="tabs",
                          tabPanel("Reguly", tableOutput("reguly"),
                                             visNetworkOutput("reguly_wykres")),
                          tabPanel("Wykres czestosci", plotOutput("frequency",width = "100%", height = "600px")),
                          tabPanel("Podsumowanie zbioru", verbatimTextOutput("summary")),
                          tabPanel("Objasnienia", verbatimTextOutput("Objasnienia"))
    )))))