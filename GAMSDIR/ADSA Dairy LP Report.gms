*** Include this file to report on ADSA Dairy LP

set cat This is a category for reporting
/        Category        /;

** Display Results

Display                 vForageArea.l
Display                 vLeaseOut.l
Display                 vDMProduction.l
Display                 vConserved.l
Display                 vSupplPurch.l
Display                 vGrainToCows.l
Display                 vForageToCows.l
Display                 vConsToCows.l
Display                 vNumberCows.l
**Display                 vMilkProd.l
*Display                 vMilkProd.l
Display                 vMilkSold.l
*Display                 vFixedCosts.l
Display                 vHireLab.l
Display                 vCashTransfer.l
*Display                 vOverdraft.l

Parameter rtSupplPurch(g) The total of SupplPurch;
rtSupplPurch(g) = sum(s, vSupplPurch.l(s,g) );
Display rtSupplPurch

Parameter rtConserved(f,h) The total of Conserved;
rtConserved(f,h) = sum(s, vConserved.l(s,f,h) );
Display rtConserved

Parameter rtMilkSold(m) The total of MilkSold;
rtMilkSold(m) = sum(s, vMilkSold.l(s,m) );
Display rtMilkSold



Parameter rMilkSalesRevenue The Revenue of MilkSales;
rMilkSalesRevenue = sum(s, vTRMilkSales.l(s) );
Display rMilkSalesRevenue

Parameter rCullSalesRevenue The Revenue of CullSales;
rCullSalesRevenue = sum(s, vTRCullSales.l(s) );
Display rCullSalesRevenue

Parameter rLeaseOutRevenue The Revenue of LeaseOut;
rLeaseOutRevenue = sum(s, vTRLEaseOut.l(s) );
Display rLeaseOutRevenue

Parameter rForageEstabCost The cost of Forage Establishment;
rForageEstabCost = sum(s, vTCForageEstab.l(s) );
Display rForageEstabCost

Parameter rFertPurchCost The cost of FertPurch;
rFertPurchCost = sum(s, vTCFertPurch.l(s) );
Display rFertPurchCost

Parameter rWaterPurchCost The cost of WaterPurch;
rWaterPurchCost = sum(s, vTCWaterPurch.l(s) );
Display rWaterPurchCost

Parameter rMakingConservedCost The cost of MakingConserved;
rMakingConservedCost = sum(s, vTCMakingConserved.l(s) );
Display rMakingConservedCost

Parameter rFeedingConservedCost The cost of FeedingConserved;
rFeedingConservedCost = sum(s, vTCFeedingConserved.l(s) );
Display rFeedingConservedCost

Parameter rSupplPurchCost The cost of SupplPurch;
rSupplPurchCost = sum(s, vTCSupplPurch.l(s) );
Display rSupplPurchCost

Parameter rCowCostsCost The cost of CowCosts;
rCowCostsCost = sum(s, vTCCowCosts.l(s) );
Display rCowCostsCost

Parameter rHiredLabourCost The cost of HiredLabour;
rHiredLabourCost = sum(s, vTCHiredLabour.l(s) );
Display rHiredLabourCost

Parameter rFixedCostsCost The cost of FixedCosts;
rFixedCostsCost = sum(s, vTCFixedCosts.l(s) );
Display rFixedCostsCost

Parameter Profit The total profit;
Profit = vObjective.l;
Display Profit

Parameter ExpenditureReport(*,Cat) This is for a pie chart of costs;
ExpenditureReport('Forage Establishment' ,'Category') = rForageEstabCost;
ExpenditureReport('Fertiliser'           ,'Category') = rFertPurchCost  ;
ExpenditureReport('Irrigation'           ,'Category') = rWaterPurchCost ;
ExpenditureReport('Conserving feed'      ,'Category') = rMakingConservedCost ;
ExpenditureReport('Feeding conserved'    ,'Category') = rFeedingConservedCost;
ExpenditureReport('Bought Supplements'   ,'Category') = rSupplPurchCost ;
ExpenditureReport('Cow Costs'            ,'Category') = rCowCostsCost   ;
ExpenditureReport('Hired Labour'         ,'Category') = rHiredLabourCost;
ExpenditureReport('Fixed Costs'          ,'Category') = rFixedCostsCost ;
ExpenditureReport('Profit'               ,'Category') = Profit ;

