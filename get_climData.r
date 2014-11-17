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

# Query 
query_climData  <- "
SELECT 	plot.plot_id,
	plot.year_measured,
	avg(mean_diurnal_range) as mean_diurnal_range,
	avg(isothermality) as isothermality,
	avg(temp_seasonality) as temp_seasonality,
	avg(max_temp_warmest_period) as max_temp_warmest_period,
	avg(min_temp_coldest_period) as min_temp_coldest_period,
	avg(temp_annual_range) as temp_annual_range,
	avg(mean_temperatre_wettest_quarter) as mean_temperatre_wettest_quarter,
	avg(mean_temp_driest_quarter) as mean_temp_driest_quarter,
	avg(mean_temp_warmest_quarter) as mean_temp_warmest_quarter,
	avg(mean_temp_coldest_quarter) as mean_temp_coldest_quarter,
	avg(annual_pp) as annual_pp,
	avg(pp_wettest_period) as pp_wettest_period,
	avg(pp_driest_period) as pp_driest_period,
	avg(pp_seasonality) as pp_seasonality,
	avg(pp_wettest_quarter) as pp_wettest_quarter,
	avg(pp_driest_quarter) as pp_driest_quarter,
	avg(pp_warmest_quarter) as pp_warmest_quarter,
	avg(pp_coldest_quarter) as pp_coldest_quarter,
	avg(julian_day_number_start_growing_season) as julian_day_number_start_growing_season,
	avg(julian_day_number_at_end_growing_season) as julian_day_number_at_end_growing_season,
	avg(number_days_growing_season) as number_days_growing_season,
	avg(total_pp_for_period_1) as total_pp_for_period_1,
	avg(total_pp_for_period_3) as total_pp_for_period_3,
	avg(gdd_above_base_temp_for_period_3) as gdd_above_base_temp_for_period_3,
	avg(annual_mean_temp) as annual_mean_temp,
	avg(annual_min_temp) as annual_min_temp,
	avg(annual_max_temp) as annual_max_temp,
	avg(mean_temp_for_period_3) as mean_temp_for_period_3,
	avg(temp_range_for_period_3) as temp_range_for_period_3
FROM rdb_quicc.climatic_data
RIGHT OUTER JOIN rdb_quicc.stm_plot_ids USING (plot_id)
LEFT OUTER JOIN rdb_quicc.plot USING (plot_id)
WHERE climatic_data.year_clim <= plot.year_measured AND climatic_data.year_clim > (plot.year_measured-15)
GROUP BY plot.plot_id, plot.year_measured
ORDER BY plot.plot_id, plot.year_measured
"

## Send the query to the database
climData <- dbGetQuery(con, query_climData)
## Time: Approx. 6 minutes

# Writing final trees dataset
## ---------------------------------------------

write.table(climData, file="out_files/climData.csv", sep=',', row.names=FALSE)

