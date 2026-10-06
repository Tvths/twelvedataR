#' Download historical prices from Twelve Data
#'
#' Retrieves historical OHLCV (open, high, low, close, volume) data for a
#' stock, ETF, currency pair or cryptocurrency from the Twelve Data
#' \code{/time_series} endpoint.
#'
#' An API key is required. Store it in your \code{.Renviron} file as
#' \code{TWELVEDATA_API_KEY=<your key>}.
#'
#' @param symbol A single character string, e.g. \code{"AAPL"},
#'   \code{"EUR/USD"} or \code{"BTC/USD"}.
#' @param interval Time between observations. One of \code{"1min"},
#'   \code{"5min"}, \code{"15min"}, \code{"30min"}, \code{"45min"},
#'   \code{"1h"}, \code{"2h"}, \code{"4h"}, \code{"1day"}, \code{"1week"},
#'   \code{"1month"}.
#' @param outputsize Number of observations to return, between 1 and 5000.
#'   Ignored by the API when both \code{start_date} and \code{end_date}
#'   are given.
#' @param start_date,end_date Optional dates (\code{"YYYY-MM-DD"} strings or
#'   \code{Date} objects) limiting the period.
#'
#' @return A \code{data.frame} sorted by time with columns \code{datetime}
#'   (POSIXct, UTC), \code{open}, \code{high}, \code{low}, \code{close} and,
#'   when available, \code{volume}.
#'
#' @examples
#' \dontrun{
#' aapl <- get_time_series("AAPL", interval = "1day", outputsize = 100)
#' plot(aapl$datetime, aapl$close, type = "l")
#'
#' get_time_series("EUR/USD", "1day",
#'                 start_date = "2024-01-01", end_date = "2024-03-31")
#' }
#' @export
get_time_series <- function(symbol,
                            interval = "1day",
                            outputsize = 30,
                            start_date = NULL,
                            end_date = NULL) {
  check_symbol(symbol)

  valid_intervals <- c("1min", "5min", "15min", "30min", "45min",
                       "1h", "2h", "4h", "1day", "1week", "1month")
  if (!is.character(interval) || length(interval) != 1 ||
      !interval %in% valid_intervals) {
    stop("`interval` must be one of: ",
         paste(valid_intervals, collapse = ", "), call. = FALSE)
  }

  if (!is.numeric(outputsize) || length(outputsize) != 1 ||
      is.na(outputsize) || outputsize < 1 || outputsize > 5000 ||
      outputsize != round(outputsize)) {
    stop("`outputsize` must be a whole number between 1 and 5000.",
         call. = FALSE)
  }

  params <- list(symbol = symbol,
                 interval = interval,
                 outputsize = as.integer(outputsize),
                 timezone = "UTC")
  if (!is.null(start_date)) params$start_date <- check_date(start_date, "start_date")
  if (!is.null(end_date))   params$end_date   <- check_date(end_date, "end_date")
  if (!is.null(start_date) && !is.null(end_date) &&
      as.Date(params$start_date) > as.Date(params$end_date)) {
    stop("`start_date` must be before `end_date`.", call. = FALSE)
  }

  body <- td_request("time_series", params)
  parse_time_series(body$values)
}

# Internal: turn the "values" part of the JSON into a clean data.frame
parse_time_series <- function(values) {
  if (is.null(values) || length(values) == 0) {
    stop("The API returned no data for this request.", call. = FALSE)
  }
  df <- as.data.frame(values, stringsAsFactors = FALSE)

  num_cols <- intersect(c("open", "high", "low", "close", "volume"), names(df))
  df[num_cols] <- lapply(df[num_cols], as.numeric)

  # Daily data comes as "YYYY-MM-DD", intraday as "YYYY-MM-DD HH:MM:SS"
  dt <- as.POSIXct(df$datetime, tz = "UTC", format = "%Y-%m-%d %H:%M:%S")
  only_date <- is.na(dt)
  dt[only_date] <- as.POSIXct(df$datetime[only_date], tz = "UTC",
                              format = "%Y-%m-%d")
  df$datetime <- dt

  df <- df[order(df$datetime), c("datetime", num_cols), drop = FALSE]
  rownames(df) <- NULL
  df
}
