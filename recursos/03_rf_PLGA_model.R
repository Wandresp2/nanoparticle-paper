### POLYMER PREDICTIONS ==============================================
#### PdI -- Create validation/training data
rf_pol_pdi_RAM <- peakRAM({
pdi_split_pol <- initial_split(dfML_PNP, prop = trainPerc, strata=pdi)
dfPdI_pol_train <- training(pdi_split_pol) # training data
dfPdI_pol_test <- testing(pdi_split_pol) # testing data

# Create cross-validation folds
pdi_folds_pol <- vfold_cv(dfPdI_pol_train, v=vfolds)

# Extract hyperparameters based on training data
hparam_pol_pdi <- extract_parameter_set_dials(nnet_spec) |>
  finalize(subset(dfPdI_pol_train,
    select=-c(payload, pdi, hdiam_nm, zetaPot_mV)))

# Set the regular grid based on the extracted values
forest_grid_pol_pdi <- grid_regular(hparam_pol_pdi, levels=10)

# Define the PdI recipe
pdiPol_recipe <- recipe(pdi ~ .,
  data=subset(dfPdI_pol_train,
        select=-c(payload, hdiam_nm, zetaPot_mV, percEE))) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())


# Create a workflow
# Start the clock!
ptm <- proc.time()
set.seed(42)
pdi_wflow_pol <- workflow() |>
        add_recipe(pdiPol_recipe) |>
        add_model(nnet_spec)
# Set hyperparameters
set.seed(42)
pdi_tune_pol <- pdi_wflow_pol |>
        tune_grid(resamples = pdi_folds_pol,
              grid = forest_grid_pol_pdi,
              # The options below are not required by default
              control = ctrl,
              metrics = reg_metrics)

# Best results
pdi_results_pol <- data.frame(collect_metrics(pdi_tune_pol))
show_best(pdi_tune_pol, metric="rsq")
best_pdi_pol <- select_best(pdi_tune_pol, metric="rmse")

pdi_rsq_pol <- round(#
  pdi_results_pol[which(pdi_results_pol$.metric %in% "rsq" &#
    pdi_results_pol$.config %in% best_pdi_pol[".config"]),#
           "mean"], digits=3)
pdi_rmse_pol <- round(#
  show_best(pdi_tune_pol, metric="rmse")[1,]$mean,
  digits=3)
pdi_rmseSD_pol <- round(#
  show_best(pdi_tune_pol, metric="rmse")[1,]$std_err,
  digits=3)

# Finalize workflow
final_pdi_wflow_pol <- finalize_workflow(pdi_wflow_pol, best_pdi_pol)
# Finalize fit
final_pdi_fit_pol <- final_pdi_wflow_pol |> last_fit(pdi_split_pol, metrics=reg_metrics)
pdi_fit_pol <- fit(final_pdi_wflow_pol, data=dfPdI_pol_train)

# Stop process time
proc.time()-ptm
}) # END rf_lipid_pdi_RAM
# --------------------------------------------------------------------


### Diam -- Create validation/training data ==========================
rf_pol_diam_RAM <- peakRAM({
diam_split_pol <- initial_split(dfML_PNP[#
    which(dfML_PNP$pdi <= pdi_lim),],
  prop = trainPerc, strata=hdiam_nm)
dfDiam_pol_train <- training(diam_split_pol) # training data
dfDiam_pol_test <- testing(diam_split_pol) # testing data

# Create cross-validation folds
diam_folds_pol <- vfold_cv(dfDiam_pol_train, v=vfolds)

# Extract hyperparameters based on training data
hparam_pol_diam <- extract_parameter_set_dials(nnet_spec) |>
  finalize(subset(dfDiam_pol_train,
    select=-c(payload, pdi, hdiam_nm, zetaPot_mV)))

# Set the regular grid based on the extracted values
forest_grid_pol_diam <- grid_regular(hparam_pol_diam, levels=10)

# Define the recipe
diamPol_recipe <- recipe(hdiam_nm ~ .,
    data=subset(dfDiam_pol_train,
          select=-c(payload, pdi, zetaPot_mV, percEE))) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# Create a workflow
ptm <- proc.time()
set.seed(42)
diam_wflow_pol <- workflow() |>
        add_recipe(diamPol_recipe) |>
        add_model(nnet_spec)
# Tune hyperparameters
set.seed(42)
diam_tune_pol <- diam_wflow_pol |>
        tune_grid(resamples = diam_folds_pol,
              grid = forest_grid_pol_diam,
              # The options below are not required by default
              control = ctrl,
              metrics = reg_metrics)

# Best result
diam_results_pol <- data.frame(collect_metrics(diam_tune_pol))
show_best(diam_tune_pol, metric="rsq")
best_diam_pol <- select_best(diam_tune_pol, metric="rmse")

# Finalize workflow
final_diam_wflow_pol <- finalize_workflow(diam_wflow_pol, best_diam_pol)

# Final fit
final_diam_fit_pol <- final_diam_wflow_pol |> last_fit(diam_split_pol, metrics=reg_metrics)

diam_rsq_pol <- round(#
  diam_results_pol[which(diam_results_pol$.metric %in% "rsq" &#
    diam_results_pol$.config %in% best_diam_pol[".config"]),#
                 "mean"], digits=3)
diam_rmse_pol <- round(#
  show_best(diam_tune_pol, metric="rmse")[1,]$mean,
  digits=1)
diam_rmseSD_pol <- round(#
  show_best(diam_tune_pol, metric="rmse")[1,]$std_err,
  digits=1)

diam_fit_pol <- fit(final_diam_wflow_pol, data=dfDiam_pol_train)

# End process time
proc.time()-ptm
}) # END rf_pol_diam_RAM
# --------------------------------------------------------------------


