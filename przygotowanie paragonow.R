#skrypt do przygotowania danych paragonowych, z dostepnych danych surowych


setwd("G:/studia/AI/apriori2019")
library(tidyverse)

#pobieranie danych surowych za dostepne lata
read.csv2("2019.csv",encoding="UTF-8",quote="")->X2019
read.csv2("Paragony 2018.csv",encoding="UTF-8",quote="")->X2018
read.csv2("Paragony 2017.csv",encoding="UTF-8",quote="")->X2017

#polaczenie danych w jedno
rbind(select(X2017, 5,6,8),select(X2018, 5,6,8),select(X2019, 5,6,8))->lista

#zmiana nazwy kolumn
colnames(lista)=c("PARAGON.NR","KOD.PRODUKTU","ILOSC")

#gdy chcemy filtrowaæ miesiace i robic szczegolowa analize dla danego okresu
#rbind(select(X2017,1, 5,6,8),select(X2018,1, 5,6,8),select(X2019, 1,5,6,8))->lista
## lista %>% separate(DATA, into=c("rok","miesi¹c","dzieñ"), sep="-") %>% filter(miesi¹c %in% c("08","09")) %>% select(4,5,6) -> lista

#trzeba jeszcze odfiltrowaæ reklamowki
lista[-grep(pattern="^KS", lista$KOD.PRODUKTU),]->new

#duplikowane paragnów po ilosci sztuk danego indeksu
new[rep(rownames(new), new$ILOSC),]  ->lista1 

#wybierz 1. z tych metod do pobrania kartoteki, w zaleznosci od wersji danych surowych
read.csv2("lista_produktow_opis.csv", sep="\t",encoding="UTF-8",quote="")->opis

## read.csv2("lista_produktow_opis.csv", sep=";",encoding="UTF-8",quote="")->opis
## read_delim("lista_produktow_opis.csv", delim=";",encoding="UTF-8",quote="")->opis
## read_delim("lista_produktow_opis.csv", delim=";")->opis


select(opis,1,ncol(opis)-3,ncol(opis)-4) %>% unite(Kategoria,Departament, Grupa, sep=": ")->opis1


#gotowe dane pod apriori
left_join(lista1,opis1, by=c("KOD.PRODUKTU"=colnames(opis1)[1])) %>% select(-2,-3) -> paragony 

#zmieniamy tylko nazwy kolumn
colnames(paragony)<-c("Paragon", "Produkt")
