suppressMessages(library(here))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))



url <- "https://www.arcgis.com/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data"


## Daten laden

# Überprüfen, ob heutiger Datensatz schon existiert.
is_in_dir <- !file.exists(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv"))

if (is_in_dir) {
  # Neuen Daten laden
  curl::curl_download(url,
    destfile = here("data/RKI/original/geladen.csv"),
  quiet = TRUE)

  RKI_geladen <- suppressMessages(read_csv(here("data/RKI/original/geladen.csv")))


  # Nur .csv datein, da die anderen schon gezipped wurden. Sollte eigentlich immer nur eine datei sein.
  files <- list.files(here("data/RKI/working/")) %>%
    .[grepl(".*\\.csv", .)]



  # Vergleichen ob die der neu geladene Datensatz geladen.csv gleich mit den schon im Ordner enthaltenen ist. 'a' Variable wird initialisiert auf NA.
  a <- NA
  for (i in 1:length(files)) {
    RKI_alt <- suppressMessages(read_csv(paste0(here("data/RKI/working/", files[i]))))

    a[i] <- suppressMessages(all_equal(RKI_alt, RKI_geladen)) == TRUE
  }


  # wenn der "geladen" nicht mit den anderen gleich ist umbenennen.
  # all: sind alle TRUE? wenn ja, dann soll der geladene Datensatz "geladen" umbenannt werden aufs heutige Datum.

  if (any(a) == FALSE) {
    file.rename(
      here("data/RKI/original/geladen.csv"),
      paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv")
    )
    message("RKI-Fallzahlen: Neue Daten geladen")



    # Datensatz vom Vortag zippen und original csv löschen wenn neue csv von heute da ist und die zip vom Vortag noch nicht da ist.
    if (file.exists(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv")) &
      !file.exists(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date() - 1, ".zip"))
    ) {
      setwd(here("data/RKI/working/"))
      
      suppressMessages(
        zip(
          zipfile = paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date() - 1, ""),
          files = paste0("RKI_COVID19_", Sys.Date() - 1, ".csv")
        )
      )

      # Wenn .zip datei existiert, .csv löschen
      if (file.exists(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date() - 1, ".zip"))) {
        file.remove(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date() - 1, ".csv"))
      }
      setwd(here())
      message("RKI-Fallzahlen:  Alter Datensatz gezippt")
    }

    Neufindektion_Datum_df <- suppressMessages(read_csv(here("data/Erstellt/Neufindektion_Datum_df.csv")))



    # Neuen Daten in Neufindektion_Datum_df schreiben. Nur wenn neue Daten geladen sind & Sie noch nicht in Neuinfektionen geschrieben wurden
    if (file.exists(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv")) &
      max(Neufindektion_Datum_df$Datum) != Sys.Date()
    ) {
      if (!exists("RKI_COVID19")) {
        RKI_COVID19 <-
          suppressMessages(read_csv(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv"))) %>%
          mutate(
            Meldedatum = ymd(as.Date(Meldedatum)),
            Refdatum = ymd(as.Date(Refdatum)),
            Datenstand = as_date(dmy_hm(Datenstand))
          ) %>%
          arrange(desc(Meldedatum))
      }




      if (all(max(RKI_COVID19$Meldedatum) + 1 != Neufindektion_Datum_df$Datum)) {
        # Datum in Datum schreiben. Maximales Datum aus Datensatz +1 rechnen.
        # Im Datenframe eine neue Zeile anlegen [+1,1]
        Neufindektion_Datum_df[nrow(Neufindektion_Datum_df) + 1, 1] <- max(RKI_COVID19$Meldedatum) + 1

        Neufindektion_Datum_df[nrow(Neufindektion_Datum_df), 2] <- RKI_COVID19 %>%
          filter(NeuerFall %in% c(-1, 1)) %>%
          summarise(AnzahlFall = sum(AnzahlFall)) %>%
          as.numeric()
        
        
        #### Siebentage Inzidenz schreiben
        
        
        ma <- function(x, n = 7) {
          stats::filter(x, rep(1 / n, n), sides = 2)
        }
        
        Bund = RKI_COVID19 %>%
          filter(NeuerFall %in% c(0, 1)) %>%
          group_by(Meldedatum) %>%
          summarise(AnzahlFall = sum(AnzahlFall)) %>%
          ungroup() %>%
          mutate(ma_AnzahlFall = round(ma(AnzahlFall)))
        
        LetzteWocheInzidenz = Bund %>% 
          filter(Meldedatum>Sys.Date()-8) %>% 
          select(AnzahlFall) %>% 
          sum()
        
        EinwohnerzahlBund = 83166711
        
        LetzteWocheInzidenz = round(LetzteWocheInzidenz/(EinwohnerzahlBund/100000),1)
        
        
        Neufindektion_Datum_df[nrow(Neufindektion_Datum_df), 3] <- LetzteWocheInzidenz
        
        
        
        ####
        
        
        
        Neufindektion_Datum_df <- Neufindektion_Datum_df %>%
          arrange(Datum)


        write.csv(
          Neufindektion_Datum_df,
          here("data/Erstellt/Neufindektion_Datum_df.csv"),
          row.names = F
        )
        message("RKI-Fallzahlen: Gesamtzahl der Neuinfektionen von heute wurden ergänzt")
      }
      
      
    }
    
    
  } # Ende if (any(a) == FALSE)

  
  
  if (any(a) == TRUE) {
    file.remove(here("data/RKI/original/geladen.csv"))
    message("RKI-Fallzahlen: Keine Neue Daten")
  }
  
} else {
  message("RKI-Fallzahlen: Daten existieren schon")
}
