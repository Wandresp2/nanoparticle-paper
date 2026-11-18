### Model specifications
nnet_spec <- rand_forest(mtry=tune(), 
			 trees=tune(), 
			 min_n=tune()) |>
	set_engine("randomForest") |>
	set_mode("regression") |>
	translate()
### Lipid PdI predictions ============================================
#### PdI -- Create validation/training data
set.seed(seed)
rf_lipid_pdi_RAM <- peakRAM({
pdi_split_lipid <- initial_split(dfML_lipid, prop = trainPerc, strata=pdi)
dfPdI_lipid_train <- training(pdi_split_lipid) # training data
dfPdI_lipid_test <- testing(pdi_split_lipid) # testing data

# Create cross-validation folds
pdi_folds_lipid <- vfold_cv(dfPdI_lipid_train, v=vfolds)

# Extract hyperparameters based on training data
hparam_lipid_pdi <- extract_parameter_set_dials(nnet_spec) |>
  finalize(subset(dfPdI_lipid_train,
    select=-c(payload, hdiam_nm, zetaPot_mV, percEE)))

# Set the regular grid based on the extracted values
forest_grid_lipid_pdi <- grid_regular(hparam_lipid_pdi, levels=10)

# Define the PdI recipe
pdiLipid_recipe <- recipe(pdi ~ ., 
	data=subset(dfPdI_lipid_train, 
				select=-c(payload, hdiam_nm, zetaPot_mV, percEE))) |>
	step_zv(all_predictors()) |>
	step_normalize(all_numeric_predictors())

# Create a workflow
# Start the clock!
ptm <- proc.time()
set.seed(seed)
pdi_wflow_lipid <- workflow() |>
				add_recipe(pdiLipid_recipe) |>
				add_model(nnet_spec)
# Set hyperparameters
set.seed(seed)
pdi_tune_lipid <- pdi_wflow_lipid |> 
    tune_grid(resamples = pdi_folds_lipid,
              grid = forest_grid_lipid_pdi,
              control = ctrl,
              metrics = reg_metrics)

pdi_results_lipid <- data.frame(collect_metrics(pdi_tune_lipid))
#autoplot(pdi_wflow)
show_best(pdi_tune_lipid, metric="rmse")
# Best hyperparameters
best_pdi_lipid <- select_best(pdi_tune_lipid, metric="rmse")
pdi_rsq_lipid <- round(#
	pdi_results_lipid[which(pdi_results_lipid$.metric %in% "rsq" &#
		pdi_results_lipid$.config %in% best_pdi_lipid[".config"]),#
					   "mean"], digits=3)
pdi_rmse_lipid <- round(#
	show_best(pdi_tune_lipid, metric="rmse")[1,]$mean,
	digits=3)
pdi_rmseSD_lipid <- round(#
	show_best(pdi_tune_lipid, metric="rmse")[1,]$std_err,
	digits=3)

# Generate finalized workflow
final_pdi_wflow_lipid <- finalize_workflow(pdi_wflow_lipid, best_pdi_lipid)
final_pdi_fit_lipid <- final_pdi_wflow_lipid |> last_fit(pdi_split_lipid, metrics=reg_metrics)
final_tree_pdi_lipid <- extract_workflow(final_pdi_fit_lipid)

# Generate fits
pdi_fit_lipid <- fit(final_pdi_wflow_lipid, data=dfPdI_lipid_train)

# Stop the clock
proc.time() - ptm
}) # End rf_lipid_pdi_RAM
# --------------------------------------------------------------------

