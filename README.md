STModel-Data
============

## Getting started

#### 1. Download repository

	git clone git@github.com:TheoreticalEcosystemEcology/STModel-Data.git
	cd STModel-Data

#### 2. Install R dependencies

    Rscript install_dependencies.r

Note for mac users: this may fail if pg_config is not in your path. If so, you need to
install psql first. This is easiest with macports:

    sudo port install postgresql93
    sudo ln -s /opt/local/lib/postgresql93/bin/* /opt/local/bin
    Rscript install_dependencies.r

#### 3. Get all datasets

##### Localy:

	make -j all

##### Remotely:

If you want to get the data and you are not at UQAR or connected by wired, please follow this procedure:

1. Modify ```con_quicc_db.r``` to:

```
require("RPostgreSQL")

dbname <- "db_quicc_for"
dbhost <- "127.0.0.1"
dbport <- 55432
```

2. Open the VPN tunnel:

    * Open the web page: https://eduvpn.uqar.ca.
    * Login with your UQAR account (e.g. viss0001 is my username)
    * Click on the icon «BD PostgreSQL SRBD04».
    * The tunnel to the QUICCFOR DB is open.

3. Run ```make -j all```

## Alternatively: Retrieve dataset separately

**Get only tree data**: ```make treeData```

**Get only climatic data**: ```make climData```

**Get only plot info data**: ```make plotInfoData```

**Get only past climate grid input**: ```make pastClimate_grid```

## Plots distribution

![Plots_distribution](./out_files/plots_map.png)

## Metadata

### Reshaping script

The reshape script comes in two parts, the first, `reshape/reshapeStates.r` computes the
states, and the second, `reshape/reshapeTransitions.r` computes transitions between
states. In general, use the makefile, either with `make -j all` or `make -j reshape` to
run the scripts (which will use default options). The most important option, setting the
threshold basal area for the R state, can be changed by editing the variable at the
beginning of the makefile. To see other options and change them, run the scripts using
Rscript. Start with:

    Rscript reshape/reshapeStates.r --help
    Rscript reshape/reshapeTransitions.r --help

to get information on the options. There is an additional script, 
`reshape/reshapeClimTest.r`, that does some testing. See its help for more information.
Finally, note that the file `reshape/tmpStateData_r$N.rdata`, where `$N` is the cutoff
for the R state, is a temporary file that should not be used. The correct output file,
assuming default options, is `out_files/transitions_r$N.rdata`.

Defaults:

* threshold basal area for determining the R state: 1 (change in makefile or with -r option)
* climate variables for transitions: annual mean temperature, annual precipitation
* output file: transitions_r1.rdata, where the number will be the r threshold
	

A rough outline of what the script does:

* Read coarse data from the treeData.csv, plotInfoData.csv, and climData.csv files produced by the sql queries.
* Collapse the tree data into a single state for each year sampled in each plot, using species lists specified in the script.
* Merge the collapsed data with the plotInfoData (to get lat/long)
* Merge this with the climate data into stateData. This is a dataframe with one row for each unique plot-year combination. This will output warnings if there are  missing records in the climate or state data; do not ignore these warnings!
* Output some basic summary statistics on the states
* reshapes the sample data into a transition data frame, containing columns for the measurement years, the states, and the mean of the 2 climate variables
* drop all rows from both the transition and state objects containing a U state
* scale the climate variables in the transition data frame
* print the transition table to the console
* save the state and the transition objects, and the transformation for the climate variables, into a single .rdata file

### plotInfoData

Column        | Description
---           | ---
**plot_id**   | Unique id of the plot
**longitude** | longitude of the plot (degree decimal)
**latitude**  | latitude of the plot (degree decimal)
**srid**      | Spatial Reference System Identifier. All plots have a srid code corresponding to the datum: WGS84 (see [here](http://spatialreference.org/ref/epsg/4326/)).
**drainage**  | *coming soon*
**slope**     | *coming soon* (in degree)

### treeData

Column | Description
---- | ---
**plot_id** | Unique id of the plot
**year_measured** | year of the measurement
**id_spe** | Species code, details are available in ./stm_code_species.csv file
**basal area** | basal area of the species in **m²/ha**

### climData

Column                                      | Description
---                                         | ---
**plot_id**                                 | Unique id of the plot
**year_measured**                           | year of the measurement
**mean_diurnal_range**                      | Avg of monthly temperature ranges
**isothermality**                           | mean_diurnal_range ÷ temp_annual_range
**temp_seasonality**                        | Standard deviation of monthly-mean temperature estimates expressed as a percent of their mean
**max_temp_warmest_period**                 | Highest monthly maximum temperature
**min_temp_coldest_period**                 | Lowest monthly minimum temperature
**temp_annual_range**                       | max_temp_warmest_period – min_temp_coldest_period
**mean_temperatre_wettest_quarter**         | Avg temperature during 3 wettest months
**mean_temp_driest_quarter**                | Avg temperature during 3 driest months
**mean_temp_warmest_quarter**               | Avg temperature during 3 warmest months
**mean_temp_coldest_quarter**               | Avg temperature during 3 coldest months
**annual_pp**                               | Sum of monthly precipitation values
**pp_wettest_period**                       | Precipitation of the wettest month
**pp_driest_period**                        | Precipitation of the driest month
**pp_seasonality**                          | Standard deviation of the monthly precipitation estimates expressed as a percent of their mean
**pp_wettest_quarter**                      | Total precipitation of 3 wettest months
**pp_driest_quarter**                       | Total precipitation of 3 driest months
**pp_warmest_quarter**                      | Total precipitation of 3 warmest months
**pp_coldest_quarter**                      | Total precipitation of 3 coldest months
**julian_day_number_start_growing_season**  | Julian day number at start of growing season
**julian_day_number_at_end_growing_season** | Julian day number at end of growing season
**number_days_growing_season**              | Length of growing season (days)
**total_pp_for_period_1**                   | Total precipitation 3 weeks prior to growing season
**total_pp_for_period_3**                   | Total precipitation during the growing season
**gdd_above_base_temp_for_period_3**        | Degree days (above 5ºC) for growing season Variable
**annual_mean_temp**                        | Avg of mean monthly temperatures
**annual_min_temp**                         | Avg of min monthly temperatures
**annual_max_temp**                         | Avg of max monthly temperatures
**mean_temp_for_period_3**                  | Average temperature during growing season
**temp_range_for_period_3**                 | Highest maximum temperature minus lowest minimum temperature during growing

**Further details [here](http://journals.ametsoc.org/doi/pdf/10.1175/2011BAMS3132.1)**

### pastClimate_grid

Column   | Description
---      | ---
**x**    | x coordinate of the cell (longitude). i.e. x = 0 corresponds to min(longitude)
**y**    | y coordinate of the cell (latitude). i.e. y = 0 corresponds to min(latitude)
**year** | year of the climate measurement. In the sql query, year column equal to 0 because the climate has been aggregated temporarily.
**env1** | average of the mean temperature (°C) between 1970-2000.
**env2** | average of the annual precipitation (meters) between 1970-2000.

## Code description

### Species

Code           | Species
---            | ---
18032-ABI-BAL  | Balsam fir
18034-PIC-RUB  | Red spruce
19408-QUE-RUB  | Red oak
19462-FAG-GRA  | American beech
19466-ALN-NA   | Saule
19481-BET-ALL  | Yellow birch
19489-BET-PAP  | White
19511-OST-VIR  | Ironwood
21536-TIL-AME  | Basswood
22453-POP-BAL  | Balsam poplar
22463-POP-GRA  | Large tooth
24764-PRU-SER  | Black cherry
24799-PRU-PEN  | Pin cherry
25319-SOR-AME  | American mountain-ash
28728-ACE-RUB  | Red maple
28731-ACE-SAC  | Sugar maple
32931-FRA-AME  | White ash
32945-FRA-NIG  | Black ash
183295-PIC-GLA | White spruce
183302-PIC-MAR | Black spruce
183319-PIN-BAN | jack pine
183412-LAR-LAR | Tamarack
195773-POP-TRE | Trembling aspen

### Soils codes

| Code | Soil type    |
|:----:|:------------:|
| 0    | NODATA       |
| 1    | Acrisols     |
| 2    | Albeluvisols |
| 3    | Alisols      |
| 4    | Andosols     |
| 5    | Anthrosols   |
| 6    | Arenosols    |
| 7    | Calcisols    |
| 8    | Cambisols    |
| 9    | Chernozems   |
| 10   | Cryosols     |
| 11   | Durisols     |
| 12   | Ferralsols   |
| 13   | Fluvisols    |
| 14   | Gleysols     |
| 15   | Gypsisols    |
| 16   | Histosols    |
| 17   | Kastanozems  |
| 18   | Leptosols    |
| 19   | Lixisols     |
| 20   | Luvisols     |
| 21   | Nitisols     |
| 22   | Phaeozems    |
| 23   | Planosols    |
| 24   | Plinthosols  |
| 25   | Podzols      |
| 27   | Regosols     |
| 28   | Solonchaks   |
| 29   | Solonetz     |
| 30   | Stagnosols   |
| 31   | Umbrisols    |
| 32   | Vertisols    |