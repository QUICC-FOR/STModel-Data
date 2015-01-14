# Connect a R session to the remote QUICC-FOR PostgreSQL database
# November 13th, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")

## use when on campus
# dbname <- "db_quicc_for"
# dbhost <- "srbd04.uqar.ca"
# dbport <- 5432
# 

# use when off campus
dbname <- "db_quicc_for"
dbhost <- "127.0.0.1"
dbport <- 55432

drv <- dbDriver("PostgreSQL")
source("credentials.r")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser, password=dbpass)
