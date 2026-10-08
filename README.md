# twelvedataR

<!-- badges: start -->
[![R-CMD-check](https://github.com/Tvths/twelvedataR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Tvths/twelvedataR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`twelvedataR` is an R package for retrieving historical market prices and
latest quotes from the [Twelve Data REST API](https://twelvedata.com/docs).
It validates request inputs and returns ordinary R data frames.

## Installation

```r
install.packages("pak")
pak::pak("Tvths/twelvedataR")
```

## API key

Create a Twelve Data account, then store the API key in your user-level
`.Renviron` file. In RStudio, open it with:

```r
usethis::edit_r_environ()
```

Add the following line, save the file, and restart R:

```text
TWELVEDATA_API_KEY=your_key_here
```

Keep the key out of scripts and Git. The package reads it from the environment
for each request. Twelve Data plan limits and API credit costs vary; check your
account and the [API documentation](https://twelvedata.com/docs) before making
large or repeated requests.

## Examples

Download the latest 100 daily observations for Apple:

```r
library(twelvedataR)

aapl <- get_time_series("AAPL", interval = "1day", outputsize = 100)
head(aapl)

plot(aapl$datetime, aapl$close, type = "l",
     xlab = "Date (UTC)", ylab = "Closing price",
     main = "AAPL daily closing prices")
```

Request observations in a date range. When both dates are supplied,
`outputsize` is omitted from the API request; Twelve Data's per-request
maximum still applies:

```r
jan <- get_time_series(
  "AAPL",
  interval = "1day",
  start_date = "2024-01-01",
  end_date = "2024-01-31"
)

quote <- get_quote("AAPL")
quote[, c("symbol", "name", "close", "change", "percent_change")]
```

See the package vignette for more examples:

```r
vignette("twelvedataR")
```

## Tests and package check

The default test suite runs without an API key or internet access:

```r
devtools::test()
devtools::check()
```

Optional live API tests are skipped by default. To enable them, set
`TWELVEDATA_API_TESTS=true` and `TWELVEDATA_API_KEY` in your environment before
running the tests. These requests use your Twelve Data API allowance.

The R-CMD-check run for package-code commit `1777ebf` on 2026-10-08 completed
all five CI jobs successfully. Its GitHub-hosted runner notices concerned
the upcoming `ubuntu-latest` image migration and macOS runner capacity;
these are infrastructure advisories, and all package-check jobs passed.

## Shiny application

The Shiny application is published in the separate GitHub repository
`Tvths/Twelvedata_shiny`. After installing this package and setting the API
key above, launch it with:

```r
shiny::runGitHub("Twelvedata_shiny", "Tvths")
```

## Authors

| Name | LiU-ID | GitHub | Email |
|---|---|---|---|
| Zhengyu Wang | `zhewa470` | [wwwzyccc777](https://github.com/wwwzyccc777) | zhewa470@student.liu.se |
| Viet Tien Trinh | `vietr933` | [Tvths](https://github.com/Tvths) | vietr933@student.liu.se |