### Encapsulation % training =========================================
rf_pol_ee_RAM <- peakRAM({
ee_split_pol <- initial_split(dfML_PNP, prop = trainPerc, strata=percEE)
dfEE_pol_train <- training(ee_split_pol) # training data
dfEE_pol_test <- testing(ee_split_pol) # testing data

# Create cross-validation folds
ee_folds_pol <- vfold_cv(dfEE_pol_train, v=vfolds)

# Extract hyperparameters based on training data
hparam_pol_ee <- extract_parameter_set_dials(nnet_spec) |>
  finalize(subset(dfEE_pol_train,
    select=-c(payload, pdi, hdiam_nm, zetaPot_mV)))

# Set the regular grid based on the extracted values
forest_grid_pol_ee <- grid_regular(hparam_pol_ee, levels=10)

# Define the recipe
eePol_recipe <- recipe(percEE ~ .,
    data=subset(dfEE_pol_train,
          select=-c(payload, hdiam_nm, pdi, zetaPot_mV))) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# Create a workflow
ptm <- proc.time()
set.seed(42)
ee_wflow_pol <- workflow() |>
        add_recipe(eePol_recipe) |>
        add_model(nnet_spec)
# Tune hyperparameters
set.seed(42)
ee_tune_pol <- ee_wflow_pol |>
        tune_grid(resamples = ee_folds_pol,
              grid = forest_grid_pol_ee,
              # The options below are not required by default
              control = ctrl,
              metrics = reg_metrics)

# Best result
ee_results_pol <- data.frame(collect_metrics(ee_tune_pol))
show_best(ee_tune_pol, metric="rsq")
best_ee_pol <- select_best(ee_tune_pol, metric="rmse")

# Finalize workflow
final_ee_wflow_pol <- finalize_workflow(ee_wflow_pol, best_ee_pol)

ee_rsq_pol <- round(#
  ee_results_pol[which(ee_results_pol$.metric %in% "rsq" &#
    ee_results_pol$.config %in% best_ee_pol[".config"]),#
                 "mean"], digits=3)
ee_rmse_pol <- round(#
  show_best(ee_tune_pol, metric="rmse")[1,]$mean,
  digits=1)
ee_rmseSD_pol <- round(#
  show_best(ee_tune_pol, metric="rmse")[1,]$std_err,
  digits=1)


# Final fit
final_ee_fit_pol <- final_ee_wflow_pol |> last_fit(ee_split_pol, metrics=reg_metrics)
ee_fit_pol <- fit(final_ee_wflow_pol, data=dfEE_pol_train)

# End process time
proc.time()-ptm
}) # End rf_pol_ee_RAM
# --------------------------------------------------------------------


# Results ============================================================
# Make predictions -- PdI
dfPdI_pol_train$dataset <- "training data"
dfPdI_pol_test$dataset <- "testing data"
pred_pdi_train_pol <- predict(pdi_fit_pol, new_data = dfPdI_pol_train)
pred_pdi_test_pol <- predict(pdi_fit_pol, new_data = dfPdI_pol_test)
result_pdi_pol_train <- data.frame(#
  pdi = dfPdI_pol_train$pdi,
  pred_pdi = pred_pdi_train_pol$.pred,
  dataset="training data"
)
result_pdi_pol_test <- data.frame(#
  pdi = dfPdI_pol_test$pdi,
  pred_pdi = pred_pdi_test_pol$.pred,
  dataset="testing data"
)
result_pdi_pol <- rbind(#
  result_pdi_pol_train, result_pdi_pol_test
)

