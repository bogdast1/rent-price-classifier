# 03_modeling.R
#
# Naive Bayes klasifikacija High_Rent promenljive: podela na train/test,
# diskretizacija numerickih prediktora, treniranje modela, ocena preko
# konfuzione matrice, i optimizacija praga odluke preko ROC krive.

library(e1071)
library(pROC)
library(caret)

#' Deli podatke na train/test uz stratifikaciju po izlaznoj promenljivoj
#'
#' @param data ociscen data.frame sa High_Rent kolonom
#' @param p udeo podataka koji ide u train skup
#' @param seed seed za reproducibilnost
#' @return list(train = ..., test = ...)
split_train_test <- function(data, p = 0.8, seed = 1010) {
  set.seed(seed)
  idx <- caret::createDataPartition(data$High_Rent, p = p, list = FALSE)
  list(train = data[idx, ], test = data[-idx, ])
}

#' Priprema podatke za Naive Bayes: diskretizuje numericke prediktore
#' (BHK, Size, Bathroom) na intervale jednake frekvencije.
#'
#' Broj intervala (2, 5, 2) je zadrzan iz originalne analize - manji broj
#' intervala za BHK i Bathroom je posledica toga sto te promenljive imaju
#' malo razlicitih celobrojnih vrednosti, pa vise od 2-3 intervala pravi
#' prazne ili skoro prazne kategorije.
#'
#' @param data data.frame (tipicno train ili test skup)
#' @return data.frame sa diskretizovanim BHK/Size/Bathroom kolonama i
#'   nepromenjenim ostalim kolonama
prepare_for_naive_bayes <- function(data) {
  numeric_cols <- c("BHK", "Size", "Bathroom")
  discretized <- quantile_discretize_df(data[numeric_cols], breaks = c(2, 5, 2))

  cbind(discretized, data[setdiff(names(data), numeric_cols)])
}

#' Trenira Naive Bayes model za High_Rent
#'
#' @param train_data pripremljen (diskretizovan) train skup
#' @return objekat klase naiveBayes
train_naive_bayes <- function(train_data) {
  e1071::naiveBayes(High_Rent ~ ., data = train_data)
}

#' Racuna ROC krivu i AUC za predikcije modela na test skupu
#'
#' @param model naiveBayes model
#' @param test_data pripremljen test skup
#' @return objekat klase roc (paket pROC)
compute_roc <- function(model, test_data) {
  probs <- predict(model, newdata = test_data, type = "raw")

  pROC::roc(
    response = test_data$High_Rent,
    predictor = probs[, "yes"],
    levels = c("no", "yes"),
    quiet = TRUE
  )
}

#' Nalazi prag koji maksimizuje sumu specificity i sensitivity (Youden J)
#'
#' @param roc_obj objekat klase roc
#' @return numericka vrednost praga
find_youden_threshold <- function(roc_obj) {
  coords_best <- pROC::coords(roc_obj, x = "best", best.method = "youden",
                               ret = "threshold", transpose = FALSE)
  as.numeric(coords_best$threshold)
}

#' Klasifikuje test skup koriscenjem zadatog praga verovatnoce za klasu "yes"
#'
#' @param model naiveBayes model
#' @param test_data pripremljen test skup
#' @param threshold prag verovatnoce (default 0.5 = podrazumevano pravilo)
#' @return factor predikcija sa nivoima c("no", "yes")
predict_with_threshold <- function(model, test_data, threshold = 0.5) {
  probs <- predict(model, newdata = test_data, type = "raw")
  factor(
    ifelse(probs[, "yes"] >= threshold, "yes", "no"),
    levels = c("no", "yes")
  )
}
