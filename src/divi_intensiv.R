### DIVI Intensiv zahlen laden
### Darauf achten, dass sich der Datensatz auch täglich ändern kann

# URL zu den DAten      https://edoc.rki.de/bitstream/handle/176904/8106/2021-04-15_12-15_teilbare_divi_daten.csv?sequence=1&isAllowed=y
# URL zum Daten Portal https://edoc.rki.de/handle/176904/8106
# alte URL     url <- paste0("https://www.divi.de/joomlatools-files/docman-files/divi-intensivregister-tagesreports-csv/DIVI-Intensivregister_", date, "_", j, "-15.csv")


suppressMessages(library(here))
suppressMessages(library(readxl))
suppressMessages(library(janitor))
suppressMessages(library(tidyverse))



tt <- as.POSIXct("2015-07-23 00:00:00")
tts <- seq(tt, by = "hours", length = 24)
tth <- format(tts, "%H")


tage_spanne <- as.numeric(Sys.Date() - as.Date("2020-04-24"))

for (i in 0:tage_spanne) {
  date <- Sys.Date() - i



  if (!file.exists(paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), date, ".csv"))) {
    for (j in tth) {
      url <- paste0("https://edoc.rki.de/bitstream/handle/176904/8106/", date, "-", j, "-15teilbare_divi_daten.csv?sequence=1&isAllowed=y")
      tryCatch(
        {
          curl::curl_download(url, destfile = paste0(here("data/DIVI_Intensiv/working/DIVI_Intensiv_"), date, ".csv"))
        },
        error = function(e) {}
      )
    }
  }
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

