$Title Dairy LP model to find optimal forage and supplement choice: Base model from my honours thesis (Neal, 1999)
$eolcom #
***OPTIONS***

option limrow = 42;
option limcol = 42;
option lp = conopt;
option dnlp=conopt;
option mip=coincbc;
option rminlp=conopt

***SETS***

Set a MultiSolves / run1*run5 /;
Set aNow(a) Dynamic Set for Current run;
*$ontext
Set ax xMultiSolves / MAxWH1, MAxWH2, MAxWH3, MAxWH4, MAxWH5,
                      KIxRR1, KIxRR2, KIxRR3, KIxRR4, KIxRR5,
                      RP1, RP2, RP3, RP4, RP5,
                      MA1, MA2, MA3, MA4, MA5,
                      Water1, Water2, Water3, Water4, Water5,
                      RPout, PRout, REout, WCout,
                      Base, SeasP, SeasC, SeasPSeasC,
                      Stock2, Stock3, Stock4, Stock5, Stock6
                      Prod9000s /;
*$offtext
*Set ax xMultiSolves / Dummy1*Dummy36 /;

Set axNow(ax) xDynamic Set for Current run;
Set axData xMultiSolvesData / dMAxWH, dKIxRR, dRP, dMA, dMinPercent, dWater, dMaxCows, dPRlim, dRPlim, dRElim, dWClim, dUni, dSeas, dSeasC, d6000s, d9000s /;

Set s Seasons  / Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec /;
Set d CropSeasons / Summer, Winter /;
Set f Forages  / CH, FE, LU, PA, PH, PL, PR, RB, RP, RE, RS, WC, MA, SO, KI, LA, WH, RA, PE, RR,
                 MAxWH, MAxRA, MAxPE, MAxRR, SOxWH, SOxRA, SOxPE, SOxRR,
                 KIxWH, KIxRA, KIxPE, KIxRR, LAxWH, LAxRA, LAxPE, LAxRR     /;
Set g Grain    / WheatGrain, BarleyGrain, OatsGrain, TriticaleGrain, SorghumGrain,
                 MaizeGrain, LupinsGrain, CanolaGrain,
                 LucerneHay, CloverHay, OatenHay, CerealStraw               /;
Set m MilkMarkets   / Contract, Spot /;
Set h HarvestMethod / Hay, Silage /;
Set l LactPeriods   / Month1*Month12 /;
Set q ProdFnSteps   / PFStep1*PFStep6 /;
Set r SubstSteps    / SStep1*SStep3 /;
Set e FertTypes     / Urea, Pasture25 /;

Set b Fibre types   / NDF /;
Set w ProtSet   / Protein /;
Set x MESet     / ME /;
Set y DMSet     / DM /;
Set z LitresSet / Litres /;
Set v RotSet    / Rotation /;
alias (c,s);    #The SSet c is the month that calving occurs
alias (o,s);    #The SSet o is the month of conserved feed stock
Parameter ReSet(o,s) This is an identity matrix that resets data from s to o;
Reset(o,s)=1$ord(o)=ord(s);

***DATA***
*** Pastures, Fertiliser and water

Scalar  TotalArea        Total area of land available (ha)      / 200 /;

Table AF(d,f)  Area Requirement of Forage by crop seasons (Ha per crop season)
* Here is an example of reading data from an excel file saved in csv
$ondelim
$include AF.csv
$offdelim
display AF;

* Here is an example of reading data from an excel file saved in csv
Table GF(s,f)  Growth of Forage  (DM per day)
$ondelim
$include GF.csv
$offdelim
display GF;

Table FertManure(s,e)  Fertiliser supplied by Manure  (kg per month)
$ondelim
$include FertManure.csv
$offdelim
display FertManure;

Parameter FertManureAdv(c,s,e);
FertManureAdv(c,s,e)=FertManure(s--(ord(c)-1),e);
display FertManureAdv;

Table UreaF(s,f)  Urea Fertiliser required for Forage  (kg per month)
$ondelim
$include UreaF.csv
$offdelim
display UreaF;

Table P25F(s,f)  Pasture25 Fertiliser required for Forage  (kg per month)
$ondelim
$include P25F.csv
$offdelim
display P25F;

Table WI(s,f)  Irrigation water required each month (ML per month)
$ondelim
$include WI.csv
$offdelim
display WI;

Table CF(s,f)  Seed cost and herbicide for forage establishment (dol per ha)
$ondelim
$include CF.csv
$offdelim
display CF;

Table LF(s,f)  Labour use for forage establishment (hrs per ha)
$ondelim
$include LF.csv
$offdelim
display LF;

Table FertApp(s,f)  Fertiliser applications (apps per ha)
$ondelim
$include FertApp.csv
$offdelim
display FertApp;

Table RF(v,f)  Years between planting for each forage (years)
$ondelim
$include RF.csv
$offdelim
display RF;

Table Mow(s,f)  Times forage is mown by tractor (times per ha)
$ondelim
$include Mow.csv
$offdelim
display Mow;

*** Supplements (inc Grain)

Table CS(s,g)  Cash use for supplement (inc grain) (dol per t)
$ondelim
$include CS.csv
$offdelim
display CS;

Scalar LS      Labour use for supplement unloading (hrs per t) / 0.15 /;

*** Conserved Feed, making and feeding out

Parameter LMH(h)     Labour for making conserved feed   (hours per t DM)
*                 / 2.5
*                   2   /;
* divide by 0.8 for amount harvested (assume 20% losses)
                 / Hay    3.125
                   Silage 2.5   /;
*                 / Hay    0
*                   Silage 0   /;                                                    #experimental only

Table Harvestf(s,f)  Is harvest of crop by contract (no=0.yes=1)
*This is to take account of contract pit silage harvesting for Maize and Wheat
$ondelim
$include HarvestF.csv
$offdelim
display HarvestF;

Parameter CMH(h)     plastic and twine for making conserved feed (hours per t DM)
* twine                  /  16
* plastic                   26 /;
* divide by 0.8 for amount harvested (assume 20% losses)
* it is already per tonne: doesn't require multiplying by 30/1000
                 /   Hay    16
                     Silage 26 /;

Parameter LFH(h)     Labour for feeding conserved feed (hours per kg DM for month)
*  hours per tonne  / 0.9
*                     1   /;
* divide by 0.8, the multiply by 30/1000 to get labour per kg per day for the month
                 /  Hay    0.03375
                    Silage 0.0375 /;
