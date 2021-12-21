library(shiny)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(RColorBrewer)
library(arules)
library(arulesViz)
library(visNetwork) #for html widget

shinyServer(function(input, output){

# 1. pobieranie danych uzytkownika
zbior_paragonow = reactive({inFile <- input$paragony
  if(is.null(inFile))
    return(NULL)
  read.csv(inFile$datapath) %>% select(Data = 1, 2,3)
})

##TODO Daj opcje kilku plikow


# 2. wywiltrowanie wlasciwego zakresu
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


# 4.Wyznaczenie reguł asocjacyjnych (podobienstw)

reguly = reactive({
  
  support = input$support
  confidence = input$confidence
  
  
  apriori(transakcje(), parameter = list(supp=support, conf=confidence,minlen=2, maxlen=2))
  
}) 

# 5. Wybor najmocniejszych regul

top_reguly = reactive({
  
  # parametry wyboru regul
  by = input$sortowanie
  n = input$ilosc_regul
  
  # odfiltrowany zbior regul
  head(reguly(), n, by = by)
  
})


# prezentacja najmocniejszych regul
output$reguly = renderTable({
  inspect(top_reguly())
})

output$reguly_wykres = renderVisNetwork({
  plot(top_reguly(), method = "graph",  engine = "htmlwidget")
})


# prezentacja wynikow summary zbioru paragonow
output$summary = renderPrint({
  summary(transakcje())
  
})


# prezentacja czestotliwosci wystepowania (udzial danego produktu w calosci)
output$frequency = renderPlot({
  
  n = input$TopN
  
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


# obsjasnienie pojec i hasel
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



#moze jakis komunikat jaka jest ostatnia dostepna data, albo ta data znajduje sie poza zakresem ??