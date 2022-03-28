# Grazing dairy farm linear programming model

This linear programming model, implemented in GAMS, was published in:
Neal M, Neal J, Fulkerson WJ (2007) Optimal Choice of Dairy Forages in Eastern Australia, Journal of Dairy Science, 90(6), P3044-3059, DOI: https://doi.org/10.3168/jds.2006-645

## Abstract

Although several forage species such as perennial ryegrass are predominant, there is a wide range of forage species that could be grown in subtropical and temperate regions in Australia as dairy pastures. These species have differing seasonal patterns of growth, nutrient quality, and water-use efficiency, as demonstrated in a large experiment evaluating over 30 species at the University of Sydney (Camden, New South Wales, Australia). Some species can be grazed, whereas others require mechanical harvesting, which incurs a further cost. Previous comparisons of species that relied on yield of dry matter per unit of some input (typically land or water) did not simultaneously take into account the season in which forage is produced, or other factors related to the costs of production and delivery to the cows. To effectively compare the profitability of individual species, or combinations of species, requires the use of a whole-farm, multiperiod model. Linear programming was used to find the most profitable mix of forage species for an irrigated dairy farm in a warm temperate irrigation region of New South Wales, Australia. It was concluded that for a typical farmer facing the prevailing milk and purchased feed prices with average milk production per cow, the most profitable mix of species would include a large proportion of perennial ryegrass (Lolium perenne) and prairie grass (Bromus willdenowii). The result was robust to changes in seasonal milk pricing and a move from year-round to a more seasonal calving pattern.

## GAMS model details

This model builds on the Mark Neal's honour's thesis work (1), which itself built on a previous assignment (2). This model takes advantage of experimental data from James Neal (3).

The final model input after addressing reviewer comments is 'ADSA Dairy LP RDP UDP.gms'. The output is'ADSA Dairy LP RDP UDP.lst'. The detailed results are viewable in 'DairyFarm_p.gdx'.  

A table of results are created towards the end of the file for ease of reporting. This can be seen in 'xllink.gdx' (open in gams), and gams attempts to create 'AdsaLpReport.xls' in c:\gams\.

To run the model requires a license (gamslice.txt) with the conopt3 solver. Other solvers may work, but have not been tried recently. Also note you will need to open a new gams project file (.gpr) first in the directory with the model to point to the proper default location for the files to include on your computer.

Parameters are often read from csv files for ease of data entry (e.g. AF.csv).

Load_point files (created with save_point in previous runs) have previously been used to provide a starting point to speed solutions, but are not necessary, and hence are commented out.

A loop (with subscript ax) is available to run multiple solves for all the scenarios reported on in the paper, using a table in csv format (xMultiSolvesTable.csv). Currently this option is commented out a dummy table is used for one solution (xMultiSolvesDummy.csv), which solves in about 2 minutes on a circa 2020 laptop.

## References

(1) Neal M (1999) Modelling seasonal production of a NSW Dairy Farm: A linear programming approach, 
University of Sydney, Bachelor of Agricultural Economics Thesis, Advisor: Bob Batterham. 
https://www.researchgate.net/publication/272418932_Modelling_seasonal_production_of_a_NSW_Dairy_Farm_A_linear_programming_approach

(2) Neal M (1998) Clareview Dairy Farm: A mock consultants report using a linear programming model of a dairy farm to propose optimal solution, Assignment prepared in Agribusiness Management.

(3) Neal JS, Fulkerson WJ, Lawrie R, Barchia IM (2009) Difference in yield and persistence among perennial forages used by the dairy industry under optimum and deficit irrigation. Crop Pasture Science. 2009, 60, 1071–1087.
https://www.publish.csiro.au/CP/CP09059
