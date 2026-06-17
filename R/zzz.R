.onLoad <- function(libname, pkgname) {
  ns <- topenv()
  # Install the seaborn default look as the active global theme + color scales,
  # mirroring how `import seaborn` + set_theme() mutates matplotlib rcParams.
  # Wrapped in try() so a headless device or odd ggplot2 state can't block load.
  try(set_theme(), silent = TRUE)
  # Create and export the sns.* dotted aliases now that all functions exist.
  try(.rb_install_sns_aliases(ns), silent = TRUE)
  invisible()
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "reaborn ", utils::packageVersion("reaborn"),
    " — seaborn, the R way. Plots are ggplots; extend them with +."
  )
}
