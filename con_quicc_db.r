# Connect a R session to the remote QUICC-FOR PostgreSQL database
# November 13th, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")

dbname <- "quicc_for_dev"
dbuser <- "postgres"
dbpass <- "maple"
dbhost <- "localhost"
dbport <- 5433

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser, password=dbpass) 
