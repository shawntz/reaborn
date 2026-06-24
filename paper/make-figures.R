# Generate the manuscript figures from the installed reaborn package.
# Run from the package root:  Rscript paper/make-figures.R
suppressMessages(library(reaborn))
suppressMessages(library(ggplot2))

reaborn::set_theme(context = "paper")   # match the seaborn JOSS paper's scaling
set.seed(0)

## Figure 1: the SAME example as the seaborn JOSS paper (fmri relplot), in reaborn.
fmri <- load_dataset("fmri")
g1 <- relplot(
  data = fmri, kind = "line",
  x = "timepoint", y = "signal",
  hue = "event", style = "event", col = "region"
)
ggsave("paper/figures/fig-relplot.pdf", g1, width = 6.3, height = 2.7, device = cairo_pdf)
ggsave("paper/figures/fig-relplot.png", g1, width = 6.3, height = 2.7, dpi = 200, bg = "white")

## Figure 2: the grammar-of-graphics thesis. A reaborn one-liner returns a ggplot,
## so native ggplot2 layers (facets, an added stat) compose directly onto it.
pen <- load_dataset("penguins")
g2 <- scatterplot(data = pen, x = "bill_length_mm", y = "bill_depth_mm", hue = "species") +
  stat_ellipse(aes(colour = species), type = "norm", linewidth = 0.4) +
  facet_wrap(~island) +
  labs(title = NULL)
ggsave("paper/figures/fig-grammar.pdf", g2, width = 6.3, height = 2.5, device = cairo_pdf)
ggsave("paper/figures/fig-grammar.png", g2, width = 6.3, height = 2.5, dpi = 200, bg = "white")

reaborn::set_theme()  # restore
cat("Wrote manuscript figures to paper/figures/\n")
