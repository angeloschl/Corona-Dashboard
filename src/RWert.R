### R-Wert vom RKI holen
### Immer nur die aktuelle Tabelle, die alten soll gelöscht werden.


suppressMessages(library(here))
suppressMessages(library(readxl))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))



url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen_csv.csv?__blob=publicationFile"
 

# Daten vom Server holen und in RKI_Impf_geladen schreiben
curl::curl_download(url, destfile = here("data/RKI_RWert/working/geladen.csv"))

#Achtung. Bei den Daten vom RKI wird das datum mit punkten getretnnt. 01.01.2021. Dass geht mit read_csv nicht. 
RKI_RWert_geladen <- suppressMessages(read_csv2(here("data/RKI_RWert/working/geladen.csv")))%>% 
  drop_na() %>% 
  mutate(Datum = as.Date(Datum, "%d.%m.%Y"))

RKI_RWert_alt <- suppressMessages(read_csv(here("data/RKI_RWert/working/RKI_RWert_heute.csv"))) %>% 
  drop_na() 



sind_gleich <- suppressMessages(all_equal(RKI_RWert_alt, RKI_RWert_geladen)) == TRUE




if (sind_gleich == TRUE) {
  file.remove(here("data/RKI_RWert/working/geladen.csv"))
  message("RKI_R-Wert: Keine Neuen Zahlen.")

}


if (sind_gleich == FALSE) {
  
  
  file.remove(here("data/RKI_RWert/working/RKI_RWert_heute.csv"))
  
  
  write.csv(
    RKI_RWert_geladen,
    here("data/RKI_RWert/working/RKI_RWert_heute.csv"),
    row.names = F)
  
  
  file.remove(here("data/RKI_RWert/working/geladen.csv"))
  
  
  # file.rename(
  #   here("data/RKI_RWert/working/geladen.csv"),
  #   here("data/RKI_RWert/working/RKI_RWert_heute.csv"))
  
  
  
  message("RKI_RWert: Neue Daten geladen.")
  
}