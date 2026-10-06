# Internal helper: send one GET request to the Twelve Data REST API.
#
# endpoint: e.g. "time_series" or "quote"
# params:   named list of query parameters (without apikey)
# api_key:  defaults to the key from the environment
#
# Returns the parsed JSON body as an R list.
# Stops with a clear message if the HTTP call fails OR if the API
# returns an error object in the body (Twelve Data may answer with
# status = "error" even when the HTTP code is 200).
td_request <- function(endpoint, params = list(), api_key = td_api_key()) {
  stopifnot(is.character(endpoint), length(endpoint) == 1)

  req <- httr2::request("https://api.twelvedata.com")
  req <- httr2::req_url_path_append(req, endpoint)
  req <- httr2::req_url_query(req, !!!params, apikey = api_key)
  req <- httr2::req_user_agent(req, "twelvedataR (R package)")
  # Retry automatically on 429 (rate limit) and transient errors
  req <- httr2::req_retry(req, max_tries = 3)
  # Do not let httr2 throw on 4xx; we handle the error body ourselves
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- httr2::req_perform(req)
  body <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  is_api_error <- !is.null(body$status) && identical(body$status, "error")
  if (httr2::resp_is_error(resp) || is_api_error) {
    code <- if (!is.null(body$code)) body$code else httr2::resp_status(resp)
    msg  <- if (!is.null(body$message)) body$message else "Unknown error"
    stop("Twelve Data API error ", code, ": ", msg, call. = FALSE)
  }

  body
}
