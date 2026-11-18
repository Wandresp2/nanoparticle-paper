# Get all the model recipes
# Bagged MARS via earth
bagmars_spec <- bag_mars(num_terms = tune(), 
						 prod_degree = tune(), 
						 prune_method = tune()) |>
	set_engine("earth") |>
	set_mode("regression") |>
	translate()

# Bagged MLP neural network via 'nnet'
bagmlp_spec <- bag_mlp(hidden_units=tune(),
                       penalty=tune(),
                       epochs=tune()) |>
    set_engine("nnet") |>
    set_mode("regression")

# Bagged trees via 'rpart'
bagtrees_spec <- bag_tree(tree_depth = tune(), 
						  min_n = tune(),
						  cost_complexity = tune()) |> 
  set_engine("rpart") |> 
  set_mode("regression") |> 
  translate()

# Boosted trees via 'xgboost'
xgboost_spec <- boost_tree(mtry = tune(), 
						   trees = tune(), 
						   min_n = tune(), 
						   tree_depth = tune(),
						   learn_rate = tune(), 
						   loss_reduction = tune(), 
						   sample_size = tune(),
						   stop_iter = tune()) |>
	set_engine("xgboost") |>
	set_mode("regression") |>
	translate()


# k-nearest neighbors via 'kknn'
knn_spec <- nearest_neighbor(neighbors=tune(),
                             weight_func=tune(),
                             dist_power=tune()) |>
    set_engine("kknn") |>
    set_mode("regression") |>
    translate()

# LASSO
lasso_spec <- linear_reg(penalty = tune(), 
						 mixture = 1) |>  
	set_mode("regression") |>
	set_engine("glmnet") 


# Linear regression via 'lm'
lm_spec <- linear_reg() |>
    set_engine("lm") |>
    translate()


# Poisson regression via glm
poisson_spec <- poisson_reg() |>
  set_engine("glm") |>
  translate() 

# Random forest via 'randomForest'
rf_spec <- rand_forest(mtry=tune(),
                       trees=tune(),
                       min_n=tune()) |>
    set_engine("randomForest") |>
    set_mode("regression") |>
    translate()

# RIDGE
ridge_spec <- linear_reg(penalty = tune(), 
						 mixture = 0) |>  
	set_mode("regression") |>
	set_engine("glmnet") 

# Linear SVM via 'kernlab'
linSVM_spec <- svm_linear(cost=tune(),
                          margin=tune()) |>
    set_engine("kernlab") |>
    set_mode("regression") |>
    translate()

# Polynomial SVM  via 'kernlab'
polySVM_spec <- svm_poly(cost = tune(),
						 degree = tune(),
						 scale_factor = tune(),
						 margin = tune()) |> 
	set_engine("kernlab") |>
	set_mode("regression") |>
	translate()

# Radial SVM via 'kernlab'
radSVM_spec <- svm_rbf(cost = tune(),
					   rbf_sigma = tune(),
					   margin = tune()) |>
	set_engine("kernlab") |>
	set_mode("regression") |>
	translate()


# Create lists
models_list <- c("bagged\nMARS",
				 "bagged\nMLP", 
				 "bagged\ntrees",
				 "xgboost",
         "k-nearest\nneighbors",
				 "LASSO",
				 "random\nforest",
				 "RIDGE",
				 "linear\nSVM",
				 "polynomial\nSVM",
				 "radial\nSVM")
alg_list <- c("bagmars_spec",
			  "bagmlp_spec",
			  "bagtrees_spec",
			  "xgboost_spec",
			  "knn_spec",
			  "lasso_spec",
			  "rf_spec",
			  "ridge_spec",
              "linSVM_spec",
			  "polySVM_spec",
			  "radSVM_spec")
models_list_noHype <- c(
				 "linear\nregression",
				 "Poisson\nregression"
)
alg_list_noHype <- c(
			  "lm_spec",
			  "poisson_spec"
)


# Data Subsetting ===========================================================
varPdI_lipid_train <- dfPdI_lipid_train
varDiam_lipid_train <- dfDiam_lipid_train
varEE_lipid_train <- dfEE_lipid_train

varPdI_pol_train <- dfPdI_pol_train
varDiam_pol_train <- dfDiam_pol_train
varEE_pol_train <- dfEE_pol_train

# Redefine the regression metric (just RMSE)
#reg_metrics <- metric_set(rmse)

# RMSE lists
diam_lipid_rmseList <- c()
pdi_lipid_rmseList <- c()
ee_lipid_rmseList <- c()

diam_pol_rmseList <- c()
pdi_pol_rmseList <- c()
ee_pol_rmseList <- c()

# RMSE SD lists
diam_lipid_SDrmseList <- c()
pdi_lipid_SDrmseList <- c()
ee_lipid_SDrmseList <- c()

diam_pol_SDrmseList <- c()
pdi_pol_SDrmseList <- c()
ee_pol_SDrmseList <- c()

# RSQ lists
diam_lipid_rsqList <- c()
pdi_lipid_rsqList <- c()
ee_lipid_rsqList <- c()

diam_pol_rsqList <- c()
pdi_pol_rsqList <- c()
ee_pol_rsqList <- c()

# RSQ SD lists
diam_lipid_SDrsqList <- c()
pdi_lipid_SDrsqList <- c()
ee_lipid_SDrsqList <- c()

diam_pol_SDrsqList <- c()
pdi_pol_SDrsqList <- c()
ee_pol_SDrsqList <- c()


