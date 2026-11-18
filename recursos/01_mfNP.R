# Libraries ========================================
# Data
#library(DBI) # For SQL database
#library(RSQLite) # For SQL database
library(readODS) # To read .ods files
library(dplyr) 
library(tidyr)
library(readxl) # To read Excel files
library(peakRAM) # For monitoring RAM usage
# Plotting
library(ggplot2)
library(viridis)
library(ggsci)
library(cowplot)
library(patchwork)
library(scales)
library(GGally)
library(ggfortify)
library(rgl) # for plotting the parameter design space
library(plot3D)
library(xtable)
# SHAP plots
library(kernelshap)
library(shapviz)
# ML/AI
library(tidymodels)
 # see: https://tidymodels.org/find/parsnip
library(baguette)
library(earth)
library(doParallel)
library(glmnet)
library(kernlab)
library(kknn)
library(rpart)
library(randomForest)
library(probably)
#library(modeltime)
library(poissonreg)

# Load Functions =============================================================
# Also loads data
source("extra/functions.R")
# ----------------------------------------------------------------------------

# Load Data ==================================================================
df_main <- read.csv("data/mfNP_database.csv")
# ----------------------------------------------------------------------------

# Set constant variables =====================================================
# Set randomization seed
seed <- 1987

# Set PdI limit
pdi_lim <- 0.250
# Set the percent data for training vs validation
trainPerc <- 0.85

# Number of folds for v-fold cross-validation
vfolds = 10

# Define the regression metrics
reg_metrics <- metric_set(rmse, rsq)
# Control for resamples
ctrl <- control_grid(save_pred=TRUE)

# Hyperparameter tuning grid size
nGrid <- 10

# Parallelization on multiple CPU cores
ncores <- round(parallel::detectCores()*0.80) # Use 80% of CPU cores
registerDoParallel(cores=ncores) # Enables multiple cores to run
# ----------------------------------------------------------------------------

# Tidy up data ===============================================================
# Convert columns to numeric
df <- prep_main(df_main)

# Add a dispersity column
df$dispersity <- ifelse(df$pdi <= pdi_lim, "monodisperse", "polydisperse")


# Summary DF
col_select <- c("class", "np_type","tfr", "frr",
				"org_phase", "aq_phase",
				"totOrg_conc", "totAq_conc",
				"orgReag1_reag", "orgReag1_conc",
				"orgReag2_reag", "orgReag2_conc",
				"orgReag3_reag", "orgReag3_conc",
				"orgReag4_reag", "orgReag4_conc",
				"orgReag5_reag", "orgReag5_conc",
				"orgReag6_reag", "orgReag6_conc",
				"aqReag1_reag", "aqReag1_conc",
				"aqReag2_reag", "aqReag2_conc",
				"payload", "payloadConc_mM",
				"hdiam_nm", "pdi", "percEE")

df_summ <- df[, col_select]
df_summ <- df_summ %>% 
		group_by(class, np_type, tfr, frr, 
				 org_phase, aq_phase, 
				 totOrg_conc, totAq_conc,
				 orgReag1_reag, orgReag1_conc,
				 orgReag2_reag, orgReag2_conc,
				 orgReag3_reag, orgReag3_conc,
				 orgReag4_reag, orgReag4_conc,
				 orgReag5_reag, orgReag5_conc,
				 orgReag6_reag, orgReag6_conc,
				 aqReag1_reag, aqReag1_conc,
				 aqReag2_reag, aqReag2_conc,
				 payload, payloadConc_mM) %>% 
		summarize(meanDiam = mean(hdiam_nm),
				  sdDiam = sd(hdiam_nm),
				  meanPdI = mean(pdi),
				  sdPdI = sd(pdi),
				  meanEE = mean(percEE),
				  sdEE = sd(percEE)
		)
df_summ$dispersity <- ifelse(df_summ$meanPdI <= pdi_lim, 
							 "monodisperse", "polydisperse")
# Replace empty strings ("") with NA 
df_summ <- replace(df_summ, df_summ == "", NA)

# Get the number of unique formulations
## Create unique ID for summary DF
df_summ$id <- paste0(
	df_summ$np_type,":",
	df_summ$tfr,":", df_summ$frr,":",
	df_summ$org_phase,":", df_summ$aq_phase,":",
	df_summ$orgReag1_reag,":", df_summ$orgReag1_conc,":",
	df_summ$orgReag2_reag,":", df_summ$orgReag2_conc,":",
	df_summ$orgReag3_reag,":", df_summ$orgReag3_conc,":",
	df_summ$orgReag4_reag,":", df_summ$orgReag4_conc,":",
	df_summ$orgReag5_reag,":", df_summ$orgReag5_conc,":",
	df_summ$orgReag6_reag,":", df_summ$orgReag6_conc,":",
	df_summ$aqReag1_reag,":", df_summ$aqReag1_conc,":",
	df_summ$aqReag2_reag,":", df_summ$aqReag2_conc,":",
	df_summ$payload,":",df_summ$payloadConc_mM
)
write.csv(df_summ, "data/df_summary.csv", row.names=FALSE)

