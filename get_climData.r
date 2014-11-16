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
query_treeData  <- "
SELECT plot_id, year_measured, id_spe, surf_spe_m2*10000/plot_size as basal_area FROM(
	SELECT plot_id, year_measured, id_spe, sum(surf_mm2)/1000000 as surf_spe_m2, plot_size FROM (
			SELECT tree.plot_id, tree.year_measured,tree.tree_id,tree.id_spe,
			 (((tree.dbh)/2)^2*pi()) as surf_mm2, plot.plot_size
			FROM rdb_quicc.tree
			RIGHT OUTER JOIN rdb_quicc.stm_plot_ids USING (plot_id)
			LEFT OUTER JOIN rdb_quicc.plot USING (plot_id,year_measured)
			WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL 
			AND id_spe IN ('18032-ABI-BAL','18034-PIC-RUB','19408-QUE-RUB',
			'19462-FAG-GRA','19466-ALN-NA','19481-BET-ALL','19489-BET-PAP',
			'19511-OST-VIR','21536-TIL-AME','22453-POP-BAL','22463-POP-GRA',
			'24764-PRU-SER','24799-PRU-PEN','25319-SOR-AME','28728-ACE-RUB',
			'28731-ACE-SAC','32931-FRA-AME','32945-FRA-NIG','183295-PIC-GLA',
			'183302-PIC-MAR','183319-PIN-BAN','183412-LAR-LAR','195773-POP-TRE')
		) AS get_individual_tree_surf
	GROUP BY plot_id, year_measured, id_spe, plot_size 

	UNION ALL

	-- Other species
	SELECT plot_id, year_measured, 'other species' As id_spe, sum(surf_mm2)/1000000 as surf_spe_m2, plot_size FROM (
			SELECT tree.plot_id, tree.year_measured,tree.tree_id,tree.id_spe,
			 (((tree.dbh)/2)^2*pi()) as surf_mm2, plot.plot_size
			FROM rdb_quicc.tree
			RIGHT OUTER JOIN rdb_quicc.stm_plot_ids USING (plot_id)
			LEFT OUTER JOIN rdb_quicc.plot USING (plot_id,year_measured)
			WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL 
			AND id_spe NOT IN ('18032-ABI-BAL','18034-PIC-RUB','19408-QUE-RUB',
			'19462-FAG-GRA','19466-ALN-NA','19481-BET-ALL','19489-BET-PAP',
			'19511-OST-VIR','21536-TIL-AME','22453-POP-BAL','22463-POP-GRA',
			'24764-PRU-SER','24799-PRU-PEN','25319-SOR-AME','28728-ACE-RUB',
			'28731-ACE-SAC','32931-FRA-AME','32945-FRA-NIG','183295-PIC-GLA',
			'183302-PIC-MAR','183319-PIN-BAN','183412-LAR-LAR','195773-POP-TRE')
		) AS get_other_tree_species_surf
	GROUP BY plot_id, year_measured, plot_size
) AS final_tree_data
ORDER BY plot_id, year_measured, id_spe;
"

## Send the query to the database
treeData <- dbGetQuery(con, query_treeData)
## Time: Approx. 3 minutes

# Writing final trees dataset
## ---------------------------------------------

write.table(treeData, file="out_files/treeData.csv", sep=',', row.names=FALSE)