# Make predictions -- Diameter
dfDiam_pol_train$dataset <- "training data"
dfDiam_pol_test$dataset <- "testing data"
pred_diam_train_pol <- predict(diam_fit_pol, new_data = dfDiam_pol_train)
pred_diam_test_pol <- predict(diam_fit_pol, new_data = dfDiam_pol_test)
result_diam_pol_train <- data.frame(#
  hdiam_nm = dfDiam_pol_train$hdiam_nm,
  pred_diam = pred_diam_train_pol$.pred,
  dataset="training data"
)
result_diam_pol_test <- data.frame(#
  hdiam_nm = dfDiam_pol_test$hdiam_nm,
  pred_diam = pred_diam_test_pol$.pred,
  dataset="testing data"
)
result_diam_pol <- rbind(#
  result_diam_pol_train, result_diam_pol_test
)

# Make predictions -- %EE
dfEE_pol_train$dataset <- "training data"
dfEE_pol_test$dataset <- "testing data"
pred_ee_train_pol <- predict(ee_fit_pol, new_data = dfEE_pol_train)
pred_ee_test_pol <- predict(ee_fit_pol, new_data = dfEE_pol_test)
result_ee_pol_train <- data.frame(#
  percEE = dfEE_pol_train$percEE,
  pred_ee = pred_ee_train_pol$.pred,
  dataset="training data"
)
result_ee_pol_test <- data.frame(#
  percEE = dfEE_pol_test$percEE,
  pred_ee = pred_ee_test_pol$.pred,
  dataset="testing data"
)
result_ee_pol <- rbind(#
  result_ee_pol_train, result_ee_pol_test
)
# --------------------------------------------------------------------


# Calculate error ====================================================
# PdI error
result_pdi_pol$pdiPerc_error <- (result_pdi_pol$pred_pdi-result_pdi_pol$pdi)/result_pdi_pol$pdi*100
result_pdi_pol <- result_pdi_pol[order(result_pdi_pol$pdiPerc_error, decreasing=TRUE),]
result_pdi_pol$index <- 1:nrow(result_pdi_pol)
# Diameter error
result_diam_pol$diamPerc_error <- (result_diam_pol$pred_diam-result_diam_pol$hdiam_nm)/result_diam_pol$hdiam_nm*100
result_diam_pol <- result_diam_pol[order(result_diam_pol$diamPerc_error, decreasing=TRUE),]
result_diam_pol$index <- 1:nrow(result_diam_pol)
# %EE error
result_ee_pol$eePerc_error <- (result_ee_pol$pred_ee-result_ee_pol$percEE)/result_ee_pol$percEE*100
result_ee_pol <- result_ee_pol[order(result_ee_pol$eePerc_error, decreasing=TRUE),]
result_ee_pol$index <- 1:nrow(result_ee_pol)

# Statistics -- PdI
r2.pdi_test_pol <- summary(lm(pdi~pred_pdi,#
  result_pdi_pol[which(result_pdi_pol$dataset == "testing data"),]))['r.squared']
r2.pdi_test_pol <- signif(r2.pdi_test_pol$r.squared, digits=3)

r2.pdi_train_pol <- summary(lm(pdi~pred_pdi,#
  result_pdi_pol[which(result_pdi_pol$dataset == "training data"),]))['r.squared']
r2.pdi_train_pol <- signif(r2.pdi_train_pol$r.squared, digits=3)

# PdI stats -- monodisperse vs polydisperse
r2.pdi_test_pol_mono <- summary(lm(pdi~pred_pdi,#
  result_pdi_pol[which(result_pdi_pol$pdi <= pdi_lim &#
                     result_pdi_pol$dataset == "testing data"),]))['r.squared']
r2.pdi_test_pol_mono <- signif(r2.pdi_test_pol_mono$r.squared, digits=3)

r2.pdi_test_pol_poly <- summary(lm(pdi~pred_pdi,#
  result_pdi_pol[which(result_pdi_pol$pdi > pdi_lim &#
                     result_pdi_pol$dataset == "testing data"),]))['r.squared']
r2.pdi_test_pol_poly <- signif(r2.pdi_test_pol_poly$r.squared, digits=3)

r2.pdi_train_pol_mono <- summary(lm(pdi~pred_pdi,#
  result_pdi_pol[which(result_pdi_pol$pdi <= pdi_lim &#
                     result_pdi_pol$dataset == "training data"),]))['r.squared']
r2.pdi_train_pol_mono <- signif(r2.pdi_train_pol_mono$r.squared, digits=3)

r2.pdi_train_pol_poly <- summary(lm(pdi~pred_pdi,#
  result_pdi_pol[which(result_pdi_pol$pdi > pdi_lim &#
                     result_pdi_pol$dataset == "training data"),]))['r.squared']
r2.pdi_train_pol_poly <- signif(r2.pdi_train_pol_poly$r.squared, digits=3)

