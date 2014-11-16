STModel-Data
============

## Getting started

#### 1. Download repository

	git clone git@github.com:TheoreticalEcosystemEcology/STModel-Data.git
	cd STModel-Data
	
#### 2. Install R dependencies

	install.packages("RPostgreSQL")
	install.packages("ggmap")

#### 3. Setup your database account

In ```con_quicc_db.r```, replace ```dbuser``` and ```dbpass``` variables with your account. Your computer must be connected by wired on the UQAR network.

#### 4. Get all datasets

	make all

## Retrieve dataset separately

**Get only tree data**: ```make get_treeData```

**Get only climatic data**: ```make get_climData```

**Get only plot info data**: ```make get_plotInfoData```

**Get only past climate grid input**: ```make get_pastClimate_grid```

## Plots distribution

![Plots_distribution](./out_files/plots_map.png)

## Datasets metadata

### plotInfoData

Column        | Description
---           | ---
**plot_id**   | Unique id of the plot
**longitude** | longitude of the plot (degree decimal)
**latitude**  | latitude of the plot (degree decimal)
**srid**      | Spatial Reference System Identifier. All plots have a srid code corresponding to the datum: WGS84 (see [here](http://spatialreference.org/ref/epsg/4326/)).
**drainage**  | *Incoming* 
**slope**     | *Incoming* (in degree)

### treeData 

Column            | Description
---               | ---
**plot_id**       | Unique id of the plot
**year_measured** | year of the measurement
**id_spe**        | Species code, details are available in ./out_files/stm_code_species.csv file
**basal area**    | basal area of the species in **m²/ha**

### pastClimate_grid

Column   | Description
---      | ---
**x**    | x coordinate of the cell (longitude). i.e. x = 0 corresponds to min(longitude)
**y**    | y coordinate of the cell (latitude). i.e. y = 0 corresponds to min(latitude)
**year** | year of the climate measurement. In the sql query, year column equal to 0 because the climate has been aggregated temporarily.
**env1** | average of the mean temperature (°C) between 1970-2000.
**env2** | average of the annual precipitation (meters) between 1970-2000.

## Code metadata

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

### Drainage 