#' reaborn: Statistical Data Visualization, the Seaborn Way
#'
#' reaborn is an R port of the Python seaborn library. It mirrors seaborn's
#' public function API (identical names, arguments, and defaults) and produces
#' visually indistinguishable plots built on ggplot2. Every reaborn plot is a
#' ggplot object, so it composes with the full ggplot2 grammar of graphics.
#'
#' @keywords internal
#' @import ggplot2
#' @importFrom grDevices col2rgb rgb colorRamp convertColor
#' @importFrom stats approx
#' @rawNamespace exportPattern("^sns\\.")
"_PACKAGE"

# Internal package environment: holds the active theme/context state so that
# set_theme() can mutate global look the way seaborn mutates matplotlib rcParams.
.reaborn <- new.env(parent = emptyenv())
