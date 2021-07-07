### Checken ob es neue Daten gibt. Wenn es sie gibt soll erst das Markdown geknittet und hochgeladen werden. sonst soll nichts passieren
### Darauf achten, dass sich der Datensatz auch täglich ändern kann

suppressMessages(library(here))
suppressMessages(library(readxl))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))

speichern_laden <- function(x, y) {
  # Speichert die Datei
  write.csv(x, here(y), row.names = F)
  # läd die Datei neu in den Speicher
  x <- suppressMessages(read_csv(here(y)))
}


daten_monitor <- suppressMessages(read_csv(here("src/daten_monitor.csv")))


#message("--------------------------------------------")
time_start <- Sys.time()
print(time_start)
message("")



# RKI-Fallzahlen --------------------------------------------------------------
message("RKI-Fallzahlen:")
# liest das Datum aus der daten_monitor Datei und speichert es in der var.
RKI_Fallzahl_datum_daten_monitor <- daten_monitor %>%
  filter(daten == "RKI_Fallzahl") %>%
  pull("version")

# Prüfen, ob es schon ein neuer Tag ist und ob es später als 6 Uhr ist. Wenn beides warh ist, wird das sktip zum Laden der Fallzahlen aktiviert.
# Wenn es dann einen neuen Datensatz gibt, wird in der Monitor Datei das Datum von heute geschrieben und die Neu Variable auf 1 gesetzt.
# Wenn es keinen neuen Datensatz gibt, wird eine Nachricht drüber zurück gegeben.
if (RKI_Fallzahl_datum_daten_monitor != Sys.Date() &
  format(Sys.time(), "%X") > "06:00:00") {
  message("Es wird geschaut, ob es schon neue RKI-Fallzahlen gibt")

  

  source("~/Documents/RStudio_Projekte/CoronaDashboard/src/Fallzahlen_laden.R")



  if (file.exists(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv"))) {
    RKI_Fallzahlen_ctime <- as.Date(file.info(paste0(here("data/RKI/working/RKI_COVID19_"), Sys.Date(), ".csv"))$ctime)

    daten_monitor[1, "version"] <- RKI_Fallzahlen_ctime
    daten_monitor[1, "neu"] <- 1

    speichern_laden(daten_monitor, "src/daten_monitor.csv")

    message("RKI-Fallzahlen von heute wurden geladen. \n")
  } else {
    message("RKI-Fallzahlen sind noch aktuell! \n")
  }
} else {
  # Wenn es früher als 6 Uhr ist, wird diese Nachricht gezeigt
  if (format(Sys.time(), "%X") < "06:00:00") {
    message("RKI-Fallzahlen sind noch aktuell und werden ab 06:00 Uhr aktualisiert. \n")
  }

  # Wenn es später als 6 Uhr ist, wird diese Nachricht gezeigt
  if (format(Sys.time(), "%X") > "06:00:00") {
    message("RKI-Fallzahlen sind aktuell! \n")
  }
}




# RKI-Impfzahlen ----------------------------------------------------------
message("RKI-Impfzahlen:")
# liest das Datum aus der daten_monitor Datei und speichert es in der var.
RKI_Impfzahlen_datum_daten_monitor <- daten_monitor %>%
  filter(daten == "RKI_Impf") %>%
  pull("version")

# Prüfen, ob es schon ein neuer Tag ist und ob es später als 10 Uhr ist. Wenn beides warh ist, wird das sktip zum Laden der Fallzahlen aktiviert.
# Wenn es dann einen neuen Datensatz gibt, wird in der Monitor Datei das Datum von heute geschrieben und die Neu Variable auf 1 gesetzt.
# Wenn es keinen neuen Datensatz gibt, wird eine Nachricht drüber zurück gegeben.
# Wenn es Sonntag wird der Skript nicht gestartet, da Sonntag keine Impfzahlen gibt. 
if (RKI_Impfzahlen_datum_daten_monitor != Sys.Date() &
    format(Sys.time(), "%X") > "08:00:00" & weekdays(as.Date(Sys.Date())) != "Sonntag") {
  message("Es wird geschaut, ob es schon neue RKI-Impfzahlen gibt")
  
  
  
  source("~/Documents/RStudio_Projekte/CoronaDashboard/src/Impfen_neu.R")
  
  
  
  if (file.exists(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))) {
    RKI_Impfzahlen_ctime <- as.Date(file.info(paste0(here("data/RKI_Impf/working/RKI_Impfquote_COVID19_"), Sys.Date(), ".xlsx"))$ctime)
    
    daten_monitor[2, "version"] <- RKI_Impfzahlen_ctime
    daten_monitor[2, "neu"] <- 1
    
    speichern_laden(daten_monitor, "src/daten_monitor.csv")
    
    message("RKI-Impfzahlen von heute wurden geladen. \n")
  } else {
    message("RKI-Impfzahlen sind noch aktuell! \n")
  }
  
  
} else {
  
  #Wenn es sonntag ist diese Nachricht:
  if (weekdays(as.Date(Sys.Date())) == "Sonntag"){
    message("RKI-Impfzahlen werden Sonntags nicht aktualisiert. \n")
  }
  
  
  # Wenn es nicht Sonntag ist diese Nachichten: 
  if (weekdays(as.Date(Sys.Date())) != "Sonntag"){
    
  
    # Wenn es früher als 6 Uhr ist, wird diese Nachricht gezeigt
    if (format(Sys.time(), "%X") < "08:00:00") {
      message("RKI-Impfzahlen sind noch aktuell und werden ab 08:00 Uhr aktualisiert. \n")
    }
    
    # Wenn es später als 6 Uhr ist, wird diese Nachricht gezeigt
    if (format(Sys.time(), "%X") > "08:00:00") {
      message("RKI-Impfzahlen sind aktuell! \n")
    }
  }
}
  