# Workflows
diam_lipid_wflow <- c("bagmars_wflow_diam_lipid",
                       "bagmlp_wflow_diam_lipid",
                       "bagtrees_wflow_diam_lipid",
                       "xgboost_wflow_diam_lipid",
                       "knn_wflow_diam_lipid",
                       "lasso_wflow_diam_lipid",
                       "randomforest_wflow_diam_lipid",
                       "ridge_wflow_diam_lipid",
                       "linSVM_wflow_diam_lipid",
                       "polySVM_wflow_diam_lipid",
                       "radSVM_wflow_diam_lipid")
diam_lipid_wflow_noHype <- c("lm_wflow_diam_lipid",
                             "poisson_wflow_diam_lipid")
pdi_lipid_wflow <- c("bagmars_wflow_pdi_lipid",
                       "bagmlp_wflow_pdi_lipid",
                       "bagtrees_wflow_pdi_lipid",
                       "xgboost_wflow_pdi_lipid",
                       "knn_wflow_pdi_lipid",
                       "lasso_wflow_pdi_lipid",
                       "randomforest_wflow_pdi_lipid",
                       "ridge_wflow_pdi_lipid",
                       "linSVM_wflow_pdi_lipid",
                       "polySVM_wflow_pdi_lipid",
                       "radSVM_wflow_pdi_lipid")
pdi_lipid_wflow_noHype <- c("lm_wflow_pdi_lipid",
                            "poisson_wflow_pdi_lipid")

ee_lipid_wflow <- c("bagmars_wflow_ee_lipid",
                       "bagmlp_wflow_ee_lipid",
                       "bagtrees_wflow_ee_lipid",
                       "xgboost_wflow_ee_lipid",
                       "knn_wflow_ee_lipid",
                       "lasso_wflow_ee_lipid",
                       "randomforest_wflow_ee_lipid",
                       "ridge_wflow_ee_lipid",
                       "linSVM_wflow_ee_lipid",
                       "polySVM_wflow_ee_lipid",
                       "radSVM_wflow_ee_lipid")
ee_lipid_wflow_noHype <- c("lm_wflow_ee_lipid",
                           "poisson_wflow_ee_lipid")


diam_pol_wflow <- c("bagmars_wflow_diam_pol",
                       "bagmlp_wflow_diam_pol",
                       "bagtrees_wflow_diam_pol",
                       "xgboost_wflow_diam_pol",
                       "knn_wflow_diam_pol",
                       "lasso_wflow_diam_pol",
                       "randomforest_wflow_diam_pol",
                       "ridge_wflow_diam_pol",
                       "linSVM_wflow_diam_pol",
                       "polySVM_wflow_diam_pol",
                       "radSVM_wflow_diam_pol")
diam_pol_wflow_noHype <- c("lm_wflow_diam_pol",
                           "poisson_wflow_diam_pol")

pdi_pol_wflow <- c("bagmars_wflow_pdi_pol",
                       "bagmlp_wflow_pdi_pol",
                       "bagtrees_wflow_pdi_pol",
                       "xgboost_wflow_pdi_pol",
                       "knn_wflow_pdi_pol",
                       "lasso_wflow_pdi_pol",
                       "randomforest_wflow_pdi_pol",
                       "ridge_wflow_pdi_pol",
                       "linSVM_wflow_pdi_pol",
                       "polySVM_wflow_pdi_pol",
                       "radSVM_wflow_pdi_pol")
pdi_pol_wflow_noHype <- c("lm_wflow_pdi_pol",
                          "poisson_wflow_pdi_pol")

ee_pol_wflow <- c("bagmars_wflow_ee_pol",
                  "bagmlp_wflow_ee_pol",
                       "bagtrees_wflow_ee_pol",
                       "xgboost_wflow_ee_pol",
                       "knn_wflow_ee_pol",
                       "lasso_wflow_ee_pol",
                       "randomforest_wflow_ee_pol",
                       "ridge_wflow_ee_pol",
                       "linSVM_wflow_ee_pol",
                       "polySVM_wflow_ee_pol",
                       "radSVM_wflow_ee_pol")
ee_pol_wflow_noHype <- c("lm_wflow_ee_pol",
                         "poisson_wflow_ee_pol")

# Model Lists
diam_lipid_models <- c("bagmars_tune_diam_lipid", 
                       "bagmlp_tune_diam_lipid", 
                       "bagtrees_tune_diam_lipid",
                       "xgboost_tune_diam_lipid",
                       "knn_tune_diam_lipid",
                       "lasso_tune_diam_lipid",
                       "randomforest_tune_diam_lipid",
                       "ridge_tune_diam_lipid",
                       "linSVM_tune_diam_lipid",
                       "polySVM_tune_diam_lipid",
                       "radSVM_tune_diam_lipid")
diam_lipid_models_noHype <- c("lm_tune_diam_lipid",
                              "poisson_tune_diam_lipid")

pdi_lipid_models <- c("bagmars_tune_pdi_lipid", 
                       "bagmlp_tune_pdi_lipid", 
                       "bagtrees_tune_pdi_lipid",
                       "xgboost_tune_pdi_lipid",
                       "knn_tune_pdi_lipid",
                       "lasso_tune_pdi_lipid",
                       "randomforest_tune_pdi_lipid",
                       "ridge_tune_pdi_lipid",
                       "linSVM_tune_pdi_lipid",
                       "polySVM_tune_pdi_lipid",
                       "radSVM_tune_pdi_lipid")
