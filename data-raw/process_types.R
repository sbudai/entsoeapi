# read raw tsv, trim the character columns and remove empty columns
process_types <- fs::path("data-raw",
                          "process_types",
                          ext = "tsv") |>
  data.table::fread(encoding = "UTF-8", fill = TRUE) |>
  purrr::modify_if(is.character, trimws, which = "both") |>
  purrr::discard(~is.na(.x) |> all())

# save the package data in the correct format
usethis::use_data(process_types, overwrite = TRUE)
