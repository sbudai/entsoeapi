% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/en_helpers.R
\name{area_eic}
\alias{area_eic}
\title{Get Area Y Energy Identification Codes}
\usage{
area_eic()
}
\description{
This function downloads approved area Y
energy identification codes from this site:
https://www.entsoe.eu/data/energy-identification-codes-eic/eic-approved-codes
}
\examples{

library(entsoeapi)

eic_area <- area_eic()

str(eic_area)

}
