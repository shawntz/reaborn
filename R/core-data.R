# The shared data-assignment engine. Every reaborn plotting function funnels its
# inputs through rb_assign_variables(): it accepts seaborn-style long-form input
# (a data frame plus string column names) OR raw vectors, and returns a tidy
# frame whose columns are named by ROLE (x, y, hue, size, style, units, ...),
# together with each role's original name (for axis/legend labels) and inferred
# variable type. This mirrors seaborn's VectorPlotter.assign_variables.

# Classify a vector the way seaborn's variable_type does: numeric, datetime, or
# categorical. Integers count as numeric (seaborn maps them to continuous hue).
rb_variable_type <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXt"))) return("datetime")
  if (is.numeric(x)) return("numeric")
  "categorical"
}

# Ordered levels of a categorical variable, matching seaborn categorical_order:
# explicit order wins; factors use their levels; numeric is sorted; everything
# else keeps order of appearance (NOT alphabetical).
rb_categorical_order <- function(x, order = NULL) {
  if (!is.null(order)) return(as.character(order))
  if (is.factor(x)) return(levels(x))
  u <- unique(x[!is.na(x)])
  if (is.numeric(u)) u <- sort(u)
  as.character(u)
}

#' Assign plot variables from data + role references
#'
#' @param data A data frame, or `NULL` when passing vectors directly.
#' @param ... Named role assignments (`x=`, `y=`, `hue=`, ...). Each value is
#'   either a length-1 column name found in `data`, or a vector of values.
#' @return A list with `data` (tidy frame, columns named by role), `names`
#'   (role -> original variable name), and `types` (role -> variable type).
#' @keywords internal
rb_assign_variables <- function(data = NULL, ...) {
  vars <- list(...)
  vars <- vars[!vapply(vars, is.null, logical(1))]

  cols <- list()
  names_map <- list()
  for (role in names(vars)) {
    v <- vars[[role]]
    if (is.character(v) && length(v) == 1L && !is.null(data) && v %in% names(data)) {
      cols[[role]] <- data[[v]]
      names_map[[role]] <- v
    } else if (is.character(v) && length(v) == 1L && is.null(data)) {
      # A bare string with no data frame is treated as a literal constant label,
      # but more commonly this is a user error; surface it clearly.
      stop(sprintf("Variable '%s' = '%s' given but no `data` to look it up in", role, v))
    } else {
      cols[[role]] <- v
      names_map[[role]] <- if (!is.null(names(vars)) && nzchar(role)) role else NULL
    }
  }

  # Recycle scalars and assemble a tidy frame with role-named columns.
  n <- max(vapply(cols, length, integer(1)), 0L)
  for (role in names(cols)) {
    if (length(cols[[role]]) == 1L && n > 1L) cols[[role]] <- rep(cols[[role]], n)
  }
  df <- if (length(cols)) {
    as.data.frame(cols, stringsAsFactors = FALSE, optional = TRUE,
                  check.names = FALSE)
  } else {
    data.frame()
  }
  names(df) <- names(cols)

  types <- lapply(df, rb_variable_type)
  list(data = df, names = names_map, types = types)
}

# Drop rows with NA in any of the given roles (seaborn drops incomplete rows
# before plotting). Returns the filtered frame.
rb_drop_na <- function(df, roles = names(df)) {
  roles <- intersect(roles, names(df))
  if (!length(roles)) return(df)
  keep <- stats::complete.cases(df[roles])
  df[keep, , drop = FALSE]
}
