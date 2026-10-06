# These tests call the real API. They are skipped when no key is set
# (e.g. on CRAN). Kept few on purpose: the free plan allows 8 calls/minute.

skip_if_no_key <- function() {
  if (!nzchar(Sys.getenv("TWELVEDATA_API_KEY"))) {
    testthat::skip("TWELVEDATA_API_KEY not set")
  }
}

test_that("get_time_series returns the requested structure", {
  skip_on_cran(); skip_if_offline(); skip_if_no_key()
  df <- get_time_series("AAPL", interval = "1day", outputsize = 10)
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 10)
  expect_true(all(c("datetime", "open", "high", "low", "close") %in% names(df)))
  expect_true(all(df$high >= df$low))
  expect_false(is.unsorted(df$datetime))
})

test_that("a big query (maximum outputsize) works", {
  skip_on_cran(); skip_if_offline(); skip_if_no_key()
  df <- get_time_series("AAPL", interval = "1day", outputsize = 5000)
  expect_gt(nrow(df), 4000)   # AAPL has > 5000 trading days of history
})

test_that("historical data is stable for a fixed period", {
  skip_on_cran(); skip_if_offline(); skip_if_no_key()
  df <- get_time_series("AAPL", interval = "1day",
                        start_date = "2024-01-02", end_date = "2024-01-31")
  expect_gt(nrow(df), 15)
  expect_true(all(as.Date(df$datetime) >= as.Date("2024-01-02")))
  expect_true(all(as.Date(df$datetime) <= as.Date("2024-01-31")))
  # The first trading day of 2024 never changes
  expect_equal(as.Date(df$datetime[1]), as.Date("2024-01-02"))
})

test_that("an unknown symbol gives an API error", {
  skip_on_cran(); skip_if_offline(); skip_if_no_key()
  expect_error(get_time_series("NOTAREALTICKER123"), "Twelve Data API error")
})

test_that("get_quote returns one row", {
  skip_on_cran(); skip_if_offline(); skip_if_no_key()
  q <- get_quote("AAPL")
  expect_equal(nrow(q), 1)
  expect_equal(q$symbol, "AAPL")
  expect_type(q$close, "double")
})
