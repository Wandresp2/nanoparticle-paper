#source("1_rFigsm\nforem\nfore.R")
#source("2_rVarMods.R")

## PdI ===============================================================
### Bagged MARS ======
print("'Bagged MARS' PdI - Lipids")
bagmars_best_pdi_lipid <- select_best(bagmars_tune_pdi_lipid, metric="rmse")
bagmars_final_wflow_pdi_lipid <- finalize_workflow(bagmars_wflow_pdi_lipid, bagmars_best_pdi_lipid)
bagmars_model_pdi_lipid <- fit(bagmars_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
bagmars_pred_pdi_lipid <- predict(bagmars_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_bagmars_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = bagmars_pred_pdi_lipid$.pred)
df_bagmars_pdi_lipid$perc_error_pdi <- abs(df_bagmars_pdi_lipid$pdi-df_bagmars_pdi_lipid$pred_pdi)/df_bagmars_pdi_lipid$pdi*100
df_bagmars_pdi_lipid$model <- "bagged MARS"
df_bagmars_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Bagged MLP ======
print("Bagged MLP PdI - Lipids")
bagmlp_best_pdi_lipid <- select_best(bagmlp_tune_pdi_lipid, metric="rmse")
bagmlp_final_wflow_pdi_lipid <- finalize_workflow(bagmlp_wflow_pdi_lipid, bagmlp_best_pdi_lipid)
bagmlp_fit_pdi_lipid <- bagmlp_final_wflow_pdi_lipid |> last_fit(pdi_split_lipid, metrics=reg_metrics)
bagmlp_model_pdi_lipid <- fit(bagmlp_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
bagmlp_pred_pdi_lipid <- predict(bagmlp_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_bagmlp_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = bagmlp_pred_pdi_lipid$.pred)
df_bagmlp_pdi_lipid$perc_error_pdi <- abs(df_bagmlp_pdi_lipid$pdi-df_bagmlp_pdi_lipid$pred_pdi)/df_bagmlp_pdi_lipid$pdi*100
df_bagmlp_pdi_lipid$model <- "bagged MLP"
df_bagmlp_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Bagged trees ======
print("Bagged Trees PdI - Lipids")
bagtrees_best_pdi_lipid <- select_best(bagtrees_tune_pdi_lipid, metric="rmse")
bagtrees_final_wflow_pdi_lipid <- finalize_workflow(bagtrees_wflow_pdi_lipid, bagtrees_best_pdi_lipid)
bagtrees_model_pdi_lipid <- fit(bagtrees_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
bagtrees_pred_pdi_lipid <- predict(bagtrees_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_bagtrees_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = bagtrees_pred_pdi_lipid$.pred)
df_bagtrees_pdi_lipid$perc_error_pdi <- abs(df_bagtrees_pdi_lipid$pdi-df_bagtrees_pdi_lipid$pred_pdi)/df_bagtrees_pdi_lipid$pdi*100
df_bagtrees_pdi_lipid$model <- "bagged trees"
df_bagtrees_pdi_lipid$npType <- "Lipid-based nanoparticles"

### XGBOOST ======
print("XGBoost PdI - Lipids")
xgboost_best_pdi_lipid <- select_best(xgboost_tune_pdi_lipid, metric="rmse")
xgboost_final_wflow_pdi_lipid <- finalize_workflow(xgboost_wflow_pdi_lipid, xgboost_best_pdi_lipid)
xgboost_model_pdi_lipid <- fit(xgboost_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
xgboost_pred_pdi_lipid <- predict(xgboost_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_xgboost_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = xgboost_pred_pdi_lipid$.pred)
df_xgboost_pdi_lipid$perc_error_pdi <- abs(df_xgboost_pdi_lipid$pdi-df_xgboost_pdi_lipid$pred_pdi)/df_xgboost_pdi_lipid$pdi*100
df_xgboost_pdi_lipid$model <- "xgboost"
df_xgboost_pdi_lipid$npType <- "Lipid-based nanoparticles"

### kNN ======
print("KNN PdI - Lipids")
knn_best_pdi_lipid <- select_best(knn_tune_pdi_lipid, metric="rmse")
knn_final_wflow_pdi_lipid <- finalize_workflow(knn_wflow_pdi_lipid, knn_best_pdi_lipid)
knn_model_pdi_lipid <- fit(knn_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
knn_pred_pdi_lipid <- predict(knn_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_knn_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = knn_pred_pdi_lipid$.pred)
df_knn_pdi_lipid$perc_error_pdi <- abs(df_knn_pdi_lipid$pdi-df_knn_pdi_lipid$pred_pdi)/df_knn_pdi_lipid$pdi*100
df_knn_pdi_lipid$model <- "k-nearest neighbors"
df_knn_pdi_lipid$npType <- "Lipid-based nanoparticles"

### LASSO ======
print("LASSO PdI - Lipids")
lasso_best_pdi_lipid <- select_best(lasso_tune_pdi_lipid, metric="rmse")
lasso_final_wflow_pdi_lipid <- finalize_workflow(lasso_wflow_pdi_lipid, lasso_best_pdi_lipid)
lasso_model_pdi_lipid <- fit(lasso_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
lasso_pred_pdi_lipid <- predict(lasso_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_lasso_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = lasso_pred_pdi_lipid$.pred)
df_lasso_pdi_lipid$perc_error_pdi <- abs(df_lasso_pdi_lipid$pdi-df_lasso_pdi_lipid$pred_pdi)/df_lasso_pdi_lipid$pdi*100
df_lasso_pdi_lipid$model <- "LASSO"
df_lasso_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Linear ======
print("Linear Model PdI - Lipids")
lm_best_pdi_lipid <- select_best(lm_tune_pdi_lipid, metric="rmse")
lm_final_wflow_pdi_lipid <- finalize_workflow(lm_wflow_pdi_lipid, lm_best_pdi_lipid)
lm_model_pdi_lipid <- fit(lm_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
lm_pred_pdi_lipid <- predict(lm_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_lm_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = lm_pred_pdi_lipid$.pred)
df_lm_pdi_lipid$perc_error_pdi <- abs(df_lm_pdi_lipid$pdi-df_lm_pdi_lipid$pred_pdi)/df_lm_pdi_lipid$pdi*100
df_lm_pdi_lipid$model <- "linear regression"
df_lm_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Poisson ======
print("Poisson PdI - Lipids")
poisson_best_pdi_lipid <- select_best(poisson_tune_pdi_lipid, metric="rmse")
poisson_final_wflow_pdi_lipid <- finalize_workflow(poisson_wflow_pdi_lipid, poisson_best_pdi_lipid)
poisson_model_pdi_lipid <- fit(poisson_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
poisson_pred_pdi_lipid <- predict(poisson_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_poisson_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = poisson_pred_pdi_lipid$.pred)
df_poisson_pdi_lipid$perc_error_pdi <- abs(df_poisson_pdi_lipid$pdi-df_poisson_pdi_lipid$pred_pdi)/df_poisson_pdi_lipid$pdi*100
df_poisson_pdi_lipid$model <- "Poisson regression"
df_poisson_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Random Forest ======
print("Random Forest PdI - Lipids")
randomforest_best_pdi_lipid <- select_best(randomforest_tune_pdi_lipid, metric="rmse")
randomforest_final_wflow_pdi_lipid <- finalize_workflow(randomforest_wflow_pdi_lipid, randomforest_best_pdi_lipid)
randomforest_model_pdi_lipid <- fit(randomforest_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
randomforest_pred_pdi_lipid <- predict(randomforest_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_randomforest_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = randomforest_pred_pdi_lipid$.pred)
df_randomforest_pdi_lipid$perc_error_pdi <- abs(df_randomforest_pdi_lipid$pdi-df_randomforest_pdi_lipid$pred_pdi)/df_randomforest_pdi_lipid$pdi*100
df_randomforest_pdi_lipid$model <- "random forest"
df_randomforest_pdi_lipid$npType <- "Lipid-based nanoparticles"

### RIDGE ======
print("RIDGE PdI - Lipids")
ridge_best_pdi_lipid <- select_best(ridge_tune_pdi_lipid, metric="rmse")
ridge_final_wflow_pdi_lipid <- finalize_workflow(ridge_wflow_pdi_lipid, ridge_best_pdi_lipid)
ridge_model_pdi_lipid <- fit(ridge_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
ridge_pred_pdi_lipid <- predict(ridge_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_ridge_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = ridge_pred_pdi_lipid$.pred)
df_ridge_pdi_lipid$perc_error_pdi <- abs(df_ridge_pdi_lipid$pdi-df_ridge_pdi_lipid$pred_pdi)/df_ridge_pdi_lipid$pdi*100
df_ridge_pdi_lipid$model <- "RIDGE"
df_ridge_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Linear SVM ======
print("Linear SVM PdI - Lipids")
linSVM_best_pdi_lipid <- select_best(linSVM_tune_pdi_lipid, metric="rmse")
linSVM_final_wflow_pdi_lipid <- finalize_workflow(linSVM_wflow_pdi_lipid, linSVM_best_pdi_lipid)
linSVM_model_pdi_lipid <- fit(linSVM_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
linSVM_pred_pdi_lipid <- predict(linSVM_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_linSVM_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = linSVM_pred_pdi_lipid$.pred)
df_linSVM_pdi_lipid$perc_error_pdi <- abs(df_linSVM_pdi_lipid$pdi-df_linSVM_pdi_lipid$pred_pdi)/df_linSVM_pdi_lipid$pdi*100
df_linSVM_pdi_lipid$model <- "linear SVM"
df_linSVM_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Polynomial SVM ======
print("Polynomial SVM PdI - Lipids")
polySVM_best_pdi_lipid <- select_best(polySVM_tune_pdi_lipid, metric="rmse")
polySVM_final_wflow_pdi_lipid <- finalize_workflow(polySVM_wflow_pdi_lipid, polySVM_best_pdi_lipid)
polySVM_model_pdi_lipid <- fit(polySVM_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
polySVM_pred_pdi_lipid <- predict(polySVM_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_polySVM_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = polySVM_pred_pdi_lipid$.pred)
df_polySVM_pdi_lipid$perc_error_pdi <- abs(df_polySVM_pdi_lipid$pdi-df_polySVM_pdi_lipid$pred_pdi)/df_polySVM_pdi_lipid$pdi*100
df_polySVM_pdi_lipid$model <- "polynomial SVM"
df_polySVM_pdi_lipid$npType <- "Lipid-based nanoparticles"

### Radial SVM ======
print("Radial SVM PdI - Lipids")
radSVM_best_pdi_lipid <- select_best(radSVM_tune_pdi_lipid, metric="rmse")
radSVM_final_wflow_pdi_lipid <- finalize_workflow(radSVM_wflow_pdi_lipid, radSVM_best_pdi_lipid)
radSVM_model_pdi_lipid <- fit(radSVM_final_wflow_pdi_lipid, data=dfPdI_lipid_train)
radSVM_pred_pdi_lipid <- predict(radSVM_model_pdi_lipid, new_data=dfDiam_lipid_train)
df_radSVM_pdi_lipid <- data.frame(pdi=dfDiam_lipid_train$pdi, pred_pdi = radSVM_pred_pdi_lipid$.pred)
df_radSVM_pdi_lipid$perc_error_pdi <- abs(df_radSVM_pdi_lipid$pdi-df_radSVM_pdi_lipid$pred_pdi)/df_radSVM_pdi_lipid$pdi*100
df_radSVM_pdi_lipid$model <- "radial SVM"
df_radSVM_pdi_lipid$npType <- "Lipid-based nanoparticles"

# Combined PdI error data frame
df_error_pdi <- rbind(#
	df_bagmars_pdi_lipid,
	df_bagmlp_pdi_lipid,
	df_bagtrees_pdi_lipid,
	df_xgboost_pdi_lipid,
	df_knn_pdi_lipid,
	df_lasso_pdi_lipid,
	df_lm_pdi_lipid,
	df_poisson_pdi_lipid,
	df_randomforest_pdi_lipid,
	df_ridge_pdi_lipid,
	df_linSVM_pdi_lipid,
	df_polySVM_pdi_lipid,
	df_radSVM_pdi_lipid
)


## Diameter ======
### Bagged MARS ======
print("Bagged MARS Diameter - Lipids")
bagmars_best_diam_lipid <- select_best(bagmars_tune_diam_lipid, metric="rmse")
bagmars_final_wflow_diam_lipid <- finalize_workflow(bagmars_wflow_diam_lipid, bagmars_best_diam_lipid)
bagmars_model_diam_lipid <- fit(bagmars_final_wflow_diam_lipid, data=dfDiam_lipid_train)
bagmars_pred_diam_lipid <- predict(bagmars_model_diam_lipid, new_data=dfDiam_lipid_train)
df_bagmars_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = bagmars_pred_diam_lipid$.pred)
df_bagmars_diam_lipid$perc_error_diam <- abs(df_bagmars_diam_lipid$diam-df_bagmars_diam_lipid$pred_diam)/df_bagmars_diam_lipid$diam*100
df_bagmars_diam_lipid$model <- "bagged MARS"
df_bagmars_diam_lipid$npType <- "Lipid-based nanoparticles"


### Bagged MLP ======
print("Bagged MLP Diameter - Lipids")
bagmlp_best_diam_lipid <- select_best(bagmlp_tune_diam_lipid, metric="rmse")
bagmlp_final_wflow_diam_lipid <- finalize_workflow(bagmlp_wflow_diam_lipid, bagmlp_best_diam_lipid)
bagmlp_model_diam_lipid <- fit(bagmlp_final_wflow_diam_lipid, data=dfDiam_lipid_train)
bagmlp_pred_diam_lipid <- predict(bagmlp_model_diam_lipid, new_data=dfDiam_lipid_train)
df_bagmlp_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = bagmlp_pred_diam_lipid$.pred)
df_bagmlp_diam_lipid$perc_error_diam <- abs(df_bagmlp_diam_lipid$diam-df_bagmlp_diam_lipid$pred_diam)/df_bagmlp_diam_lipid$diam*100
df_bagmlp_diam_lipid$model <- "bagged MLP"
df_bagmlp_diam_lipid$npType <- "Lipid-based nanoparticles"

### Bagged trees ======
print("Bagged Trees Diameter - Lipids")
bagtrees_best_diam_lipid <- select_best(bagtrees_tune_diam_lipid, metric="rmse")
bagtrees_final_wflow_diam_lipid <- finalize_workflow(bagtrees_wflow_diam_lipid, bagtrees_best_diam_lipid)
bagtrees_model_diam_lipid <- fit(bagtrees_final_wflow_diam_lipid, data=dfDiam_lipid_train)
bagtrees_pred_diam_lipid <- predict(bagtrees_model_diam_lipid, new_data=dfDiam_lipid_train)
df_bagtrees_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = bagtrees_pred_diam_lipid$.pred)
df_bagtrees_diam_lipid$perc_error_diam <- abs(df_bagtrees_diam_lipid$diam-df_bagtrees_diam_lipid$pred_diam)/df_bagtrees_diam_lipid$diam*100
df_bagtrees_diam_lipid$model <- "bagged trees"
df_bagtrees_diam_lipid$npType <- "Lipid-based nanoparticles"

### XGBOOST ======
print("XGBoost Diameter - Lipids")
xgboost_best_diam_lipid <- select_best(xgboost_tune_diam_lipid, metric="rmse")
xgboost_final_wflow_diam_lipid <- finalize_workflow(xgboost_wflow_diam_lipid, xgboost_best_diam_lipid)
xgboost_model_diam_lipid <- fit(xgboost_final_wflow_diam_lipid, data=dfDiam_lipid_train)
xgboost_pred_diam_lipid <- predict(xgboost_model_diam_lipid, new_data=dfDiam_lipid_train)
df_xgboost_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = xgboost_pred_diam_lipid$.pred)
df_xgboost_diam_lipid$perc_error_diam <- abs(df_xgboost_diam_lipid$diam-df_xgboost_diam_lipid$pred_diam)/df_xgboost_diam_lipid$diam*100
df_xgboost_diam_lipid$model <- "xgboost"
df_xgboost_diam_lipid$npType <- "Lipid-based nanoparticles"

### kNN ======
print("kNN Diameter - Lipids")
knn_best_diam_lipid <- select_best(knn_tune_diam_lipid, metric="rmse")
knn_final_wflow_diam_lipid <- finalize_workflow(knn_wflow_diam_lipid, knn_best_diam_lipid)
knn_model_diam_lipid <- fit(knn_final_wflow_diam_lipid, data=dfDiam_lipid_train)
knn_pred_diam_lipid <- predict(knn_model_diam_lipid, new_data=dfDiam_lipid_train)
df_knn_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = knn_pred_diam_lipid$.pred)
df_knn_diam_lipid$perc_error_diam <- abs(df_knn_diam_lipid$diam-df_knn_diam_lipid$pred_diam)/df_knn_diam_lipid$diam*100
df_knn_diam_lipid$model <- "k-nearest neighbors"
df_knn_diam_lipid$npType <- "Lipid-based nanoparticles"

### LASSO ======
print("LASSO Diameter - Lipids")
lasso_best_diam_lipid <- select_best(lasso_tune_diam_lipid, metric="rmse")
lasso_final_wflow_diam_lipid <- finalize_workflow(lasso_wflow_diam_lipid, lasso_best_diam_lipid)
lasso_model_diam_lipid <- fit(lasso_final_wflow_diam_lipid, data=dfDiam_lipid_train)
lasso_pred_diam_lipid <- predict(lasso_model_diam_lipid, new_data=dfDiam_lipid_train)
df_lasso_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = lasso_pred_diam_lipid$.pred)
df_lasso_diam_lipid$perc_error_diam <- abs(df_lasso_diam_lipid$diam-df_lasso_diam_lipid$pred_diam)/df_lasso_diam_lipid$diam*100
df_lasso_diam_lipid$model <- "LASSO"
df_lasso_diam_lipid$npType <- "Lipid-based nanoparticles"

### Linear ======
print("Linear Model Diameter - Lipids")
lm_best_diam_lipid <- select_best(lm_tune_diam_lipid, metric="rmse")
lm_final_wflow_diam_lipid <- finalize_workflow(lm_wflow_diam_lipid, lm_best_diam_lipid)
lm_model_diam_lipid <- fit(lm_final_wflow_diam_lipid, data=dfDiam_lipid_train)
lm_pred_diam_lipid <- predict(lm_model_diam_lipid, new_data=dfDiam_lipid_train)
df_lm_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = lm_pred_diam_lipid$.pred)
df_lm_diam_lipid$perc_error_diam <- abs(df_lm_diam_lipid$diam-df_lm_diam_lipid$pred_diam)/df_lm_diam_lipid$diam*100
df_lm_diam_lipid$model <- "linear regression"
df_lm_diam_lipid$npType <- "Lipid-based nanoparticles"

### Poisson ======
print("Poisson Diameter - Lipids")
poisson_best_diam_lipid <- select_best(poisson_tune_diam_lipid, metric="rmse")
poisson_final_wflow_diam_lipid <- finalize_workflow(poisson_wflow_diam_lipid, poisson_best_diam_lipid)
poisson_model_diam_lipid <- fit(poisson_final_wflow_diam_lipid, data=dfDiam_lipid_train)
poisson_pred_diam_lipid <- predict(poisson_model_diam_lipid, new_data=dfDiam_lipid_train)
df_poisson_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = poisson_pred_diam_lipid$.pred)
df_poisson_diam_lipid$perc_error_diam <- abs(df_poisson_diam_lipid$diam-df_poisson_diam_lipid$pred_diam)/df_poisson_diam_lipid$diam*100
df_poisson_diam_lipid$model <- "Poisson regression"
df_poisson_diam_lipid$npType <- "Lipid-based nanoparticles"

### Random Forest ======
print("Random Forest Diameter - Lipids")
randomforest_best_diam_lipid <- select_best(randomforest_tune_diam_lipid, metric="rmse")
randomforest_final_wflow_diam_lipid <- finalize_workflow(randomforest_wflow_diam_lipid, randomforest_best_diam_lipid)
randomforest_model_diam_lipid <- fit(randomforest_final_wflow_diam_lipid, data=dfDiam_lipid_train)
randomforest_pred_diam_lipid <- predict(randomforest_model_diam_lipid, new_data=dfDiam_lipid_train)
df_randomforest_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = randomforest_pred_diam_lipid$.pred)
df_randomforest_diam_lipid$perc_error_diam <- abs(df_randomforest_diam_lipid$diam-df_randomforest_diam_lipid$pred_diam)/df_randomforest_diam_lipid$diam*100
df_randomforest_diam_lipid$model <- "random forest"
df_randomforest_diam_lipid$npType <- "Lipid-based nanoparticles"

### RIDGE ======
print("RIDGE Diameter - Lipids")
ridge_best_diam_lipid <- select_best(ridge_tune_diam_lipid, metric="rmse")
ridge_final_wflow_diam_lipid <- finalize_workflow(ridge_wflow_diam_lipid, ridge_best_diam_lipid)
ridge_model_diam_lipid <- fit(ridge_final_wflow_diam_lipid, data=dfDiam_lipid_train)
ridge_pred_diam_lipid <- predict(ridge_model_diam_lipid, new_data=dfDiam_lipid_train)
df_ridge_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = ridge_pred_diam_lipid$.pred)
df_ridge_diam_lipid$perc_error_diam <- abs(df_ridge_diam_lipid$diam-df_ridge_diam_lipid$pred_diam)/df_ridge_diam_lipid$diam*100
df_ridge_diam_lipid$model <- "RIDGE"
df_ridge_diam_lipid$npType <- "Lipid-based nanoparticles"

### Linear SVM ======
print("Linear SVM Diameter - Lipids")
linSVM_best_diam_lipid <- select_best(linSVM_tune_diam_lipid, metric="rmse")
linSVM_final_wflow_diam_lipid <- finalize_workflow(linSVM_wflow_diam_lipid, linSVM_best_diam_lipid)
linSVM_model_diam_lipid <- fit(linSVM_final_wflow_diam_lipid, data=dfDiam_lipid_train)
linSVM_pred_diam_lipid <- predict(linSVM_model_diam_lipid, new_data=dfDiam_lipid_train)
df_linSVM_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = linSVM_pred_diam_lipid$.pred)
df_linSVM_diam_lipid$perc_error_diam <- abs(df_linSVM_diam_lipid$diam-df_linSVM_diam_lipid$pred_diam)/df_linSVM_diam_lipid$diam*100
df_linSVM_diam_lipid$model <- "linear SVM"
df_linSVM_diam_lipid$npType <- "Lipid-based nanoparticles"

### Polynomial SVM ======
print("Polynomial SVM Diameter - Lipids")
polySVM_best_diam_lipid <- select_best(polySVM_tune_diam_lipid, metric="rmse")
polySVM_final_wflow_diam_lipid <- finalize_workflow(polySVM_wflow_diam_lipid, polySVM_best_diam_lipid)
polySVM_model_diam_lipid <- fit(polySVM_final_wflow_diam_lipid, data=dfDiam_lipid_train)
polySVM_pred_diam_lipid <- predict(polySVM_model_diam_lipid, new_data=dfDiam_lipid_train)
df_polySVM_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = polySVM_pred_diam_lipid$.pred)
df_polySVM_diam_lipid$perc_error_diam <- abs(df_polySVM_diam_lipid$diam-df_polySVM_diam_lipid$pred_diam)/df_polySVM_diam_lipid$diam*100
df_polySVM_diam_lipid$model <- "polynomial SVM"
df_polySVM_diam_lipid$npType <- "Lipid-based nanoparticles"