Display ExpenditureReport

Display vTCGrowingAndFeeding.l

Parameter TCGAndFPerHa(f)   Total cost growing and feeding per ha;
TCGAndFPerHa(f) = ( vTCGrowingAndFeeding.l(f) / vForageArea.l(f)        )$(vForageArea.l(f)>0) ;
Display TCGAndFPerHa;

Parameter ForageTonnageGrown(f)      Tonnes grown;
ForageTonnageGrown(f) = 30 * ( sum(s, vForageArea.l(f)*GF(s,f) /1000 )) ;
Display ForageTonnageGrown;

Parameter ForageTonnageEaten(f)      Tonnes eaten ie grazed and fed as conserved;
ForageTonnageEaten(f) = 30 * ( sum(s, sum(c, sum(h, vConsToCows.l(s,c,f,h) ))) + sum(s, sum(c, vForageToCows.l(s,c,f) )) ) /1000 ;
Display ForageTonnageEaten;

Parameter TCForagePerTGrown(f)   Total effective cost per tonne grown;
TCForagePerTGrown(f) = ( vTCGrowingAndFeeding.l(f) / ForageTonnageGrown(f)     )$(vForageArea.l(f)>0) ;
Display TCForagePerTGrown;

Parameter TCForagePerTEaten(f)   Total effective cost per tonne eaten;
TCForagePerTEaten(f) = ( vTCGrowingAndFeeding.l(f) / ForageTonnageEaten(f) )$(vForageArea.l(f)>0) ;
Display TCForagePerTEaten;

$ontext
***PLOTTING OUTPUT***
* Plot Forage Production
Parameter ForageProd(s,f) The optimal Forage production in tonnes;
ForageProd(s,f)= vForageArea.l(f)*GF(s,f)*30/1000;
$set domain s
$set labels s
$set series f

$libinclude xlchart ForageProd
*$offtext

*$ontext
* Plot Supplement use
Parameter SupplUse(s,g) The optimal Supplement Use;
SupplUse(s,g)=vSupplPurch.l(s,g);
$set domain s
$set labels s
$set series g

$libinclude xlchart SupplUse
*$offtext

*$ontext
* Plot cows calved
Parameter Cows(c) Cows calved in each month;
Cows(c)= vNumberCows.l(c);
$set domain c
$set labels c
*$set series

$libinclude xlchart Cows

* Plot Milk sold
Parameter Milk(s,m) Milk sold to contract and to spot market;
Milk(s,m)= vMilkSold.l(s,m);
$set domain s
$set labels s
$set series m

$libinclude xlchart Milk
*$offtext

* Plot Labour Requirement
Parameter FTES(s) The optimal Full time Equivalent Labour Requirement;
FTES(s)= vHireLab.l(s)/160;
* 48 weeks worked per year per FTE with 40 hour weeks divided by 12 months is 160 hours per FTE per month
$set domain s
$set labels s
*$set series

$libinclude xlchart FTES

$offtext

$ontext
* Plot Cash at end of month
Parameter CashAtEOM(s) The cash BAlance at the End of the Month;
CashAtEOM(s)= vCashTransfer.l(s);
$set domain s
$set labels s
*$set series

$libinclude xlchart CashAtEOM

$offtext

$ontext
***PLOTTING SCATTER XY GRAPHS***

*Illustrate gnupltxy usage

SETS
LINES      Lines in graph /A,B/
POINTS     Points on line /1*10/
ORDINATES  ORDINATES      /X-AXIS,Y-AXIS/  ;

TABLE GRAPHDATA(LINES,POINTS,ORDINATES)
       X-AXIS   Y-AXIS
A.1       1       1
A.2       2       4
A.3       3       9
A.4       5      25
A.5      10     100
B.1       1       2
B.2       3       6
B.3       7      15
B.4      12      36
;
*$LIBINCLUDE GNUPLTXY GRAPHDATA Y-AXIS X-AXIS
$offtext

$ontext
#user model library stuff
Main topic Output
Featured item 1 Graphics
Featured item 2 GNUPLTXY.gms
Featured item 3
Featured item 4
Description
Illustrate GNUPLTXY usage
$offtext