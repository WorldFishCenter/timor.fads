//Created 24 Oct 2022
//To generate key dataset for primary analysis (based on pre-analysis plan)
//9 March 2023 - added BL variables to check for confounding
//April 17 2024 - added mddw_EL
//June 20 2024 Adding exploratory analyses

clear
set more off


/*
run "FSSP2 data cleaning script v2.do"


keep resp a_interviewer_detailsdistrict village arm month totalfishhhm ///
c_household_membershh_household c_household_membershh_children pca5 HHScore ///
d_household_detailshead_educatio d_household_detailshead_educatio ///
d_household_detailsmoney e_household_incomeclassify nutgroup ///
anyVSLA othersavings agcoop othergrp ///
daysoffishweek_BL anyfish seafood_MDD_BL fish_c_BL mddw_BL firstfish ///
c_household_membersrespondent_ag


rename 	c_household_membersrespondent_ag respage
rename  a_interviewer_detailsdistrict district
rename c_household_membershh_children othersavings
rename c_household_membershh_household sizeofHH
rename d_household_detailshead_educatio HHhead_ed
rename d_household_detailsmoney moneyearned_twoweeksUSD
rename e_household_incomeclassify HHincomeclassify
rename HHScore HHfoodinsecurity
rename month month_BL


save "C:\Users\kendr\OneDrive\Timor\FSSP2 Data\BLdata_formerge.dta", replace



merge 1:1 resp using "fishamounts_el"

drop freshfishhhm_el driedfishhhm_el prawnwthhm_el tinfishhhm_el totalfishhhmv2_el _merge

merge 1:1 resp using "ELmonthdata"
drop _merge

save "C:\Users\kendr\OneDrive\Timor\FSSP2 Data\Dataset_primaryanalysisV2.dta", replace 

*/



/*
run "FSSP2 EL data cleaning script.do"

/*For adding EL variables for primary analysis dataset
-Keep mother and child fish variable in prev 24 hours: seafood_MDD and fish_c_EL
-Keep households consuming fish at EL: anyfish_EL
-Keep knowledge on fish introduction at 6 mos: fish_CF 
Added variables for further analysis on Feb 22

*/




keep resp seafood_MDD mddw_EL fish_c_EL anyfish_EL fish_CF daysoffishweek  g_household_cookinghh_fresh_fish ///
namefreshfish1 namefreshfish2 namefreshfish3 namefreshfish4 namefreshfish5 namefreshfish6 namefreshfish7

merge 1:1 resp using "Dataset_primaryanalysisV2"
drop _merge


save "C:\Users\kendr\OneDrive\Timor\FSSP2 Data\Dataset_primaryanalysisV3.dta", replace 
*/


use Dataset_primaryanalysisV3

/*
merge 1:1 resp using "fishamounts_el"
drop _merge
drop totalfishhhmv2_el
*/

**Recoding arms so that they are increasing in intensity**
**********************************************************
gen arm2 = . 
replace arm2 = 1 if arm == 4
replace arm2 = 2 if arm == 2
replace arm2 = 3 if arm == 3
replace arm2 = 4 if arm == 1
**use arm2 variable in analyses

*1 = Control
*2 = FAD only, no SBC
*3 = SBC, no FAD
*4 = FAD + SBC 

**gen groups

gen comp1 = 1 if arm2 == 1
replace comp1 = 2 if arm2 == 2

gen comp2 = 1 if arm2 == 1
replace comp2 = 2 if arm2 == 3

gen comp3 = 1 if arm2 == 1
replace comp3 = 2 if arm2 == 4

**gen group for exploratory analysis
**Dropping manufahi and manatuto as they had no FAD data

gen arm3 = .
**first arm is control: real control, SBC only arm, and districts where FAD did not work
*replace arm3 = 1 if district == "Liquica"|district == "Covalima"|district == "Dili"
replace arm3 = 1 if district == 4|district == 2|district == 3

**second arm is if FAD worked, without SBC
replace arm3 = 2 if district == 1 

**********************************
*****Primary Outcome Variable*****
**********************************

*Log transform to acheive normality - still what to do w all the zeros??

gen totalfishhhmV2 = log(totalfishhhm)

gen totalfishhhm_elV2 = log(totalfishhhm_el)


*****************************
**Looking for confounding****
*****************************

