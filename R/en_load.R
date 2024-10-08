#' @title
#' Get Actual Total Load (6.1.A)
#'
#' @description
#' It is defined as equal to the actual sum of power generated by
#' plants on both TSO/DSO networks, from which is deduced:
#' - the balance (export-import) of exchanges on interconnections
#'   between neighbouring bidding zones
#' - the power absorbed by energy storage resources
#'
#' @param eic
#' Energy Identification Code of the bidding zone/country/control area
#' @param period_start
#' POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param period_end
#' POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param tidy_output
#' Defaults to TRUE. If TRUE, then flatten nested tables.
#' @param security_token
#' Security token for ENTSO-E transparency platform
#'
#' @export
#'
#' @examples
#'
#' library(entsoeapi)
#' library(lubridate)
#'
#' # German average daily load.
#' df <- load_actual_total(
#'   eic          = "10Y1001A1001A83F",
#'   period_start = ymd(x = Sys.Date() - days(x = 30), tz = "CET"),
#'   period_end   = ymd(x = Sys.Date(), tz = "CET"),
#'   tidy_output  = TRUE
#' )
#'
#' str(df)
#'
load_actual_total <- function(
  eic = NULL,
  period_start = lubridate::ymd(Sys.Date() - lubridate::days(x = 1L),
                                tz = "CET"),
  period_end = lubridate::ymd(Sys.Date(),
                              tz = "CET"),
  tidy_output = TRUE,
  security_token = Sys.getenv("ENTSOE_PAT")
) {
  # check if only one eic provided
  if (is.null(eic)) stop("One control area EIC should be provided.")
  if (length(eic) > 1L) {
    stop("This wrapper only supports one control area EIC per request.")
  }

  # check if valid security token is provided
  if (security_token == "") stop("Valid security token should be provided.")

  # convert timestamps into accepted format
  period_start <- url_posixct_format(period_start)
  period_end <- url_posixct_format(period_end)

  # check if target period not longer than 1 year
  period_range <- difftime(time1 = strptime(x = period_end,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           time2 = strptime(x = period_start,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           units = "days")
  if (period_range > 366L) stop("One year range limit should be applied!")

  # compose GET request url for a (maximum) 1 year long period
  request_url <- paste0(
    "https://web-api.tp.entsoe.eu/api",
    "?documentType=A65",
    "&processType=A16",
    "&outBiddingZone_Domain=", eic,
    "&periodStart=", period_start,
    "&periodEnd=", period_end,
    "&securityToken=", security_token
  )

  # send GET request
  en_cont_list <- api_req_safe(request_url)

  # return with the extracted the response
  return(extract_response(content = en_cont_list, tidy_output = tidy_output))
}



#' @title
#' Get Day-Ahead Total Load Forecast (6.1.B)
#'
#' @description
#' It is defined as equal to the day-ahead forecasted sum of
#' power generated by plants on both TSO/DSO networks,
#' from which is deduced:
#' - the balance (export-import) of exchanges on interconnections
#'   between neighbouring bidding zones
#' - the power absorbed by energy storage resources
#'
#' @param eic Energy Identification Code of the bidding zone/
#'            country/control area
#' @param period_start POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param period_end POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param tidy_output Defaults to TRUE
#'                    If TRUE, then flatten nested tables.
#' @param security_token Security token for ENTSO-E transparency platform
#'
#' @export
#'
#' @examples
#'
#' library(entsoeapi)
#' library(lubridate)
#'
#' # German average daily load.
#' df <- load_day_ahead_total_forecast(
#'   eic          = "10Y1001A1001A83F",
#'   period_start = ymd(x = Sys.Date() - days(x = 30), tz = "CET"),
#'   period_end   = ymd(x = Sys.Date(), tz = "CET"),
#'   tidy_output  = TRUE
#' )
#'
#' str(df)
#'
load_day_ahead_total_forecast <- function(
  eic = NULL,
  period_start = lubridate::ymd(Sys.Date() - lubridate::days(x = 1L),
                                tz = "CET"),
  period_end = lubridate::ymd(Sys.Date(),
                              tz = "CET"),
  tidy_output = TRUE,
  security_token = Sys.getenv("ENTSOE_PAT")
) {
  # check if only one eic provided
  if (is.null(eic)) stop("One control area EIC should be provided.")
  if (length(eic) > 1L) {
    stop("This wrapper only supports one control area EIC per request.")
  }

  # check if valid security token is provided
  if (security_token == "") stop("Valid security token should be provided.")

  # convert timestamps into accepted format
  period_start <- url_posixct_format(period_start)
  period_end <- url_posixct_format(period_end)

  # check if target period not longer than 1 year
  period_range <- difftime(time1 = strptime(x = period_end,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           time2 = strptime(x = period_start,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           units = "days")
  if (period_range > 366L) stop("One year range limit should be applied!")

  # compose GET request url for a (maximum) 1 year long period
  request_url <- paste0(
    "https://web-api.tp.entsoe.eu/api",
    "?documentType=A65",
    "&processType=A01",
    "&outBiddingZone_Domain=", eic,
    "&periodStart=", period_start,
    "&periodEnd=", period_end,
    "&securityToken=", security_token
  )

  # send GET request
  en_cont_list <- api_req_safe(request_url)

  # return with the extracted the response
  return(extract_response(content = en_cont_list, tidy_output = tidy_output))
}



#' @title
#' Get Week-Ahead Total Load Forecast (6.1.C)
#'
#' @description
#' It is defined as equal to the week-ahead forecasted sum of
#' power generated by plants on both TSO/DSO networks,
#' from which is deduced:
#' - the balance (export-import) of exchanges on interconnections
#'   between neighbouring bidding zones
#' - the power absorbed by energy storage resources
#'
#' @param eic Energy Identification Code of the bidding zone/
#'            country/control area
#' @param period_start POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param period_end POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param tidy_output Defaults to TRUE.
#'                    If TRUE, then flatten nested tables.
#' @param security_token Security token for ENTSO-E transparency platform
#'
#' @export
#'
#' @examples
#'
#' library(entsoeapi)
#' library(lubridate)
#'
#' df <- load_week_ahead_total_forecast(
#'   eic          = "10Y1001A1001A82H",
#'   period_start = ymd(x = "2019-11-01", tz = "CET"),
#'   period_end   = ymd(x = "2019-11-30", tz = "CET"),
#'   tidy_output  = TRUE
#' )
#'
#' str(df)
#'
load_week_ahead_total_forecast <- function(
  eic = NULL,
  period_start = lubridate::ymd(Sys.Date() - lubridate::days(x = 1L),
                                tz = "CET"),
  period_end = lubridate::ymd(Sys.Date(), tz = "CET"),
  tidy_output = TRUE,
  security_token = Sys.getenv("ENTSOE_PAT")
) {
  # check if only one eic provided
  if (is.null(eic)) stop("One control area EIC should be provided.")
  if (length(eic) > 1L) {
    stop("This wrapper only supports one control area EIC per request.")
  }

  # check if valid security token is provided
  if (security_token == "") stop("Valid security token should be provided.")

  # convert timestamps into accepted format
  period_start <- url_posixct_format(period_start)
  period_end <- url_posixct_format(period_end)

  # check if target period not longer than 1 year
  period_range <- difftime(time1 = strptime(x = period_end,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           time2 = strptime(x = period_start,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           units = "days")
  if (period_range > 366L) stop("One year range limit should be applied!")

  # compose GET request url for a (maximum) 1 year long period
  request_url <- paste0(
    "https://web-api.tp.entsoe.eu/api",
    "?documentType=A65",
    "&processType=A31",
    "&outBiddingZone_Domain=", eic,
    "&periodStart=", period_start,
    "&periodEnd=", period_end,
    "&securityToken=", security_token
  )

  # send GET request
  en_cont_list <- api_req_safe(request_url)

  # return with the extracted the response
  return(extract_response(content = en_cont_list, tidy_output = tidy_output))
}



#' @title
#' Get Month-Ahead Total Load Forecast (6.1.D)
#'
#' @description
#' It is defined as equal to the month-ahead forecasted sum of
#' power generated by plants on both TSO/DSO networks,
#' from which is deduced:
#' - the balance (export-import) of exchanges on interconnections
#'   between neighbouring bidding zones
#' - the power absorbed by energy storage resources
#'
#' @param eic Energy Identification Code of the bidding zone/
#'            country/control area
#' @param period_start POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param period_end POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param tidy_output Defaults to TRUE.
#'                    If TRUE, then flatten nested tables.
#' @param security_token Security token for ENTSO-E transparency platform
#'
#' @export
#'
#' @examples
#'
#' library(entsoeapi)
#' library(lubridate)
#'
#' df <- load_month_ahead_total_forecast(
#'   eic          = "10Y1001A1001A82H",
#'   period_start = ymd(x = "2019-11-01", tz = "CET"),
#'   period_end   = ymd(x = "2019-11-30", tz = "CET"),
#'   tidy_output  = TRUE
#' )
#'
#' str(df)
#'
load_month_ahead_total_forecast <- function(
  eic = NULL,
  period_start = lubridate::ymd(Sys.Date() - lubridate::days(x = 1L),
                                tz = "CET"),
  period_end = lubridate::ymd(Sys.Date(),
                              tz = "CET"),
  tidy_output = TRUE,
  security_token = Sys.getenv("ENTSOE_PAT")
) {
  # check if only one eic provided
  if (is.null(eic)) stop("One control area EIC should be provided.")
  if (length(eic) > 1L) {
    stop("This wrapper only supports one control area EIC per request.")
  }

  # check if valid security token is provided
  if (security_token == "") stop("Valid security token should be provided.")

  # convert timestamps into accepted format
  period_start <- url_posixct_format(period_start)
  period_end <- url_posixct_format(period_end)

  # check if target period not longer than 1 year
  period_range <- difftime(time1 = strptime(x = period_end,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           time2 = strptime(x = period_start,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           units = "days")
  if (period_range > 366L) stop("One year range limit should be applied!")

  # compose GET request url for a (maximum) 1 year long period
  request_url <- paste0(
    "https://web-api.tp.entsoe.eu/api",
    "?documentType=A65",
    "&processType=A32",
    "&outBiddingZone_Domain=", eic,
    "&periodStart=", period_start,
    "&periodEnd=", period_end,
    "&securityToken=", security_token
  )

  # send GET request
  en_cont_list <- api_req_safe(request_url)

  # return with the extracted the response
  return(extract_response(content = en_cont_list, tidy_output = tidy_output))
}



#' @title
#' Get Year-Ahead Total Load Forecast (6.1.E)
#'
#' @description
#' It is defined as equal to the year-ahead forecasted sum of
#' power generated by plants on both TSO/DSO networks,
#' from which is deduced:
#' - the balance (export-import) of exchanges on interconnections
#'   between neighbouring bidding zones
#' - the power absorbed by energy storage resources
#'
#' @param eic Energy Identification Code of the bidding zone/
#'            country/control area
#' @param period_start POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param period_end POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param tidy_output Defaults to TRUE.
#'                    If TRUE, then flatten nested tables.
#' @param security_token Security token for ENTSO-E transparency platform
#'
#' @export
#'
#' @examples
#'
#' library(entsoeapi)
#' library(lubridate)
#'
#' df <- load_year_ahead_total_forecast(
#'   eic          = "10Y1001A1001A82H",
#'   period_start = ymd(x = "2019-11-01", tz = "CET"),
#'   period_end   = ymd(x = "2019-11-30", tz = "CET"),
#'   tidy_output  = TRUE
#' )
#'
#' str(df)
#'
load_year_ahead_total_forecast <- function(
  eic = NULL,
  period_start = lubridate::ymd(Sys.Date() - lubridate::days(x = 1L),
                                tz = "CET"),
  period_end = lubridate::ymd(Sys.Date(), tz = "CET"),
  tidy_output = TRUE,
  security_token = Sys.getenv("ENTSOE_PAT")
) {
  # check if only one eic provided
  if (is.null(eic)) stop("One control area EIC should be provided.")
  if (length(eic) > 1L) {
    stop("This wrapper only supports one control area EIC per request.")
  }

  # check if valid security token is provided
  if (security_token == "") stop("Valid security token should be provided.")

  # convert timestamps into accepted format
  period_start <- url_posixct_format(period_start)
  period_end <- url_posixct_format(period_end)

  # check if target period not longer than 1 year
  period_range <- difftime(time1 = strptime(x = period_end,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           time2 = strptime(x = period_start,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           units = "days")
  if (period_range > 366L) stop("One year range limit should be applied!")

  # compose GET request url for a (maximum) 1 year long period
  request_url <- paste0(
    "https://web-api.tp.entsoe.eu/api",
    "?documentType=A65",
    "&processType=A33",
    "&outBiddingZone_Domain=", eic,
    "&periodStart=", period_start,
    "&periodEnd=", period_end,
    "&securityToken=", security_token
  )

  # send GET request
  en_cont_list <- api_req_safe(request_url)

  # return with the extracted the response
  return(extract_response(content = en_cont_list, tidy_output = tidy_output))
}



#' @title
#' Get Year-Ahead Forecast Margin (8.1)
#'
#' @description
#' It is defined as a difference between yearly forecast of
#' available generation capacity and yearly forecast of
#' total load, taking into account the forecast of
#' total generation capacity forecast of availability of
#' generation and forecast of reserves contracted for
#' system services.
#'
#' @param eic Energy Identification Code of the bidding zone/
#'            country/control area
#' @param period_start POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param period_end POSIXct or YYYY-MM-DD HH:MM:SS format
#' @param tidy_output Defaults to TRUE.
#'                    If TRUE, then flatten nested tables.
#' @param security_token Security token for ENTSO-E transparency platform
#'
#' @export
#'
#' @examples
#'
#' library(entsoeapi)
#' library(lubridate)
#'
#' df <- load_year_ahead_forecast_margin(
#'   eic          = "10Y1001A1001A82H",
#'   period_start = ymd(x = "2019-01-01", tz = "CET"),
#'   period_end   = ymd(x = "2019-12-31", tz = "CET"),
#'   tidy_output  = TRUE
#' )
#'
#' str(df)
#'
load_year_ahead_forecast_margin <- function(
  eic = NULL,
  period_start = lubridate::ymd(Sys.Date() - lubridate::days(x = 1L),
                                tz = "CET"),
  period_end = lubridate::ymd(Sys.Date(), tz = "CET"),
  tidy_output = TRUE,
  security_token = Sys.getenv("ENTSOE_PAT")
) {
  # check if only one eic provided
  if (is.null(eic)) stop("One control area EIC should be provided.")
  if (length(eic) > 1L) {
    stop("This wrapper only supports one control area EIC per request.")
  }

  # check if valid security token is provided
  if (security_token == "") stop("Valid security token should be provided.")

  # convert timestamps into accepted format
  period_start <- url_posixct_format(period_start)
  period_end <- url_posixct_format(period_end)

  # check if target period not longer than 1 year
  period_range <- difftime(time1 = strptime(x = period_end,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           time2 = strptime(x = period_start,
                                            format = "%Y%m%d%H%M",
                                            tz = "UTC") |>
                             as.POSIXct(tz = "UTC"),
                           units = "days")
  if (period_range > 366L) stop("One year range limit should be applied!")

  # compose GET request url for a (maximum) 1 year long period
  request_url <- paste0(
    "https://web-api.tp.entsoe.eu/api",
    "?documentType=A70",
    "&processType=A33",
    "&outBiddingZone_Domain=", eic,
    "&periodStart=", period_start,
    "&periodEnd=", period_end,
    "&securityToken=", security_token
  )

  # send GET request
  en_cont_list <- api_req_safe(request_url)

  # return with the extracted the response
  return(extract_response(content = en_cont_list, tidy_output = tidy_output))
}
