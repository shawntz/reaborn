# Miscellaneous plots: palplot (display a palette) and dogplot (an easter egg).

#' Plot the values in a color palette as a horizontal array
#'
#' Port of `seaborn.palplot`. Returns a [reaborn_plot].
#'
#' @param pal A sequence of colors (e.g. from [color_palette]).
#' @param size Scaling factor for the swatch size.
#' @return A `reaborn_plot`.
#' @export
palplot <- function(pal, size = 1) {
  n <- length(pal)
  df <- data.frame(x = seq_len(n), y = 1, fill = factor(seq_len(n)))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$x, y = .data$y, fill = .data$fill)) +
    ggplot2::geom_tile(width = 1, height = 1) +
    ggplot2::scale_fill_manual(values = stats::setNames(pal, seq_len(n)), guide = "none") +
    ggplot2::coord_fixed() +
    ggplot2::theme_void()
  reaborn_plot(p, call = match.call())
}

#' Who's a good boy?
#'
#' Port of `seaborn.dogplot` (an easter egg). Prints an affirmation.
#' @param ... Ignored.
#' @return Invisibly `NULL`.
#' @export
dogplot <- function(...) {
  message("\U0001F436  Woof! (seaborn's dogplot shows a very good dog; reaborn salutes them.)")
  invisible(NULL)
}
