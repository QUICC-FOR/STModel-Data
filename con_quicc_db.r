require("RPostgreSQL")

## use when logged to ip33 with your regular account
dbname <- "quicc_for_dev"
dbhost <- "localhost"
dbuser <- 'sviss' # please change for your username, if you don't have one ask to Steve
dbport <- 5432
drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser)