pdi_lipid_models_noHype <- c("lm_tune_pdi_lipid",
                      "poisson_tune_pdi_lipid")

ee_lipid_models <- c("bagmars_tune_ee_lipid", 
                       "bagmlp_tune_ee_lipid", 
                       "bagtrees_tune_ee_lipid",
                       "xgboost_tune_ee_lipid",
                       "knn_tune_ee_lipid",
                       "lasso_tune_ee_lipid",
                       "randomforest_tune_ee_lipid",
                       "ridge_tune_ee_lipid",
                       "linSVM_tune_ee_lipid",
                       "polySVM_tune_ee_lipid",
                       "radSVM_tune_ee_lipid")
ee_lipid_models_noHype <- c("lm_tune_ee_lipid",
                            "poisson_tune_ee_lipid")

diam_pol_models <- c("bagmars_tune_diam_pol", 
                       "bagmlp_tune_diam_pol", 
                       "bagtrees_tune_diam_pol",
                       "xgboost_tune_diam_pol",
                       "knn_tune_diam_pol",
                       "lasso_tune_diam_pol",
                       "randomforest_tune_diam_pol",
                       "ridge_tune_diam_pol",
                       "linSVM_tune_diam_pol",
                       "polySVM_tune_diam_pol",
                       "radSVM_tune_diam_pol")
diam_pol_models_noHype <- c("lm_tune_diam_pol",
                     "poisson_tune_diam_pol")

pdi_pol_models <- c("bagmars_tune_pdi_pol", 
                       "bagmlp_tune_pdi_pol", 
                       "bagtrees_tune_pdi_pol",
                       "xgboost_tune_pdi_pol",
                       "knn_tune_pdi_pol",
                       "lasso_tune_pdi_pol",
                       "randomforest_tune_pdi_pol",
                       "ridge_tune_pdi_pol",
                       "linSVM_tune_pdi_pol",
                       "polySVM_tune_pdi_pol",
                       "radSVM_tune_pdi_pol")
pdi_pol_models_noHype <- c("lm_tune_pdi_pol",
                    "poisson_tune_pdi_pol")

ee_pol_models <- c("bagmars_tune_ee_pol", 
                       "bagmlp_tune_ee_pol", 
                       "bagtrees_tune_ee_pol",
                       "xgboost_tune_ee_pol",
                       "knn_tune_ee_pol",
                       "lasso_tune_ee_pol",
                       "randomforest_tune_ee_pol",
                       "ridge_tune_ee_pol",
                       "linSVM_tune_ee_pol",
                       "polySVM_tune_ee_pol",
                       "radSVM_tune_ee_pol")
ee_pol_models_noHype <- c("lm_tune_ee_pol",
                          "poisson_tune_ee_pol")