**These were for the BL table 1
glm month_BL arm2
glm month_EL arm2
logit anyfish month_BL i.arm2, cluster (village) robust
*confounder
glm daysoffishweek_BL arm2
glm daysoffishweek_BL month_BL i.arm2, cluster (village) robust
**but it is not normally dist, thus a non-para is needed
ranksum (daysoffishweek_BL), by(comp1)
glm totalfishhhmV2 arm2
glm totalfishhhmV2 month_BL i.arm2, cluster (village) robust
*confounder
logit seafood_MDD_BL month_BL
logit seafood_MDD_BL i.arm2, cluster (village) robust
logit fish_c_BL month_BL
logit fish_c_BL i.arm2, cluster (village) robust
logit mddw_BL i.arm2, cluster (village) robust
logit firstfish i.arm2, cluster (village) robust
glm respage i.arm2, cluster (village) robust
glm HHhead_ed i.arm2, cluster (village) robust
glm sizeofHH i.arm2, cluster (village) robust
glm othersavings i.arm2, cluster (village) robust
logit HHfoodinsecurity month_BL, cluster (village) robust
logit HHfoodinsecurity month_BL i.arm2, cluster (village) robust
glm pca5 month_BL, cluster (village) robust
glm pca5 i.arm2, cluster (village) robust
**pca5 (asset index) is a confounder
logit anyVSLA i.arm2, cluster (village) robust
logit agcoop i.arm2, cluster (village) robust
logit othergrp i.arm2, cluster (village) robust
logit othersavings i.arm2, cluster (village) robust
logit nutgroups i.arm2, cluster (village) robust

ta anyfish if arm2 == 1
ta anyfish if arm2 == 2
ta anyfish if arm2 == 3
ta anyfish if arm2 == 4

codebook daysoffishweek_BL if arm2 == 1
codebook daysoffishweek_BL if arm2 == 2
codebook daysoffishweek_BL if arm2 == 3
codebook daysoffishweek_BL if arm2 == 4

*use non-transformed variable
sum totalfishhhm  if arm2 == 1
sum totalfishhhm  if arm2 == 2
sum totalfishhhm  if arm2 == 3
sum totalfishhhm  if arm2 == 4

ci means totalfishhhmV2 if arm2 == 1
ci means totalfishhhmV2 if arm2 == 2
ci means totalfishhhmV2 if arm2 == 3
ci means totalfishhhmV2 if arm2 == 4


ta seafood_MDD_BL  if arm2 == 1
ta seafood_MDD_BL  if arm2 == 2
ta seafood_MDD_BL  if arm2 == 3
ta seafood_MDD_BL  if arm2 == 4

ta fish_c_BL  if arm2 == 1
ta fish_c_BL  if arm2 == 2
ta fish_c_BL  if arm2 == 3
ta fish_c_BL  if arm2 == 4

ta mddw_BL  if arm2 == 1
ta mddw_BL  if arm2 == 2
ta mddw_BL  if arm2 == 3
ta mddw_BL  if arm2 == 4

ta firstfish  if arm2 == 1
ta firstfish  if arm2 == 2
ta firstfish  if arm2 == 3
ta firstfish  if arm2 == 4

sum respage  if arm2 == 1
sum respage  if arm2 == 2
sum respage  if arm2 == 3
sum respage  if arm2 == 4

ta HHhead_ed  if arm2 == 1
ta HHhead_ed  if arm2 == 2
ta HHhead_ed  if arm2 == 3
ta HHhead_ed  if arm2 == 4

sum sizeofHH  if arm2 == 1
sum sizeofHH  if arm2 == 2
sum sizeofHH  if arm2 == 3
sum sizeofHH  if arm2 == 4

ta childU5  if arm2 == 1
ta childU5  if arm2 == 2
ta childU5  if arm2 == 3
ta childU5  if arm2 == 4

ta HHfoodinsecurity  if arm2 == 1
ta HHfoodinsecurity  if arm2 == 2
ta HHfoodinsecurity  if arm2 == 3
ta HHfoodinsecurity  if arm2 == 4

sum pca5  if arm2 == 1
sum pca5  if arm2 == 2
sum pca5  if arm2 == 3
sum pca5  if arm2 == 4

ta anyVSLA  if arm2 == 1
ta anyVSLA  if arm2 == 2
ta anyVSLA  if arm2 == 3
ta anyVSLA  if arm2 == 4

ta nutgroup  if arm2 == 1
ta nutgroup  if arm2 == 2
ta nutgroup  if arm2 == 3
ta nutgroup  if arm2 == 4

ta othergrp  if arm2 == 1
ta othergrp  if arm2 == 2
ta othergrp  if arm2 == 3
ta othergrp  if arm2 == 4

ta agcoop  if arm2 == 1
ta agcoop  if arm2 == 2
ta agcoop  if arm2 == 3
ta agcoop  if arm2 == 4

ta othersavings  if arm2 == 1
ta othersavings  if arm2 == 2
ta othersavings  if arm2 == 3
ta othersavings  if arm2 == 4

********************
**Primary analysis**
********************

