# utils.R
#
# Pomocne funkcije koje se koriste u vise faza analize:
#   - get_evaluation_metrics(): racuna accuracy/precision/recall/F1 iz
#     konfuzione matrice
#   - quantile_discretize_df(): diskretizuje numericke kolone po kvantilima
#
# Napomena o quantile_discretize_df(): originalna verzija ove analize je
# koristila bnlearn::discretize(method = "quantile"). Paket bnlearn nije
# dostupan preko apt-a, a instalacija sa CRAN-a je blokirana mreznim
# ogranicenjima okruzenja u kom je ovaj projekat pripreman, pa je ista ideja
# (podela svake numericke promenljive na K intervala jednake frekvencije)
# implementirana direktno preko quantile() i cut() iz base R-a. Ovo ima i
# prednost - jedna manja zavisnost za ceo projekat.

#' Racuna standardne metrike klasifikacije iz konfuzione matrice 2x2
#'
#' Pretpostavlja se matrica oblika table(true = ..., predicted = ...) gde je
#' [1,1] = negativna klasa tacno predvidjena (TN), a [2,2] = pozitivna klasa
#' tacno predvidjena (TP). Ako je pozitivna klasa u drugom redu/koloni
#' (alfabetski "yes" dolazi posle "no"), ovo vazi automatski za factor
#' nivoe c("no", "yes").
#'
#' @param cm 2x2 table (confusion matrix)
#' @return imenovan numericki vektor: Accuracy, Precision, Recall, F1
get_evaluation_metrics <- function(cm) {
  stopifnot(all(dim(cm) == c(2, 2)))

  TP <- cm[2, 2]
  TN <- cm[1, 1]
  FP <- cm[1, 2]
  FN <- cm[2, 1]

  accuracy  <- sum(diag(cm)) / sum(cm)
  precision <- TP / (TP + FP)
  recall    <- TP / (TP + FN)
  f1        <- (2 * precision * recall) / (precision + recall)

  c(Accuracy = accuracy, Precision = precision, Recall = recall, F1 = f1)
}

#' Diskretizuje jednu numericku promenljivu na intervale jednake frekvencije
#'
#' @param x numericki vektor
#' @param breaks broj intervala (kategorija) koje treba dobiti
#' @return factor
quantile_discretize <- function(x, breaks) {
  probs <- seq(0, 1, length.out = breaks + 1)
  cuts <- unique(stats::quantile(x, probs = probs, na.rm = TRUE, type = 7))

  if (length(cuts) < 2) {
    stop("Promenljiva nema dovoljno razlicitih vrednosti za trazeni broj intervala.")
  }

  cut(x, breaks = cuts, include.lowest = TRUE, dig.lab = 4)
}

#' Diskretizuje vise kolona data.frame-a odjednom, svaku sa svojim brojem
#' intervala (analogno bnlearn::discretize(..., method = "quantile"))
#'
#' @param df data.frame sa iskljucivo numerickim kolonama koje treba
#'   diskretizovati
#' @param breaks numericki vektor - broj intervala za svaku kolonu, istim
#'   redosledom kao kolone u df
#' @return data.frame sa factor kolonama
quantile_discretize_df <- function(df, breaks) {
  stopifnot(ncol(df) == length(breaks))

  out <- Map(quantile_discretize, df, breaks)
  as.data.frame(out)
}