# Generate model workflows
## Lipids - Diameters
vec_alg <- numeric(0)
vec_diam_lipid_procTime <- numeric(0)
vec_diam_lipid_peakRAM <- numeric(0)
print("Tuning Hyperparameters: Lipid Diameters")
for (alg in 1:length(alg_list)){
  set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list[alg]))
  ptm <- proc.time()[3]
  df_ram <- peakRAM({
	temp_recipe <- recipe(hdiam_nm ~ ., 
						 data=subset(varDiam_lipid_train, 
									 select=-c(payload, pdi, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list[alg]))
  temp_hparams <- extract_parameter_set_dials(get(alg_list[alg])) |>
    finalize(subset(dfDiam_lipid_train, 
      select=-c(payload, pdi, zetaPot_mV, percEE, dataset)))
  temp_grid <- grid_random(temp_hparams, size=nGrid)
	temp_tune <- temp_wflow |>
			tune_grid(resamples = diam_folds_lipid, 
					  grid=temp_grid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(diam_lipid_wflow[alg], temp_wflow)
  assign(diam_lipid_models[alg], temp_tune)
	diam_lipid_rmseList <- append(diam_lipid_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	diam_lipid_SDrmseList <- append(diam_lipid_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	diam_lipid_rsqList <- append(diam_lipid_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	diam_lipid_SDrsqList <- append(diam_lipid_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
  temp_time <- as.numeric(proc.time()[3]-ptm)

  # Append algorithm and computation time to vectors
  vec_alg <- c(vec_alg, alg_list[alg])
  vec_diam_lipid_procTime <- c(vec_diam_lipid_procTime, temp_time)
  vec_diam_lipid_peakRAM <- c(vec_diam_lipid_peakRAM, df_ram$Peak_RAM_Used_MiB)
}

## Lipids - PdI
print("Tuning Hyperparameters: Lipid PdI")
vec_pdi_lipid_procTime <- numeric(0)
vec_pdi_lipid_peakRAM <- numeric(0)
for (alg in 1:length(alg_list)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list[alg]))
  ptm <- proc.time()[3]
  df_ram <- peakRAM({
	temp_recipe <- recipe(pdi ~ ., 
						 data=subset(varPdI_lipid_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list[alg]))
  temp_hparams <- extract_parameter_set_dials(get(alg_list[alg])) |>
    finalize(subset(dfPdI_lipid_train, 
      select=-c(payload, hdiam_nm, zetaPot_mV, percEE, dataset)))
  temp_grid <- grid_random(temp_hparams, size=nGrid)
	temp_tune <- temp_wflow |>
			tune_grid(resamples = pdi_folds_lipid, 
					  grid=temp_grid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(pdi_lipid_wflow[alg], temp_wflow)
  assign(pdi_lipid_models[alg], temp_tune)
	pdi_lipid_rmseList <- append(pdi_lipid_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	pdi_lipid_SDrmseList <- append(pdi_lipid_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	pdi_lipid_rsqList <- append(pdi_lipid_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	pdi_lipid_SDrsqList <- append(pdi_lipid_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
  temp_time <- as.numeric(proc.time()[3]-ptm)

  # Append algorithm and computation time to vectors
  vec_pdi_lipid_procTime <- c(vec_pdi_lipid_procTime, temp_time)
  vec_pdi_lipid_peakRAM <- c(vec_pdi_lipid_peakRAM, df_ram$Peak_RAM_Used_MiB)
}

## Lipids - %EE
vec_ee_lipid_procTime <- numeric(0)
vec_ee_lipid_peakRAM <- numeric(0)
print("Tuning Hyperparameters: Lipid %EE")
for (alg in 1:length(alg_list)){
	set.seed(1987)
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(percEE ~ ., 
						 data=subset(varPdI_lipid_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   pdi, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list[alg]))
  temp_hparams <- extract_parameter_set_dials(get(alg_list[alg])) |>
    finalize(subset(dfEE_lipid_train, 
      select=-c(payload, hdiam_nm, zetaPot_mV, pdi, dataset)))
  temp_grid <- grid_random(temp_hparams, size=nGrid)
  temp_tune <- temp_wflow |>
			tune_grid(resamples = ee_folds_lipid, 
					  grid=temp_grid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(ee_lipid_wflow[alg], temp_wflow)
  assign(ee_lipid_models[alg], temp_tune)
	ee_lipid_rmseList <- append(ee_lipid_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	ee_lipid_SDrmseList <- append(ee_lipid_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	ee_lipid_rsqList <- append(ee_lipid_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	ee_lipid_SDrsqList <- append(ee_lipid_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
  temp_time <- as.numeric(proc.time()[3]-ptm)

  # Append algorithm and computation time to vectors
  vec_ee_lipid_procTime <- c(vec_ee_lipid_procTime, temp_time)
  vec_ee_lipid_peakRAM <- c(vec_ee_lipid_peakRAM, df_ram$Peak_RAM_Used_MiB)
}


vec_alg_noHype <- numeric(0)
vec_diam_lipid_procTime_noHype <- numeric(0)
vec_diam_lipid_peakRAM_noHype <- numeric(0)
print("LM and Poisson models: Lipid Diameters")
for (alg in 1:length(alg_list_noHype)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list_noHype[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(hdiam_nm ~ ., 
						 data=subset(varDiam_lipid_train, 
									 select=-c(payload, pdi, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list_noHype[alg]))
	temp_tune <- temp_wflow |>
			tune_grid(resamples = diam_folds_lipid, 
					  grid=nGrid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(diam_lipid_wflow_noHype[alg], temp_wflow)
  assign(diam_lipid_models_noHype[alg], temp_tune)
	diam_lipid_rmseList <- append(diam_lipid_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	diam_lipid_SDrmseList <- append(diam_lipid_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	diam_lipid_rsqList <- append(diam_lipid_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	diam_lipid_SDrsqList <- append(diam_lipid_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
  temp_time <- as.numeric(proc.time()[3]-ptm)

  # Append algorithm and computation time to vectors
  vec_alg_noHype <- c(vec_alg_noHype, alg_list_noHype[alg])
  vec_diam_lipid_procTime_noHype <- c(vec_diam_lipid_procTime_noHype, temp_time)
  vec_diam_lipid_peakRAM_noHype <- c(vec_diam_lipid_peakRAM_noHype, df_ram$Peak_RAM_Used_MiB)
}

## Lipids - PdI
vec_pdi_lipid_procTime_noHype <- numeric(0)
vec_pdi_lipid_peakRAM_noHype <- numeric(0)
print("LM and Poisson models: Lipid PdI")
for (alg in 1:length(alg_list_noHype)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list_noHype[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(pdi ~ ., 
						 data=subset(varPdI_lipid_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list_noHype[alg]))
	temp_tune <- temp_wflow |>
			tune_grid(resamples = pdi_folds_lipid, 
					  grid=nGrid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(pdi_lipid_wflow_noHype[alg], temp_wflow)
  assign(pdi_lipid_models_noHype[alg], temp_tune)
	pdi_lipid_rmseList <- append(pdi_lipid_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	pdi_lipid_SDrmseList <- append(pdi_lipid_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	pdi_lipid_rsqList <- append(pdi_lipid_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	pdi_lipid_SDrsqList <- append(pdi_lipid_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_pdi_lipid_procTime_noHype <- c(vec_pdi_lipid_procTime_noHype, temp_time)
    vec_pdi_lipid_peakRAM_noHype <- c(vec_pdi_lipid_peakRAM_noHype, df_ram$Peak_RAM_Used_MiB)
}

## Lipids - %EE
vec_ee_lipid_procTime_noHype <- numeric(0)
vec_ee_lipid_peakRAM_noHype <- numeric(0)
print("LM and Poisson models: Lipid %EE")
for (alg in 1:length(alg_list_noHype)){
	set.seed(1987)
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(percEE ~ ., 
						 data=subset(varPdI_lipid_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   pdi, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list_noHype[alg]))
  temp_tune <- temp_wflow |>
			tune_grid(resamples = ee_folds_lipid, 
					  grid=nGrid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(ee_lipid_wflow_noHype[alg], temp_wflow)
  assign(ee_lipid_models_noHype[alg], temp_tune)
	ee_lipid_rmseList <- append(ee_lipid_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	ee_lipid_SDrmseList <- append(ee_lipid_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	ee_lipid_rsqList <- append(ee_lipid_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	ee_lipid_SDrsqList <- append(ee_lipid_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_ee_lipid_procTime_noHype <- c(vec_ee_lipid_procTime_noHype, temp_time)
    vec_ee_lipid_peakRAM_noHype <- c(vec_ee_lipid_peakRAM_noHype, df_ram$Peak_RAM_Used_MiB)
}


## Data frame of results
df_lipid_varMods_rmse <- data.frame(
                 algorithm=append(models_list, models_list_noHype), 
							   engine=append(alg_list, alg_list_noHype), 
							   diam_rmse=diam_lipid_rmseList,
							   diam_rmseSD=diam_lipid_SDrmseList, 
							   pdi_rmse=pdi_lipid_rmseList, 
							   pdi_rmseSD=pdi_lipid_SDrmseList, 
							   ee_rmse=ee_lipid_rmseList, 
							   ee_rmseSD=ee_lipid_SDrmseList)
df_lipid_varMods_rmse$normDiam_rmse <-# 
	(df_lipid_varMods_rmse$diam_rmse-min(df_lipid_varMods_rmse$diam_rmse))/#
	(max(df_lipid_varMods_rmse$diam_rmse)-min(df_lipid_varMods_rmse$diam_rmse))
df_lipid_varMods_rmse$normPdI_rmse <-# 
	(df_lipid_varMods_rmse$pdi_rmse-min(df_lipid_varMods_rmse$pdi_rmse))/#
	(max(df_lipid_varMods_rmse$pdi_rmse)-min(df_lipid_varMods_rmse$pdi_rmse))
df_lipid_varMods_rmse$normEE_rmse <-# 
	(df_lipid_varMods_rmse$ee_rmse-min(df_lipid_varMods_rmse$ee_rmse))/#
	(max(df_lipid_varMods_rmse$ee_rmse)-min(df_lipid_varMods_rmse$ee_rmse))

df_lipid_varMods_rsq <- data.frame(
                 algorithm=append(models_list, models_list_noHype), 
							   engine=append(alg_list, alg_list_noHype), 
							   diam_rsq=diam_lipid_rsqList,
							   diam_rsqSD=diam_lipid_SDrsqList, 
							   pdi_rsq=pdi_lipid_rsqList, 
							   pdi_rsqSD=pdi_lipid_SDrsqList, 
							   ee_rsq=ee_lipid_rsqList, 
							   ee_rsqSD=ee_lipid_SDrsqList)

df_process_lipid <- data.frame(
    engine = c(vec_alg, vec_alg_noHype),
    pdi_procTime = c(vec_pdi_lipid_procTime, vec_pdi_lipid_procTime_noHype),
    pdi_peakRAM = c(vec_pdi_lipid_peakRAM, vec_pdi_lipid_peakRAM_noHype),
    diam_procTime = c(vec_diam_lipid_procTime, vec_diam_lipid_procTime_noHype),
    diam_peakRAM = c(vec_diam_lipid_peakRAM, vec_diam_lipid_peakRAM_noHype),
    ee_procTime = c(vec_ee_lipid_procTime, vec_ee_lipid_procTime_noHype),
    ee_peakRAM = c(vec_ee_lipid_peakRAM, vec_ee_lipid_peakRAM_noHype) 
)


## Polymers - Diameters
print("Tuning Hyperparameters: PLGA diameters")
vec_diam_pol_procTime <- numeric(0)
vec_diam_pol_peakRAM <- numeric(0) 
for (alg in 1:length(alg_list)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(hdiam_nm ~ ., 
						 data=subset(varDiam_pol_train, 
									 select=-c(payload, pdi, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list[alg]))
  temp_hparams <- extract_parameter_set_dials(get(alg_list[alg])) |>
    finalize(subset(dfDiam_pol_train, 
      select=-c(payload, percEE, zetaPot_mV, pdi, dataset)))
  temp_grid <- grid_random(temp_hparams, size=nGrid)
  temp_tune <- temp_wflow |>
			tune_grid(resamples = diam_folds_pol, 
					  grid=temp_grid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(diam_pol_wflow[alg], temp_wflow)
  assign(diam_pol_models[alg], temp_tune)
	diam_pol_rmseList <- append(diam_pol_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	diam_pol_SDrmseList <- append(diam_pol_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	diam_pol_rsqList <- append(diam_pol_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	diam_pol_SDrsqList <- append(diam_pol_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_diam_pol_procTime <- c(vec_diam_pol_procTime, temp_time)
    vec_diam_pol_peakRAM <- c(vec_diam_pol_peakRAM, df_ram$Peak_RAM_Used_MiB)
}

## PLGA - PdI
print("Tuning Hyperparameters: PLGA PdI")
vec_pdi_pol_procTime <- numeric(0)
vec_pdi_pol_peakRAM <- numeric(0) 
for (alg in 1:length(alg_list)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(pdi ~ ., 
						 data=subset(varPdI_pol_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list[alg]))  
  temp_hparams <- extract_parameter_set_dials(get(alg_list[alg])) |>
    finalize(subset(dfPdI_pol_train, 
      select=-c(payload, hdiam_nm, zetaPot_mV, percEE, dataset)))
  temp_grid <- grid_random(temp_hparams, size=nGrid)
  temp_tune <- temp_wflow |>
			tune_grid(resamples = pdi_folds_pol, 
					  grid=temp_grid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(pdi_pol_wflow[alg], temp_wflow)
  assign(pdi_pol_models[alg], temp_tune)
	pdi_pol_rmseList <- append(pdi_pol_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	pdi_pol_SDrmseList <- append(pdi_pol_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	pdi_pol_rsqList <- append(pdi_pol_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	pdi_pol_SDrsqList <- append(pdi_pol_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_pdi_pol_procTime <- c(vec_pdi_pol_procTime, temp_time)
    vec_pdi_pol_peakRAM <- c(vec_pdi_pol_peakRAM, df_ram$Peak_RAM_Used_MiB)
}

## pol - %EE
print("Tuning Hyperparameters: PLGA %EE")
vec_ee_pol_procTime <- numeric(0)
vec_ee_pol_peakRAM <- numeric(0) 
for (alg in 1:length(alg_list)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(percEE ~ ., 
						 data=subset(varPdI_pol_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   pdi, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list[alg]))
  temp_hparams <- extract_parameter_set_dials(get(alg_list[alg])) |>
    finalize(subset(dfEE_pol_train, 
      select=-c(payload, hdiam_nm, zetaPot_mV, pdi, dataset)))
  temp_grid <- grid_random(temp_hparams, size=nGrid)
  temp_tune <- temp_wflow |>
			tune_grid(resamples = ee_folds_pol, 
					  grid=temp_grid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(ee_pol_wflow[alg], temp_wflow)
  assign(ee_pol_models[alg], temp_tune)
	ee_pol_rmseList <- append(ee_pol_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	ee_pol_SDrmseList <- append(ee_pol_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	ee_pol_rsqList <- append(ee_pol_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	ee_pol_SDrsqList <- append(ee_pol_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_ee_pol_procTime <- c(vec_ee_pol_procTime, temp_time)
    vec_ee_pol_peakRAM <- c(vec_ee_pol_peakRAM, df_ram$Peak_RAM_Used_MiB)
}




## Polymers - Diameters
print("LM and Poisson models: PLGA diameters")
vec_diam_pol_procTime_noHype <- numeric(0)
vec_diam_pol_peakRAM_noHype <- numeric(0) 
for (alg in 1:length(alg_list_noHype)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list_noHype[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(hdiam_nm ~ ., 
						 data=subset(varDiam_pol_train, 
									 select=-c(payload, pdi, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list_noHype[alg]))
  temp_tune <- temp_wflow |>
			tune_grid(resamples = diam_folds_pol, 
					  grid=nGrid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(diam_pol_wflow_noHype[alg], temp_wflow)
  assign(diam_pol_models_noHype[alg], temp_tune)
	diam_pol_rmseList <- append(diam_pol_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	diam_pol_SDrmseList <- append(diam_pol_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	diam_pol_rsqList <- append(diam_pol_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	diam_pol_SDrsqList <- append(diam_pol_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_diam_pol_procTime_noHype <- c(vec_diam_pol_procTime_noHype, temp_time)
    vec_diam_pol_peakRAM_noHype <- c(vec_diam_pol_peakRAM_noHype, df_ram$Peak_RAM_Used_MiB)
}

## PLGA - PdI
print("LM and Poisson models: PLGA PdI")
vec_pdi_pol_procTime_noHype <- numeric(0)
vec_pdi_pol_peakRAM_noHype <- numeric(0) 
for (alg in 1:length(alg_list_noHype)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list_noHype[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(pdi ~ ., 
						 data=subset(varPdI_pol_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   percEE, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list_noHype[alg]))  
  temp_tune <- temp_wflow |>
			tune_grid(resamples = pdi_folds_pol, 
					  grid=nGrid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(pdi_pol_wflow_noHype[alg], temp_wflow)
  assign(pdi_pol_models_noHype[alg], temp_tune)
	pdi_pol_rmseList <- append(pdi_pol_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	pdi_pol_SDrmseList <- append(pdi_pol_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	pdi_pol_rsqList <- append(pdi_pol_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	pdi_pol_SDrsqList <- append(pdi_pol_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_pdi_pol_procTime_noHype <- c(vec_pdi_pol_procTime_noHype, temp_time)
    vec_pdi_pol_peakRAM_noHype <- c(vec_pdi_pol_peakRAM_noHype, df_ram$Peak_RAM_Used_MiB)
}

## pol - %EE
print("LM and Poisson models: PLGA %EE")
vec_ee_pol_procTime_noHype <- numeric(0)
vec_ee_pol_peakRAM_noHype <- numeric(0) 
for (alg in 1:length(alg_list_noHype)){
	set.seed(1987)
  print("# ===============================================================")
  print(paste("Now running:", alg_list_noHype[alg]))
    ptm <- proc.time()[3]
    df_ram <- peakRAM({
	temp_recipe <- recipe(percEE ~ ., 
						 data=subset(varPdI_pol_train, 
									 select=-c(payload, hdiam_nm, zetaPot_mV, 
											   pdi, dataset))) |> 
					step_zv(all_predictors()) |>
					step_normalize(all_numeric_predictors())
	temp_wflow <- workflow() |>
			add_recipe(temp_recipe) |>
			add_model(get(alg_list_noHype[alg]))
  temp_tune <- temp_wflow |>
			tune_grid(resamples = ee_folds_pol, 
					  grid=nGrid, 
					  control=ctrl, 
					  metrics=reg_metrics)
  assign(ee_pol_wflow_noHype[alg], temp_wflow)
  assign(ee_pol_models_noHype[alg], temp_tune)
	ee_pol_rmseList <- append(ee_pol_rmseList,# 
			show_best(temp_tune, metric="rmse")[1,]$mean
	)
	ee_pol_SDrmseList <- append(ee_pol_SDrmseList,#
			show_best(temp_tune, metric="rmse")[1,]$std_err
	)
	ee_pol_rsqList <- append(ee_pol_rsqList,#
			show_best(temp_tune, metric="rsq")[1,]$mean
	)
	ee_pol_SDrsqList <- append(ee_pol_SDrsqList,#
			show_best(temp_tune, metric="rsq")[1,]$std_err
	)
    }) # End peakRAM
    temp_time <- as.numeric(proc.time()[3]-ptm)

    # Append computation time to vector
    vec_ee_pol_procTime_noHype <- c(vec_ee_pol_procTime_noHype, temp_time)
    vec_ee_pol_peakRAM_noHype <- c(vec_ee_pol_peakRAM_noHype, df_ram$Peak_RAM_Used_MiB)
}


## Data frame of results
df_pol_varMods_rmse <- data.frame(
                 algorithm=append(models_list, models_list_noHype), 
							   engine=append(alg_list, alg_list_noHype), 
							   diam_rmse=diam_pol_rmseList,
							   diam_rmseSD=diam_pol_SDrmseList, 
							   pdi_rmse=pdi_pol_rmseList, 
							   pdi_rmseSD=pdi_pol_SDrmseList, 
							   ee_rmse=ee_pol_rmseList, 
							   ee_rmseSD=ee_pol_SDrmseList)
df_pol_varMods_rmse$normDiam_rmse <-# 
	(df_pol_varMods_rmse$diam_rmse-min(df_pol_varMods_rmse$diam_rmse))/#
	(max(df_pol_varMods_rmse$diam_rmse)-min(df_pol_varMods_rmse$diam_rmse))
df_pol_varMods_rmse$normPdI_rmse <-# 
	(df_pol_varMods_rmse$pdi_rmse-min(df_pol_varMods_rmse$pdi_rmse))/#
	(max(df_pol_varMods_rmse$pdi_rmse)-min(df_pol_varMods_rmse$pdi_rmse))
df_pol_varMods_rmse$normEE_rmse <-# 
	(df_pol_varMods_rmse$ee_rmse-min(df_pol_varMods_rmse$ee_rmse))/#
	(max(df_pol_varMods_rmse$ee_rmse)-min(df_pol_varMods_rmse$ee_rmse))

df_pol_varMods_rsq <- data.frame(
                 algorithm=append(models_list, models_list_noHype), 
							   engine=append(alg_list, alg_list_noHype), 
							   diam_rsq=diam_pol_rsqList,
							   diam_rsqSD=diam_pol_SDrsqList, 
							   pdi_rsq=pdi_pol_rsqList, 
							   pdi_rsqSD=pdi_pol_SDrsqList, 
							   ee_rsq=ee_pol_rsqList, 
							   ee_rsqSD=ee_pol_SDrsqList)


df_process_pol <- data.frame(
    engine = c(vec_alg, vec_alg_noHype),
    pdi_procTime = c(vec_pdi_pol_procTime, vec_pdi_pol_procTime_noHype),
    pdi_peakRAM = c(vec_pdi_pol_peakRAM, vec_pdi_pol_peakRAM_noHype),
    diam_procTime = c(vec_diam_pol_procTime, vec_diam_pol_procTime_noHype),
    diam_peakRAM = c(vec_diam_pol_peakRAM, vec_diam_pol_peakRAM_noHype),
    ee_procTime = c(vec_ee_pol_procTime, vec_ee_pol_procTime_noHype),
    ee_peakRAM = c(vec_ee_pol_peakRAM, vec_ee_pol_peakRAM_noHype)
)


df_lipid_rmse_summ <- df_lipid_varMods_rmse |> group_by(algorithm) |>
		summarize(
			meanRMSE = mean(normDiam_rmse, normPdI_rmse, normEE_rmse)
		)
df_lipid_rmse_summ <- df_lipid_rmse_summ[order(df_lipid_rmse_summ$meanRMSE),]
df_lipid_rmse_summ$rank <- 1:nrow(df_lipid_rmse_summ)

df_lipid_rsq_summ <- df_lipid_varMods_rsq |> group_by(algorithm) |>
		summarize(
			meanRSQ = mean(diam_rsq, pdi_rsq, ee_rsq)
		)
df_lipid_rsq_summ <- df_lipid_rsq_summ[order(df_lipid_rsq_summ$meanRSQ,# 
											 decreasing = TRUE),]
df_lipid_rsq_summ$rank <- 1:nrow(df_lipid_rsq_summ)

df_pol_rmse_summ <- df_pol_varMods_rmse |> group_by(algorithm) |>
		summarize(
			meanRMSE = mean(normDiam_rmse, normPdI_rmse, normEE_rmse)
		)
df_pol_rmse_summ <- df_pol_rmse_summ[order(df_pol_rmse_summ$meanRMSE),]
df_pol_rmse_summ$rank <- 1:nrow(df_pol_rmse_summ)

df_pol_rsq_summ <- df_pol_varMods_rsq |> group_by(algorithm) |>
		summarize(
			meanRSQ = mean(diam_rsq, pdi_rsq, ee_rsq)
		)
df_pol_rsq_summ <- df_pol_rsq_summ[order(df_pol_rsq_summ$meanRSQ,# 
											 decreasing = TRUE),]
df_pol_rsq_summ$rank <- 1:nrow(df_pol_rsq_summ)

#ranking_lipid <- rbind(
#	subset(df_lipid_rmse_summ, select=-c(meanRMSE)),
#	subset(df_lipid_rsq_summ, select=-c(meanRSQ))
#)
#ranking_lipid <- ranking_lipid |> group_by(algorithm) |>
#		summarize(sumRank = sum(rank))
ranking_lipid <- df_lipid_rmse_summ
ranking_lipid <- subset(ranking_lipid, select=-c(meanRMSE))
ranking_lipid <- ranking_lipid[order(ranking_lipid$rank),]

#ranking_pol <- rbind(
#	subset(df_pol_rmse_summ, select=-c(meanRMSE)),
#	subset(df_pol_rsq_summ, select=-c(meanRSQ))
#)
#ranking_pol <- ranking_pol |> group_by(algorithm) |>
#		summarize(sumRank = sum(rank))
ranking_pol <- df_pol_rmse_summ
ranking_pol <- subset(ranking_pol, select=-c(meanRMSE))
ranking_pol <- ranking_pol[order(ranking_pol$rank),]


## Merge processing time data frames with RMSE data frames
df_process_lipid <- merge(df_lipid_varMods_rmse[,1:2], df_process_lipid, 
                           by="engine")
df_process_pol <- merge(df_pol_varMods_rmse[,1:2], df_process_pol, 
                         by="engine")

# ===========================================================================
library(xtable)
#gitumLips
print("Algorithm Performance -- Lipid")
gitumLip <- data.frame(algorithm = df_lipid_varMods_rmse$algorithm, 
                       rmse_dh = round(df_lipid_varMods_rmse$diam_rmse, digits=0),
                       rmse_dh_sd = round(df_lipid_varMods_rmse$diam_rmseSD, digits=0),
                       rsq_dh = round(df_lipid_varMods_rsq$diam_rsq, digits=3),
                       rsq_dh_sd = round(df_lipid_varMods_rsq$diam_rsqSD, digits=3),
                       rmse_pdi = round(df_lipid_varMods_rmse$pdi_rmse, digits=3),
                       rmse_pdi_sd = round(df_lipid_varMods_rmse$pdi_rmseSD, digits=3),
                       rsq_pdi = round(df_lipid_varMods_rsq$pdi_rsq, digits=3),
                       rsq_pdi_sd = round(df_lipid_varMods_rsq$pdi_rsqSD, digits=3),
                       rmse_ee = round(df_lipid_varMods_rmse$ee_rmse, digits=1),
                       rmse_ee_sd = round(df_lipid_varMods_rmse$ee_rmseSD, digits=1),
                       rsq_ee = round(df_lipid_varMods_rsq$ee_rsq, digits=3),
                       rsq_ee_sd = round(df_lipid_varMods_rsq$ee_rsqSD, digits=3))
print(xtable(gitumLip, type="latex", digits=4))
write.csv(gitumLip, file="extra/lipid_variousModels.csv", row.names=FALSE)


print("Algorithm Performance -- PLGA")
gitumPol <- data.frame(algorithm = df_pol_varMods_rmse$algorithm, 
                       rmse_dh = round(df_pol_varMods_rmse$diam_rmse, digits=0),
                       rmse_dh_sd = round(df_pol_varMods_rmse$diam_rmseSD, digits=0),
                       rsq_dh = round(df_pol_varMods_rsq$diam_rsq, digits=3),
                       rsq_dh_sd = round(df_pol_varMods_rsq$diam_rsqSD, digits=3),
                       rmse_pdi = round(df_pol_varMods_rmse$pdi_rmse, digits=3),
                       rmse_pdi_sd = round(df_pol_varMods_rmse$pdi_rmseSD, digits=3),
                       rsq_pdi = round(df_pol_varMods_rsq$pdi_rsq, digits=3),
                       rsq_pdi_sd = round(df_pol_varMods_rsq$pdi_rsqSD, digits=3),
                       rmse_ee = round(df_pol_varMods_rmse$ee_rmse, digits=1),
                       rmse_ee_sd = round(df_pol_varMods_rmse$ee_rmseSD, digits=1),
                       rsq_ee = round(df_pol_varMods_rsq$ee_rsq, digits=3),
                       rsq_ee_sd = round(df_pol_varMods_rsq$ee_rsqSD, digits=3))
print(xtable(gitumPol, type="latex", digits=4))
write.csv(gitumPol, file="extra/pol_variousModels.csv", row.names=FALSE)

print("======================================================================")
print("Summary of Lipid RMSEs")
print(df_lipid_rmse_summ)
print("Summary of Polymer RMSEs")
print(df_pol_rmse_summ)
print("----------------------------------------------------------------------")
print("Summary of Lipid RSQs")
print(df_lipid_rsq_summ)
print("Summary of Poymer RSQs")
print(df_pol_rsq_summ)
print("======================================================================")
print("Algorithm Ranking - Lipids")
print(ranking_lipid)
print("Algorithm Ranking - PLGA")
print(ranking_pol)
