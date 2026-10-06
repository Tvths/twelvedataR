# Internal input checks, shared by the exported functions.
# Validating before calling the API saves requests (free plan: 8/min).

check_symbol <- function(symbol) {
  if (!is.character(symbol) || length(symbol) != 1 ||
      is.na(symbol) || !nzchar(trimws(symbol))) {
    stop("`symbol` must be a single non-empty character string, e.g. \"AAPL\".",
         call. = FALSE)
  }
  invisible(TRUE)
}

check_date <- function(x, name) {
  invalid_date <- function() {
    stop("`", name, "` must be a date in the format \"YYYY-MM-DD\".",
         call. = FALSE)
  }

  if (inherits(x, "Date") && length(x) == 1L && !is.na(x)) {
    d <- x
  } else if (is.character(x) && length(x) == 1L && !is.na(x) &&
             grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x)) {
    d <- suppressWarnings(tryCatch(
      as.Date(x, format = "%Y-%m-%d"),
      error = function(e) NA
    ))
    if (is.na(d) || format(d, "%Y-%m-%d") != x) invalid_date()
  } else {
    invalid_date()
  }

  format(d, "%Y-%m-%d")
}

check_outputsize <- function(outputsize) {
  if (!is.numeric(outputsize) || length(outputsize) != 1L ||
      is.na(outputsize) || outputsize < 1 || outputsize > 5000 ||
      outputsize != round(outputsize)) {
    stop("`outputsize` must be a whole number between 1 and 5000.",
         call. = FALSE)
  }
  as.integer(outputsize)
}