ta anyfish_EL if arm2 == 1
ta anyfish_EL if arm2 == 2
ta anyfish_EL if arm2 == 3
ta anyfish_EL if arm2 == 4

sum totalfishhhm_el if arm2 == 1
sum totalfishhhm_el if arm2 == 2
sum totalfishhhm_el if arm2 == 3
sum totalfishhhm_el if arm2 == 4

sum totalfishhhm_elV2 if arm2 == 1
sum totalfishhhm_elV2 if arm2 == 2
sum totalfishhhm_elV2 if arm2 == 3
sum totalfishhhm_elV2 if arm2 == 4

ci means totalfishhhm_elV2 if arm2 == 1
ci means totalfishhhm_elV2 if arm2 == 2
ci means totalfishhhm_elV2 if arm2 == 3
ci means totalfishhhm_elV2 if arm2 == 4

ci means totalfishhhm_el if arm2 == 1
ci means totalfishhhm_el if arm2 == 2
ci means totalfishhhm_el if arm2 == 3
ci means totalfishhhm_el if arm2 == 4

**reported back transformed geometric means in paper - see excel

**Checking on month - not a confounder
glm totalfishhhm_elV2 month_EL


**Linear regression controlling for asset index, BL fish cons
meglm totalfishhhm_elV2 totalfishhhmV2 pca5 i.arm2 || village:
**NO sig difference 


*meglm freshfishhhm_el pca5 i.arm || village:
*meglm freshfishhhm_el pca5 i.arm || district:


logit anyfish month_EL  

logit mddw_EL month_EL
*month is associated with mddw_EL
ta mddw_EL if month_EL == 6
ta mddw_EL if month_EL == 7
ta mddw_EL if month_EL == 8
logit mddw_EL i.arm2 mddw_BL month_EL pca5, cluster (village) robust

*month_EL is a confounder, anyfish at BL is a confounder
logit anyfish_EL i.arm2 anyfish month_EL pca5, cluster (village) robust 

replace g_household_cookinghh_fresh_fish = . if g_household_cookinghh_fresh_fish == 98
replace g_household_cookinghh_fresh_fish = 0 if g_household_cookinghh_fresh_fish == 2

logit g_household_cookinghh_fresh_fish i.arm2 pca5 month_EL, cluster (village) robust


**************************
**Mediation analysis******
**************************

*Self-reported knowledge of approp CF feeding of fish
meglm totalfishhhm_elV2 i.arm2#fish_CF pca5 || village:



**************************
**Secondary analysis******
**************************

logit seafood_MDD month_EL
logit seafood_MDD i.arm2 pca5, cluster (village) robust
logit fish_c_EL month_EL
logit fish_c_EL i.arm2 pca5, cluster (village) robust

**adding in BL fish consumption
logit seafood_MDD i.arm2 seafood_MDD_BL pca5, cluster (village) robust

*Season wouldn't be a confounder here
logit fish_CF i.arm2 pca5, cluster (village) robust

**Prob should log daysoffishweek
*glm daysoffishweek month_EL
*month_EL is a confounder here
*meglm daysoffishweek i.arm2 month_EL pca5 || village: 
*actually this is sort of a weird variable so I won't model it


ta seafood_MDD  if arm2 == 1
ta seafood_MDD  if arm2 == 2
ta seafood_MDD  if arm2 == 3
ta seafood_MDD  if arm2 == 4

ta fish_c_EL  if arm2 == 1
ta fish_c_EL  if arm2 == 2
ta fish_c_EL  if arm2 == 3
ta fish_c_EL  if arm2 == 4

sum daysoffishweek if arm2 == 1
sum daysoffishweek if arm2 == 2
sum daysoffishweek if arm2 == 3
sum daysoffishweek if arm2 == 4

****Look for differences by district
logit anyfish_EL i.arm2 anyfish month_EL pca5, cluster (village) robust

logit anyfish_EL i.district

ta anyfish_EL district 

*xtset anyfish_EL arm2, fe (cluster) district 


**************************
**Exploratory analysis****
**************************
nonsense

ci means totalfishhhm_elV2 if arm3 == 1
ci means totalfishhhm_elV2 if arm3 == 2

*logit anyfish_EL i.arm3 anyfish month_EL pca5, cluster (village) robust 
logit anyfish_EL arm3 anyfish month_EL pca5, cluster (village) robust 
meglm totalfishhhm_elV2 totalfishhhmV2 pca5 i.arm3 || village:

meglm totalfishhhm_elV2 totalfishhhmV2 pca5 arm3 || village:

logit seafood_MDD arm3 pca5, cluster (village) robust

ta seafood_MDD if arm3 == 1
ta seafood_MDD if arm3 == 2