### Radial SVM ======
print("Radial SVM Diameter - Lipids")
radSVM_best_diam_lipid <- select_best(radSVM_tune_diam_lipid, metric="rmse")
radSVM_final_wflow_diam_lipid <- finalize_workflow(radSVM_wflow_diam_lipid, radSVM_best_diam_lipid)
radSVM_model_diam_lipid <- fit(radSVM_final_wflow_diam_lipid, data=dfDiam_lipid_train)
radSVM_pred_diam_lipid <- predict(radSVM_model_diam_lipid, new_data=dfDiam_lipid_train)
df_radSVM_diam_lipid <- data.frame(diam = dfDiam_lipid_train$hdiam_nm, pred_diam = radSVM_pred_diam_lipid$.pred)
df_radSVM_diam_lipid$perc_error_diam <- abs(df_radSVM_diam_lipid$diam-df_radSVM_diam_lipid$pred_diam)/df_radSVM_diam_lipid$diam*100
df_radSVM_diam_lipid$model <- "radial SVM"
df_radSVM_diam_lipid$npType <- "Lipid-based nanoparticles"

# Diameter error data frame
df_error_diam <- rbind(#
  df_bagmars_diam_lipid,
  df_bagmlp_diam_lipid,
  df_bagtrees_diam_lipid,
  df_xgboost_diam_lipid,
  df_knn_diam_lipid,
  df_lasso_diam_lipid,
  df_lm_diam_lipid,
  df_poisson_diam_lipid,
  df_randomforest_diam_lipid,
  df_ridge_diam_lipid,
  df_linSVM_diam_lipid,
  df_polySVM_diam_lipid,
  df_radSVM_diam_lipid
)