# DIVI-Intensiv ----------------------------------------------------------
message("DIVI-Intensiv:")
# liest das Datum aus der daten_monitor Datei und speichert es in der var.
DIVI_Intensiv_datum_daten_monitor <- daten_monitor %>%
  filter(daten == "DIVI_Intensiv") %>%
  pull("version")

# Prüfen, ob es schon ein neuer Tag ist und ob es später als 10 Uhr ist. Wenn beides warh ist, wird das sktip zum Laden der Fallzahlen aktiviert.
# Wenn es dann einen neuen Datensatz gibt, wird in der Monitor Datei das Datum von heute geschrieben und die Neu Variable auf 1 gesetzt.
# Wenn es keinen neuen Datensatz gibt, wird eine Nachricht drüber zurück gegeben.
if (DIVI_Intensiv_datum_daten_monitor != Sys.Date() &
    format(Sys.time(), "%X") > "12:30:00") {
  message("Es wird geschaut, ob es schon neue DIVI-Intensiv zahlen gibt")
  
  
  
  source("~/Documents/RStudio_Projekte/CoronaDashboard/src/divi_intensiv.R")
  
  
  
  if (file.exists(paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), Sys.Date(), ".csv"))) {
    DIVI_Intensiv_ctime <- as.Date(file.info(paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), Sys.Date(), ".csv"))$ctime)
    
    daten_monitor[3, "version"] <- DIVI_Intensiv_ctime
    daten_monitor[3, "neu"] <- 1
    
    speichern_laden(daten_monitor, "src/daten_monitor.csv")
    
    message("DIVI-Intensiv von heute wurden geladen. \n")
  } else {
    message("DIVI-Intensiv sind noch aktuell! \n")
  }
} else {
  # Wenn es früher als 12 Uhr ist, wird diese Nachricht gezeigt
  if (format(Sys.time(), "%X") < "12:30:00") {
    message("DIVI-Intensiv sind noch aktuell und werden ab 12:30 Uhr aktualisiert.  \n")
  }
  
  # Wenn es später als 12 Uhr ist, wird diese Nachricht gezeigt
  if (format(Sys.time(), "%X") > "12:30:00") {
    message("DIVI-Intensivzahlen sind aktuell! \n")
  }
}