### Lipid Diam predictions ===========================================
#### Diam -- Create validation/training data
set.seed(seed)
rf_lipid_diam_RAM <- peakRAM({
diam_split_lipid <- initial_split(dfML_lipid[#
							which(dfML_lipid$pdi <= pdi_lim),], 
							prop = trainPerc, strata=hdiam_nm)
dfDiam_lipid_train <- training(diam_split_lipid) # training data
dfDiam_lipid_test <- testing(diam_split_lipid) # testing data

# Create cross-validation folds
diam_folds_lipid <- vfold_cv(dfDiam_lipid_train, v=vfolds)

# Extract hyperparameters based on training data
hparam_lipid_diam <- extract_parameter_set_dials(nnet_spec) |>
  finalize(subset(dfDiam_lipid_train,
    select=-c(payload, pdi, zetaPot_mV, percEE)))

# Set the regular grid based on the extracted values
forest_grid_lipid_diam <- grid_regular(hparam_lipid_diam, levels=10)

# Define the recipe
diamLipid_recipe <- recipe(hdiam_nm ~ ., 
	data=subset(dfDiam_lipid_train, 
				select=-c(payload, pdi, zetaPot_mV, percEE))) |>
	step_zv(all_predictors()) |>
	step_normalize(all_numeric_predictors())

# Create a workflow
ptm <- proc.time()
set.seed(seed)
diam_wflow_lipid <- workflow() |>
				add_recipe(diamLipid_recipe) |>
				add_model(nnet_spec)

# Tune hyperparameters
set.seed(seed)
diam_tune_lipid <- diam_wflow_lipid |> 
	tune_grid(resamples = diam_folds_lipid,
              grid = forest_grid_lipid_diam,
              control = ctrl,
              metrics = reg_metrics)

diam_results_lipid <- data.frame(collect_metrics(diam_tune_lipid))
show_best(diam_tune_lipid, metric="rmse")
best_diam_lipid <- select_best(diam_tune_lipid, metric="rmse")

diam_rsq_lipid <- round(#
	diam_results_lipid[which(diam_results_lipid$.metric %in% "rsq" &#
		diam_results_lipid$.config %in% best_diam_lipid[".config"]),#
						"mean"], digits=3)
diam_rmse_lipid <- round(#
	show_best(diam_tune_lipid, metric="rmse")[1,]$mean,
	digits=1)
diam_rmseSD_lipid <- round(#
	show_best(diam_tune_lipid, metric="rmse")[1,]$std_err,
	digits=1)

# Finalize workflow
final_diam_wflow_lipid <- finalize_workflow(diam_wflow_lipid, best_diam_lipid)
# Final fit
final_diam_fit_lipid <- final_diam_wflow_lipid |> last_fit(diam_split_lipid, metrics=reg_metrics)
diam_fit_lipid <- fit(final_diam_wflow_lipid, data=dfDiam_lipid_train)

# Stop process time
proc.time() - ptm
}) # End rf_lipid_diam_RAM
# --------------------------------------------------------------------

### Lipid EE predictions =============================================
#### percEE -- Predictions on lipid-based NP
rf_lipid_ee_RAM <- peakRAM({
ee_split_lipid <- initial_split(dfML_lipid, 
							prop = trainPerc, strata=percEE)
dfEE_lipid_train <- training(ee_split_lipid) # training data
dfEE_lipid_test <- testing(ee_split_lipid) # testing data

# Create cross-validation folds
ee_folds_lipid <- vfold_cv(dfEE_lipid_train, v=vfolds)

# Extract hyperparameters based on training data
hparam_lipid_ee <- extract_parameter_set_dials(nnet_spec) |>
  finalize(subset(dfEE_lipid_train,
    select=-c(payload, pdi, hdiam_nm, zetaPot_mV)))

# Set the regular grid based on the extracted values
forest_grid_lipid_ee <- grid_regular(hparam_lipid_ee, levels=10)


# Define the recipe
eeLipid_recipe <- recipe(percEE ~ ., 
	data=subset(dfEE_lipid_train, 
				select=-c(payload, pdi, hdiam_nm, zetaPot_mV))) |>
	step_zv(all_predictors()) |>
	step_normalize(all_numeric_predictors())

# Create a workflow
ptm <- proc.time()
set.seed(seed)
ee_wflow_lipid <- workflow() |>
				add_recipe(eeLipid_recipe) |>
				add_model(nnet_spec)
# Tune hyperparameters
set.seed(seed)
ee_tune_lipid <- ee_wflow_lipid |> 
				tune_grid(resamples = ee_folds_lipid,
						  grid = forest_grid_lipid_ee,
						  # The options below are not required by default
						  control = ctrl,
						  metrics = reg_metrics)

ee_results_lipid <- data.frame(collect_metrics(ee_tune_lipid))

# Best result
show_best(ee_tune_lipid, metric="rmse")
best_ee_lipid <- select_best(ee_tune_lipid, metric="rmse")

ee_rsq_lipid <- round(#
	ee_results_lipid[which(ee_results_lipid$.metric %in% "rsq" &#
		ee_results_lipid$.config %in% best_ee_lipid[".config"]),#
					  "mean"], digits=3)
ee_rmse_lipid <- round(#
	show_best(ee_tune_lipid, metric="rmse")[1,]$mean,
	digits=1)
ee_rmseSD_lipid <- round(#
	show_best(ee_tune_lipid, metric="rmse")[1,]$std_err,
	digits=1)

# Finalize workflow
final_ee_wflow_lipid <- finalize_workflow(ee_wflow_lipid, best_ee_lipid)
final_ee_fit_lipid <- final_ee_wflow_lipid |> last_fit(ee_split_lipid, metrics=reg_metrics)

# Generate fits
ee_fit_lipid <- fit(final_ee_wflow_lipid, data=dfEE_lipid_train)


# End process time 
proc.time() - ptm
})
# --------------------------------------------------------------------