## %EE ======
### Bagged MARS ======
print("Bagged MARS EE - Lipids")
bagmars_best_ee_lipid <- select_best(bagmars_tune_ee_lipid, metric="rmse")
bagmars_final_wflow_ee_lipid <- finalize_workflow(bagmars_wflow_ee_lipid, bagmars_best_ee_lipid)
bagmars_model_ee_lipid <- fit(bagmars_final_wflow_ee_lipid, data=dfEE_lipid_train)
bagmars_pred_ee_lipid <- predict(bagmars_model_ee_lipid, new_data=dfDiam_lipid_train)
df_bagmars_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = bagmars_pred_ee_lipid$.pred)
df_bagmars_ee_lipid$perc_error_ee <- abs(df_bagmars_ee_lipid$percEE-df_bagmars_ee_lipid$pred_ee)/df_bagmars_ee_lipid$percEE*100
df_bagmars_ee_lipid$model <- "bagged MARS"
df_bagmars_ee_lipid$npType <- "Lipid-based nanoparticles"


### Bagged MLP ======
print("Bagged MLP EE - Lipids")
bagmlp_best_ee_lipid <- select_best(bagmlp_tune_ee_lipid, metric="rmse")
bagmlp_final_wflow_ee_lipid <- finalize_workflow(bagmlp_wflow_ee_lipid, bagmlp_best_ee_lipid)
bagmlp_model_ee_lipid <- fit(bagmlp_final_wflow_ee_lipid, data=dfEE_lipid_train)
bagmlp_pred_ee_lipid <- predict(bagmlp_model_ee_lipid, new_data=dfDiam_lipid_train)
df_bagmlp_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = bagmlp_pred_ee_lipid$.pred)
df_bagmlp_ee_lipid$perc_error_ee <- abs(df_bagmlp_ee_lipid$percEE-df_bagmlp_ee_lipid$pred_ee)/df_bagmlp_ee_lipid$percEE*100
df_bagmlp_ee_lipid$model <- "bagged MLP"
df_bagmlp_ee_lipid$npType <- "Lipid-based nanoparticles"

