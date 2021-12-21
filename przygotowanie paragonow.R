# skrypt do przygotowania danych paragonowych, z dostepnych danych surowych

renv::init()

library(tidyverse)
library(readxl)


# pobieranie danych surowych za dostepne lata
dane = NULL
for (i in list.files("dane_surowe")){
  x = read.csv2(file.path("dane_surowe",i),) %>% select(Data = 1, NrParagonu =5 ,KodProduktu = 6, Ilosc = 8) 
  dane = bind_rows(x, dane)
}

# typowanie paragonow z min 2 szt.
ile_sztuk = dane %>% group_by(NrParagonu) %>% summarise(suma = sum(Ilosc))
wielosztuki = dane %>% left_join(ile_sztuk, by = "NrParagonu") %>% filter(suma > 1) %>% select(-suma)

# duplikowane paragnow ze wzgledu na ilosc szt danego indeksu
dane1 = uncount(wielosztuki, Ilosc)

# pobieranie danych o hierachii produktow
hierarchia = read_xlsx("hierarchia_produktow/HierarchiaProd.xlsx",sheet = 'listaModeli') %>% select(KodProduktu = 2, Departament = 11,Grupa = 12)

# wszystko z duzej
hierarchia_1 = as.data.frame(sapply(hierarchia, toupper))

# scalenie grupy i departamentu
hierarchia_2 = hierarchia_1 %>% mutate(Produkt = paste(Departament, ": ", Grupa)) %>% select(-Departament, - Grupa)
                        
# polaczenie paragonow i hierarchii
paragony_hierarchia = dane1 %>% left_join(hierarchia_2, by = "KodProduktu") %>% select(-KodProduktu)

# zapisanie CSV - jako plik wsadowy do aplikacji
write.csv(paragony_hierarchia, "paragony.csv",row.names = FALSE)

renv::snapshot()