# Results ============================================================
# Make predictions -- PdI
dfPdI_lipid_train$dataset <- "training data"
dfPdI_lipid_test$dataset <- "testing data"
pred_pdi_train_lipid <- predict(pdi_fit_lipid, new_data = dfPdI_lipid_train)
pred_pdi_test_lipid <- predict(pdi_fit_lipid, new_data = dfPdI_lipid_test)
result_pdi_lipid_train <- data.frame(#
	pdi = dfPdI_lipid_train$pdi,
	pred_pdi=pred_pdi_train_lipid$.pred,
	dataset="training data"
)
result_pdi_lipid_test <- data.frame(#
	pdi = dfPdI_lipid_test$pdi,
	pred_pdi=pred_pdi_test_lipid$.pred,
	dataset="testing data"
)
result_pdi_lipid <- rbind(#
	result_pdi_lipid_train, result_pdi_lipid_test
)

# Make predictions -- Diameter
dfDiam_lipid_train$dataset <- "training data"
dfDiam_lipid_test$dataset <- "testing data"
pred_diam_train_lipid <- predict(diam_fit_lipid, new_data = dfDiam_lipid_train)
pred_diam_test_lipid <- predict(diam_fit_lipid, new_data = dfDiam_lipid_test)
result_diam_lipid_train <- data.frame(#
	hdiam_nm = dfDiam_lipid_train$hdiam_nm,
	pred_diam=pred_diam_train_lipid$.pred,
	dataset="training data"
)
result_diam_lipid_test <- data.frame(#
	hdiam_nm = dfDiam_lipid_test$hdiam_nm,
	pred_diam=pred_diam_test_lipid$.pred,
	dataset="testing data"
)
result_diam_lipid <- rbind(#
	result_diam_lipid_train, result_diam_lipid_test
)

# Make predictions -- %EE
dfEE_lipid_train$dataset <- "training data"
dfEE_lipid_test$dataset <- "testing data"
pred_ee_train_lipid <- predict(ee_fit_lipid, new_data = dfEE_lipid_train)
pred_ee_test_lipid <- predict(ee_fit_lipid, new_data = dfEE_lipid_test)
result_ee_lipid_train <- data.frame(#
	percEE = dfEE_lipid_train$percEE,
	pred_ee=pred_ee_train_lipid$.pred,
	dataset="training data"
)
result_ee_lipid_test <- data.frame(#
	percEE = dfEE_lipid_test$percEE,
	pred_ee=pred_ee_test_lipid$.pred,
	dataset="testing data"
)
result_ee_lipid <- rbind(#
	result_ee_lipid_train, result_ee_lipid_test
)
# --------------------------------------------------------------------

# Calculate error ====================================================
# PdI error
result_pdi_lipid$pdiPerc_error <- (result_pdi_lipid$pred_pdi-result_pdi_lipid$pdi)/result_pdi_lipid$pdi*100
result_pdi_lipid <- result_pdi_lipid[order(result_pdi_lipid$pdiPerc_error, decreasing=TRUE),]
# Diameter error
result_diam_lipid$diamPerc_error <- (result_diam_lipid$pred_diam-result_diam_lipid$hdiam_nm)/result_diam_lipid$hdiam_nm*100
result_diam_lipid <- result_diam_lipid[order(result_diam_lipid$diamPerc_error, decreasing=TRUE),]
# %EE error
result_ee_lipid$eePerc_error <- (result_ee_lipid$pred_ee-result_ee_lipid$percEE)/result_ee_lipid$percEE*100
result_ee_lipid <- result_ee_lipid[order(result_ee_lipid$eePerc_error, decreasing=TRUE),]

## Statistics
### PdI
r2.pdi_train_lipid <- summary(lm(pdi~pred_pdi,#
	result_pdi_lipid_train))['r.squared']
r2.pdi_train_lipid <- signif(r2.pdi_train_lipid$r.squared, digits=3)
##
r2.pdi_test_lipid <- summary(lm(pdi~pred_pdi,#
	result_pdi_lipid_test))['r.squared']
r2.pdi_test_lipid <- signif(r2.pdi_test_lipid$r.squared, digits=3)
### Diameter
r2.diam_train_lipid <- summary(lm(hdiam_nm~pred_diam,#
	result_diam_lipid_train))['r.squared']
