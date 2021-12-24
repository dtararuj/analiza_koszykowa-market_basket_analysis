Sys.setlocale("LC_ALL", "polish")
library(shiny)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(RColorBrewer)
library(arules)
library(arulesViz)
library(visNetwork) #for html widget


ui = shinyUI(fluidPage(
  titlePanel(title =h2("Analiza koszykowa", align ='center')),
  sidebarLayout(
    sidebarPanel(
      
      # wgrywanie pliku
      fileInput("paragony",
                "Wgraj plik/i z lista paragonow", 
                multiple = TRUE,
                accept = ".csv"),  
      
      # tekst pomocniczy
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
      
      # dobor produkt w celu wyznaczenia powiazan z tym produktem
      uiOutput("produkt"),
      
      br(),
      
      #p("Parametry wykresu czestosci wystepowania:"),
      #numericInput("TopN",
      #            "Ilosc najpopularniejszych produktow",
      #             value = 15),
      width = 3),
    
    mainPanel(
      tabsetPanel(
        type="tabs",
        tabPanel("Reguly", tableOutput("reguly"),
                 verbatimTextOutput("komunikat"),
                 visNetworkOutput("reguly_wykres")),
        tabPanel("Wykres czestosci", plotOutput("frequency",width = "100%", height = "600px")),
        tabPanel("Podsumowanie zbioru", verbatimTextOutput("summary")),
        tabPanel("Objasnienia", verbatimTextOutput("Objasnienia"))
      )))))


