# These tests need no internet and no API key, so they always run on CI.

test_that("missing API key gives a clear error", {
  withr::local_envvar(TWELVEDATA_API_KEY = "")
  expect_error(td_api_key(), "TWELVEDATA_API_KEY")
})

test_that("API key is read from the environment", {
  withr::local_envvar(TWELVEDATA_API_KEY = "test-key-123")
  expect_equal(td_api_key(), "test-key-123")
})

test_that("get_time_series validates symbol", {
  expect_error(get_time_series(123), "symbol")
  expect_error(get_time_series(c("AAPL", "MSFT")), "symbol")
  expect_error(get_time_series(""), "symbol")
  expect_error(get_time_series(NA_character_), "symbol")
})

test_that("get_time_series validates interval", {
  expect_error(get_time_series("AAPL", interval = "3days"), "interval")
  expect_error(get_time_series("AAPL", interval = 1), "interval")
})

test_that("get_time_series validates outputsize (API limits 1-5000)", {
  expect_error(get_time_series("AAPL", outputsize = 0), "outputsize")
  expect_error(get_time_series("AAPL", outputsize = 5001), "outputsize")
  expect_error(get_time_series("AAPL", outputsize = 10.5), "outputsize")
  expect_error(get_time_series("AAPL", outputsize = "10"), "outputsize")
})

test_that("get_time_series validates dates", {
  expect_error(get_time_series("AAPL", start_date = "not a date"), "start_date")
  expect_error(get_time_series("AAPL", start_date = "2024-05-01",
                               end_date = "2024-01-01"), "before")
})

test_that("get_quote validates symbol", {
  expect_error(get_quote(42), "symbol")
})

test_that("parse_time_series returns a clean, sorted data.frame", {
  fake <- data.frame(
    datetime = c("2024-01-03", "2024-01-02"),
    open = c("2", "1"), high = c("3", "2"), low = c("1", "0.5"),
    close = c("2.5", "1.5"), volume = c("100", "200"),
    stringsAsFactors = FALSE
  )
  df <- parse_time_series(fake)
  expect_s3_class(df, "data.frame")
  expect_equal(names(df), c("datetime", "open", "high", "low", "close", "volume"))
  expect_s3_class(df$datetime, "POSIXct")
  expect_type(df$close, "double")
  expect_equal(df$close, c(1.5, 2.5))   # sorted oldest first
})

test_that("parse_time_series handles intraday timestamps", {
  fake <- data.frame(datetime = "2024-01-02 15:30:00", close = "10",
                     stringsAsFactors = FALSE)
  df <- parse_time_series(fake)
  expect_equal(format(df$datetime, "%H:%M"), "15:30")
})

test_that("parse_time_series fails on empty data", {
  expect_error(parse_time_series(NULL), "no data")
})
