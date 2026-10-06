#' Get the latest quote for a symbol
#'
#' Retrieves the most recent quote (latest price, daily change, 52-week
#' range etc.) from the Twelve Data \code{/quote} endpoint.
#'
#' @param symbol A single character string, e.g. \code{"AAPL"}.
#'
#' @return A one-row \code{data.frame} with columns \code{symbol},
#'   \code{name}, \code{exchange}, \code{currency}, \code{datetime},
#'   \code{open}, \code{high}, \code{low}, \code{close},
#'   \code{previous_close}, \code{change} and \code{percent_change}.
#'
#' @examples
#' \dontrun{
#' get_quote("AAPL")
#' }
#' @export
get_quote <- function(symbol) {
  check_symbol(symbol)
  body <- td_request("quote", list(symbol = symbol))

  get_field <- function(x) if (is.null(body[[x]])) NA else body[[x]]

  out <- data.frame(
    symbol         = get_field("symbol"),
    name           = get_field("name"),
    exchange       = get_field("exchange"),
    currency       = get_field("currency"),
    datetime       = get_field("datetime"),
    open           = as.numeric(get_field("open")),
    high           = as.numeric(get_field("high")),
    low            = as.numeric(get_field("low")),
    close          = as.numeric(get_field("close")),
    previous_close = as.numeric(get_field("previous_close")),
    change         = as.numeric(get_field("change")),
    percent_change = as.numeric(get_field("percent_change")),
    stringsAsFactors = FALSE
  )
  out
}
