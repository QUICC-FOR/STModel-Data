# Connect a R session to the remote QUICC-FOR PostgreSQL database
# November 13th, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")
source("credentials.r")

dbname <- "db_quicc_for"
dbhost <- "srbd04.uqar.ca"
dbport <- 5432

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser, password=dbpass) 
