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
  d <- tryCatch(as.Date(x), error = function(e) NA)
  if (length(d) != 1 || is.na(d)) {
    stop("`", name, "` must be a date in the format \"YYYY-MM-DD\".",
         call. = FALSE)
  }
  format(d, "%Y-%m-%d")
}
