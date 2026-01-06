# Code repository for: *A supply and demand intervention increased fish consumption among rural women: a randomized, controlled trial*

This repository contains the analysis code used in the paper *“A supply and demand intervention increased fish consumption among rural women: a randomized, controlled trial”*.

## Repository structure (key files)

### Household survey analysis (Stata)
- `code_HH_survey.do`  
  Runs the household survey analyses: recodes treatment arms (FAD/SBC intensity), checks baseline balance/confounding, and estimates primary, secondary, and exploratory effects (with village-level clustering / mixed-effects where specified).

### CPUE difference-in-differences analysis (Quarto/R)
- `did_analysis.qmd`  
  Estimates the impact of FAD installation on catch per unit effort (CPUE) using a difference-in-differences design with Leopa as the control site. Defines “before” and “after installation” windows for Suai, Hera, and Atabae, bootstraps DiD estimates (1000 replicates), and produces the main plot and summary estimates.

## Data
- `Dataset_primaryanalysisV3.dta`  
  Household survey analysis dataset used by `code_HH_survey.do`.

- `trips_clean.parquet`  
  Input trip-level dataset used by `did_analysis.qmd`.