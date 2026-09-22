# 01_data_cleaning.R
#
# Ucitavanje i ciscenje rent.csv skupa podataka (Kaggle: "House Rent
# Prediction Dataset", indijsko trziste izdavanja nekretnina) i kreiranje
# izlazne promenljive High_Rent.
#
# Definise load_and_clean_rent_data(), koju analysis.Rmd poziva i dalje
# prosledjuje rezultat u EDA i modeling fazu.

#' Ucitava rent.csv, cisti ga i kreira binarnu izlaznu promenljivu High_Rent
#'
#' High_Rent = "yes" ako kirija pripada gornjih 15% (85. percentil) cena u
#' skupu podataka, inace "no". Prag od 85. percentila je namerno izabran
#' tako da klasa "yes" predstavlja jasnu manjinu (segment "skupljih"
#' nekretnina), sto cini problem klasifikacije neuravnotezenim - a to je i
#' razlog zasto se kasnije, u modeling fazi, posebno razmatra optimizacija
#' praga odluke preko ROC krive umesto podrazumevanog praga 0.5.
#'
#' @param path putanja do rent.csv
#' @return ociscen data.frame spreman za EDA i modeliranje
load_and_clean_rent_data <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE)

  # Rent je ucitan kao character jer dva reda sadrze "-" umesto broja;
  # te vrednosti (i jednu pravu NA vrednost) tretiramo kao nedostajuce i
  # izbacujemo, jer se od Rent-a direktno pravi izlazna promenljiva pa ne
  # zelimo da je nagadjamo imputacijom.
  data$Rent[data$Rent == "-"] <- NA
  data <- data[complete.cases(data$Rent), ]
  data$Rent <- as.numeric(data$Rent)

  rent_p85 <- stats::quantile(data$Rent, 0.85)
  data$High_Rent <- factor(
    ifelse(data$Rent > rent_p85, "yes", "no"),
    levels = c("no", "yes")
  )
  data$Rent <- NULL

  # Posted.On (datum oglasa), Floor i Area.Locality imaju previse
  # razlicitih vrednosti da bi bile korisne kao prediktori (81, 480 i 2234
  # nivoa na ovom skupu) - uklanjamo ih.
  data$Posted.On <- NULL
  data$Floor <- NULL
  data$Area.Locality <- NULL

  # City ima jednu nedostajucu vrednost - popunjavamo najcescom kategorijom
  # (modom), jer je faktorska promenljiva pa medijana nema smisla.
  most_common_city <- names(sort(table(data$City), decreasing = TRUE))[1]
  data$City[is.na(data$City)] <- most_common_city

  # Size ima jednu nedostajucu vrednost. Shapiro-Wilk test odbacuje hipotezu
  # normalnosti (p < 0.05), pa se za imputaciju koristi medijana umesto
  # aritmeticke sredine.
  median_size <- stats::median(data$Size, na.rm = TRUE)
  data$Size[is.na(data$Size)] <- median_size

  data$City <- factor(data$City)
  data$Furnishing.Status <- factor(data$Furnishing.Status)
  data$Tenant.Preferred <- factor(data$Tenant.Preferred)
  data$Point.of.Contact <- factor(data$Point.of.Contact)

  data
}
