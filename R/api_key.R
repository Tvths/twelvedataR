# Internal helper: read the Twelve Data API key from an environment variable.
# The key is never stored in the package or in a global variable.
td_api_key <- function() {
  key <- Sys.getenv("TWELVEDATA_API_KEY")
  if (!nzchar(key)) {
    stop(
      "No API key found. Add TWELVEDATA_API_KEY=<your key> to your .Renviron ",
      "(usethis::edit_r_environ()) and restart R.",
      call. = FALSE
    )
  }
  key
}
