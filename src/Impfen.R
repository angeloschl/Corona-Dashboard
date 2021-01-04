### Impfzahlen vom RKI ergänzen

library(here)
library(readxl)
library(janitor)
library(tidyverse)
library(plotly)



url = "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx;jsessionid=191B8B9B966E7F09BCCCF72ABE990854.internet081?__blob=publicationFile"



## Daten laden

# Überprüfen, ob heutiger Datensatz schon existiert.
is_in_dir <- !file.exists(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))

# Wenn heutiger Datensatz noch nich existiert, if befehl ausführen. Datensatz laden und überprüfen ober er aktuell ist in dem ermit den vorherigen Daten verglichen wird. ist er neu wird er umbenannt. ist er halt passiert nichts. 
if (is_in_dir) {
  # Neuen Daten laden
  curl::curl_download(url, destfile = here("data/RKI_Impf/working/geladen.xlsx"))
  
  RKI_Impf_geladen <- read_excel(here("data/RKI_Impf/working/geladen.xlsx"),sheet = 2)
  
  
  files <- list.files(here("data/RKI_Impf/working/")) %>%
    .[!. %in% "geladen.xlsx"] %>% # . Punkt steht in diesem Fall für files
    str_sort(decreasing = TRUE)
  
  
  # Vergleichen ob die der neu geladene Datensatz geladen.xlsx gleich mit den schon im Ordner enthaltenen ist. a vector wird initialisiert auf NA.
  a = NA
  for (i in 1:length(files)) {
    RKI_Impf_alt <-
      read_excel(paste0(here("data/RKI_Impf/working/", files[i])),sheet = 2)
    
    a[i] <- all_equal(RKI_Impf_alt, RKI_Impf_geladen) == TRUE
  }
  
  
  # wenn der "geladen" nicht mit den anderen gleich ist umbenennen.
  # all: sind alle TRUE? wenn ja, dann soll der geladene Datensatz "geladen" umbenannt werden aufs heutige Datum.
  if (any(a) == FALSE) {
    file.rename(here("data/RKI_Impf/working/geladen.xlsx"),
                paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"),Sys.Date(),".xlsx"))
    message("Neue Daten geladen")
  }
  
  if (any(a) == TRUE) {
    file.remove(here("data/RKI_Impf/working/geladen.xlsx"))
    message("Keine Neue Daten")
  }
  
  
  
} else{
  message("Daten existieren schon")
}


# Hier schon laden, da es in der nächsten if schleife abgefragt wird.
RKI_Impf_gesamt <-
  read_csv(here("data/RKI_Impf/final/RKI_Impf_gesamt.csv"))


## Daten zum Gesamt Datensatz hinzufügen und abspeichern in Gesamt csv. Wenn xlsx von heute existiert & wenn noch nicht nicht in gesamt geschrieben wurde
if (file.exists(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"),Sys.Date(),".xlsx")) &
    max(RKI_Impf_gesamt$date)!=Sys.Date()-1
    ) {
  
  
  # Daten aus dem aktuellen xlsx lesen. Nur Bundesländer ohne gesmat (row 1:16). Datum von Gestern (Tag der Imfpung) hinzugügen
  RKI_Impf_heute <-
    read_excel(paste0(
      here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"),Sys.Date(), ".xlsx"),
    sheet = 2,
    n_max = 16)
  
  # clean Data
  RKI_Impf_heute <- RKI_Impf_heute %>%
    clean_names() %>%
    mutate(date = Sys.Date() - 1) %>%
    select(date, everything()) # trick um date als erste Spalte zu bekommen
  
  
  
  # Wenn heute noch nicht in gesamt steht, hinzugügen. vorallem wichtig, wenn mehre files gelesen werden.
  # Aktuell noch doppelt, da ähnliches schon oben im if abgefragt wird. 
  if (sum(RKI_Impf_gesamt$date %in% RKI_Impf_heute$date) == 0) {
    RKI_Impf_gesamt <-
      bind_rows(RKI_Impf_gesamt, RKI_Impf_heute) %>%
      arrange(desc(date))
    message("Neue Daten hinzugefügt")
  }
  
  
  #Neuen gesamt Datensatz Speichern
  write.csv(RKI_Impf_gesamt,
            here("data/RKI_Impf/final/RKI_Impf_gesamt.csv"),
            row.names = F)

    
}

# ggplotly(
# RKI_Impf_gesamt %>% 
#   group_by(date) %>% 
#   summarize(differenz_zum_vortag = sum(differenz_zum_vortag,na.rm = TRUE)) %>% 
#   mutate(date = date - 1) %>% 
#   ggplot(aes(x = date , y = differenz_zum_vortag)) + 
#   geom_col()
# )