### Bagged trees ======
print("Bagged Trees EE - Lipids")
bagtrees_best_ee_lipid <- select_best(bagtrees_tune_ee_lipid, metric="rmse")
bagtrees_final_wflow_ee_lipid <- finalize_workflow(bagtrees_wflow_ee_lipid, bagtrees_best_ee_lipid)
bagtrees_model_ee_lipid <- fit(bagtrees_final_wflow_ee_lipid, data=dfEE_lipid_train)
bagtrees_pred_ee_lipid <- predict(bagtrees_model_ee_lipid, new_data=dfDiam_lipid_train)
df_bagtrees_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = bagtrees_pred_ee_lipid$.pred)
df_bagtrees_ee_lipid$perc_error_ee <- abs(df_bagtrees_ee_lipid$percEE-df_bagtrees_ee_lipid$pred_ee)/df_bagtrees_ee_lipid$percEE*100
df_bagtrees_ee_lipid$model <- "bagged trees"
df_bagtrees_ee_lipid$npType <- "Lipid-based nanoparticles"

### XGBOOST ======
print("XGBoost EE - Lipids")
xgboost_best_ee_lipid <- select_best(xgboost_tune_ee_lipid, metric="rmse")
xgboost_final_wflow_ee_lipid <- finalize_workflow(xgboost_wflow_ee_lipid, xgboost_best_ee_lipid)
xgboost_model_ee_lipid <- fit(xgboost_final_wflow_ee_lipid, data=dfEE_lipid_train)
xgboost_pred_ee_lipid <- predict(xgboost_model_ee_lipid, new_data=dfDiam_lipid_train)
df_xgboost_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = xgboost_pred_ee_lipid$.pred)
df_xgboost_ee_lipid$perc_error_ee <- abs(df_xgboost_ee_lipid$percEE-df_xgboost_ee_lipid$pred_ee)/df_xgboost_ee_lipid$percEE*100
df_xgboost_ee_lipid$model <- "xgboost"
df_xgboost_ee_lipid$npType <- "Lipid-based nanoparticles"