# Diff np data frames
dfLipid <- df[which(df$class == "Lipid-based Nanoparticles"), ]
dfPNP <- df[which(df$class == "Polymeric Nanoparticles"),]


## Subset summary DF by np class
df_summLipid <- df_summ[which(df_summ$class == "Lipid-based Nanoparticles"), ]
df_summLipid[which(is.na(df_summLipid$payload)), "payload"] = "No payload"
df_summLipid[which(is.na(df_summLipid$payloadConc_mM)), "payloadConc_mM"] = 0
df_summLipid$reag_payload_ratio <- df_summLipid$totOrg_conc/#
		df_summLipid$payloadConc_mM
df_summLipid[which(df_summLipid$reag_payload_ratio == Inf),
			 "reag_payload_ratio"] = 0

df_summPol <- df_summ[which(df_summ$class == "Polymeric Nanoparticles"),]
df_summPol[which(is.na(df_summPol$payload)), "payload"] = "No payload"

df_summPol[which(is.na(df_summPol$payloadConc_mM)), "payloadConc_mM"] = 0
df_summPol$reag_payload_ratio <- df_summPol$totOrg_conc/#
		df_summPol$payloadConc_mM
df_summPol[which(df_summPol$reag_payload_ratio == Inf),
			 "reag_payload_ratio"] = 0
#  ---------------------------------------------------------------------------

# Data summary =========================================================
## Calculate no unique formulations
totNo_unique <- length(unique(df_summ$id))
print(paste("Total unique formulations:",totNo_unique))
lipid_basedNo_unique <- nrow(df_summLipid)
print(paste("Total unique lipid-based formulations:",lipid_basedNo_unique))
lipidNo_unique <- nrow(df_summLipid[which(df_summLipid$np_type == "Lipid Nanoparticle"),]) 
print(paste("Total unique LNPs formulations:",lipidNo_unique))
print(paste("Total LNP measurements:",nrow(df[which(df$np_type == "Lipid Nanoparticle"),])))
lipoNo_unique <- nrow(df_summLipid[which(df_summLipid$np_type == "Liposome"),])
print(paste("Total unique liposome formulations:",lipoNo_unique))
print(paste("Total liposome measurements:",nrow(df[which(df$np_type == "Liposome"),])))
polNo_unique <- nrow(df_summPol)
print(paste("Total polymeric nanoparticle formulations:",polNo_unique))
print(paste("Total PLGA NP measurements:",nrow(df[which(df$np_type == "PLGA Nanoparticle"),])))
print(paste("Total number of measurements:",nrow(df)))

# Particle design space
## Lipid nanoparticles
### TFR
unique(df_summLipid[df_summLipid$np_type == "Lipid Nanoparticle", "tfr"])
### FRR
unique(df_summLipid[df_summLipid$np_type == "Lipid Nanoparticle", "frr"])
### Total organic concentration
unique(df_summLipid[df_summLipid$np_type == "Lipid Nanoparticle", "totOrg_conc"])

## Polymeric nanoparticles
### TFR
unique(df_summPol$tfr)
### FRR
unique(df_summPol$frr)
### Total organic concentration
unique(df_summPol$totOrg_conc)

## 3D plots for the paprameter space =========================================
lipid3d <- df_summ[which(df_summ$np_type == "Lipid Nanoparticle"),]
liposome3d <- df_summ[which(df_summ$np_type == "Liposome"),]
# Before need to include payload
liposome3d_nocurc <- liposome3d[which(liposome3d$np_type == "Liposome"),]
pol3d <- df_summ[which(df_summ$class == "Polymeric Nanoparticles"),]


# Correlation heatmaps =======================================================
# Lipid NP
dfCorr_lipid <- ml_prep(dfLipid[which(dfLipid$np_type == "Lipid Nanoparticle"),])
q
# Liposomes
dfCorr_liposome <- ml_prep(dfLipid[which(dfLipid$np_type == "Liposome"),])

### Wrangle polymer-based particles database =================================
dfML_PNP <- ml_prep(dfPNP)

### Wrangle lipid-based particles database (generalized) =====================
dfML_lipid <- ml_prep(dfLipid) # not separating lipid NP/liposomes
# ----------------------------------------------------------------------------
