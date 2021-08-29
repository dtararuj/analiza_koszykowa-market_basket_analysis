# analiza_koszykowa2019

Skrypty przedstawiaja narzedzia potrzebne do przeprowadzenia analizy koszykowej w sieci sklepow detalicznych za rok 2019
- pierwszy plik to narzedzie do przetworzenia danych potrzebnych do uruchomienia skryptu,
- drugi plik to skrypt własciwy.

Poniżej przykładowe (wygenerowane w sposób losowy) dane jakie uzyskujemy:

a) wykres czestosci danego asortymentu we wszystkich paragonach spelniajacych kryterium analizy (tj. gdzie sa min. 2 transakcje)
![nazwa](https://raw.githubusercontent.com/dtararuj/analiza_koszykowa2019/master/obrazki/item1.jpg)

b) zestawienie kilku przykladowych reguł (x i y - to nazwy grup, ze wzgledu na poufnosc danych sa one ukryte)

|             lhs    | .                                                 |         ..            |         rhs                                       |                 support        |                 confidence    |                 coverage       |                 lift         |                 count              |
|--------------------|---------------------------------------------------|-----------------------|---------------------------------------------------|--------------------------------|-------------------------------|--------------------------------|------------------------------|------------------------------------|
|         [1]        |                 {xx}            |                 =>    |                 {yyy}    |                 0.002742604    |                 0.5938042     |                 0.004618702    |                 57.024770    |                 2741               |
|         [2]        |                 {x}    |                 =>    |                 {yy}            |                 0.002742604    |                 0.2633804     |                 0.010413092    |                 57.024770    |                 2741               |
|         [3]        |                 {x}            |                 =>    |                 {yy}            |                 0.001114652    |                 0.2413345     |                 0.004618702    |                 1.298169     |                 1114               |
|         [4]        |                 {x}    |                 =>    |                 {yy}            |                 0.002248315    |                 0.3204050     |                 0.007017105    |                 1.723499     |                 2247               |
|         [5]        |                 {xx}        |                 =>    |                 {yy            |                 0.002098227    |                 0.2586016     |                 0.008113747    |                 1.391051     |                 2097               |
|         [6]        |                 {xx}         |                 =>    |                 {yy}            |                 0.002185278    |                 0.2395525     |                 0.009122337    |                 1.288583     |                 2184               |


c) wykres prezentujace dwie glowne reguly, ktore wyklarowaly sie podczas analizy. 
![nazwa](https://raw.githubusercontent.com/dtararuj/analiza_koszykowa2019/master/obrazki/item2.jpg)