### kNN ======
print("kNN EE - Lipids")
knn_best_ee_lipid <- select_best(knn_tune_ee_lipid, metric="rmse")
knn_final_wflow_ee_lipid <- finalize_workflow(knn_wflow_ee_lipid, knn_best_ee_lipid)
knn_model_ee_lipid <- fit(knn_final_wflow_ee_lipid, data=dfEE_lipid_train)
knn_pred_ee_lipid <- predict(knn_model_ee_lipid, new_data=dfDiam_lipid_train)
df_knn_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = knn_pred_ee_lipid$.pred)
df_knn_ee_lipid$perc_error_ee <- abs(df_knn_ee_lipid$percEE-df_knn_ee_lipid$pred_ee)/df_knn_ee_lipid$percEE*100
df_knn_ee_lipid$model <- "k-nearest neighbors"
df_knn_ee_lipid$npType <- "Lipid-based nanoparticles"

### LASSO ======
print("LASSO EE - Lipids")
lasso_best_ee_lipid <- select_best(lasso_tune_ee_lipid, metric="rmse")
lasso_final_wflow_ee_lipid <- finalize_workflow(lasso_wflow_ee_lipid, lasso_best_ee_lipid)
lasso_model_ee_lipid <- fit(lasso_final_wflow_ee_lipid, data=dfEE_lipid_train)
lasso_pred_ee_lipid <- predict(lasso_model_ee_lipid, new_data=dfDiam_lipid_train)
df_lasso_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = lasso_pred_ee_lipid$.pred)
df_lasso_ee_lipid$perc_error_ee <- abs(df_lasso_ee_lipid$percEE-df_lasso_ee_lipid$pred_ee)/df_lasso_ee_lipid$percEE*100
df_lasso_ee_lipid$model <- "LASSO"
df_lasso_ee_lipid$npType <- "Lipid-based nanoparticles"

