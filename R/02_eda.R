# 02_eda.R
#
# Eksplorativna analiza: kako se raspodela svake prediktorske promenljive
# razlikuje izmedju "high rent" i "low rent" nekretnina. Ovo je i osnova za
# odluku da se sve raspolozive promenljive zadrze u modelu - za svaku od
# njih postoji vizuelno vidljiva razlika izmedju dve klase.

library(ggplot2)

#' Generise EDA grafike za rent skup podataka
#'
#' @param data ociscen data.frame (izlaz load_and_clean_rent_data())
#' @return imenovana lista ggplot objekata
generate_eda_plots <- function(data) {
  theme_set(theme_minimal(base_size = 12))

  plots <- list()

  plots$bhk <- ggplot(data, aes(x = BHK, fill = High_Rent)) +
    geom_density(alpha = 0.5) +
    labs(
      title = "Broj soba (BHK) po kategoriji kirije",
      x = "BHK (Bedroom-Hall-Kitchen)", y = "Gustina", fill = "High Rent"
    )

  plots$size <- ggplot(data, aes(x = Size, fill = High_Rent)) +
    geom_density(alpha = 0.5) +
    labs(
      title = "Povrsina stana po kategoriji kirije",
      x = "Povrsina (sq. ft.)", y = "Gustina", fill = "High Rent"
    )

  plots$bathroom <- ggplot(data, aes(x = Bathroom, fill = High_Rent)) +
    geom_density(alpha = 0.5) +
    labs(
      title = "Broj kupatila po kategoriji kirije",
      x = "Broj kupatila", y = "Gustina", fill = "High Rent"
    )

  plots$city <- ggplot(data, aes(x = City, fill = High_Rent)) +
    geom_bar(position = "fill") +
    labs(
      title = "Udeo skupih nekretnina po gradu",
      x = NULL, y = "Udeo", fill = "High Rent"
    ) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1))

  plots$furnishing <- ggplot(data, aes(x = Furnishing.Status, fill = High_Rent)) +
    geom_bar(position = "fill") +
    labs(
      title = "Udeo skupih nekretnina po opremljenosti",
      x = NULL, y = "Udeo", fill = "High Rent"
    )

  plots$tenant <- ggplot(data, aes(x = Tenant.Preferred, fill = High_Rent)) +
    geom_bar(position = "fill") +
    labs(
      title = "Udeo skupih nekretnina po preferiranom zakupcu",
      x = NULL, y = "Udeo", fill = "High Rent"
    ) +
    theme(axis.text.x = element_text(angle = 15, hjust = 1))

  plots$contact <- ggplot(data, aes(x = Point.of.Contact, fill = High_Rent)) +
    geom_bar(position = "fill") +
    labs(
      title = "Udeo skupih nekretnina po tipu kontakta",
      x = NULL, y = "Udeo", fill = "High Rent"
    ) +
    theme(axis.text.x = element_text(angle = 15, hjust = 1))

  plots
}

#' Cuva sve EDA grafike kao PNG fajlove
#'
#' @param plots imenovana lista ggplot objekata (izlaz generate_eda_plots())
#' @param out_dir folder u koji se cuvaju slike (kreira se ako ne postoji)
save_eda_plots <- function(plots, out_dir = "figures") {
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

  for (name in names(plots)) {
    ggsave(
      filename = file.path(out_dir, paste0("eda_", name, ".png")),
      plot = plots[[name]],
      width = 7, height = 4.5, dpi = 150
    )
  }

  invisible(NULL)
}
