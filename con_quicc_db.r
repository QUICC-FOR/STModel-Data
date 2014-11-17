# Connect a R session to the remote QUICC-FOR PostgreSQL database
# November 13th, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")

dbname <- "db_quicc_for"
dbuser <- "vissst01"
dbhost <- "srdb04.uqar.ca"
dbport <- 5432

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser) 