### Linear ======
print("Linear Model EE - Lipids")
lm_best_ee_lipid <- select_best(lm_tune_ee_lipid, metric="rmse")
lm_final_wflow_ee_lipid <- finalize_workflow(lm_wflow_ee_lipid, lm_best_ee_lipid)
lm_model_ee_lipid <- fit(lm_final_wflow_ee_lipid, data=dfEE_lipid_train)
lm_pred_ee_lipid <- predict(lm_model_ee_lipid, new_data=dfDiam_lipid_train)
df_lm_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = lm_pred_ee_lipid$.pred)
df_lm_ee_lipid$perc_error_ee <- abs(df_lm_ee_lipid$percEE-df_lm_ee_lipid$pred_ee)/df_lm_ee_lipid$percEE*100
df_lm_ee_lipid$model <- "linear regression"
df_lm_ee_lipid$npType <- "Lipid-based nanoparticles"

### Poisson ======
print("Poisson EE - Lipids")
poisson_best_ee_lipid <- select_best(poisson_tune_ee_lipid, metric="rmse")
poisson_final_wflow_ee_lipid <- finalize_workflow(poisson_wflow_ee_lipid, poisson_best_ee_lipid)
poisson_model_ee_lipid <- fit(poisson_final_wflow_ee_lipid, data=dfEE_lipid_train)
poisson_pred_ee_lipid <- predict(poisson_model_ee_lipid, new_data=dfDiam_lipid_train)
df_poisson_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = poisson_pred_ee_lipid$.pred)
df_poisson_ee_lipid$perc_error_ee <- abs(df_poisson_ee_lipid$percEE-df_poisson_ee_lipid$pred_ee)/df_poisson_ee_lipid$percEE*100
df_poisson_ee_lipid$model <- "Poisson regression"
df_poisson_ee_lipid$npType <- "Lipid-based nanoparticles"

