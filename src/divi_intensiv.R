### DIVI Intensiv zahlen laden
### Darauf achten, dass sich der Datensatz auch täglich ändern kann

# URL zu den DAten      https://edoc.rki.de/bitstream/handle/176904/8106/2021-04-15_12-15_teilbare_divi_daten.csv?sequence=1&isAllowed=y
# URL zum Daten Portal https://edoc.rki.de/handle/176904/8106
# alte URL     url <- paste0("https://www.divi.de/joomlatools-files/docman-files/divi-intensivregister-tagesreports-csv/DIVI-Intensivregister_", date, "_", j, "-15.csv")
# Neu ? https://diviexchange.blob.core.windows.net/%24web/DIVI_Intensivregister_Auszug_pro_Landkreis.csv

suppressMessages(library(here))
suppressMessages(library(readxl))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))




# for (i in 0:tage_spanne) {
#   date <- Sys.Date() - i
# 
# 
#   if (!file.exists(paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), date, ".csv"))) {
#     for (j in tth) {
#       url <- paste0("https://edoc.rki.de/bitstream/handle/176904/8109/", date, "_", j, "-15_teilbare_divi_daten.csv?sequence=1&isAllowed=y")
#       tryCatch(
#         {
#           curl::curl_download(url, destfile = paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), date, ".csv"))
#         },
#         error = function(e) {}
#       )
#     }
#   }
# }






url <- "https://diviexchange.blob.core.windows.net/%24web/DIVI_Intensivregister_Auszug_pro_Landkreis.csv"


is_in_dir <- file.exists(paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), Sys.Date(), ".csv"))

if (!is_in_dir) {
  # Neuen Daten laden
  curl::curl_download(url,destfile = here("data/DIVI_Intensiv/geladen/geladen.csv"))
  
  DIVI_Intensiv_geladen <- suppressMessages(read_csv(here("data/DIVI_Intensiv/geladen/geladen.csv")))
  
  
  # Nur .csv datein, da die anderen schon gezipped wurden. Sollte eigentlich immer nur eine datei sein.
  files <- list.files(here("data/DIVI_Intensiv/working/")) %>%
    .[grepl(".*\\.csv", .)]
  
  
  
  # Vergleichen ob die der neu geladene Datensatz geladen.csv gleich mit den schon im Ordner enthaltenen ist. 'a' Variable wird initialisiert auf NA.
  a <- NA
  suppressWarnings(
  for (i in 1:length(files)) {
    DIVI_Intensiv_alt <- suppressMessages(read_csv(paste0(here("data/DIVI_Intensiv/working/", files[i]))))
    
    a[i] <- suppressMessages(all_equal(DIVI_Intensiv_alt, DIVI_Intensiv_geladen)) == TRUE 
  }
  )
  
  # wenn der "geladen" nicht mit den anderen gleich ist umbenennen.
  # all: sind alle TRUE? wenn ja, dann soll der geladene Datensatz "geladen" umbenannt werden aufs heutige Datum.
  
  if (any(a) == FALSE) {
    file.rename(
      here("data/DIVI_Intensiv/geladen/geladen.csv"),
      paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), Sys.Date(), ".csv")
    )
    message("DIVI-Intensiv: Neue Daten geladen")
    

    }
    

  
  if (any(a) == TRUE) {
    file.remove(here("data/DIVI_Intensiv/geladen/geladen.csv"))
    message("DIVI-Intensiv: Keine Neue Daten")
  }
  
} else {
  message("DIVI-Intensiv: Daten existieren schon")
}













# for (i in 0:tage_spanne) {
#   date <- as.Date("2020-04-24")
#   suppressWarnings(df_divi <- read_csv(paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), date + i, ".csv")))
# 
#   daten_stand_enthalten <- "daten_stand" %in% names(df_divi)
# 
#   if (!daten_stand_enthalten) {
#     df_divi <- df_divi %>%
#       mutate(daten_stand = date + i)
#     write.csv(df_divi,
#               paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), date + i, ".csv"),
#               row.names = FALSE)
# 
# 
# 
#     print(date + i)
#     message("Iz net Da")
#   } else {
#     print(date + i)
#     message("Iz Da")
#   }
# }





files  <- list.files(path = here("data/DIVI_Intensiv/working"), pattern = '\\.csv')

tables <- lapply(here(paste0(here("data/DIVI_Intensiv/working/"),files)), read.csv, header = TRUE)



combined.df <- bind_rows(tables)

combined.df <- combined.df %>%
  mutate(date = as.Date(daten_stand)) %>% 
  group_by(date) %>% 
  summarise(betten_belegt = sum(betten_belegt),
            faelle_covid_aktuell = sum(faelle_covid_aktuell)) %>% 
  drop_na()

# combined.df %>% 
#   ggplot(aes(x = date , y = faelle_covid_aktuell)) +
#   geom_line()



write.csv(combined.df,
  here("data/DIVI_Intensiv/aufbereitet/divi_intesiv_aufbereitet.csv"),
  row.names = FALSE)

