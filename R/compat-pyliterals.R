# Python-literal compatibility bindings. The headline goal of reaborn is that a
# user can paste seaborn Python into R and have it run. Python's True/False/None
# are the most common literals appearing inside seaborn calls (fill=True,
# legend=False, hue=None), so reaborn exports them as bindings that resolve to
# the R equivalents. They become visible after `library(reaborn)`.
#
# This DOES shadow nothing in base R (R has no True/False/None), but a user who
# defines their own `True`/`None` will mask these -- documented, and the
# canonical values remain available as reaborn::True etc.

#' Python literal compatibility values
#'
#' `True`, `False`, and `None` are provided so that seaborn Python code pasted
#' into R (e.g. `histplot(data = df, x = "a", kde = True)`) runs unchanged.
#' They are exactly `TRUE`, `FALSE`, and `NULL`.
#'
#' @format `True` and `False` are length-one logicals; `None` is `NULL`.
#' @name python-literals
#' @rdname python-literals
#' @export
True <- TRUE

#' @rdname python-literals
#' @export
False <- FALSE

#' @rdname python-literals
#' @export
None <- NULL