### Random Forest ======
print("Random Forest EE - Lipids")
randomforest_best_ee_lipid <- select_best(randomforest_tune_ee_lipid, metric="rmse")
randomforest_final_wflow_ee_lipid <- finalize_workflow(randomforest_wflow_ee_lipid, randomforest_best_ee_lipid)
randomforest_model_ee_lipid <- fit(randomforest_final_wflow_ee_lipid, data=dfEE_lipid_train)
randomforest_pred_ee_lipid <- predict(randomforest_model_ee_lipid, new_data=dfDiam_lipid_train)
df_randomforest_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = randomforest_pred_ee_lipid$.pred)
df_randomforest_ee_lipid$perc_error_ee <- abs(df_randomforest_ee_lipid$percEE-df_randomforest_ee_lipid$pred_ee)/df_randomforest_ee_lipid$percEE*100
df_randomforest_ee_lipid$model <- "random forest"
df_randomforest_ee_lipid$npType <- "Lipid-based nanoparticles"

### RIDGE ======
print("RIDGE EE - Lipids")
ridge_best_ee_lipid <- select_best(ridge_tune_ee_lipid, metric="rmse")
ridge_final_wflow_ee_lipid <- finalize_workflow(ridge_wflow_ee_lipid, ridge_best_ee_lipid)
ridge_model_ee_lipid <- fit(ridge_final_wflow_ee_lipid, data=dfEE_lipid_train)
ridge_pred_ee_lipid <- predict(ridge_model_ee_lipid, new_data=dfDiam_lipid_train)
df_ridge_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = ridge_pred_ee_lipid$.pred)
df_ridge_ee_lipid$perc_error_ee <- abs(df_ridge_ee_lipid$percEE-df_ridge_ee_lipid$pred_ee)/df_ridge_ee_lipid$percEE*100
df_ridge_ee_lipid$model <- "RIDGE"
df_ridge_ee_lipid$npType <- "Lipid-based nanoparticles"

### Linear SVM ======
print("Linear SVM EE - Lipids")
linSVM_best_ee_lipid <- select_best(linSVM_tune_ee_lipid, metric="rmse")
linSVM_final_wflow_ee_lipid <- finalize_workflow(linSVM_wflow_ee_lipid, linSVM_best_ee_lipid)
linSVM_model_ee_lipid <- fit(linSVM_final_wflow_ee_lipid, data=dfEE_lipid_train)
linSVM_pred_ee_lipid <- predict(linSVM_model_ee_lipid, new_data=dfDiam_lipid_train)
df_linSVM_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = linSVM_pred_ee_lipid$.pred)
df_linSVM_ee_lipid$perc_error_ee <- abs(df_linSVM_ee_lipid$percEE-df_linSVM_ee_lipid$pred_ee)/df_linSVM_ee_lipid$percEE*100
df_linSVM_ee_lipid$model <- "linear SVM"
df_linSVM_ee_lipid$npType <- "Lipid-based nanoparticles"

### Polynomial SVM ======
print("Polynomial SVM EE - Lipids")
polySVM_best_ee_lipid <- select_best(polySVM_tune_ee_lipid, metric="rmse")
polySVM_final_wflow_ee_lipid <- finalize_workflow(polySVM_wflow_ee_lipid, polySVM_best_ee_lipid)
polySVM_model_ee_lipid <- fit(polySVM_final_wflow_ee_lipid, data=dfEE_lipid_train)
polySVM_pred_ee_lipid <- predict(polySVM_model_ee_lipid, new_data=dfDiam_lipid_train)
df_polySVM_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = polySVM_pred_ee_lipid$.pred)
df_polySVM_ee_lipid$perc_error_ee <- abs(df_polySVM_ee_lipid$percEE-df_polySVM_ee_lipid$pred_ee)/df_polySVM_ee_lipid$percEE*100
df_polySVM_ee_lipid$model <- "polynomial SVM"
df_polySVM_ee_lipid$npType <- "Lipid-based nanoparticles"

### Radial SVM ======
print("Radial SVM EE - Lipids")
radSVM_best_ee_lipid <- select_best(radSVM_tune_ee_lipid, metric="rmse")
radSVM_final_wflow_ee_lipid <- finalize_workflow(radSVM_wflow_ee_lipid, radSVM_best_ee_lipid)
radSVM_model_ee_lipid <- fit(radSVM_final_wflow_ee_lipid, data=dfEE_lipid_train)
radSVM_pred_ee_lipid <- predict(radSVM_model_ee_lipid, new_data=dfDiam_lipid_train)
df_radSVM_ee_lipid <- data.frame(percEE = dfDiam_lipid_train$percEE, pred_ee = radSVM_pred_ee_lipid$.pred)
df_radSVM_ee_lipid$perc_error_ee <- abs(df_radSVM_ee_lipid$percEE-df_radSVM_ee_lipid$pred_ee)/df_radSVM_ee_lipid$percEE*100
df_radSVM_ee_lipid$model <- "radial SVM"
df_radSVM_ee_lipid$npType <- "Lipid-based nanoparticles"