r2.diam_train_lipid <- signif(r2.diam_train_lipid$r.squared, digits=3)
##
r2.diam_test_lipid <- summary(lm(hdiam_nm~pred_diam,#
	result_diam_lipid_test))['r.squared']
r2.diam_test_lipid <- signif(r2.diam_test_lipid$r.squared, digits=3)
### % EE
r2.ee_train_lipid <- summary(lm(percEE~pred_ee,#
	result_ee_lipid_train))['r.squared']
r2.ee_train_lipid <- signif(r2.ee_train_lipid$r.squared, digits=3)
##
r2.ee_test_lipid <- summary(lm(percEE~pred_ee,#
	result_ee_lipid_test))['r.squared']
r2.ee_test_lipid <- signif(r2.ee_test_lipid$r.squared, digits=3)

# Data frame of R-squared values =====================================
df_pdiRSQ_lipid <- data.frame(
  "dataset" = c("training data", "testing data"),
  "pred_pdi" = c(0.0, 0.0),
  "pdi" = c(0.95, 0.95),
  "lab" = c(paste0("r^2==",r2.pdi_train_lipid),
        paste0("r^2==",r2.pdi_test_lipid))
)

df_diamRSQ_lipid <- data.frame(
  "dataset" = c("training data", "testing data"),
  "pred_diam" = c(0.0, 0.0),
  "hdiam_nm" = c(0.95, 0.95),
  "lab" = c(paste0("r^2==",r2.diam_train_lipid),
        paste0("r^2==",r2.diam_test_lipid))
)

df_eeRSQ_lipid <- data.frame(
  "dataset" = c("training data", "testing data"),
  "pred_diam" = c(0.0, 0.0),
  "hdiam_nm" = c(0.95, 0.95),
  "lab" = c(paste0("r^2==",r2.ee_train_lipid),
        paste0("r^2==",r2.ee_test_lipid))
)
# --------------------------------------------------------------------


# PdI RMSE
rmse_rf_lipid_pdi_train <- sqrt((1/nrow(result_pdi_lipid_train))*sum((result_pdi_lipid_train$pdi-result_pdi_lipid_train$pred_pdi)^2))
rmse_rf_lipid_pdi_test <- sqrt((1/nrow(result_pdi_lipid_test))*sum((result_pdi_lipid_test$pdi-result_pdi_lipid_test$pred_pdi)^2))
# Diameter RMSE
rmse_rf_lipid_diam_train <- sqrt((1/nrow(result_diam_lipid_train))*sum((result_diam_lipid_train$hdiam_nm-result_diam_lipid_train$pred_diam)^2))
rmse_rf_lipid_diam_test <- sqrt((1/nrow(result_diam_lipid_test))*sum((result_diam_lipid_test$hdiam_nm-result_diam_lipid_test$pred_diam)^2))
# % EE RMSE
rmse_rf_lipid_ee_train <- sqrt((1/nrow(result_ee_lipid_train))*sum((result_ee_lipid_train$percEE-result_ee_lipid_train$pred_ee)^2))
rmse_rf_lipid_ee_test <- sqrt((1/nrow(result_ee_lipid_test))*sum((result_ee_lipid_test$percEE-result_ee_lipid_test$pred_ee)^2))

# PdI RSQ
rsq_rf_lipid_pdi_train <- summary(lm(pdi ~ pred_pdi, result_pdi_lipid_train))$r.squared
rsq_rf_lipid_pdi_test <- summary(lm(pdi ~ pred_pdi, result_pdi_lipid_test))$r.squared
# Diameter RSQ
rsq_rf_lipid_diam_train <- summary(lm(hdiam_nm ~ pred_diam, result_diam_lipid_train))$r.squared
rsq_rf_lipid_diam_test <- summary(lm(hdiam_nm ~ pred_diam, result_diam_lipid_test))$r.squared
# % EE RSQ
rsq_rf_lipid_ee_train <- summary(lm(percEE ~ pred_ee, result_ee_lipid_train))$r.squared
rsq_rf_lipid_ee_test <- summary(lm(percEE ~ pred_ee, result_ee_lipid_test))$r.squared

# Print RAM usage
print(paste("RAM usage (MB) -- Lipid / Diam:",rf_lipid_diam_RAM$Peak_RAM_Used_MiB*1.048576))
print(paste("RAM usage (MB) -- Lipid / PdI:",rf_lipid_pdi_RAM$Peak_RAM_Used_MiB*1.048576))
print(paste("RAM usage (MB) -- Lipid / EE:",rf_lipid_ee_RAM$Peak_RAM_Used_MiB*1.048576))