# RKI_R-Wert ----------------------------------------------------------
message("RKI_R-Wert:")
# liest das Datum aus der daten_monitor Datei und speichert es in der var.
RKI_R_Wert_datum_daten_monitor <- daten_monitor %>%
  filter(daten == "RKI_R-Wert") %>%
  pull("version")

# Prüfen, ob es schon ein neuer Tag ist und ob es später als 10 Uhr ist. Wenn beides warh ist, wird das sktip zum Laden der Fallzahlen aktiviert.
# Wenn es dann einen neuen Datensatz gibt, wird in der Monitor Datei das Datum von heute geschrieben und die Neu Variable auf 1 gesetzt.
# Wenn es keinen neuen Datensatz gibt, wird eine Nachricht drüber zurück gegeben.
if (RKI_R_Wert_datum_daten_monitor != Sys.Date() &
    format(Sys.time(), "%X") > "17:00:00") {
  message("Es wird geschaut, ob es schon neue RKI_R-Werte gibt")
  
  
  
  source("~/Documents/RStudio_Projekte/CoronaDashboard/src/RWert.R")
  
  
  
  if ( as.Date(file.info(here("data/RKI_RWert/working/RKI_RWert_heute.csv"))$ctime) == Sys.Date() ) {
    RKI_RWert_ctime <- as.Date(file.info(here("data/RKI_RWert/working/RKI_RWert_heute.csv"))$ctime) 
    
    daten_monitor[4, "version"] <- RKI_RWert_ctime
    daten_monitor[4, "neu"] <- 1
    
    speichern_laden(daten_monitor, "src/daten_monitor.csv")
    
    message("RKI_R-Werte von heute wurden geladen. \n")
  } else {
    message("RKI_R-Werte sind noch aktuell! \n")
  }
} else {
  # Wenn es früher als 08 Uhr ist, wird diese Nachricht gezeigt
  if (format(Sys.time(), "%X") < "17:00:00") {
    message("RKI_R-Werte sind noch aktuell und werden ab 17:00 Uhr aktualisiert.")
  }
  
  # Wenn es später als 08 Uhr ist, wird diese Nachricht gezeigt
  if (format(Sys.time(), "%X") > "17:00:00") {
    message("RKI_R-Werte sind aktuell! \n")
  }
}




# RMardown / Dashboard Knitten --------------------------------------------------------

# Wenn eins der neuen Daten aktualisiert wurde, soll das Dashboard / RMardown neu geknittet werden, sonst nicht.
# IN die dashboard_upload Datei wird wenn es geknittet wurde eine '1' geschrieben. Das heißt es wurde aktualisiert. 

if (sum(daten_monitor$neu) > 0) {
  suppressWarnings(suppressMessages(rmarkdown::render(here("Corona_Dashboard.Rmd"), quiet = TRUE)))

  message("Dashboard wurde aktualisiert \n")


  # Einfügen, dass das neu wieder auf null gesetzt wird.

  is_new <-  file.info(paste0(here("Corona_Dashboard.html")))$ctime > Sys.time()-10
  

  if (is_new) {
    # RKI_Fallzahlen
    daten_monitor[1, "neu"] <- 0
    # RKI_Impf 
    daten_monitor[2, "neu"] <- 0
    # DIVI_Intensiv 
    daten_monitor[3, "neu"] <- 0
    # RKI_R-Wert
    daten_monitor[4, "neu"] <- 0
    
    speichern_laden(daten_monitor, "src/daten_monitor.csv")
    
    message("Daten Monitor wurde auf Null gesetzt. \n")
    
  }



  # 1 in upload file schreiben.
  message("Upload wurde auf 1 gesetzt. \n")
  
  writeLines("1", "~/Documents/RStudio_Projekte/CoronaDashboard/cron/dashboard_upload_0_1.txt")
}


message("")
time_end <- Sys.time()
print(round(time_end - time_start))


