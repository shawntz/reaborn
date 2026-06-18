# Fidelity harness: render the filled-KDE comparison panel through reaborn's
# public kdeplot() (hue legend, fill), for side-by-side comparison against the
# seaborn reference. Rendered at the same 6.5x5in @100dpi as the other panels so
# data-raw/make-gallery.py can composite it without rescaling drift.
suppressMessages(devtools::load_all(quiet = TRUE))

pen <- load_dataset("penguins")

p <- kdeplot(pen, x = "flipper_length_mm", hue = "species", fill = TRUE)

ggplot2::ggsave(
  "tests/fidelity/out/reaborn_kde.png", p,
  width = 6.5, height = 5, dpi = 100, bg = "white"
)
cat("reaborn KDE PNG saved\n")