*                 /  Hay    0
*                    Silage 0 /;                                                    #experimental only


Parameter CFH(h)     Other costs for feeding conserved feed ($ per kg DM for month)
* There are no costs of feeding silage beyond the tractor cost
* divide by 0.8, the multiply by 30/1000 to get tractor cost per kg per day for the month
                 / Hay    0
                   Silage 0    /;

*** Nutritional data
**Supply - quality of feed
*DM Dry Matter
Table DMS(r,g)  Dry matter used by kilo of supplement (kg DMI per kg DM)
$ondelim
$include DMS.csv
$offdelim
display DMS;

Table DMF(s,f)  Dry matter used by kilo of forage (kg DMI per kg DM)
$ondelim
$include DMF.csv
$offdelim
display DMF;

Table DMFH(o,f)  Dry matter used by kilo of forage (kg DMI per kg DM)
$ondelim
$include DMF.csv
$offdelim
display DMFH;

Table DMH(h,f)  Dry matter used by kilo of conserved hay (kg DMI per kg DM)
$ondelim
$include DMH.csv
$offdelim
display DMH;

*Table DMHay(s,f)  Dry matter used by kilo of conserved hay (kg DMI per kg DM)
*$ondelim
*$include DMHay.csv
*$offdelim
*display DMHay;

*Table DMSil(s,f)  Dry matter used by kilo of conserved silage (kg DMI per kg DM)
*$ondelim
*$include DMSil.csv
*$offdelim
*display DMSil;

* ME Metabolisable Energy
Table MES(x,g)  ME provided by kilo of supplement (ME per kg DM)
$ondelim
$include MES.csv
$offdelim
display MES;

Table MEF(s,f)  ME provided by kilo of forage (ME per kg DM)
$ondelim
$include MEF.csv
$offdelim
display MEF;

Table MEFH(o,f)  ME provided by kilo of forage (ME per kg DM)
$ondelim
$include MEF.csv
$offdelim
display MEFH;

Table MEH(h,f)  ME provided by kilo of conserved Hay (ME per kg DM)
$ondelim
$include MEH.csv
$offdelim
display MEH;

*Table MEHay(s,f)  ME provided by kilo of conserved Hay (ME per kg DM)
*$ondelim
*$include MEHay.csv
*$offdelim
*display MEHay;

*Table MESil(s,f)  ME provided by kilo of conserved Silage (ME per kg DM)
*$ondelim
*$include MESil.csv
*$offdelim
*display MESil;

*P Protein
Table PS(w,g)  P provided by kilo of supplement (% per kg DM)
$ondelim
$include PS.csv
$offdelim
display PS;

Table PF(s,f)  P provided by kilo of forage (% per kg DM)
$ondelim
$include PF.csv
$offdelim
display PF;

Table PFH(o,f)  P provided by kilo of forage (% per kg DM)
$ondelim
$include PF.csv
$offdelim
display PFH;

Table PH(h,f)  P provided by kilo of conserved hay (% per kg DM)
$ondelim
$include PH.csv
$offdelim
display PH;

*Table PHay(s,f)  P provided by kilo of conserved hay (% per kg DM)
*$ondelim
*$include PHay.csv
*$offdelim
*display PHay;

*Table PSil(s,f)  P provided by kilo of conserved Silage (% per kg DM)
*$ondelim
*$include PSil.csv
*$offdelim
*display PSil;

*F Fibre
Table FS(b,g)  Fibre provided by kilo of grain or supplement (ME per kg DM)
$ondelim
$include FS.csv
$offdelim
display FS;

Table FF(s,f)  Fibre provided by kilo of forage (ME per kg DM)
$ondelim
$include FF.csv
$offdelim
display FF;

Table FFH(o,f)  Fibre provided by kilo of forage (ME per kg DM)
$ondelim
$include FF.csv
$offdelim
display FFH;

Table FH(h,f)  Fibre provided by kilo of conserved hay (ME per kg DM)
$ondelim
$include FH.csv
$offdelim
display FH;

*Table FHay(s,f)  Fibre provided by kilo of conserved hay (ME per kg DM)
*$ondelim
*$include FHay.csv
*$offdelim
*display FHay;

*Table FSil(s,f)  Fibre provided by kilo of conserved Silage (ME per kg DM)
*$ondelim
*$include FSil.csv
*$offdelim
*display FSil;

*DM percentage of Supplements
Table PDMS(y,g)  Percentage DM provided by kilo of as-fed (kg DM per kg as-fed)
$ondelim
$include PDMS.csv
$offdelim
display PDMS;

**Demand - Cow requirements
*DM
Table DMIs(s,y)  Dry matter Intake per day for lactation months (kg DM)
$ondelim
$include DMIs.csv
$offdelim
display DMIs;

Parameter DMIAdv(c,s,y);
DMIAdv(c,s,y)=DMIs(s--(ord(c)-1),y);
display DMIAdv;

*ME
Table MEMaints(s,x)  ME required per day for lactation months (ME)
$ondelim
$include MEMaints.csv
$offdelim
display MEMaints;

Parameter MEMaintAdv(c,s,x);
MEMaintAdv(c,s,x)=MEMaints(s--(ord(c)-1),x);
display MEMaintAdv;

Table MEProds(s,q)  ME required per litre at each step of production function (ME)
$ondelim
$include MEProds.csv
$offdelim
display MEProds;

Parameter MEProdAdv(c,s,q);
MEProdAdv(c,s,q)=MEProds(s--(ord(c)-1),q);
display MEProdAdv;

*Protein
Table Prots(s,w)  Protein percent for lactation months (kg DM)
$ondelim
$include Prots.csv
$offdelim
display Prots;

Parameter ProtAdv(c,s);
ProtAdv(c,s)=sum(w, Prots(s--(ord(c)-1),w) );
display ProtAdv;
*$offtext

*Production Function
Table ProdRest6000s(s,q)  Maximum litres for each step of production function (Litres)
$ondelim
$include ProdRest6000s.csv
$offdelim
display ProdRest6000s;

Parameter ProdRest6000Adv(c,s,q);
ProdRest6000Adv(c,s,q)=sum(z, ProdRest6000s(s--(ord(c)-1),q) );
display ProdRest6000Adv;

Table ProdRest9000s(s,q)  Maximum litres for each step of production function (Litres)
$ondelim
$include ProdRest9000s.csv
$offdelim
display ProdRest9000s;

Parameter ProdRest9000Adv(c,s,q);
ProdRest9000Adv(c,s,q)=sum(z, ProdRest9000s(s--(ord(c)-1),q) );
display ProdRest9000Adv;

