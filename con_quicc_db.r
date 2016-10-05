require("RPostgreSQL")

drv <- dbDriver("PostgreSQL")
dbname <- "quicc_for_dev"
dbhost <- "localhost"
user <- "postgres"

con <- dbConnect(drv, dbname=dbname,host=dbhost,user=user)
