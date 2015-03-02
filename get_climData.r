# Get Climat data
# Date: November 16th, 2014

# This script extract climat for all plots
# Return the mean of the bioclimatic variables over the last 15 years before the year of the measurement.
## ---------------------------------------------

# Climatic variables descriptions:

  # mean_diurnal_range: Avg of monthly temperature ranges
  # isothermality:  mean_diurnal_range ÷  temp_annual_range
  # temp_seasonality: Standard deviation of monthly-mean temperature estimates expressed as a percent of their mean
  # max_temp_warmest_period: Highest monthly maximum temperature
  # min_temp_coldest_period: Lowest monthly minimum temperature
  # temp_annual_range: max_temp_warmest_period – min_temp_coldest_period
  # mean_temperatre_wettest_quarter: Avg temperature during 3 wettest months
  # mean_temp_driest_quarter: Avg temperature during 3 driest months
  # mean_temp_warmest_quarter: Avg temperature during 3 warmest months
  # mean_temp_coldest_quarter: Avg temperature during 3 coldest months
  # annual_pp : Sum of monthly precipitation values
  # pp_wettest_period: Precipitation of the wettest month
  # pp_driest_period: Precipitation of the driest month
  # pp_seasonality: Standard deviation of the monthly precipitation estimates expressed as a percent of their mean
  # pp_wettest_quarter: Total precipitation of 3 wettest months
  # pp_driest_quarter: Total precipitation of 3 driest months
  # pp_warmest_quarter: Total precipitation of 3 warmest months
  # pp_coldest_quarter: Total precipitation of 3 coldest months
  # julian_day_number_start_growing_season: Julian day number at start of growing season
  # julian_day_number_at_end_growing_season: Julian day number at end of growing season
  # number_days_growing_season: Length of growing season (days)
  # total_pp_for_period_1: Total precipitation 3 weeks prior to growing season
  # total_pp_for_period_3: Total precipitation during the growing season
  # gdd_above_base_temp_for_period_3: Degree days (above 5ºC) for growing season Variable
  # annual_mean_temp: Avg of mean monthly temperatures
  # annual_min_temp: Avg of min monthly temperatures
  # annual_max_temp: Avg of max monthly temperatures
  # mean_temp_for_period_3: Average temperature during growing season
  # temp_range_for_period_3: Highest maximum temperature minus lowest minimum temperature during growing

# Source: http://journals.ametsoc.org/doi/abs/10.1175/2011BAMS3132.1

## Get climData from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')

#Load librairies
require('reshape2')

query_climData <- "
SELECT * FROM rdb_quicc.stm_plots_clim"

## Send the query to the database
climData <- dbGetQuery(con, query_climData)
## Time: Approx. 12 minutes


# Reshaping and writing grid dataset
## ---------------------------------------------

climData_reshape = climData

## Reshape
climData_reshape$biovar <- as.factor(climData_reshape$biovar)
climData_reshape[climData_reshape$mean_val == -9999.0,"avg_val"] <- NA
climData_reshape <- dcast(climData_reshape,plot_id+year_measured ~ biovar, value.var="avg_val")

## NOTE: For bio grids the values of temperature must be divided by 10, and the values of Temperature Seasonality (C of V) must be divided by 100
climData_reshape$mean_diurnal_range <- climData_reshape$mean_diurnal_range/10
climData_reshape$max_temp_warmest_period <- climData_reshape$max_temp_warmest_period/10
climData_reshape$mean_temp_coldest_quarter <- climData_reshape$mean_temp_coldest_quarter/10
climData_reshape$mean_temp_driest_quarter <- climData_reshape$mean_temp_driest_quarter/10
climData_reshape$mean_temp_warmest_quarter <- climData_reshape$mean_temp_warmest_quarter/10
climData_reshape$mean_temp_wettest_quarter <- climData_reshape$mean_temp_wettest_quarter/10
climData_reshape$min_temp_coldest_period <- climData_reshape$min_temp_coldest_period/10
climData_reshape$temp_annual_range <- climData_reshape$temp_annual_range/10
climData_reshape$temp_seasonality <- climData_reshape$temp_seasonality/100

# Writing final trees dataset
## ---------------------------------------------

write.table(climData_reshape, file="out_files/climData.csv", sep=',', row.names=FALSE)

