# sns.* namespace shim. In Python one writes `sns.scatterplot(...)`. Because R
# allows dots in identifiers, reaborn defines real functions literally named
# `sns.scatterplot`, `sns.color_palette`, etc., so pasted Python runs verbatim.
# These dotted aliases are created at load time from the canonical seaborn public
# names below, for every one that reaborn currently implements, and exported via
# exportPattern("^sns\\.") in NAMESPACE.

# The canonical set of seaborn public function names (its modules' __all__, plus
# the most-used utils). As reaborn implements more of these, more aliases appear
# automatically -- the installer only aliases names that actually exist.
.RB_SNS_NAMES <- c(
  # relational
  "relplot", "scatterplot", "lineplot",
  # regression
  "lmplot", "regplot", "residplot",
  # categorical
  "catplot", "stripplot", "swarmplot", "boxplot", "violinplot",
  "boxenplot", "pointplot", "barplot", "countplot",
  # distributions
  "displot", "histplot", "kdeplot", "ecdfplot", "rugplot", "distplot",
  # matrix
  "heatmap", "clustermap",
  # miscplot
  "palplot", "dogplot",
  # axisgrid
  "FacetGrid", "PairGrid", "JointGrid", "pairplot", "jointplot",
  # palettes
  "color_palette", "hls_palette", "husl_palette", "mpl_palette",
  "dark_palette", "light_palette", "diverging_palette", "blend_palette",
  "xkcd_palette", "crayon_palette", "cubehelix_palette", "set_color_codes",
  # theming
  "set_theme", "set", "reset_defaults", "reset_orig", "axes_style",
  "set_style", "plotting_context", "set_context", "set_palette",
  # utils
  "desaturate", "saturate", "set_hls_values", "move_legend", "despine",
  "load_dataset", "get_dataset_names"
)

# Create `sns.<name>` aliases in the package namespace for every canonical name
# that is currently a defined function, and export them so they are visible after
# library(reaborn). Run from .onLoad (namespace fully built at that point).
.rb_install_sns_aliases <- function(ns = topenv()) {
  created <- character(0)
  for (nm in .RB_SNS_NAMES) {
    if (exists(nm, envir = ns, inherits = FALSE) &&
        is.function(get(nm, envir = ns, inherits = FALSE))) {
      alias <- paste0("sns.", nm)
      assign(alias, get(nm, envir = ns, inherits = FALSE), envir = ns)
      created <- c(created, alias)
    }
  }
  if (length(created)) {
    # Make the new aliases part of the namespace's export set so attaching the
    # package (library/require) puts them on the search path.
    try(namespaceExport(ns, created), silent = TRUE)
  }
  created
}