server = shinyServer(function(input, output, seasion){

# 1. pobieranie danych uzytkownika
zbior_paragonow = reactive({
  inFile <- input$paragony
  
  if(is.null(inFile)){
    return(NULL)
    
  }else{
    
  numfiles = nrow(inFile)
  pliki = NULL
  
  for (i in 1:numfiles){
    plik = read.csv(inFile[[i,'datapath']]) 
    
    if (ncol(plik) < 3){
      plik = read.csv2(inFile[[i,'datapath']]) 
    }
    pliki = bind_rows(plik %>% select(Data = 1, 2,3) %>% na.omit(), pliki)
    
  return(pliki)
  }}
})


# 2.Zdefiniowanie dynamicznych sliderow

## Wybor poziomu wsparcia reguly
output$support =  renderUI({
  
  if(is.null(grupy())){
    return()
  }else{
    sliderInput("support",
            "Minimalny poziom wsparcia reguly:",
            min = 0.0001,
            max = 0.2,
            value = 0.002,
            step = 0.0001)
  }
})

## wybor poziomu confidence
output$confidence =  renderUI({
  
  if(is.null(grupy())){
    return()
  }else{
    sliderInput("confidence",
                "Prawdop. dobrania jako druga szt.:",
                min = 0.1,
                max = 1,
                value = 0.3,
                step = 0.05)
  }
})

## wybor ile regul ma wyswietlac
output$ilosc_regul =  renderUI({
  
  if(is.null(grupy())){
    helpText(HTML("<i>Wgraj plik i kliknij Oblicz </i>")) 
  }else{
    numericInput("ilosc_regul",
             "Ile regul wyswietlic:",
             value = 5)
  }
})

## wybor sposobu sortowania regul
output$sortowanie =  renderUI({
  
  if(is.null(grupy())){
    return()
  }else{
    selectInput("sortowanie",
            "Sortowanie regul wg:",
            c("confidence","lift","support"),
            selected = "confidence")
  }
})

# 3. wywiltrowanie wlasciwego zakresu dat

## zdefiniowane poczatku i konca osi czasu
start = reactive({zbior_paragonow() %>% select(1) %>% pull() %>% min() })
end   = reactive({zbior_paragonow() %>% select(1) %>% pull() %>% max() })

## dynamiczny filtr dat
output$zakres_dat = renderUI({  
  
  if(is.null(zbior_paragonow())){
    return()
  }else{
  sliderInput("daty",
               "Wybierz zakres dat:", 
               min = as.Date(start(), "%Y-%m-%d"),
               max = as.Date(end(), "%Y-%m-%d"),
               value = c(as.Date(start()), as.Date(end())),
               timeFormat = "%Y-%m-%d")
}})

## odfiltorowanie dat poza zakresem 
paragony_w_okresie = reactive({
  start = as.character(input$daty[1])
  koniec = as.character(input$daty[2])
  zbior_paragonow() %>% filter(Data >= start & Data <= koniec )
  
})
  
# 3. przetworzenie danych do formatu zbioru transakcji
transakcje = reactive({

  # usuniecie kolumny z data  
  Paragony = paragony_w_okresie() %>% select(NrParagonu = 2, Produkt = 3)
  
  # przetworzenie danych do obiektu transactions
  write.table(Paragony, file = tmp <- file(), row.names = FALSE)
  trans <- read.transactions(tmp, format = "single",
                              header = TRUE, cols = c("NrParagonu", "Produkt"), rm.duplicates = FALSE)
  close(tmp)
  
  return (trans)
})

# 4. Lista rozwijana oparta na zaladowanym pliku z lista produktow

## lista dostepnych produktow
grupy = eventReactive(input$run,{
  
  grupy = paragony_w_okresie() %>% select(Produkt = 3) %>% arrange(Produkt) %>% unique() %>% pull()
})

## stworzenie listy rozwijanej
output$produkt = renderUI({

  if(is.null(zbior_paragonow())){
    return() 
  }else if(is.null(grupy())){
    helpText('Loading...')
  }else{
    
    selectInput("Produkt",
              "Reguly dla wybranego produktu:",
              choices = c("IGNORUJ",grupy()),
              selected = "IGNORUJ")
  }
})

# 5.Wyznaczenie reguł asocjacyjnych (podobienstw)
reguly = reactive({
  
  support = input$support
  confidence = input$confidence
  
  # co wybiera klient jako kolejny produktu w przypadku wyboru konkretnego produktu 
  lhs = input$Produkt
  
  if (lhs =="IGNORUJ"){
    apriori(transakcje(), parameter = list(supp=support, conf=confidence,minlen=2, maxlen=2))
  } else {
    apriori(transakcje(), parameter = list(supp=support, conf=confidence,minlen=2, maxlen=2), appearance = list(lhs= lhs))
  }
}) 

# 6. Wybor najmocniejszych regul po kliknieciu w przycisk
top_reguly = eventReactive(input$run1, {
  
  # parametry wyboru regul
  by = input$sortowanie
  n = input$ilosc_regul
  
  # odfiltrowany zbior regul
  head(reguly(), n, by = by)
})

# 6. Generacja wynikow

## prezentacja najmocniejszych regul w formie tabeli i wykresu

output$komunikat = renderPrint({
  if (is.null(zbior_paragonow())){
    cat("Instrukcja:", "\n",
        "1. Wgraj dane","\n",
        "2. Gdy dane  sie zaladuja kliknij 'Oblicz',","\n", 
        "3. Po chwili, gdy wyswietla sie wszystkie filtry, ustaw dowolnie parametry i kliknij 'Wyswietl'," ,"\n", 
        "W razie pojawienia sie bledow powtorz krok 2.")
}})


output$reguly = renderTable({
  if (is.null(top_reguly())){
    print("Poczekaj az zaladuja sie dane, kliknij oblicz, odczekaj chwile i kliknij wyswietl")
  }else{
    inspect(top_reguly())
  }
})

output$reguly_wykres =  renderVisNetwork({
  plot(top_reguly(), method = "graph",  engine = "htmlwidget")
})


## prezentacja wynikow summary zbioru paragonow
output$summary = renderPrint({
  summary(transakcje())
})

# prezentacja czestotliwosci wystepowania (udzial danego produktu w calosci)
output$frequency = renderPlot({
  
  #n = input$TopN   #jezeli chcialbym udostepnic uzytkownikowi modyfikacje tego parametru
  n = 15
  
  # ustawiamy marginesy
  #dev.off()
  #par(mar=c(1,2,1,1))
  
  # drukujemy wykres w ujeciu relatywnym
  itemFrequencyPlot(transakcje(),
                    topN=n,
                    type="relative",
                    col=brewer.pal(4,'Pastel1'),
                    main="Popularnosc produktow")
})

## obsjasnienie pojec i hasel
output$Objasnienia = renderPrint({
  cat("Slowniczek pojec:", "\n",
      "# items - ilosc kategorii produktowych,", "\n", 
      "# transaction - ilosc paragonow w zbiorze,", "\n", 
      "# support - udzial danej pary produktow we wszystkich paragonach,", "\n", 
      "# confidence - prawdopodobienstwo dobrania danego produktu jako druga rzecz na paragonie (jak często towar A jest kupowany z towarem B),", "\n", 
      "# lift - jak zakup produktu A wplywa od zakupu produktu B (o ile czesciej zostanie kupiony produkt B, po zakupie A)", "\n",
      "Mozemy mowic o zaleznosci jedynie przy lift > 1,", "\n",
      "# count - ilosc wystapien danej pary transakcji."
  )
})

})

# uruchomienie aplikacji
shinyApp(ui = ui, server = server)
