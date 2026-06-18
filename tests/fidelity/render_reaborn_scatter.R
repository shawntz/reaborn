# M0 fidelity harness: render the seaborn default scatter using reaborn's theme
# + palette, for side-by-side / SSIM comparison against the seaborn reference.
suppressMessages(devtools::load_all(quiet = TRUE))

pen <- load_dataset("penguins")
pal <- color_palette("deep", 3)

p <- ggplot2::ggplot(
  pen,
  ggplot2::aes(bill_length_mm, bill_depth_mm, colour = species)
) +
  ggplot2::geom_point(size = 2.4, stroke = 0) +
  ggplot2::scale_colour_manual(values = pal) +
  ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
  ggplot2::scale_y_continuous(breaks = rb_mpl_breaks()) +
  ggplot2::labs(x = "bill_length_mm", y = "bill_depth_mm", colour = "species") +
  move_legend(loc = "lower left")

ggplot2::ggsave(
  "tests/fidelity/out/reaborn_scatter.png", p,
  width = 6, height = 5, dpi = 100, bg = "white"
)
cat("reaborn PNG saved\n")
