### Impfzahlen vom RKI ergänzen
### Darauf achten, dass sich der Datensatz auch täglich ändern kann

suppressMessages(library(here))
suppressMessages(library(readxl))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))


# url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx;jsessionid=191B8B9B966E7F09BCCCF72ABE990854.internet081?__blob=publicationFile"
url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx?__blob=publicationFile"


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
    
    message("RKI-Impfzahlen: Heute geladen")
  }
  
}



# Wenn is_in_dir FALSE ist, gibt es zwei Möglichkeiten.
# 1. Der Datensatz ist noch gleich zu dem von Gestern, weil es noch keine neuen Daten von Heute gibt. Dann muss 'geladen.xlsx' wieder gelöscht werden
# 2. Der Datensatz ist der Neue von heute. Dann muss er umbenannt werden auf das heutige Datum und die Daten in RKI_Impf_gesamt.csv hinzugefügt werden. 


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
    
    # Blatt 2 aufbereiten ----------------------------------------------------
    
    # 'RKI_Impf_heute_blatt_2' laden und neue Daten von heute hinzufügen
    RKI_Impf_heute_blatt_2 <- suppressMessages(read_csv(here("data/RKI_Impf/aufbereitete_daten/RKI_Impf_heute_blatt_2.csv")))
    
    
    # Umbenannten Datensatz 'geladen.xlsx', jetzt "RKI_Impfquote_COVID19_",Sys.Date(),".xlsx", laden und in RKI_Impf_heute_blatt_2/3/4 laden
    # header_blatt_2 <- c("rs", "bundesland",
    #             "insgesamt_über_alle_impfstellen_gesamtzahl_bisher_verabreichter_impfungen","insgesamt_über_alle_impfstellen_gesamtzahl_einmalig_geimpft","insgesamt_über_alle_impfstellen_gesamtzahl_vollständig_geimpft",
    #             "insgesamt_über_alle_impfstellen_impfquote_mit_einer_impfung_gesmat","insgesamt_über_alle_impfstellen_impfquote_mit_einer_impfung_<60_jahre","insgesamt_über_alle_impfstellen_impfquote_mit_einer_impfung_60+_jahre",
    #             "insgesamt_über_alle_impfstellen_impfquote_vollständig_geimpft_gesmat","insgesamt_über_alle_impfstellen_impfquote_vollständig_geimpft_<60_jahre","insgesamt_über_alle_impfstellen_impfquote_vollständig_geimpft_60+_jahre",
    #             "impfungen_in_impfzentren_mobilen_teams_und_krankenhäusern_eine_impfung_<60_jahre","impfungen_in_impfzentren_mobilen_teams_und_krankenhäusern_eine_impfung_60+_jahre", "impfungen_in_impfzentren_mobilen_teams_und_krankenhäusern_vollständig_geimpft_<60_jahre","impfungen_in_impfzentren_mobilen_teams_und_krankenhäusern_vollständig_geimpft_60+_jahre",
    #             "impfungen_bei_niedergelassenen_ärzten_eine_impfung_<60_jahre","impfungen_bei_niedergelassenen_ärzten_eine_impfung_60+_jahre", "impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_<60_jahre","impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_60+_jahre")
    # 
    
    
    # Umbenannten Datensatz 'geladen.xlsx', jetzt "RKI_Impfquote_COVID19_",Sys.Date(),".xlsx", laden und in RKI_Impf_heute_blatt_2/3/4 laden
    header_blatt_2 <- c("rs", "bundesland",
                        "gesamtzahl_bisher_verabreichter_impfungen","gesamtzahl_mindestens_einmal_geimpft_gesamt","gesamtzahl_mindestens_einmal_geimpft_davon_5_bis_11","gesamtzahl_vollständig_geimpft","gesamtzahl_personen_mit_auffrischungsimpfung",
                        "impfquote_mindestens_einmal_geimpft_gesamt","impfquote_mindestens_einmal_geimpft_12-17_jahre","impfquote_mindestens_einmal_geimpft_>18_jahre_gesamt","impfquote_mindestens_einmal_geimpft_>18_jahre_18-59_jahre","impfquote_mindestens_einmal_geimpft_>18_jahre_60+_jahre",
                        "impfquote_vollständig_geimpft_gesamt","impfquote_vollständig_geimpft_12-17_jahre","impfquote_vollständig_geimpft_>18_jahre_gesamt","impfquote_vollständig_geimpft_>18_jahre_18-59_jahre","impfquote_vollständig_geimpft_>18_jahre_60+_jahre",
                        "impfquote_auffrischimpfung_gesamt","impfquote_auffrischimpfung_12-17_jahre","impfquote_auffrischimpfung_>18_jahre_gesamt","impfquote_auffrischimpfung_>18_jahre_18-59_jahre","impfquote_auffrischimpfung_>18_jahre_60+_jahre")
    
    

      RKI_Impf_heute_blatt_2 <-
      suppressMessages(read_excel(paste0(
        here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"),
        sheet = 2,
        col_names = header_blatt_2,
        skip = 3,
        n_max = 18))
  
  
    # Clean Data
    RKI_Impf_heute_blatt_2 <- RKI_Impf_heute_blatt_2 %>%
      clean_names() 
    
    
    # Neuen gesamt Datensatz Speichern
    write.csv(RKI_Impf_heute_blatt_2,
              here("data/RKI_Impf/aufbereitete_daten/RKI_Impf_heute_blatt_2.csv"),
              row.names = FALSE)
    
    message("Neue Daten 'RKI_Impf_heute_blatt_2' hinzugefügt")
  
    

#  Blatt 3 aufbereiten ----------------------------------------------------
    RKI_Impf_heute_blatt_3 <- suppressMessages(read_csv(here("data/RKI_Impf/aufbereitete_daten/RKI_Impf_heute_blatt_3.csv")))
    
    
    # Umbenannten Datensatz 'geladen.xlsx', jetzt "RKI_Impfquote_COVID19_",Sys.Date(),".xlsx", laden und in RKI_Impf_heute_blatt_2/3/4 laden
    # header_blatt_3 <- c("rs", "bundesland",
    #                     "impfungen_in_impfzentren_mobilen_teams_krankenhäusern_eine_impfung_impfungen_kumulativ_gesamt","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_eine_impfung_impfungen_kumulativ_biontech","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_eine_impfung_impfungen_kumulativ_moderna","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_eine_impfung_impfungen_kumulativ_astrazeneca","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_eine_impfung_differenz_zum_Vortag",									
    #                     "impfungen_in_impfzentren_mobilen_teams_krankenhäusern_vollständig_geimpft_impfungen_kumulativ_gesamt","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_vollständig_geimpft_impfungen_kumulativ_biontech","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_vollständig_geimpft_impfungen_kumulativ_moderna","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_vollständig_geimpft_impfungen_kumulativ_astrazeneca","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_vollständig_geimpft_impfungen_kumulativ_janssen","impfungen_in_impfzentren_mobilen_teams_krankenhäusern_vollständig_geimpft_differenz_zum_Vortag",									
    #                     "impfungen_bei_niedergelassenen_ärzten_eine_impfung_impfungen_kumulativ_gesamt","impfungen_bei_niedergelassenen_ärzten_eine_impfung_impfungen_kumulativ_biontech","impfungen_bei_niedergelassenen_ärzten_eine_impfung_impfungen_kumulativ_moderna","impfungen_bei_niedergelassenen_ärzten_eine_impfung_impfungen_kumulativ_astrazeneca","impfungen_bei_niedergelassenen_ärzten_eine_impfung_differenz_zum_Vortag",									
    #                     "impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_impfungen_kumulativ_gesamt","impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_impfungen_kumulativ_biontech","impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_impfungen_kumulativ_moderna","impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_impfungen_kumulativ_astrazeneca","impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_impfungen_kumulativ_janssen","impfungen_bei_niedergelassenen_ärzten_vollständig_geimpft_differenz_zum_Vortag")

    
    # Umbenannten Datensatz 'geladen.xlsx', jetzt "RKI_Impfquote_COVID19_",Sys.Date(),".xlsx", laden und in RKI_Impf_heute_blatt_2/3/4 laden
    # header_blatt_3 <- c("rs", "bundesland",
    #                     "mindestens_einmal_geimpft_impfungen_kumulativ_gesamt","mindestens_einmal_geimpft_impfungen_kumulativ_biontech","mindestens_einmal_geimpft_impfungen_kumulativ_moderna","mindestens_einmal_geimpft_impfungen_kumulativ_astrazeneca","mindestens_einmal_geimpft_impfungen_kumulativ_janssen","mindestens_einmal_geimpft_differenz_zum_Vortag",
    #                     "vollständig_geimpftimpfungen_kumulativ_gesamt","vollständig_geimpftimpfungen_kumulativ_biontech","vollständig_geimpftimpfungen_kumulativ_moderna","vollständig_geimpftimpfungen_kumulativ_astrazeneca","vollständig_geimpftimpfungen_kumulativ_janssen","vollständig_geimpftdifferenz_zum_Vortag")
    
    
    RKI_Impf_heute_blatt_3 <-
      suppressMessages(read_excel(paste0(
        here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"),
        sheet = 3,
#        col_names = header_blatt_3,
        skip = 4,
        n_max = 18))
    
    
    # Clean Data
    RKI_Impf_heute_blatt_3 <- RKI_Impf_heute_blatt_3 %>%
      clean_names() 
    
    
    # Neuen gesamt Datensatz Speichern
    write.csv(RKI_Impf_heute_blatt_3,
              here("data/RKI_Impf/aufbereitete_daten/RKI_Impf_heute_blatt_3.csv"),
              row.names = FALSE)
    
    message("Neue Daten 'RKI_Impf_heute_blatt_3' hinzugefügt")
    

    
    
    
    #  Blatt 4 aufbereiten ----------------------------------------------------
    RKI_Impf_heute_blatt_4 <- suppressMessages(read_csv(here("data/RKI_Impf/aufbereitete_daten/RKI_Impf_heute_blatt_4.csv")))
    
    
    # Umbenannten Datensatz 'geladen.xlsx', jetzt "RKI_Impfquote_COVID19_",Sys.Date(),".xlsx", laden und in RKI_Impf_heute_blatt_2/3/4 laden
    header_blatt_4 <- c("datum",	"erstimpfung",	"zweitimpfung","Auffrischungsimpfung",	"gesamtzahl_verabreichter_impfstoffdosen")
    
    
    RKI_Impf_heute_blatt_4 <-
      suppressMessages(read_excel(paste0(
        here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"),
        sheet = 4,
        col_names = header_blatt_4,
        skip = 1,
        n_max = Inf)) 
    
    RKI_Impf_heute_blatt_4 <- RKI_Impf_heute_blatt_4 %>% 
#      head(-4) %>% 
      rename(date = datum) %>% 
#      mutate(date = excel_numeric_to_date(as.numeric(date))) %>% 
      mutate(date = lubridate::dmy(date)) %>% 
      drop_na(date) 
#        head(-1) # aktuell nötig weil irgendwas in der letzten zeile schief läuft. letzte datum steht immer doppelt da. 

     # Clean Data
    RKI_Impf_heute_blatt_4 <- RKI_Impf_heute_blatt_4 %>%
      clean_names() 
    
    
    # Neuen gesamt Datensatz Speichern
    write.csv(RKI_Impf_heute_blatt_4,
              here("data/RKI_Impf/aufbereitete_daten/RKI_Impf_heute_blatt_4.csv"),
              row.names = FALSE)
    
    message("Neue Daten 'RKI_Impf_heute_blatt_4' hinzugefügt")
    
  
    message("RKI-Impfzahlen: Neue Daten geladen und aufgereitet.")
  }
  
}