# Statistics -- Diameter
r2.diam_test_pol <- summary(lm(hdiam_nm~pred_diam,#
  result_diam_pol[which(result_diam_pol$dataset == "testing data"),]))['r.squared']
r2.diam_test_pol <- signif(r2.diam_test_pol$r.squared, digits=3)

r2.diam_train_pol <- summary(lm(hdiam_nm~pred_diam,#
  result_diam_pol[which(result_diam_pol$dataset == "training data"),]))['r.squared']
r2.diam_train_pol <- signif(r2.diam_train_pol$r.squared, digits=3)


# Statistics -- %EE
r2.ee_test_pol <- summary(lm(percEE~pred_ee,#
  result_ee_pol[which(result_ee_pol$dataset == "testing data"),]))['r.squared']
r2.ee_test_pol <- signif(r2.ee_test_pol$r.squared, digits=3)

r2.ee_train_pol <- summary(lm(percEE~pred_ee,#
  result_ee_pol[which(result_ee_pol$dataset == "training data"),]))['r.squared']
r2.ee_train_pol <- signif(r2.ee_train_pol$r.squared, digits=3)
# --------------------------------------------------------------------

# Data frame of R-squared values =====================================
df_pdiRSQ_pol <- data.frame(
  "dataset" = c("training data", "testing data"),
  "pred_pdi" = c(0.0, 0.0),
  "pdi" = c(0.95, 0.95),
  "lab" = c(paste0("r^2==",r2.pdi_train_pol),
        paste0("r^2==",r2.pdi_test_pol))
)

df_diamRSQ_pol <- data.frame(
  "dataset" = c("training data", "testing data"),
  "pred_diam" = c(0.0, 0.0),
  "hdiam_nm" = c(0.95, 0.95),
  "lab" = c(paste0("r^2==",r2.diam_train_pol),
        paste0("r^2==",r2.diam_test_pol))
)

df_eeRSQ_pol <- data.frame(
  "dataset" = c("training data", "testing data"),
  "pred_ee" = c(0.0, 0.0),
  "percEE" = c(100, 95),
  "lab" = c(paste0("r^2==",r2.ee_train_pol),
        paste0("r^2==",r2.ee_test_pol))
)
# --------------------------------------------------------------------

# PdI RMSE
rmse_rf_pol_pdi_train <- sqrt((1/nrow(result_pdi_pol_train))*sum((result_pdi_pol_train$pdi-result_pdi_pol_train$pred_pdi)^2))
rmse_rf_pol_pdi_test <- sqrt((1/nrow(result_pdi_pol_test))*sum((result_pdi_pol_test$pdi-result_pdi_pol_test$pred_pdi)^2))
# Diameter RMSE
rmse_rf_pol_diam_train <- sqrt((1/nrow(result_diam_pol_train))*sum((result_diam_pol_train$hdiam_nm-result_diam_pol_train$pred_diam)^2))
rmse_rf_pol_diam_test <- sqrt((1/nrow(result_diam_pol_test))*sum((result_diam_pol_test$hdiam_nm-result_diam_pol_test$pred_diam)^2))
# % EE RMSE
rmse_rf_pol_ee_train <- sqrt((1/nrow(result_ee_pol_train))*sum((result_ee_pol_train$percEE-result_ee_pol_train$pred_ee)^2))
rmse_rf_pol_ee_test <- sqrt((1/nrow(result_ee_pol_test))*sum((result_ee_pol_test$percEE-result_ee_pol_test$pred_ee)^2))

# PdI RSQ
rsq_rf_pol_pdi_train <- summary(lm(pdi ~ pred_pdi, result_pdi_pol_train))$r.squared
rsq_rf_pol_pdi_test <- summary(lm(pdi ~ pred_pdi, result_pdi_pol_test))$r.squared
# Diameter RSQ
rsq_rf_pol_diam_train <- summary(lm(hdiam_nm ~ pred_diam, result_diam_pol_train))$r.squared
rsq_rf_pol_diam_test <- summary(lm(hdiam_nm ~ pred_diam, result_diam_pol_test))$r.squared
# % EE RSQ
rsq_rf_pol_ee_train <- summary(lm(percEE ~ pred_ee, result_ee_pol_train))$r.squared
rsq_rf_pol_ee_test <- summary(lm(percEE ~ pred_ee, result_ee_pol_test))$r.squared

# Print RAM usage
print(paste("RAM usage (MB) -- PLGA / Diam:",rf_pol_diam_RAM$Peak_RAM_Used_MiB*1.048576))
print(paste("RAM usage (MB) -- PLGA / PdI:",rf_pol_pdi_RAM$Peak_RAM_Used_MiB*1.048576))
print(paste("RAM usage (MB) -- PLGA / EE:",rf_pol_ee_RAM$Peak_RAM_Used_MiB*1.048576))