* Other diet parameters

Parameter Substitution(r) 3 marginal proportions of diet where substitution changes
                 /  SStep1 0.25
                    SStep2 0.25
                    SStep3 0.50 /;

Parameter FibreReq(b)    Fibre requirement (%)
                     / NDF 0.30 /;

*** Labour and other financial variables
*Cow related
Table LCCAdv(s,c)  Labour requirement per cow including requirement at calving
$ondelim
$include LCCAdv.csv
$offdelim
display LCCAdv;

Table CCs(s,c)  Costs per cow across calvings (dol per season)
$ondelim
$include CCs.csv
$offdelim
display CCs;

*Pasture related
Parameter FertCost(e) Fertiliser cost ($ per t)
                 /   Urea      505
                     Pasture25 360 /;

Scalar FertLabour Labour required to apply fertiliser (hrs per ha)
                 /   0.6   /;

Scalar MowLabour Labour required to mow (hrs per ha)
                 /   1.9   /;

Scalar WaterCost Water cost per ML for water purchase plus pumping ($ per ML)
* 45 water plus 22 pumping electricity gives 67 (if double to 90+22=112
                 /   67    /;                                                        #Redundant - see WaterCostDynamic


* Tractor costs and Labour costs/requirements
Scalar TractorCost Cost per hour to operate a tractor ($ per hr)
* Our farm calculations were $8 for R&M plus fuel and oil, but NSW Ag said $12
                 /   12    /;

Scalar LabCost      Cost of hired labour       (dol per hour)    / 24 /;

Scalar OwnLab       Owner labour       (hours per season)         / 0 /;

Scalar FixedLabour  Fixed labour (dairy fixed other per seas)  / 337.25 /;

Scalar FixedCosts   Fixed farm costs (dol per season per ha)    / 25 /;
* ^ 300/12 months
Scalar OpCash       Opening cash                 (dol)        / 400000 /;
* Increase to larger number to force solution eg multiply by 10

Scalar MaxOD        Maximum overdraft            (dol)        / 500000 /;

Scalar ODInt        Overdraft interest(1 plus (i per season)) / 1.015 /;

Scalar ContractHarvest Cost of contract harvesting maize or wheat into a pit / 50 /;

Scalar LeaseOutPrice Value of leasing out per month (375 div by 12)   / 31.25 /;

Scalar CullRevenuePerMilker Cull and calf sales per milker      / 150 /;

*Milk prices and contract volumes
Table MPUni(s,m)       Prices for milk Uniform through year      (Dol per L)
$ondelim
$include MPUni.csv
$offdelim
display MPUni;

Table MPSeas(s,m)      Prices for milk Low Aug-Jan High Feb-Aug  (Dol per L)
$ondelim
$include MPSeas.csv
$offdelim
display MPSeas;



Scalar ContractVol  Contract volume     (L per season)            / 0 /;
* no obligation contract. Requires more constraints if delivery is compulsory

*** Miscellaneous scalars

Scalar ForageUtilisation  Utilisation of forage (eg 0.65) / 1.00 /;

Scalar ConsUtilisation    Utilisation of conserved feeds  / 0.90 /;
* eg change to 0.8 or 0.9

Scalar kgT          Kilograms in a tonne         (1000)        / 1000 /;

Scalar dim          Days in a month              (30)            / 30 /;

Scalar MaxCows      Maximum number of cows       (cows)         / 800 /;            #redundant - see maxcowsdynamic

***Test effect of forage constraints in this GAMS model

*$ontext
Parameter ConstrainForages(f) Constrain forages to at least these levels
/        CH      0
         FE      0
         LU      0
         PA      0
         PH      0
         PL      0
         PR      0
         RB      0
         RP      0
         RE      0
         RS      0
         WC      0
         MA      0
         SO      0
         KI      0
         LA      0
         WH      0
         RA      0
         PE      0
         RR      0
         MAxWH   0
         MAxRA   0
         MAxPE   0
         MAxRR   0
         SOxWH   0
         SOxRA   0
         SOxPE   0
         SOxRR   0
         KIxWH   0
         KIxRA   0
         KIxPE   0
         KIxRR   0
         LAxWH   0
         LAxRA   0
         LAxPE   0
         LAxRR   0        /;
*$offtext

*** Dynamic sets used for solving in a loop
Parameter MinPercentForage(a)
*         /       Run1    0
*                 Run2    0.25
*                 Run3    0.50
*                 Run4    0.75
*                 Run5    1.00    /;
         /       Run1    0
                 Run2    0
                 Run3    0
                 Run4    0
                 Run5    0    /;
*         /       Run1    1
*                 Run2    1
*                 Run3    1
*                 Run4    1
*                 Run5    1     /;
$ontext
/
run1        0
run2        0.041666667
run3        0.083333333
run4        0.125
run5        0.166666667
run6        0.208333333
run7        0.25
run8        0.291666667
run9        0.333333333
run10        0.375
run11        0.416666667
run12        0.458333333
run13        0.5
run14        0.541666667
run15        0.583333333
run16        0.625
run17        0.666666667
run18        0.708333333
run19        0.75
run20        0.791666667
run21        0.833333333
run22        0.875
run23        0.916666667
run24        0.958333333
run25        1
/;
$offtext

Parameter WaterCostDynamic(a)
*         /       Run1    22
*                 Run2    44.5
*                 Run3    67
*                 Run4    89.5
*                 Run5   102.0    /;
         /       Run1    67
                 Run2    67
                 Run3    67
                 Run4    67
                 Run5    67    /;
$ontext
/
run1        67
run2        67
run3        67
run4        67
run5        67
run6        67
run7        67
run8        67
run9        67
run10        67
run11        67
run12        67
run13        67
run14        67
run15        67
run16        67
run17        67
run18        67
run19        67
run20        67
run21        67
run22        67
run23        67
run24        67
run25        67
/;
$offtext
Parameter MaxCowsDynamic(a)
*         /       Run1    400
*                 Run2    600
*                 Run3    800
*                 Run4    1000
*                 Run5    1200    /;
         /       Run1    800
                 Run2    800
                 Run3    800
                 Run4    800
                 Run5    800    /;
$ontext
/
run1        800
run2        800
run3        800
run4        800
run5        800
run6        800
run7        800
run8        800
run9        800
run10        800
run11        800
run12        800
run13        800
run14        800
run15        800
run16        800
run17        800
run18        800
run19        800
run20        800
run21        800
run22        800
run23        800
run24        800
run25        800
/;
$offtext

*** The full set of scenarios - takes 15 minutes to solve
*$ontext
Table xMultiSolvesTable(ax,axData)      xData table for MultiSolves
$ondelim
$include xMultiSolvesTable.csv
$offdelim
display xMultiSolvesTable;
*$offtext

*** A dummy set - the base scenarios
** use with Set ax xMultiSolves / Dummy /;
$ontext
Table xMultiSolvesTable(ax,axData)      xData table for MultiSolves
$ondelim
$include xMultiSolvesDummy.csv
$offdelim
display xMultiSolvesTable;
$offtext

***VARIABLES***

Variables        vForageArea(f)         ForageArea planted to forage(p)   (ha)
                 vLeaseOut              Area leased out                   (ha)
                 vDMProduction(s,f)     Transfer forage to DM             (DM)
                 vConserved(s,f,h)      Conserved as hay or silage        (DM)
*                 vConserved(s,f,h)      Conserved as hay or silage        (DM)
*                 vConservedO(o,f,h)     Conserved as hay or silage(re set)(DM)
                 vSupplPurch(s,g)       Supplement Purchase               (T)
                 vGrainToCows(s,c,g,r)  Transfer grain to cows            (DM)
                 vForageToCows(s,c,f)   Transfer forage to cows           (DM)
*                 vConsToCows(o,s,c,f,h) Transfer conserved feed to cows   (DM)
                 vConsToCows(s,c,f,h)   Transfer conserved feed to cows   (DM)
                 vNumberCows(c)         Number of cows in season(s)       (cows)
                 vMilkProd(c,s,q)       Production in each month of lact  (L)
                 vMilkSold(s,m)         Milk sold to m markets            (L)
                 vFixedCosts            Fixed costs (the variable)        (dol)
                 vHireLab(s)            Hire of labour in season(s)       (hours)
                 vCashTransfer(s)       Transfer of cash between seasons  (dol)
                 vOverdraft(s)          Overdraft and transfers (s)       (dol)
                 vObjective             Value of final cash balance       ($)
                 vFibreSlack(s,c,b)     Removes Fibre Restrictions
                 vProtSlack(s,c)        Removes Protein Restrictions
                 vFertReqt(e)           Fertiliser Requirement            (kg)
                 vWaterReqt(s)          Water Requirement                 (ML)
                 vTCForageEstab(s)      Total cost of ($)
                 vTCSupplPurch(s)       Total cost of ($)
                 vTCCowCosts(s)         Total cost of ($)
                 vTRMilkSales(s)        Total revenue from ($)
                 vTRCullSales(s)        Total revenue from ($)
                 vTRLeaseOut(s)         Total revenue from ($)
                 vTCMakingConserved(s)  Total cost of ($)
                 vTCFeedingConserved(s) Total cost of ($)
                 vTCHiredLabour(s)      Total cost of ($)
                 vTCFertPurch(s)        Total cost of ($)
                 vTCWaterPurch(s)       Total cost of ($)
                 vTCFixedCosts(s)       Total cost of ($)
                 vTCGrowingAndFeeding(f) Total cost summed over f

                 vtSupplPurch(g)       Supplement purchased summary
                 vtConserved(f)        Conserved summary
                 vtMilkSold(s)         Milk sold summary
                 vtWaterReqt           Water required summary

                 vsMilkSalesRevenue     Total revenue summed up ($)
                 vsCullSalesRevenue     Total revenue summed up ($)
                 vsLeaseOutRevenue      Total revenue summed up ($)
                 vsForageEstabCost      Total cost summed up ($)
                 vsFertPurchCost        Total cost summed up ($)
                 vsWaterPurchCost       Total cost summed up ($)
                 vsMakingConservedCost  Total cost summed up ($)
                 vsFeedingConservedCost Total cost summed up ($)
                 vsSupplPurchCost       Total cost summed up ($)
                 vsCowCostsCost         Total cost summed up ($)
                 vsHiredLabourCost      Total cost summed up ($)
                 vsFixedCostsCost       Total cost summed up ($)

;
Positive Variables
                 vForageArea(f)
                 vLeaseOut
                 vDMProduction(s,f)
                 vConserved(s,f,h)
*                 vConserved(s,f,h)
*                 vConservedO(o,f,h)
                 vSupplPurch(s,g)
                 vGrainToCows(s,c,g,r)
                 vForageToCows(s,c,f)
*                 vConsToCows(o,s,c,f,h)
                 vConsToCows(s,c,f,h)
                 vNumberCows(c)
                 vMilkProd(c,s,q)
                 vMilkSold(s,m)
                 vFixedCosts
                 vHireLab(s)
                 vCashTransfer(s)
                 vOverdraft(s)
                 vFibreSlack(s,c,b)
                 vProtSlack(s,c)
                 vFertReqt(e)
                 vWaterReqt(s)
                 vTCForageEstab(s)
                 vTCSupplPurch(s)
                 vTCCowCosts(s)
                 vTRMilkSales(s)
                 vTRCullSales(s)
                 vTRLeaseOut(s)
                 vTCMakingConserved(s)
                 vTCFeedingConserved(s)
                 vTCHiredLabour(s)
                 vTCFertPurch(s)
                 vTCWaterPurch(s)
                 vTCGrowingAndFeeding(f)
                 vtSupplPurch(g)
                 vtConserved(f)
                 vtMilkSold(s)
                 vtWaterReqt
                 vsMilkSalesRevenue
                 vsCullSalesRevenue
                 vsLeaseOutRevenue
                 vsForageEstabCost
                 vsFertPurchCost
                 vsWaterPurchCost
                 vsMakingConservedCost
                 vsFeedingConservedCost
                 vsSupplPurchCost
                 vsCowCostsCost
                 vsHiredLabourCost
                 vsFixedCostsCost
;

***EQUATIONS***

Equations  eObjFunction(s)        ObjectiveFunction -> max final cash balance       # Equation 1 (part of)
           eAreaSum(d)            ForageArea must be less than TotalArea            # Equation 2

           eForageProd(s,f)       Forage production                                 # Equation 1 (part of)
           eForageUse(s,f)        Forage use                                        # Equation 3
           eStockCons(h,f)        Stock of conserved feed                           # Equation 4
           eSupplSupply(s,g)      Supplement Supply                                 # Equation 5

           eDMSupply(s,c)         Dry Matter supply                                 # Equation 6
           eSupplRest(s,c,r)      Supplement restriction                            # Equation 7

           eMESupply(s,c)         ME Supply                                         # Equation 8
*           eRestProdFn(c,s,q)     Restrictions on Production function               # Equation 9      #no dynamic set
           eRestProdFn(c,s,q,ax)     Restrictions on Production function               # Equation 9    #ax as dynamic set

           ePsupply(s,c)          Protein Supply                                    # Equation 10
           eFSupply(s,c,b)        Fibre Supply                                      # Equation 11

           eWaterBalance(s)       Water Balance                                     # Equation 1 (part of)

           eFertBalance(e)        Fertiliser balance                                # Equation 12
           eLabourLimit(s)        Labour Balance                                    # Equation 13
           eMilkLitres(s)         Milk Balance                                      # Equation 14
           eContractLimit(s)      Contract Balance                                  # Equation 15

*           eCowsEqual(c)          Cows equal in all seasons                         # Equation 16      #no dynamic set
           eCowsEqual(c,ax)          Cows equal in all seasons                         # Equation 16    #ax as dynamic set
*           eSumCowsLimit(a)       Not more than a certain total number of cows      # Equation 17
           eSumCowsLimit(ax)       Not more than a certain total number of cows      # Equation 17

           eCashLimit(s)          Cash Balance                                      # Equation 1 (part of)
*           eTRMilkSales(s)        Calculating total revenue from
           eTRMilkSales(s,ax)        Calculating total revenue from                     #ax as dynamic set
           eTRCullSales(s)        Calculating total revenue from
           eTRLeaseOut(s)         Calculating total revenue from
           eTCCowCosts(s)         Calculating total cost of
           eTCForageEstab(s)      Calculating total cost of
           eTCFertPurch(s)        Calculating total cost of
*           eTCWaterPurch(s,a)     Calculating total cost of                             #a as dyamic set
           eTCWaterPurch(s,ax)     Calculating total cost of                             #ax as dynamic set
           eTCMakingConserved(s)  Calculating total cost of
           eTCFeedingConserved(s) Calculating total cost of
           eTCSupplPurch(s)       Calculating total cost of
           eTCHiredLabour(s)      Calculating total cost of
           eTCFixedCosts(s)       Calculating total cost of

           eOverdraftLimit(s)     Overdraft limit                                   # Equation 1 (part of)

           eTCGrowingAndFeeding(f) Equation to calculate cost of each forage

           eConstrainForages(f)   Forage area at least amount specified             # For Scenario analysis

*           eConstrainOneForage(a) Alternate method of constraining a forage         # For Scenario analysis, a as dyamic set
           eConstrainOneForage(ax) Alternate method of constraining a forage         # For Scenario analysis, ax as dynamic set
           eConstrainOutForages(ax) Removes forages from available alternatives      # For Scenario analysis, ax as dynamic set


         etSupplPurch(g)         Summary for report
         etConserved(f)          Summary for report
         etMilkSold(s)           Summary for report
         etWaterReqt             Summary for report

         esMilkSalesRevenue       Summary for report
         esCullSalesRevenue       Summary for report
         esLeaseOutRevenue        Summary for report
         esForageEstabCost        Summary for report
         esFertPurchCost          Summary for report
         esWaterPurchCost         Summary for report

         esMakingConservedCost    Summary for report
         esFeedingConservedCost   Summary for report
         esSupplPurchCost         Summary for report

         esCowCostsCost           Summary for report
         esHiredLabourCost        Summary for report
         esFixedCostsCost         Summary for report
;

***Equation 1 (a part)
eObjFunction(s)..
  + vCashTransfer(s)$(ord(s)=card(s)) - ODInt*vOverdraft(s)$(ord(s)=card(s))
  - OpCash$(ord(s)=card(s))
                               =e= vObjective$(ord(s)=card(s));
***Equation 2
eAreaSum(d)..
  + sum(f, AF(d,f)  * vForageArea(f) ) + vLeaseOut         =l= TotalArea;

***Equation 1 (a part)
eForageProd(s,f)..
  - GF(s,f) * vForageArea(f)   +   vDMProduction(s,f)    =l= 0;

***Equation 3
eForageUse(s,f)..
  - 30   *          vDMProduction(s,f)
  + 1000 / ConsUtilisation   * sum(h, vConserved(s,f,h)    )
  + 30   / ForageUtilisation * sum(c, vForageToCows(s,c,f) )   =l= 0;

*eReSetStockConsFeed(s,o,f,h)..
*  + vConserved(s,f,h)*Reset(o,s) =e= vConservedO(o,f,h)*Reset(o,s);

*eStockCons(h,f,o)..
*  - 1000        * vConservedO(o,f,h)
*  + 30   * sum(s, sum(c, vConsToCows(o,s,c,f,h) ))         =l= 0;

***Equation 4
eStockCons(h,f)..
  - 1000        * sum(s, vConserved(s,f,h)     )
  + 30   * sum(s, sum(c, vConsToCows(s,c,f,h) ))         =l= 0;

***Equation 5
eSupplSupply(s,g)..
  - 1000 * sum(y, PDMS(y,g) /100 * vSupplPurch(s,g) )
  + 30   * sum(c, sum(r,           vGrainToCows(s,c,g,r) )) =l= 0;

***Equation 6
eDMSupply(s,c)..
  +        sum(g, sum(r, DMS(r,g)     * vGrainToCows(s,c,g,r)   ))
  +               sum(f, DMF(s,f)     * vForageToCows(s,c,f)    )
*  + sum(o, sum(h, sum(f, DMFH(o,f)    * vConsToCows(o,s,c,f,h)  )))
*assume same digestibility as source forage
  +        sum(h, sum(f, DMH(h,f)     * vConsToCows(s,c,f,h)    ))
  -        sum(y, DMIAdv(c,s,y)       * vNumberCows(c)          )
                                                                         =l= 0;
***Equation 7
eSupplRest(s,c,r)..
  + sum(g,                                  vGrainToCows(s,c,g,r) )
  - sum(y, Substitution(r) * DMIAdv(c,s,y)* vNumberCows(c)        )
                                                         =l= 0;

***Equation 8
eMESupply(s,c)..
  -        sum(g, sum(r, MES('ME',g)  * vGrainToCows(s,c,g,r)   ))
  -               sum(f, MEF(s,f)     * vForageToCows(s,c,f)    )
*  - sum(o, sum(h, sum(f, MEFH(o,f)    * vConsToCows(o,s,c,f,h)  )))
*assume same digestibility as source forage
  -        sum(h, sum(f, MEH(h,f)     * vConsToCows(s,c,f,h)    ))
  +        sum(x, MEMaintAdv(c,s,x)   * vNumberCows(c)          )
  +        sum(q, MEProdAdv(c,s,q)    * vMilkProd(c,s,q)        )
                                                         =l= 0;
***Equation 9
*eRestProdFn(c,s,q,axNow)..                                                               # no dynamic sset
*  - vNumberCows(c) * ProdRest6000Adv(c,s,q) + vMilkProd(c,s,q) =l= 0;                 # (c,s,q) is not the same as (s,c,q) (eg for ProdRestAdv)

eRestProdFn(c,s,q,axNow)..                                                               # ax is dynamic sset
  - vNumberCows(c) * ProdRest6000Adv(c,s,q) * xMultiSolvesTable(axNow,'d6000s')
  - vNumberCows(c) * ProdRest9000Adv(c,s,q) * xMultiSolvesTable(axNow,'d9000s')
                                         + vMilkProd(c,s,q) =l= 0;                 # (c,s,q) is not the same as (s,c,q) (eg for ProdRestAdv)

***Equation 10
ePSupply(s,c)..
  - sum(g, sum(r, sum(w, PS(w,g) )      /100 * vGrainToCows(s,c,g,r) ))
  -               sum(f, PF(s,f)        /100 * vForageToCows(s,c,f)  )
*  - sum(o, sum(h, sum(f, PFH(o,f)       /100 * vConsToCows(o,s,c,f,h)  )))
*assume same digestibility as source forage
  -        sum(h, sum(f, PH(h,f)        /100 * vConsToCows(s,c,f,h)    ))
  + sum(y, DMIAdv(c,s,y) * ProtAdv(c,s) /100 * vNumberCows(c)        )
*  - vProtSlack(s,c)                                                                #This tests what happens if Protein was not a constraint
                                                         =l= 0;
***Equation 11
eFSupply(s,c,b)..
  -        sum(g, sum(r, FS(b,g)  /100 * vGrainToCows(s,c,g,r)   ))
  -               sum(f, FF(s,f)  /100 * vForageToCows(s,c,f)    )
*  - sum(o, sum(h, sum(f, FFH(o,f) /100 * vConsToCows(o,s,c,f,h)  )))
*assume same digestibility as source forage
  -        sum(h, sum(f, FH(h,f) /100 * vConsToCows(s,c,f,h)    ))
  +        sum(y, DMIAdv(c,s,y) * FibreReq(b) * vNumberCows(c)  )
*  - vFibreSlack(s,c,b)                                                             #This tests what happens if fibre was not a constraint
                                                         =l= 0;

***Equation 12
eFertBalance(e)..
  + sum(s, Sum(f, vForageArea(f) * UreaF(s,f)    ))$(ord(e)=1)
  + sum(s, Sum(f, vForageArea(f) * P25F(s,f)     ))$(ord(e)=2)
  - sum(s, Sum(c, vNumberCows(c) * FertManureAdv(c,s,e) ))
  - 1000 * vFertReqt(e)                         =l= 0;

***Equation 1 (part of)
eWaterBalance(s)..
  + Sum(f, vForageArea(f) * WI(s,f)    )
  - vWaterReqt(s)                                        =l= 0;

***Equation 13
eLabourLimit(s)..
           Sum(v, Sum(f, vForageArea(f)      * LF(s,f) / RF(v,f)         ))
  +               Sum(f, vForageArea(f)      * FertApp(s,f) * FertLabour )
  +               Sum(f, vForageArea(f)      * MowLabour * Mow(s,f)      )
  +               Sum(g, vSupplPurch(s,g)    * LS                        )
  +        Sum(h, sum(f, vConserved(s,f,h)*(1 - HarvestF(s,f) ) * LMH(h) ))
* Harvest(s,f) ensures no labour cost for maize or wheat harvest since this is contracted
*  + sum(o, Sum(h, Sum(c, sum(f, vConsToCows(o,s,c,f,h)* LFH(h)           ))))
  +        Sum(h, Sum(c, sum(f, vConsToCows(s,c,f,h)* LFH(h)           )))
  +               Sum(c, vNumberCows(c)      * LCCAdv(s,c)  )
  + FixedLabour
  - vHireLab(s)                                     =l= OwnLab;

***Equation 14
eMilkLitres(s)..
  - sum(q, sum(c, vMilkProd(c,s,q) ))
  +        sum(m, vMilkSold(s,m)   )                     =l= 0;


***Equation 15
eContractLimit(s)..
  vMilkSold(s, 'Contract')                     =l= ContractVol;

***Equation 1 (a part)
*Summing Total Costs
eCashLimit(s)..
  - vTRMilkSales(s)       - vTRCullSales(s) - vTRLeaseOut(s)
  + vTCCowCosts(s)
  + vTCForageEstab(s)     + vTCFertPurch(s) + vTCWaterPurch(s)
  + vTCMakingConserved(s) + vTCFeedingConserved(s)
  + vTCSupplPurch(s)
  + vTCHiredLabour(s)     + vTCFixedCosts(s)
  + vCashTransfer(s)      - vCashTransfer(s-1)$(ord(s) > 1)
  -  vOverdraft(s)        + vOverdraft(s-1)$(ord(s) > 1)*ODInt
                                       =l= (ord(s) = 1)*OpCash;

** Costs by Category (this is substantially more complex for GAMS to solve than
** subsuming all costs into a single total costs equation, but allows easy categorisation of costs)
*eTRMilkSales(s)..
*    30 *  Sum(m, vMilkSold(s, m)  * MPUni(s, m)   )
*                                                                 =g= vTRMilkSales(s)  ;  # MPUni or MPSeas for prices
eTRMilkSales(s,axNow)..
  + 30 *  Sum(m, vMilkSold(s, m)  * MPUni(s, m)  * xMultiSolvesTable(axNow,'dUni')   )
  + 30 *  Sum(m, vMilkSold(s, m)  * MPSeas(s, m) * xMultiSolvesTable(axNow,'dSeas')  )
                                                                 =g= vTRMilkSales(s)  ;  # ax as dynamic sset
eTRCullSales(s)..
                  CullRevenuePerMilker / 12 * sum(c, vNumberCows(c) ) =g= vTRCullSales(s)  ;

eTRLeaseOut(s)..
                  vLeaseOut * LeaseOutPrice                    =g= vTRLeaseOut(s)  ;
eTCCowCosts(s)..
                  Sum(c, vNumberCows(c)   * CCs(c,s)  )        =l= vTCCowCosts(s)   ;
eTCForageEstab(s)..
           Sum(v, Sum(f, vForageArea(f)   * CF(s,f) / RF(v,f)  ))
  +        Sum(v, Sum(f, vForageArea(f)   * LF(s,f) * TractorCost / RF(v,f)    ))
  +               Sum(f, vForageArea(f)   * MowLabour  * Mow(s,f)     * TractorCost )
  +               Sum(f, vForageArea(f)   * FertLabour * FertApp(s,f) * TractorCost )
                                                               =l= vTCForageEstab(s);
eTCFertPurch(s)..
    Sum(e, vFertReqt(e) * FertCost(e)  )/12      =l= vTCFertPurch(s) ;
*all fert purchased equally across the year

*eTCWaterPurch(s,aNow)..
*    vWaterReqt(s) * WaterCostDynamic(aNow)                     =l= vTCWaterPurch(s) ;              # using aNow as dynamic set
eTCWaterPurch(s,axNow)..
    vWaterReqt(s) * xMultiSolvesTable(axNow,'dWater')            =l= vTCWaterPurch(s) ;              # using axNow as dynamic set



eTCMakingConserved(s)..
    Sum(h, sum(f, CMH(h)                * vConserved(s,f,h)*(1 - HarvestF(s,f) )      ))
  + Sum(h, sum(f, LMH(h)  * TractorCost * vConserved(s,f,h)*(1 - HarvestF(s,f) )      ))
  + Sum(h, sum(f, ContractHarvest       * vConserved(s,f,h)* HarvestF(s,f)            ))
                                                               =l= vTCMakingConserved(s) ;
eTCFeedingConserved(s)..
*    Sum(o, Sum(h, Sum(c, sum(f, CFH(h)                * vConsToCows(o,s,c,f,h)    ))))
*  + Sum(o, Sum(h, Sum(c, sum(f, LFH(h)  * TractorCost * vConsToCows(o,s,c,f,h)    ))))
     Sum(h, Sum(c, sum(f, CFH(h)                * vConsToCows(s,c,f,h)    )))
  +  Sum(h, Sum(c, sum(f, LFH(h)  * TractorCost * vConsToCows(s,c,f,h)    )))
                                                               =l= vTCFeedingConserved(s) ;
eTCSupplPurch(s)..
                  Sum(g, vSupplPurch(s,g) * CS(s,g)       )    =l= vTCSupplPurch(s) ;

eTCHiredLabour(s)..
    vHireLab(s) * LabCost                                      =l= vTCHiredLabour(s) ;

eTCFixedCosts(s)..
    FixedCosts * TotalArea                                     =l= vTCFixedCosts(s) ;

eOverdraftLimit(s)..
  vOverdraft(s)                                      =l= MaxOD;
***Equation 16
*eCowsEqual(c)..
*  vNumberCows(c) - vNumberCows(c--1)                     =l= 0;                           # =n= to remove cows equal constraint
*Make relship =n= to release constraint, but leave values in mmodel (=l=)
eCowsEqual(c,axNow)..
  + vNumberCows(c)    * xMultiSolvesTable(axNow,'dSeasC')
  - vNumberCows(c--1) * xMultiSolvesTable(axNow,'dSeasC')
                                                         =l= 0;                           # ax as dynamic set




***Equation 17
*eSumCowsLimit(aNow)..
*  sum(c, vNumberCows(c))                           =l= MaxCowsDynamic(aNow);             # a as dynamic set
eSumCowsLimit(axNow)..
  sum(c, vNumberCows(c))                           =l= xMultiSolvesTable(axNow,'dMaxCows');              #ax as dynamic set


**Total costs of growing a forage species - assumes all fertiliser is purchased
eTCGrowingAndFeeding(f)..
*Establishment
           Sum(v, Sum(s, vForageArea(f)   * CF(s,f) / RF(v,f)  ))
  +        Sum(v, Sum(s, vForageArea(f)   * LF(s,f) * TractorCost / RF(v,f)    ))
  +               Sum(s, vForageArea(f)   * MowLabour  * Mow(s,f)     * TractorCost )
  +               Sum(s, vForageArea(f)   * FertLabour * FertApp(s,f) * TractorCost )
*Making
  + Sum(h, sum(s, CMH(h)                * vConserved(s,f,h)*(1 - HarvestF(s,f) )  ))
  + Sum(h, sum(s, LMH(h)  * TractorCost * vConserved(s,f,h)*(1 - HarvestF(s,f) )  ))
  + Sum(h, sum(s, ContractHarvest       * vConserved(s,f,h)* HarvestF(s,f)        ))
*Feeding
  +  Sum(h, Sum(c, sum(s, CFH(h)                * vConsToCows(s,c,f,h)    )))
  +  Sum(h, Sum(c, sum(s, LFH(h)  * TractorCost * vConsToCows(s,c,f,h)    )))
*fixed costs
  + 12 * FixedCosts * vForageArea(f)
*labour
  +        Sum(v, Sum(s, vForageArea(f)      * LF(s,f) / RF(v,f)         ))  * LabCost
  +               Sum(s, vForageArea(f)      * FertApp(s,f) * FertLabour )   * LabCost
  +               Sum(s, vForageArea(f)      * MowLabour * Mow(s,f)      )   * LabCost
*        no suppl labour
  +        Sum(h, sum(s, vConserved(s,f,h)*(1 - HarvestF(s,f) ) * LMH(h) ))  * LabCost
  +        Sum(h, Sum(c, sum(s, vConsToCows(s,c,f,h)* LFH(h)           )))   * LabCost
*Fertiliser
  + Sum(s, vForageArea(f) * UreaF(s,f)    )  /1000 * Fertcost('Urea')
  + Sum(s, vForageArea(f) * P25F(s,f)     )  /1000 * Fertcost('Pasture25')
*Water
  + Sum(s, vForageArea(f) * WI(s,f)    )  * WaterCost                               #nb WaterCostDynamic not in here
                                                         =e= vTCGrowingAndFeeding(f);
***For Scenario analysis
eConstrainForages(f)..
  + vForageArea(f)                               =g= ConstrainForages(f);           # can be removed if not required

*eConstrainOneForage(aNow)..
*** This equation allows the model to be solve 'a' times with 'a' constraints ***
*  + vForageArea('MA')                   =g= MinPercentForage(aNow) * TotalArea;
*  + vForageArea('PR')                                   =l= 0;
*  + vForageArea('PR') + vForageArea('RP')               =l= 0;
* This can also be used to drop out forages

*max yield MAxWH
*max yield (no cut) KIxRR
*max ME density RP
*max WUE MA

eConstrainOneForage(axNow)..
*** This equation allows the model to be solve 'a' times with 'a' constraints ***
  + vForageArea('MAxWH') * xMultiSolvesTable(axNow,'dMAxWH')
  + vForageArea('KIxRR') * xMultiSolvesTable(axNow,'dKIxRR')
  + vForageArea('RP')    * xMultiSolvesTable(axNow,'dRP')
  + vForageArea('MA')    * xMultiSolvesTable(axNow,'dMA')
                                        =g= xMultiSolvesTable(axNow,'dMinPercent') * TotalArea;

eConstrainOutForages(axNow)..
  + vForageArea('PR') * xMultiSolvesTable(axNow,'dPRlim')
  + vForageArea('RP') * xMultiSolvesTable(axNow,'dRPlim')
  + vForageArea('RE') * xMultiSolvesTable(axNow,'dRElim')
  + vForageArea('WC') * xMultiSolvesTable(axNow,'dWClim')
           =l= 0;


**Physical data for report
etSupplPurch(g)..
  vtSupplPurch(g) =e= sum(s, vSupplPurch(s,g) );

etConserved(f)..
  vtConserved(f) =e= sum (h, sum(s, vConserved(s,f,h) ));

etMilkSold(s)..
  vtMilkSold(s) =e= sum(m, vMilkSold(s,m) );

etWaterReqt..
  vtWaterReqt =e= sum(s, vWaterReqt(s) );

**Financial data for report
esMilkSalesRevenue..
  vsMilkSalesRevenue =e= sum(s, vTRMilkSales(s) );

esCullSalesRevenue..
  vsCullSalesRevenue =e= sum(s, vTRCullSales(s) );

esLeaseOutRevenue..
  vsLeaseOutRevenue =e= sum(s, vTRLeaseOut(s) );

esForageEstabCost..
  vsForageEstabCost =e= sum(s, vTCForageEstab(s) );

esFertPurchCost..
  vsFertPurchCost =e= sum(s, vTCFertPurch(s) );

esWaterPurchCost..
  vsWaterPurchCost =e= sum(s, vTCWaterPurch(s) );

esMakingConservedCost..
  vsMakingConservedCost =e= sum(s, vTCMakingConserved(s) );

esFeedingConservedCost..
  vsFeedingConservedCost =e= sum(s, vTCFeedingConserved(s) );

esSupplPurchCost..
  vsSupplPurchCost =e= sum(s, vTCSupplPurch(s) );

esCowCostsCost..
  vsCowCostsCost =e= sum(s, vTCCowCosts(s) );

esHiredLabourCost..
  vsHiredLabourCost =e= sum(s, vTCHiredLabour(s) );

esFixedCostsCost..
  vsFixedCostsCost =e= FixedCosts * 12 * TotalArea ;



***MODEL AND SOLVE***

Model DairyFarm  / All / ;
*option lp=gamsbas ;             # Use to save a basis (with GAMSBAS) for future use, comment out to use a previous basis file
*DairyFarm.OPTFILE=1 ;           # as above
*$OFFUNI
*$include "ADSA Dairy LP.bas"   # Use when there is a basis file (from GAMSBAS), comment out if you want to solve from activities = zero
*$ONUNI

*Option SAVEPOINT=1;              # This saves a basis

*$ontext
*** This section is a loop that creates a summary report based on solving the model 'a' times  ***

Parameter Report1(*,                      ax) Reporting on important info ;
Parameter Report2(*,                      ax) Reporting on important info ;

Execute_Loadpoint 'DairyFarm_p'  # This loads a basis

Loop(ax,
         axNow(ax) = Yes;
         Solve DairyFarm using lp maximizing vObjective    ;

         Report1(f, ax) = vForageArea.l(f)  ;
         Report1( "Lease" , ax) = vLeaseOut.l ;
         Report1(s, ax) = vNumberCows.l(s)  ;
         Report2(g, ax) = vtSupplPurch.l(g)  ;
         Report2(f, ax) =  vtConserved.l(f)  ;
         Report2(s, ax) =  vtMilkSold.l(s)   ;
         Report2( "WaterReqt",            ax) =  vtWaterReqt.l     ;
         Report2( "MilkSales",            ax) =  vsMilkSalesRevenue.l   ;
         Report2( "CullSales",            ax) =  vsCullSalesRevenue.l   ;
         Report2( "LeaseOut",             ax) =  vsLeaseOutRevenue.l    ;
         Report2( "ForageEstab",          ax) =  vsForageEstabCost.l    ;
         Report2( "FertPurch",            ax) =  vsFertPurchCost.l      ;
         Report2( "WaterPurch",           ax) =  vsWaterPurchCost.l     ;
         Report2( "MakingConserved",      ax) =  vsMakingConservedCost.l ;
         Report2( "FeedingConserved",     ax) =  vsFeedingConservedCost.l ;
         Report2( "SupplPurch",           ax) =  vsSupplPurchCost.l     ;
         Report2( "CowCosts",             ax) =  vsCowCostsCost.l       ;
         Report2( "HiredLabour",          ax) =  vsHiredLabourCost.l    ;
         Report2( "FixedCosts",           ax) =  vsFixedCostsCost.l     ;
         Report2( "Profit",               ax) = vObjective.l          ;

         axNow(ax) = No;
) ; # {endloop}

Option Report1:3:1:1 ;
Display Report1 ;
Option Report2:3:1:1 ;
Display Report2 ;

$LIBInclude xldump report1 c:\gams\AdsaLpReport.xls Sheet1!A1
$LIBInclude xldump report2 c:\gams\AdsaLpReport.xls Sheet2!A1

file ktxt /report1.txt/; ktxt.pw=600 ; put ktxt;
*$libinclude gams2tbl Report1
file ltxt /report2.txt/; ltxt.pw=600 ; put ltxt;
*$libinclude gams2tbl Report2


*$offtext
*** This is a once only solve command
*Execute_Loadpoint 'DairyFarm_p'  # This loads a previous basis
*Solve DairyFarm using lp maximizing vObjective;


*** This reports on the most recently solved solution
$Include 'ADSA Dairy LP Report.gms'