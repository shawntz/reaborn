# Dataset loading. Port of seaborn.load_dataset / get_dataset_names. A handful
# of common datasets are bundled in inst/extdata for offline use; anything else
# is downloaded from the seaborn-data repository and cached. Categorical column
# orderings are restored from the ground-truth fixtures so factor levels match
# seaborn (which ggplot would otherwise alphabetize).

SEABORN_DATA_URL <- "https://raw.githubusercontent.com/mwaskom/seaborn-data/master"

#' Load an example dataset from the seaborn-data repository
#'
#' Port of `seaborn.load_dataset`. Bundled datasets (penguins, tips, iris,
#' flights) load offline; others download from the seaborn-data repo and cache.
#' @param name Name of the dataset (the stem of a `.csv` in seaborn-data).
#' @param cache Whether to use the local cache (and bundled data).
#' @param data_home Optional cache directory.
#' @param ... Reserved for compatibility.
#' @return A data.frame, with categorical columns coerced to ordered factors
#'   matching seaborn.
#' @export
load_dataset <- function(name, cache = TRUE, data_home = NULL, ...) {
  path <- NULL
  bundled <- system.file("extdata", paste0(name, ".csv"), package = "reaborn")
  if (cache && nzchar(bundled) && file.exists(bundled)) {
    path <- bundled
  } else {
    cache_dir <- data_home %||% .rb_data_home()
    if (!dir.exists(cache_dir)) {
      dir.create(cache_dir, recursive = TRUE)
    }
    cached <- file.path(cache_dir, paste0(name, ".csv"))
    if (cache && file.exists(cached)) {
      path <- cached
    } else {
      url <- paste0(SEABORN_DATA_URL, "/", name, ".csv")
      ok <- tryCatch(
        {
          utils::download.file(url, cached, quiet = TRUE, mode = "wb")
          TRUE
        },
        error = function(e) FALSE
      )
      if (!ok) {
        stop(sprintf(
          "Could not load dataset '%s' (offline and not bundled)",
          name
        ))
      }
      path <- cached
    }
  }
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = TRUE)
  .rb_apply_dataset_dtypes(df, name)
}

#' @rdname load_dataset
#' @return For `get_dataset_names`, a character vector of available dataset names.
#' @export
get_dataset_names <- function() {
  bundled <- sub(
    "\\.csv$",
    "",
    list.files(system.file("extdata", package = "reaborn"), pattern = "\\.csv$")
  )
  fixtures <- tryCatch(names(.reaborn_fixtures$rc_style), error = function(e) {
    NULL
  })
  unique(c(
    bundled,
    c(
      "anagrams",
      "anscombe",
      "attention",
      "brain_networks",
      "car_crashes",
      "diamonds",
      "dots",
      "dowjones",
      "exercise",
      "flights",
      "fmri",
      "geyser",
      "glue",
      "healthexp",
      "iris",
      "mpg",
      "penguins",
      "planets",
      "seaice",
      "taxis",
      "tips",
      "titanic"
    )
  ))
}

# Restore seaborn's categorical dtypes / orderings for known datasets.
.rb_apply_dataset_dtypes <- function(df, name) {
  orders <- tryCatch(.reaborn_dataset_orders[[name]], error = function(e) NULL)
  if (is.null(orders)) {
    return(df)
  }
  for (col in names(orders)) {
    lv <- orders[[col]]
    if (!is.null(lv) && col %in% names(df)) {
      df[[col]] <- factor(df[[col]], levels = lv)
    }
  }
  df
}

.rb_data_home <- function() {
  Sys.getenv(
    "SEABORN_DATA",
    unset = file.path(tools::R_user_dir("reaborn", "cache"), "seaborn-data")
  )
}
