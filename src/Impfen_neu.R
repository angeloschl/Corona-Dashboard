### Impfzahlen vom RKI ergänzen
### Darauf achten, dass sich der Datensatz auch täglich ändern kann

suppressMessages(library(here))
suppressMessages(library(readxl))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))


url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx;jsessionid=191B8B9B966E7F09BCCCF72ABE990854.internet081?__blob=publicationFile"

# Daten vom Server holen und in RKI_Impf_geladen schreiben
curl::curl_download(url, destfile = here("data/RKI_Impf/working/geladen.xlsx"))
RKI_Impf_geladen <- suppressMessages(read_excel(here("data/RKI_Impf/working/geladen.xlsx"), sheet = 2))




# Gibt es schon eine datei von heute? 
is_in_dir <- file.exists(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))

# Wenn TRUE muss geschaut werden, ob es ein Update gab oder nicht
if (is_in_dir == TRUE) {
  # Testen ob der Datensatz aktualisiert wurde
  # Also geladen mit heute vergleichen
  
  RKI_Impf_heute <- suppressMessages(read_excel(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"), sheet = 2))
  istgleich_geladen_heute <- suppressMessages(all_equal(RKI_Impf_geladen, RKI_Impf_heute))  == TRUE 
  
  # Wenn gleich, wurden die Daten nicht aktualisiert und 'geladen.xlsx' kann wieder gelöscht werden.
  if (istgleich_geladen_heute == TRUE) {
    
    file.remove(here("data/RKI_Impf/working/geladen.xlsx"))
    
    message("Impfzahlen: Heute geladen / Kein Update")
  }
  
  
  # Wenn sie nicht gleich sind, dann wurden der Datensatz aktualisiert.
  # Dann muss der alte Datensatz von heute gelöscht werden und geladen in heute umbenannt werden.
  if (istgleich_geladen_heute == FALSE) {
    
    file.remove(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))
    
    file.rename(
      here("data/RKI_Impf/working/geladen.xlsx"),
      paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))
    
    
  #### TO-DO: ####  
  # Hier muss jetzt der RKI_Impf_gesamt.csv aktualisiert werden.
  # Die veralteten Daten von heute löschen und die aktuellen neu hinzufügen. 
  # Testen!  
    RKI_Impf_gesamt <- suppressMessages(read_csv(here("data/RKI_Impf/final/RKI_Impf_gesamt.csv")))
    
    header <- c("rs", "bundesland",
                "erstimpfung_impfungenkumulativ_gesamt",
                "erstimpfung_impfungenkumulativ_bio_n_tech", "erstimpfung_impfungenkumulativ_moderna",  "erstimpfung_differenz_zum_vortag", "erstimpfung_impfquote_percent",
                "zweitimpfung_impfungenkumulativ", "zweitimpfung_differenz_zum_vortag")
    
    RKI_Impf_heute_update <-
      suppressMessages(read_excel(paste0(
        here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"),
        sheet = 2,
        col_names = header,
        skip = 3,
        n_max = 17))
    
    
    # Clean Data
    RKI_Impf_heute_update <- RKI_Impf_heute_update %>%
      clean_names() %>%
      mutate(date = Sys.Date() - 1) %>% # Daten auf gestern zurück datieren, weil da wurde geimpft (nicht heute). 
      select(date, everything()) # Trick um 'date' als erste Spalte zu bekommen
    
    
    # Zahlen von heute aus dem Datensatz löschen und aktualisierte Zahlen hinzufügen
    RKI_Impf_gesamt <- RKI_Impf_gesamt %>% 
      filter(date != max(date)) %>%
      bind_rows(., RKI_Impf_heute_update) %>%
      arrange(desc(date))
    
    
    
    # Neuen Datensatz speichern
    write.csv(RKI_Impf_gesamt,
              here("data/RKI_Impf/final/RKI_Impf_gesamt.csv"),
              row.names = FALSE)
    
    
    message("Impfzahlen: Update!! 'RKI_Impf_gesamt' wurde aktualisiert")
  }
  
  
}



# Wenn is_in_dir FALSE ist, gibt es zwei Möglichkeiten.
# 1. Der Datensatz ist noch gleich zu dem von Gestern, weil es noch neuen Daten von Heute gibt. Dann muss 'geladen.xlsx' wieder gelöscht werden
# 2. Der Datensatz ist der Neue von heute. Dann muss er umbenannt werden auf dsa heutige Datum und die Daten in RKI_Impf_gesamt.csv hinzugefügt werden. 


if (is_in_dir == FALSE) {
  
  
  neuste_datei <- max(list.files(here("data/RKI_Impf/working")))
  
  RKI_Impf_neuste_datei <- suppressMessages(read_excel(paste0(here("data/RKI_Impf/working/"),neuste_datei), sheet = 2))
  # RKI_Impf_gestern <- read_excel(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date()-2, ".xlsx"), sheet = 2)
  istgleich_geladen_gestern <-  suppressMessages(all_equal(RKI_Impf_geladen, RKI_Impf_neuste_datei)) == TRUE
  
  
  # geladen und gestern gleich 'geladen.xlsx' wieder löschen (sie oben zu 1.)
  if (istgleich_geladen_gestern == TRUE) {
    
    file.remove(here("data/RKI_Impf/working/geladen.xlsx"))
    
    message("Impfzahlen: Es liegen für Heute noch keine neuen Daten vor")
  }
  
  
  # Daten nicht gleich, somit ist der Datensatz neu (sie oben zu 2.)
  if (istgleich_geladen_gestern == FALSE) {
    
    # Daten umbenennen
    file.rename(
      here("data/RKI_Impf/working/geladen.xlsx"),
      paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))
    
    
    # 'RKI_Impf_gesamt' laden und neue Daten hinzufügen
    RKI_Impf_gesamt <- suppressMessages(read_csv(here("data/RKI_Impf/final/RKI_Impf_gesamt.csv")))
    
    
    # Umbenannten Datensatz 'geladen.xlsx', jetzt "RKI_Impfquote_COVID19_",Sys.Date(),".xlsx", laden und in RKI_Impf_heute_geladen laden
    header <- c("rs", "bundesland",
                "gesamtzahl_bisher_verabreichter_impfstoffdosen",
                "erstimpfung_impfungenkumulativ_gesamt", "erstimpfung_impfungenkumulativ_bio_n_tech", "erstimpfung_impfungenkumulativ_moderna", "erstimpfung_impfungenkumulativ_AstraZeneca",
                "erstimpfung_differenz_zum_vortag", "erstimpfung_impfquote_percent",
                "zweitimpfung_impfungenkumulativ_gesamt", "zweitimpfung_impfungenkumulativ_bio_n_tech", "zweitimpfung_impfungenkumulativ_moderna", 
                "zweitimpfung_differenz_zum_vortag", "zweitimpfung_impfquote_percent")
    
    
    RKI_Impf_heute_geladen <-
      suppressMessages(read_excel(paste0(
        here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"),
        sheet = 2,
        col_names = header,
        skip = 3,
        n_max = 16))
  
  
    # Clean Data
    RKI_Impf_heute_geladen <- RKI_Impf_heute_geladen %>%
      clean_names() %>%
      mutate(date = Sys.Date() - 1) %>% # Daten auf gestern zurück datieren, weil da wurde geimpft (nicht heute). 
      select(date, everything()) # Trick um 'date' als erste Spalte zu bekommen
    
    
    
    
    # Wenn heute noch nicht in 'RKI_Impf_gesamt' steht, hinzufügen. (Davon ist auszugehen, nur zusätzliche Paranoia)
    if (sum(RKI_Impf_gesamt$date %in% RKI_Impf_heute_geladen$date) == 0) {
      RKI_Impf_gesamt <-
        bind_rows(RKI_Impf_gesamt, RKI_Impf_heute_geladen) %>%
        arrange(desc(date))
      message("Neue Daten 'RKI_Impf_gesamt' hinzugefügt")
    }
    
    
    # Neuen gesamt Datensatz Speichern
    write.csv(RKI_Impf_gesamt,
              here("data/RKI_Impf/final/RKI_Impf_gesamt.csv"),
              row.names = FALSE)
    
    ### Gesamtdaten aus Blatt 3 der aktuellen Zahlen ziehen 
    neuste_datei_neu <- max(list.files(here("data/RKI_Impf/working")))
    RKI_Impf_geladen_Blatt3 <- suppressMessages(read_excel(paste0(here("data/RKI_Impf/working/"),neuste_datei_neu), sheet = 4))
    
    RKI_Impf_geladen_Blatt3 <- RKI_Impf_geladen_Blatt3 %>% 
      clean_names() %>% 
      filter(datum != "Impfungen gesamt") %>%
      rename(date = datum) %>% 
      mutate(date = excel_numeric_to_date(as.numeric(date)))
    
    # Neuen gesamt Datensatz Speichern
    write.csv(RKI_Impf_geladen_Blatt3,
              here("data/RKI_Impf/final/RKI_Impf_gesamt_aus_neusten_daten.csv"),
              row.names = FALSE)
    
    
  
    message("Impfzahlen: Neue Daten geladen und zu 'RKI_Impf_gesamt' hinzugefügt.")
  }
  
}