# Diameter error data frame
df_error_ee <- rbind(#
  df_bagmars_ee_lipid,
  df_bagmlp_ee_lipid,
  df_bagtrees_ee_lipid,
  df_xgboost_ee_lipid,
  df_knn_ee_lipid,
  df_lasso_ee_lipid,
  df_lm_ee_lipid,
  df_poisson_ee_lipid,
  df_randomforest_ee_lipid,
  df_ridge_ee_lipid,
  df_linSVM_ee_lipid,
  df_polySVM_ee_lipid,
  df_radSVM_ee_lipid
)


# Combine data frames
df_error <- cbind(#
	subset(df_error_pdi, select=c(npType, model, perc_error_pdi)),
	subset(df_error_diam, select=c(perc_error_diam)),
	subset(df_error_ee, select=c(perc_error_ee))
)
df_summ_error <- df_error |> group_by(npType, model) |>
	summarize(
		mean_pdi_error = mean(perc_error_pdi),
		sd_pdi_error = sd(perc_error_pdi),
		mean_diam_error = mean(perc_error_diam),
		sd_diam_error = sd(perc_error_diam),
		mean_ee_error = mean(perc_error_ee),
		sd_ee_error = sd(perc_error_ee)
	)


# Plot ======
palette <- c(#
	"#43A047", #13
	"#2CAA6D", #12
	"#15b392", #11
	"#04d7de", #1
	"#15c9e1", #2
	"#25bae3", #3
	"#469de7", #4
	"#5591e9", #5
	"#6384eb", #6
	"#806ae4", #7
	"#9e51f3", #8
	"#bb38f7", #9
	"#f505fe" #10
)
#
#
#p_tot_pdi_ee <- ggplot()+
#  geom_point(data=df_error,
#             mapping=aes(perc_error_pdi, perc_error_ee,
#                         colour=model), alpha=I(0.10))+
#  geom_smooth(data=df_error,
#              mapping=aes(x=perc_error_pdi, y=perc_error_ee),
#              method="lm", colour="#00AFBB", fill="#cffcff")+
#  geom_errorbar(data=df_summ_error,
#                mapping=aes(x=mean_pdi_error, y=mean_diam_error,
#                            xmin=mean_pdi_error-sd_pdi_error,
#                            xmax=mean_pdi_error+sd_pdi_error,
#                            color=model), alpha=I(0.33))+
#  geom_errorbar(data=df_summ_error,
#                mapping=aes(x=mean_pdi_error, y=mean_ee_error,
#                            ymin=mean_ee_error-sd_ee_error,
#                            ymax=mean_ee_error+sd_ee_error,
#                            color=model), alpha=I(0.33))+
#  geom_point(data=df_summ_error,
#             mapping=aes(mean_pdi_error, mean_ee_error,
#                fill=model), shape=21, size=2)+
#  geom_smooth(data=df_summ_error,
#              mapping=aes(x=mean_pdi_error, y=mean_ee_error),
#              method="lm", colour="#FF5733", fill="#FF8166",
#              linewidth=0.5)+
#  scale_x_continuous(name="% PdI error"#, limits=c(-5,100),
#                     #breaks=seq(0,100, 25)
#										 )+
#  scale_y_continuous(name="% EE error"#, limits=c(-5,100),
#                     #breaks=seq(0,100, 25)
#										 )+
#  scale_fill_manual(values=palette)+
#  scale_colour_manual(values=palette)+
#  theme(aspect.ratio=1,
#        panel.grid=element_blank(),
#        panel.background=element_rect(colour="black", fill="white"),
#        legend.key = element_rect(colour="white"),
#        legend.title=element_blank())
#p_tot_pdi_ee
#
#
#p_all <- ggplot()+
#	geom_point(data=df_error, 
#						 mapping=aes(perc_error_pdi, perc_error_diam, 
#												 colour=model), alpha=I(0.10))+
#	geom_point(data=df_summ_error, 
#						 mapping=aes(mean_pdi_error, mean_diam_error, 
#								fill=model), shape=21, size=2)+
#	scale_x_continuous(name="% PdI error")+
#	scale_y_continuous(name="% Diameter error")+
#	scale_fill_manual(values=palette)+
#	scale_colour_manual(values=palette)+
#	theme(aspect.ratio=1, 
#				panel.grid=element_blank(),
#				panel.background=element_rect(colour="black", fill="white"),
#				legend.key = element_rect(colour="white"))
#p_all
#
#
#
#p_summ <- ggplot()+
#	geom_abline(aes(intercept=0, slope=1), 
#							colour="grey", linetype=2)+
#	geom_smooth(data=df_summ_error, 
#							mapping=aes(x=mean_pdi_error, y=mean_diam_error),
#							method="lm", colour="navy", fill="grey90", 
#							linewidth=0.5)+
#	geom_point(data=df_summ_error, 
#						 mapping=aes(mean_pdi_error, mean_diam_error, 
#												 fill=model), 
#						 shape=21, size=2)+
#	scale_x_continuous(name="% PdI error", limits=c(0,40))+
#  scale_y_continuous(name="% Diameter error", limits=c(0,40))+
#  scale_fill_manual(values=palette)+
#  scale_colour_manual(values=palette)+
#  theme(aspect.ratio=1,
#        panel.grid=element_blank(),
#        panel.background=element_rect(colour="black", fill="white"),
#        legend.key = element_rect(colour="white"),
#				legend.title = element_blank(), 
#				legend.position=c(0.15, 0.69))
#p_summ
