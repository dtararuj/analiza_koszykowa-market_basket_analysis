#apriori

install.packages(c("plyr","arules","arulesViz","tidyverse","knitr","readxl","ggplot2","lubridate"))

library(lubridate)
library(arules)
library(arulesViz)
library(tidyverse)
library(knitr)
library(readxl)
library(ggplot2)
library(plyr)

paragony2018<-paragony

#dane wejœciowe paragon; produkt  !mo¿na równie¿ te dane filtrowaæ wg daty 
##paragony2018_data<-cbind(paragony2018,select(separate(paragony2018,"PARAGON NR", into=c("nr","sklep","miesiac","rok"),sep="/"),"miesiac"))
## nr_miesiac<- "04"   ## numer miesi¹ca

#paragony2018_miesiac<-filter(paragony2018_data,miesiac==nr_miesiac) %>% select("PARAGON NR","Scalone")

#poni¿ej wykorzystuj¹c dane z dwóch lat lub wiêcej  

paragony2018<-as.data.frame(apply(paragony,2,toupper))
#ujednolici wszystie grupy i bêd¹ pisane z du¿ej litery


#sprawdzenie czy struktura danych jest odpowiednia
head(paragony2018)
str(paragony2018)

#stworzenie w³aœciwego uk³adu danych (czyli grupy produktowe z poszczegolnych min. podwójnych paragonów)
transactionData <- plyr::ddply(paragony2018,c("Paragon"),
                         function(df1)paste(df1$Produkt,
                                            collapse = ","))

#sama funkcja ddply, bez elementu function sortuje elementy w zbiorze, 
# element function - scala te elementy.

#usuwamy kolumnê, której nie potrzebujemy
dane<-transactionData[,2]


#teraz chcemy to zapisaæ jako csv, ka¿da transakcja do innej kolumny
write.csv(dane,"market_basket_transactions.csv", quote = FALSE, row.names = FALSE)

#wczytujemy dane
tr <- read.transactions('market_basket_transactions.csv', format = 'basket', sep=',')
tr


#podsumowanie co mamy w zbiorze
summary(tr)


#dajemy sobie jakieœ kolorki
if (!require("RColorBrewer")) {
  # install color package of R
  install.packages("RColorBrewer")
  #include library RColorBrewer
  library(RColorBrewer)
}

#tworzymy wykres czêœtoœci wystepowania danej grupy
itemFrequencyPlot(tr,topN=10,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")
##jakby nie dzia³a³y margiesy to uruchom: dev.off() i potem: par(mar=c(1,2,1,1))


#type="relative"  poka¿e podzia³ procentowo

#teraz wyznaczymy sobie g³ówne regu³y
reguly <- apriori(tr, parameter = list(supp=0.0001, conf=0.2,minlen=2, maxlen=2))

#items - iloœæ kategorii,
#transaction - iloœc paragonów,
#support ile transakcji danej kategorii w ca³oœci stanowi dana grupa, wskazuj¹c w powy¿szym zapytania oznacza, ¿e chcemy odfiltrowaæ te co mia³y mniej wyst¹pieñ
#confidence - z jakim min. prawdopodobienstwem wybierze kolejna rzecz
#minlen - jakie ma minimalne pary pokazywac, np 2 produkty (jeden zale¿ny od drugiego)
#maxlen - poka¿e regu³y o wskazanej maksymalnej d³ugoœci, czyli ten produkt wskazany jako maxlen, bedzie tym którym siê decyduje np, jako 2x


#najlepsze 10 regu³

inspect(reguly[1:10])

#lub wszystkie
inspect(reguly)

#im wy¿sze prawdopobieñstwo tym lepiej (confidence), czyli z jakim prawdopodobieñstwem ktoœ kupi równie¿ 2 produkt


#gdy chcemy zbadac co klient kupuje prze wybore np XX, w miejscu XX - podajemy nazwe grupy
XX.reguly <- apriori(tr, parameter = list(supp=0.001, conf=0.8),appearance = list(default="lhs",rhs="XX"))

#np. dla spodni
XX.reguly <- apriori(tr, parameter = list(supp=0.001, conf=0.1, maxlen=2),appearance = list(default="lhs",rhs="1_MÊ¯CZYZNA: SPODNIE"))


inspect(head(XX.reguly))

#gdy chcemy zbadaæ co klient kupuje równie¿ gdy kupuje XX
XX.reguly<-apriori(tr, parameter = list(supp=0.001, conf=0.8),appearance = list(lhs="XX",default="rhs"))

#dla przyk³adu spodnie 
XX.reguly<-apriori(tr, parameter = list(supp=0.001, conf=0.1),appearance = list(lhs="1_MÊ¯CZYZNA: SPODNIE",default="rhs"))

inspect(head(XX.reguly))

##graficzne przedstawienie

subRules<-reguly[quality(reguly)$confidence>0.25]
#wybór regu³ z prawdopodobieñstwem wy¿szym ni¿ 0.4

## wybór 10 najlepszych regu³ po prawdopodobieñstwie  
top10subRules <- head(subRules, n = 10, by = "confidence")

#wykres z interaktywn¹ opcj¹ wskazywania
plot(top10subRules, method = "graph",  engine = "htmlwidget")


