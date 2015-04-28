# Connect a R session to the remote QUICC-FOR PostgreSQL database
# November 13th, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")

## use when on campus
dbname <- "db_quicc_for"
dbhost <- "srbd04.uqar.ca"
dbport <- 5432

# use when off campus
vpn = Sys.getenv("QC_VPN")
if(vpn == "Y" || vpn == "y") {
	dbname <- "db_quicc_for"
	dbhost <- "127.0.0.1"
	dbport <- 55432
}

# use colosse for GCMs
colosse = Sys.getenv("COLOSSE")
if(colosse == "Y" || colosse == "y") {
    dbname <- "mffp"
    dbhost <- "132.219.137.38"
    dbport <- 5432
}

drv <- dbDriver("PostgreSQL")
dbuser = Sys.getenv("QC_USERNAME")
dbpass = Sys.getenv("QC_PASSWORD")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser, password=dbpass)
