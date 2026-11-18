# FUNCTIONS ------------------------------------------------------------------
# MACHINE LEARNING SETUP ==========================================
## Setup different algorithm framweworks
### Bagged MLP neural network
bagmlp_spec <- bag_mlp(hidden_units=tune(),#
                     penalty=tune(),#
                     epochs=tune()) |>
    set_engine("nnet") |>
    set_mode("regression")
### Boosted trees via 'xgboost'
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
## k-nearest neighbors via 'kknn'
knn_spec <- nearest_neighbor(neighbors=tune(),
                             weight_func=tune(),
                             dist_power=tune()) |>
    set_engine("kknn") |>
    set_mode("regression") |>
    translate()

## Linear regression via 'lm'
lm_spec <- linear_reg() |>
    set_engine("lm") |>
    translate()
## Poisson regression via glm
poisson_spec <- poisson_reg() |>
    set_engine("glm") |>
    translate()
## Random forest via 'randomForest'
rf_spec <- rand_forest(mtry=tune(),
                       trees=tune(),
                       min_n=tune()) |>
    set_engine("randomForest") |>
    set_mode("regression") |>
    translate()

## Linear SVM via 'kernlab'
linSVM_spec <- svm_linear(cost=tune(),
                          margin=tune()) |>
    set_engine("kernlab") |>
    set_mode("regression") |>
    translate()
## Polynomial SVM  via 'kernlab'
polySVM_spec <- svm_poly(cost = tune(),
                         degree = tune(),
                         scale_factor = tune(),
                         margin = tune()) |>
    set_engine("kernlab") |>
    set_mode("regression") |>
    translate()

## Radial SVM via 'kernlab'
radSVM_spec <- svm_rbf(cost = tune(),
                       rbf_sigma = tune(),
                       margin = tune()) |>
    set_engine("kernlab") |>
    set_mode("regression") |>
    translate()

# Define the regression metrics
reg_metrics <- metric_set(rmse, rsq)
# Control for resamples
ctrl <- control_grid(save_pred=TRUE)
# -----------------------------------------------------------------


# Trim white spaces across data frame ========================================
trimws_df <- function(x, ...){
  x[] <- lapply(x, trimws, ...)
  x
}

# Prepare main data frame ====================================================
prep_main <- function(x, ...){
	cols_to_numeric <- c("frr_aq", "frr_org", "tfr", "orgReag1_conc",
                     "orgReag2_conc", "orgReag3_conc", "orgReag4_conc",
                     "orgReag5_conc", "orgReag6_conc", "aqReag1_conc",
                     "aqReag2_conc", "frr", "totOrg_conc", "totAq_conc",
                     "payloadConc_mM", "hdiam_nm", "pdi", "zetaPot_mV", 
					 "percEE")

	x[, cols_to_numeric] = apply(x[,cols_to_numeric], 2, 
								 function(x) as.numeric(as.character(x)))

	# Check NP type naming convention
	x[which(x$np_type == "Liposomes"), "np_type"] = "Liposome"
	x[which(x$np_type == "Lipid Nanoparticles"), 
	  "np_type"] = "Lipid Nanoparticle"
	x[which(x$np_type == "Polymeric Nanoparticles"), 
	  "np_type"] = "Polymeric Nanoparticle"
	x[which(x$np_type == "Solid-lipid Nanoparticles"), 
	  "np_type"] = "Solid-lipid Nanoparticle"

	# Replace 0 and empty cells with NA
	x[x == 0] <- NA
	x[x == ""] <- NA
	x[x == "NA"] <- NA

	# Get main data frame column order
	list_col <- colnames(x)

	# Create column with all organic reagents
	x$orgReagents <- paste(x$orgReag1_reag,"|",
						   x$orgReag2_reag,"|",
                           x$orgReag3_reag,"|",
                           x$orgReag4_reag,"|",
                           x$orgReag5_reag,"|",
                           x$orgReag6_reag)
	# Create column with all aqueous reagents
	x$aqReagents <- paste(x$aqReag1_reag,"|",x$aqReag2_reag)
	# Compute the mol ratio of reagents
	x$orgRatios <- paste0(round((x$orgReag1_conc/x$totOrg_conc)#
								*100, digits = 2)," : ",
						  round((x$orgReag2_conc/x$totOrg_conc)#
								*100, digits = 2)," : ",
						  round((x$orgReag3_conc/x$totOrg_conc)#
								*100, digits = 2)," : ",
						  round((x$orgReag4_conc/x$totOrg_conc)#
								*100, digits = 2)," : ",
						  round((x$orgReag5_conc/x$totOrg_conc)#
								*100, digits = 2)," : ",
						  round((x$orgReag6_conc/x$totOrg_conc)#
								*100, digits = 2))
	x$aqRatios <- paste0(round((x$aqReag1_conc/x$totAq_conc)#
							   *100, digits=2)," : ",
						 round((x$aqReag1_conc/x$totAq_conc)#
							   *100, digits=2))

	x$id <- with(x,#
				 paste0("nptype:", np_type,",",
						"aq:", aq_phase,",",
						"org:", org_phase,",",
						"tfr:",tfr,"frr:", frr,",",
						aqReag1_reag,":", aqReag1_conc,",",
						aqReag2_reag,":", aqReag2_conc,",",
						orgReag1_reag,":", orgReag1_conc,",",
						orgReag2_reag,":", orgReag2_conc,",",
						orgReag3_reag,":", orgReag3_conc,",",
						orgReag4_reag,":", orgReag4_conc,",",
						orgReag5_reag,":", orgReag5_conc,",",
						orgReag6_reag,":", orgReag6_conc,",",
						payload,":",payloadConc_mM
                  ))
	x$id <- gsub("NA", "", x$id)
	x$id <- gsub(",,", "", x$id)
	x$id <- as.character(x$id)

	return(x)
}

# Alphabetize reagents =======================================================
alphabetize_reagents <- function(x, ...){

    tmpOrg <- dplyr::select(x,
        c("orgReag1_reag", "orgReag1_conc",
          "orgReag2_reag", "orgReag2_conc",
          "orgReag3_reag", "orgReag3_conc",
          "orgReag4_reag", "orgReag4_conc",
          "orgReag5_reag", "orgReag5_conc",
          "orgReag6_reag", "orgReag6_conc"))
    tmpOrg$index <- 1:nrow(tmpOrg)
    tmpOrg$orgReag1_reag <- as.character(tmpOrg$orgReag1_reag)
    tmpOrg$orgReag2_reag <- as.character(tmpOrg$orgReag2_reag)
    tmpOrg$orgReag3_reag <- as.character(tmpOrg$orgReag3_reag)
    tmpOrg$orgReag4_reag <- as.character(tmpOrg$orgReag4_reag)
    tmpOrg$orgReag5_reag <- as.character(tmpOrg$orgReag5_reag)
    tmpOrg$orgReag6_reag <- as.character(tmpOrg$orgReag6_reag)

    tmpOrg$orgReag1_conc <- as.numeric(tmpOrg$orgReag1_conc)
    tmpOrg$orgReag2_conc <- as.numeric(tmpOrg$orgReag2_conc)
    tmpOrg$orgReag3_conc <- as.numeric(tmpOrg$orgReag3_conc)
    tmpOrg$orgReag4_conc <- as.numeric(tmpOrg$orgReag4_conc)
    tmpOrg$orgReag5_conc <- as.numeric(tmpOrg$orgReag5_conc)
    tmpOrg$orgReag6_conc <- as.numeric(tmpOrg$orgReag6_conc)
    tmpOrg <- tmpOrg %>% tidyr::pivot_longer(-index,
                                    names_to = c("Var", ".value"),
                                    names_sep = "_")
    # Separate out the Var column (reagent order)
    orgVar_col <- dplyr::select(tmpOrg, c("Var"))
    # Detach the Var column
    tmpOrg <- dplyr::select(tmpOrg, -c("Var"))
    # Sort the column by index (row no. and reagent alphabetically)
    tmpOrg <- with(tmpOrg, tmpOrg[order(index, reag),])

    # Re-combine the Var column to the tempOrg DF
    tmpOrg <- cbind(tmpOrg, orgVar_col)
    rm(orgVar_col)

	# Put DF back into wide format
    tmpOrg <- tmpOrg %>% tidyr::pivot_wider(names_from = Var,
                                            names_glue = "{Var}_{.value}",
                                            values_from = c(reag, conc))
    tmpOrg <- dplyr::select(tmpOrg, -index) # Delete the index column


    # Organize aqueous solv. reagents alphabetically
    tmpAq <- dplyr::select(x,
                     c("aqReag1_reag", "aqReag1_conc",
                       "aqReag2_reag", "aqReag2_conc"))
    tmpAq$index <- 1:nrow(tmpAq)
    tmpAq$aqReag1_reag <- as.character(tmpAq$aqReag1_reag)
    tmpAq$aqReag2_reag <- as.character(tmpAq$aqReag2_reag)
    tmpAq$aqReag1_conc <- as.numeric(tmpAq$aqReag1_conc)
    tmpAq$aqReag2_conc <- as.numeric(tmpAq$aqReag2_conc)

    tmpAq <- tmpAq %>% tidyr::pivot_longer(-index,
                                           names_to = c("Var", ".value"),
                                           names_sep = "_")
    aqVar_col <- dplyr::select(tmpAq, c("Var"))
    tmpAq <- select(tmpAq, -c("Var"))
    tmpAq <- with(tmpAq, tmpAq[order(index, reag),])
    tmpAq <- cbind(tmpAq, aqVar_col)
    rm(aqVar_col)
    tmpAq <- tmpAq %>% tidyr::pivot_wider(names_from = Var,
                                              names_glue = "{Var}_{.value}",
                                              values_from = c(reag, conc))
    tmpAq <- dplyr::select(tmpAq, -index)

    # Disassemble/reassemble the temp. data frame
    x <- dplyr::select(x, -colnames(tmpOrg))
    x <- dplyr::select(x, -colnames(tmpAq))
    x <- cbind(x, tmpOrg, tmpAq)
    rm(tmpOrg, tmpAq)
	
	x
}

# Create data frame for building machine learning models =====================
ml_prep <- function(x, ...){
    
    x[is.na(x)] <- 0 # Replace NA with 0
	
	# Create columns based on the payload
	# Reagents/payload ratio
	x$reag_payload_ratio <- (x$totOrg_conc+x$totAq_conc)/x$payloadConc_mM 
	# Replace infinite (divided by 0) values with NA
	is.na(x) <- sapply(x, is.infinite) 
	x[is.na(x)] <- 0 # Substitute 0 for NA
	# Payload MW
	x$payloadMW <- dat_payload$MW[match(x$payload, dat_payload$payload)] 
	# Payload theor. logP value
	x$XlogP3 <- dat_payload$XlogP3[match(x$payload, dat_payload$payload)] 
	# Payload polar surface area
	x$polarSA <- dat_payload$polarSA_angSquared[match(x$payload, dat_payload$payload)]
	
	x <- subset(x, select=c(orgReag1_reag, orgReag1_conc,
							orgReag2_reag, orgReag2_conc,
							orgReag3_reag, orgReag3_conc,
							orgReag4_reag, orgReag4_conc, 
							orgReag5_reag, orgReag5_conc,
							orgReag6_reag, orgReag6_conc,
							aqReag1_reag, aqReag1_conc,
							aqReag2_reag, aqReag2_conc,
							tfr, frr, payload, reag_payload_ratio, 
							payloadMW, XlogP3, polarSA,
							hdiam_nm, pdi, zetaPot_mV, percEE
							))
	
	# Subset the organic reagents and put in order
	tmpOrg <- dplyr::select(x,
        c("orgReag1_reag", "orgReag1_conc",
          "orgReag2_reag", "orgReag2_conc",
          "orgReag3_reag", "orgReag3_conc",
          "orgReag4_reag", "orgReag4_conc",
          "orgReag5_reag", "orgReag5_conc",
          "orgReag6_reag", "orgReag6_conc"))
    tmpOrg$index <- 1:nrow(tmpOrg)
    tmpOrg$orgReag1_reag <- as.character(tmpOrg$orgReag1_reag)
    tmpOrg$orgReag2_reag <- as.character(tmpOrg$orgReag2_reag)
    tmpOrg$orgReag3_reag <- as.character(tmpOrg$orgReag3_reag)
    tmpOrg$orgReag4_reag <- as.character(tmpOrg$orgReag4_reag)
    tmpOrg$orgReag5_reag <- as.character(tmpOrg$orgReag5_reag)
    tmpOrg$orgReag6_reag <- as.character(tmpOrg$orgReag6_reag)
    
	tmpOrg <- tmpOrg |> tidyr::pivot_longer(-index,
                                    names_to = c("Var", ".value"),
                                    names_sep = "_")
    # Separate out the Var column (reagent order)
    orgVar_col <- dplyr::select(tmpOrg, c("Var"))
    # Detach the Var column
    tmpOrg <- dplyr::select(tmpOrg, -c("Var"))
    # Sort the column by index (row no. and reagent alphabetically)
    tmpOrg <- with(tmpOrg, tmpOrg[order(index, reag),])

    # Re-combine the Var column to the tempOrg DF
    tmpOrg <- cbind(tmpOrg, orgVar_col)
    rm(orgVar_col)

	# Put DF back into wide format
    tmpOrg <- tmpOrg |> tidyr::pivot_wider(names_from = Var,
                                            names_glue = "{Var}_{.value}",
                                            values_from = c(reag, conc))
    tmpOrg <- dplyr::select(tmpOrg, -index) # Delete the index column
   

	# Organize aqueous solv. reagents alphabetically
    tmpAq <- dplyr::select(x,
                     c("aqReag1_reag", "aqReag1_conc",
                       "aqReag2_reag", "aqReag2_conc"))
    tmpAq$index <- 1:nrow(tmpAq)
    tmpAq$aqReag1_reag <- as.character(tmpAq$aqReag1_reag)
    tmpAq$aqReag2_reag <- as.character(tmpAq$aqReag2_reag)
    tmpAq <- tmpAq |> tidyr::pivot_longer(-index,
                                           names_to = c("Var", ".value"),
                                           names_sep = "_")
    aqVar_col <- dplyr::select(tmpAq, c("Var"))
    tmpAq <- dplyr::select(tmpAq, -c("Var"))
    tmpAq <- with(tmpAq, tmpAq[order(index, reag),])
    tmpAq <- cbind(tmpAq, aqVar_col)
    rm(aqVar_col)
    tmpAq <- tmpAq |> tidyr::pivot_wider(names_from = Var,
                                              names_glue = "{Var}_{.value}",
                                              values_from = c(reag, conc))
    tmpAq <- dplyr::select(tmpAq, -index)

    # Disassemble the main data frame
    x <- dplyr::select(x, -colnames(tmpOrg))
    x <- dplyr::select(x, -colnames(tmpAq))

	# Re-name columns to make manipulation easier
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag1_reag"] ="reag_orgReag1"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag2_reag"] ="reag_orgReag2"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag3_reag"] ="reag_orgReag3"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag4_reag"] ="reag_orgReag4"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag5_reag"] ="reag_orgReag5"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag6_reag"] ="reag_orgReag6"

    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag1_conc"] ="conc_orgReag1"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag2_conc"] ="conc_orgReag2"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag3_conc"] ="conc_orgReag3"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag4_conc"] ="conc_orgReag4"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag5_conc"] ="conc_orgReag5"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag6_conc"] ="conc_orgReag6"

    colnames(tmpAq)[colnames(tmpAq) == "aqReag1_reag"] = "reag_aqReag1"
    colnames(tmpAq)[colnames(tmpAq) == "aqReag2_reag"] = "reag_aqReag2"

    colnames(tmpAq)[colnames(tmpAq) == "aqReag1_conc"] = "conc_aqReag1"
    colnames(tmpAq)[colnames(tmpAq) == "aqReag2_conc"] = "conc_aqReag2"

	# Re-shuffle and combine similar columns
    tmpOrg <- tmpOrg |>
            mutate(rown = row_number()) |>
            pivot_longer(-rown,
                         names_pattern = "(reag_orgReag|conc_orgReag)\\d+",
                         names_to = ".value", values_drop_na = TRUE) |>
            summarise(conc_orgReag = sum(conc_orgReag),
                      .by = c(rown, reag_orgReag)) |>
            pivot_wider(names_from = "reag_orgReag",
                        values_from = "conc_orgReag") |>
            dplyr::select(-c(rown,"0"))

    tmpAq <- tmpAq |>
            mutate(rown = row_number()) |>
            pivot_longer(-rown,
                         names_pattern = "(reag_aqReag|conc_aqReag)\\d+",
                         names_to = ".value", values_drop_na = TRUE) |>
            summarise(conc_aqReag = sum(conc_aqReag),
                      .by = c(rown, reag_aqReag)) |>
            pivot_wider(names_from = "reag_aqReag",
                        values_from = "conc_aqReag") |>
            dplyr::select(-c(rown,"0"))

    # Re-assemble the main data frame
    l <- list(tmpOrg, tmpAq, x)
    x <- do.call("cbind.data.frame", l[lengths(l) > 0])
    rm(tmpOrg, tmpAq)
 
	x[is.na(x)] <- 0 # Replace NA with 0

	# Remove chracters and spaces from column names
	names(x) <- gsub("\\s+", ".", names(x))
	names(x) <- gsub("\\-", ".", names(x))
	names(x) <- gsub("\\:", ".", names(x))
	names(x) <- gsub("\\(", "_", names(x))
	names(x) <- gsub("\\)", "_", names(x))
	
	return(x)
}

# Generate a "features mesh" on which to run predictions =====================
#generate_mesh <- function(x, ...){
#
#	# Get just the parameters columns
#    x <- subset(x, select=-c(payload, payloadMW, XlogP3, polarSA, 
#							 hdiam_nm, pdi, zetaPot_mV, percEE))
#
#    # Get the number of columns
#    ncols <- ncol(x)
#
#    # Replace spaces " " and dashes "-" in column names
#    names(x) <- gsub(x=names(x), pattern ="\\ ", replacement=".")
#    names(x) <- gsub(x=names(x), pattern ="\\-", replacement=".")
#
#    # Get column names
#    cols <- colnames(x)
#
#    # Number of data points in mesh
#    n = 3
#
#    # Generate "mesh" data frame
#    output <- matrix(ncol=ncols, nrow=n)
#    for (i in 1:ncols) {
#            output[,i] <- seq(min(x[i]), max(x[i]), length.out=n)
#    }
#    for (i in 1:ncols) {
#            output[,i] <- signif(output[,i], digits=2)
#    }
#    output <- data.frame(output)
#    names(output) <- cols
#    output <- expand.grid(output)
#
#    return(output)
#}

# Generate a random mesh (not systematic) ====================================
generate_mesh <- function(x, ...){
	# Get just the parameters columns
    x <- subset(x, select=-c(payload, payloadMW, XlogP3, polarSA,
                             hdiam_nm, pdi, zetaPot_mV, percEE))

    # Get the number of columns
    ncols <- ncol(x)

    # Replace spaces " " and dashes "-" in column names
    names(x) <- gsub(x=names(x), pattern ="\\ ", replacement=".")
    names(x) <- gsub(x=names(x), pattern ="\\-", replacement=".")

    # Get column names
    cols <- colnames(x)

	# Number of data points in the mesh
	n = 10000

	# Generate a random mesh
	output <- matrix(ncol=ncols, nrow=n)
	for (i in 1:ncols) {
		output[,i] <- runif(n, min(x[i]), max(x[i]))
	}
	for (i in 1:ncols) {
		output[,i] <- round(output[,i], digits=2)
	}
	output <- data.frame(output)
	output <- output[!duplicated(output),]
    names(output) <- cols
	return(output)
}


# Generalize reagents to "reagent classes" ===================================
generalize_reagents <- function(x, ...){

    x <- subset(x,
                select=c("orgReag1_reag", "orgReag1_conc",#
                         "orgReag2_reag", "orgReag2_conc",#
                         "orgReag3_reag", "orgReag3_conc",#
                         "orgReag4_reag", "orgReag4_conc",#
                         "orgReag5_reag", "orgReag5_conc",#
                         "orgReag6_reag", "orgReag6_conc",#
                         "aqReag1_reag", "aqReag1_conc",#
                         "aqReag2_reag", "aqReag2_conc",#
                         "tfr", "frr", "hdiam_nm", "pdi",#
                         "dispersity"))

    # Substitute reagent name with classification from the dat_mater
    # dataframe for all reagent columns
    matching1o <- dat_mater$classification[#
        match(x$orgReag1_reag, dat_mater$Product_Name)]
    matching2o <- dat_mater$classification[#
        match(x$orgReag2_reag, dat_mater$Product_Name)]
    matching3o <- dat_mater$classification[#
        match(x$orgReag3_reag, dat_mater$Product_Name)]
    matching4o <- dat_mater$classification[#
        match(x$orgReag4_reag, dat_mater$Product_Name)]
    matching5o <- dat_mater$classification[#
        match(x$orgReag5_reag, dat_mater$Product_Name)]
    matching6o <- dat_mater$classification[#
        match(x$orgReag6_reag, dat_mater$Product_Name)]
    matching1a <- dat_mater$classification[#
        match(x$aqReag1_reag, dat_mater$Product_Name)]
    matching2a <- dat_mater$classification[#
        match(x$aqReag2_reag, dat_mater$Product_Name)]

	# Replace the reagent name with the substituted classification value
    x$orgReag1_reag <- ifelse(is.na(matching1o), #
        x$orgReag1_reag, matching1o)
    x$orgReag2_reag <- ifelse(is.na(matching2o), #
        x$orgReag2_reag, matching2o)
    x$orgReag3_reag <- ifelse(is.na(matching3o), #
        x$orgReag3_reag, matching3o)
    x$orgReag4_reag <- ifelse(is.na(matching4o), #
        x$orgReag4_reag, matching4o)
    x$orgReag5_reag <- ifelse(is.na(matching5o), #
        x$orgReag5_reag, matching5o)
    x$orgReag6_reag <- ifelse(is.na(matching6o), #
        x$orgReag6_reag, matching6o)
    x$aqReag1_reag <- ifelse(is.na(matching1a), #
        x$aqReag1_reag, matching1a)
    x$aqReag2_reag <- ifelse(is.na(matching2a), #
        x$aqReag2_reag, matching2a)

	tmpOrg <- dplyr::select(x,
        c("orgReag1_reag", "orgReag1_conc",
          "orgReag2_reag", "orgReag2_conc",
          "orgReag3_reag", "orgReag3_conc",
          "orgReag4_reag", "orgReag4_conc",
          "orgReag5_reag", "orgReag5_conc",
          "orgReag6_reag", "orgReag6_conc"))
    tmpOrg$index <- 1:nrow(tmpOrg)
    tmpOrg$orgReag1_reag <- as.character(tmpOrg$orgReag1_reag)
    tmpOrg$orgReag2_reag <- as.character(tmpOrg$orgReag2_reag)
    tmpOrg$orgReag3_reag <- as.character(tmpOrg$orgReag3_reag)
    tmpOrg$orgReag4_reag <- as.character(tmpOrg$orgReag4_reag)
    tmpOrg$orgReag5_reag <- as.character(tmpOrg$orgReag5_reag)
    tmpOrg$orgReag6_reag <- as.character(tmpOrg$orgReag6_reag)

    tmpOrg$orgReag1_conc <- as.numeric(tmpOrg$orgReag1_conc)
    tmpOrg$orgReag2_conc <- as.numeric(tmpOrg$orgReag2_conc)
    tmpOrg$orgReag3_conc <- as.numeric(tmpOrg$orgReag3_conc)
    tmpOrg$orgReag4_conc <- as.numeric(tmpOrg$orgReag4_conc)
    tmpOrg$orgReag5_conc <- as.numeric(tmpOrg$orgReag5_conc)
    tmpOrg$orgReag6_conc <- as.numeric(tmpOrg$orgReag6_conc)
    tmpOrg <- tmpOrg %>% tidyr::pivot_longer(-index,
                                    names_to = c("Var", ".value"),
                                    names_sep = "_")
    # Separate out the Var column (reagent order)
    orgVar_col <- dplyr::select(tmpOrg, c("Var"))
    # Detach the Var column
    tmpOrg <- dplyr::select(tmpOrg, -c("Var"))
    # Sort the column by index (row no. and reagent alphabetically)
    tmpOrg <- with(tmpOrg, tmpOrg[order(index, reag),])

    # Re-combine the Var column to the tempOrg DF
    tmpOrg <- cbind(tmpOrg, orgVar_col)
    rm(orgVar_col)

	# Put DF back into wide format
    tmpOrg <- tmpOrg %>% tidyr::pivot_wider(names_from = Var,
                                            names_glue = "{Var}_{.value}",
                                            values_from = c(reag, conc))
    tmpOrg <- dplyr::select(tmpOrg, -index) # Delete the index column


    # Organize aqueous solv. reagents alphabetically
    tmpAq <- dplyr::select(x,
                     c("aqReag1_reag", "aqReag1_conc",
                       "aqReag2_reag", "aqReag2_conc"))
    tmpAq$index <- 1:nrow(tmpAq)
    tmpAq$aqReag1_reag <- as.character(tmpAq$aqReag1_reag)
    tmpAq$aqReag2_reag <- as.character(tmpAq$aqReag2_reag)
    tmpAq$aqReag1_conc <- as.numeric(tmpAq$aqReag1_conc)
    tmpAq$aqReag2_conc <- as.numeric(tmpAq$aqReag2_conc)

    tmpAq <- tmpAq %>% tidyr::pivot_longer(-index,
                                           names_to = c("Var", ".value"),
                                           names_sep = "_")
    aqVar_col <- dplyr::select(tmpAq, c("Var"))
    tmpAq <- dplyr::select(tmpAq, -c("Var"))
    tmpAq <- with(tmpAq, tmpAq[order(index, reag),])
    tmpAq <- cbind(tmpAq, aqVar_col)
    rm(aqVar_col)
    tmpAq <- tmpAq %>% tidyr::pivot_wider(names_from = Var,
                                              names_glue = "{Var}_{.value}",
                                              values_from = c(reag, conc))
    tmpAq <- dplyr::select(tmpAq, -index)

    # Disassemble the main data frame
    x <- dplyr::select(x, -colnames(tmpOrg))
    x <- dplyr::select(x, -colnames(tmpAq))

	# Re-name columns to make manipulation easier
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag1_reag"] ="reag_orgReag1"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag2_reag"] ="reag_orgReag2"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag3_reag"] ="reag_orgReag3"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag4_reag"] ="reag_orgReag4"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag5_reag"] ="reag_orgReag5"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag6_reag"] ="reag_orgReag6"

    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag1_conc"] ="conc_orgReag1"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag2_conc"] ="conc_orgReag2"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag3_conc"] ="conc_orgReag3"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag4_conc"] ="conc_orgReag4"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag5_conc"] ="conc_orgReag5"
    colnames(tmpOrg)[colnames(tmpOrg) == "orgReag6_conc"] ="conc_orgReag6"

    colnames(tmpAq)[colnames(tmpAq) == "aqReag1_reag"] = "reag_aqReag1"
    colnames(tmpAq)[colnames(tmpAq) == "aqReag2_reag"] = "reag_aqReag2"

    colnames(tmpAq)[colnames(tmpAq) == "aqReag1_conc"] = "conc_aqReag1"
    colnames(tmpAq)[colnames(tmpAq) == "aqReag2_conc"] = "conc_aqReag2"

	# Re-shuffle and combine similar columns
    tmpOrg <- tmpOrg |>
            mutate(rown = row_number()) |>
            pivot_longer(-rown,
                         names_pattern = "(reag_orgReag|conc_orgReag)\\d+",
                         names_to = ".value", values_drop_na = TRUE) |>
            summarise(conc_orgReag = sum(conc_orgReag),
                      .by = c(rown, reag_orgReag)) |>
            pivot_wider(names_from = "reag_orgReag",
                        values_from = "conc_orgReag") |>
            dplyr::select(-rown)

    tmpAq <- tmpAq |>
            mutate(rown = row_number()) |>
            pivot_longer(-rown,
                         names_pattern = "(reag_aqReag|conc_aqReag)\\d+",
                         names_to = ".value", values_drop_na = TRUE) |>
            summarise(conc_aqReag = sum(conc_aqReag),
                      .by = c(rown, reag_aqReag)) |>
            pivot_wider(names_from = "reag_aqReag",
                        values_from = "conc_aqReag") |>
            dplyr::select(-rown)

    # Re-assemble the main data frame
    l <- list(tmpOrg, tmpAq, x)
    x <- do.call("cbind.data.frame", l[lengths(l) > 0])
    rm(tmpOrg, tmpAq)

    # Replace NA with 0
    x[is.na(x)] <- 0

    x
}

# ============================================================================
dat_mater <- structure(list(Category = c("Lipid", "Lipid", "Lipid", "Lipid", 
"Lipid", "Lipid", "Lipid", "Lipid", "Lipid", "Lipid", "Lipid", 
"Lipid", "Lipid", "Lipid", "Polymer", "Polymer", "Polymer", "Polymer", 
"Polymer", "Polymer", "Polymer", "Polymer", "Polymer", "Polymer", 
"Polymer", "Polymer", "Polymer", "Polymer", "Polymer", "Polymer", 
"Polymer", "Polymer", "Polymer", "Polymer", "Polymer", "Polymer"
), Vendor = c("BLD Pharmatech Ltd", "Avanti Polar Lipids", "Avanti Polar Lipids", 
"Avanti Polar Lipids", "Avanti Polar Lipids", "Avanti Polar Lipids", 
"Avanti Polar Lipids", "Avanti Polar Lipids", "Avanti Polar Lipids", 
"Avanti Polar Lipids", "Avanti Polar Lipids", "Avanti Polar Lipids", 
"Merck/Sigma-Aldrich", "Avanti Polar Lipids", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", 
"Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich", "Merck/Sigma-Aldrich"
), Catalog_No = c("BL3H97A45836", "850457", "880151", "890850", 
"890890", "850375", "850725", "850355C", "810158", "850365", 
"880135", "880120", "C8667", "840051", "719897", "739952", "719870", 
"739944", "719900", "739960", "719862", "719919", "719927", "739979", 
"719978", "719951", "719943", "719935", "363081", "341584", "P8136", 
"360627", "363065", "363170", "363146", "363138"), Abbreviated_or_Product_Name = c("DLin-MC3-DMA", 
"POPC", "DMG-PEG 2000", "DODAP", "DOTAP", "DOPC", "DOPE", "DPPC", 
"DPPE-RhoB", "DSPC", "DSPE-PEG2k-COOH", "DSPE-PEG2k-OCH3", "Cholesterol", 
"Egg PC", "Resomer RG 502 H", "Resomer RG 503", "Resomer RG 503 H", 
"Resomer RG 504", "Resomer RG 504 H", "Resomer RG 505", "Resomer RG 653 H", 
"Resomer RG 752 H", "Resomer RG 756 S", "Resomer RG 858 S", "Resomer R 202 H", 
"Resomer R 202 S", "Resomer R 203 H", "Resomer R 203 S", "Poly(vinyl alcohol)", 
"Poly(vinyl alcohol)", "Poly(vinyl alcohol)", "Poly(vinyl alcohol)", 
"Poly(vinyl alcohol)", "Poly(vinyl alcohol)", "Poly(vinyl alcohol)", 
"Poly(vinyl alcohol)"), Full_Name = c("(6Z,9Z,28Z,31Z)-Heptatriaconta-6,9,28,31-tetraen-19-yl 4-(dimethylamino)butanoate", 
"1-palmitoyl-2-oleoyl-glycero-3-phosphocholine", "1,2-dimyristoyl-rac-glycero-3-methoxypolyethylene glycol-2000", 
"1,2-dioleoyl-3-dimethylammonium-propane", "1,2-dioleoyl-3-trimethylammonium-propane (chloride salt)", 
"1,2-dioleoyl-sn-glycero-3-phosphocholine", "1,2-dioleoyl-sn-glycero-3-phosphoethanolamine", 
"1,2-dipalmitoyl-sn-glycero-3-phosphocholine", "1,2-dipalmitoyl-sn-glycero-3-phosphoethanolamine-N-(lissamine rhodamine B sulfonyl) (ammonium salt)", 
"1,2-distearoyl-sn-glycero-3-phosphocholine", "1,2-distearoyl-sn-glycero-3-phosphoethanolamine-N-[carboxy(polyethylene glycol)-2000] (sodium salt)", 
"1,2-distearoyl-sn-glycero-3-phosphoethanolamine-N-[methoxy(polyethylene glycol)-2000] (ammonium salt)", 
"Cholesterol", "L-α-phosphatidylcholine (Egg, Chicken)", "poly(D,L-lactide-co-glycolide)", 
"poly(D,L-lactide-co-glycolide)", "poly(D,L-lactide-co-glycolide)", 
"poly(D,L-lactide-co-glycolide)", "poly(D,L-lactide-co-glycolide)", 
"poly(D,L-lactide-co-glycolide)", "poly(D,L-lactide-co-glycolide)", 
"poly(D,L-lactide-co-glycolide)", "poly(D,L-lactide-co-glycolide)", 
"poly(D,L-lactide-co-glycolide)", "poly(D,L-lactide)", "poly(D,L-lactide)", 
"poly(D,L-lactide)", "poly(D,L-lactide)", "Poly(vinyl alcohol)", 
"Poly(vinyl alcohol)", "Poly(vinyl alcohol)", "Poly(vinyl alcohol)", 
"Poly(vinyl alcohol)", "Poly(vinyl alcohol)", "Poly(vinyl alcohol)", 
"Poly(vinyl alcohol)"), CAS_No = c("1224606-06-7", "26853-31-6", 
"160743-62-4", "127512-29-2", "132172-61-3", "4235-95-4", "4004-05-01", 
"63-89-8", "384833-01-6", "816-94-4", "1403744-37-5", "474922-77-5", 
"57-88-5", "97281-44-2", "26780-50-7", "26780-50-7", "26780-50-7", 
"26780-50-7", "26780-50-7", "26780-50-7", "26780-50-7", "26780-50-7", 
"26780-50-7", "26780-50-7", "26680-10-04", "26680-10-04", "26680-10-04", 
"26680-10-04", "9002-89-5", "9002-89-5", "9002-89-5", "9002-89-5", 
"9002-89-5", "9002-89-5", "9002-89-5", "9002-89-5"), ApproxMW = c(642.09, 
760.076, 2509, 648, 699, 786.113, 744, 734, 1249.641, 790.145, 
2780, 2805.497, 387, 770.123, 12000, 31000, 31000, 46000, 46000, 
61500, 31000, 9500, 95500, 215000, 14000, 14000, 21000, 23000, 
104500, 93500, 50000, 9500, 166000, 18000, 104500, 40500), Notes = c(NA, 
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "50:50 lactide:glycolide", 
"50:50 lactide:glycolide", "50:50 lactide:glycolide", "50:50 lactide:glycolide", 
"50:50 lactide:glycolide", "50:50 lactide:glycolide", "65:35 lactide:glycolide", 
"75:25 lactide:glycolide", "75:25 lactide:glycolide", "85:15 lactide:glycolide", 
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA), classification = c("ionizable lipid", 
"helper lipid", "PEG-lipid", "ionizable lipid", "cationic lipid", 
"helper lipid", "helper lipid", "helper lipid", "helper lipid", 
"helper lipid", "PEG-lipid", "PEG-lipid", "membrane stabilizing lipid", 
"helper lipid", "hydrophobic polymer", "hydrophobic polymer", 
"hydrophobic polymer", "hydrophobic polymer", "hydrophobic polymer", 
"hydrophobic polymer", "hydrophobic polymer", "hydrophobic polymer", 
"hydrophobic polymer", "hydrophobic polymer", "hydrophobic polymer", 
"hydrophobic polymer", "hydrophobic polymer", "hydrophobic polymer", 
"hydrophilic polymer", "hydrophilic polymer", "hydrophilic polymer", 
"hydrophilic polymer", "hydrophilic polymer", "hydrophilic polymer", 
"hydrophilic polymer", "hydrophilic polymer")), class = "data.frame", row.names = c(NA, 
-36L))

# ============================================================================
dat_payload <- structure(list(payload = c("5-Fluorouracil", "Curcumin", "Cyclophosphamide", 
"Daunorubicin", "Docetaxel", "Doxorubicin", "Epirubicin", "Methotrexate", 
"O6-benzylguanine", "Paclitaxel", "Temozolomide"), sequence = c(NA_integer_, 
NA_integer_, NA_integer_, NA_integer_, NA_integer_, NA_integer_, 
NA_integer_, NA_integer_, NA_integer_, NA_integer_, NA_integer_
), payload_type = c("small molecule", "small molecule", "small molecule", 
"small molecule", "small molecule", "small molecule", "small molecule", 
"small molecule", "small molecule", "small molecule", "small molecule"
), primary_indication = c("anti-cancer", "anti-cancer", "anti-cancer", 
"anti-cancer", "anti-cancer", "anti-cancer", "anti-cancer", "anti-cancer", 
"anti-cancer", "anti-cancer", "anti-cancer"), MoA = c("block nucleoside metabolism", 
"mitochondrial membrane disruption", "alkylating agent", "DNA intercalation", 
"microtubule stabilization", "DNA intercalation", "inhibit nucleic acid and protein synthesis", 
"inhibit nucleotide synthesis", "Inhibit DNA repair", "microtubule stabilization", 
"DNA methylation"), CAS = c("51-21-8", "458-37-7", "50-18-0", 
"20830-81-3", "114977-28-5", "23214-92-8", "56420-45-2", "1959-05-02", 
"19916-73-5", "33069-62-4", "85622-93-1"), MW = c(130.08, 368.4, 
261.08, 527.5, 807.9, 543.5, 543.5, 454.4, 241.25, 853.9, 194.15
), bp = c(NA_integer_, NA_integer_, NA_integer_, NA_integer_, 
NA_integer_, NA_integer_, NA_integer_, NA_integer_, NA_integer_, 
NA_integer_, NA_integer_), XlogP3 = c(-0.9, 3.2, 0.6, 1.8, 1.6, 
1.3, 1.3, -1.8, 1.2, 2.5, -1.1), polarSA_angSquared = c(58.2, 
93.1, 41.6, 186, 224, 206, 206, 211, 89.7, 221, 106), source = c("https://pubchem.ncbi.nlm.nih.gov/compound/3385", 
"https://pubchem.ncbi.nlm.nih.gov/compound/Curcumin", "https://pubchem.ncbi.nlm.nih.gov/compound/2907", 
"https://pubchem.ncbi.nlm.nih.gov/compound/30323", "https://pubchem.ncbi.nlm.nih.gov/compound/148124", 
"https://pubchem.ncbi.nlm.nih.gov/compound/31703", "https://pubchem.ncbi.nlm.nih.gov/compound/41867", 
"https://pubchem.ncbi.nlm.nih.gov/compound/126941", "https://pubchem.ncbi.nlm.nih.gov/compound/4578", 
"https://pubchem.ncbi.nlm.nih.gov/compound/36314", "https://pubchem.ncbi.nlm.nih.gov/compound/5394"
)), class = "data.frame", row.names = c(NA, -11L))

dat_chips <- structure(list(mfr = c("Select manufacturer...", "Particle Works", 
"Particle Works", "Particle Works", "Precision NanoSystems", 
"Precision NanoSystems", "Precision NanoSystems", "Precision NanoSystems", 
"Precision NanoSystems", "Precision NanoSystems", "Precision NanoSystems", 
"Custom Pump + Chip Combination", "Custom Pump + Chip Combination", 
"Custom Pump + Chip Combination", "Custom Pump + Chip Combination", 
"Custom Pump + Chip Combination"), instr = c(NA, "Select instrument...", 
"Automated Library Synthesis System (ALiS)", "Automated Nanoparticle (ANP) System", 
"Select instrument...", "Spark", "Ignite", "Ignite+", "Blaze", 
"GMP System", "Benchtop NanoAssemblr (discontinued)", "Select syringe pump...", 
"Chemyx Fusion 4000 Syringe Pump", "Chemyx Fusion 100-X Syringe Pump", 
"Chemyx Fusion 200-X Syringe Pump", "Harvard Apparatus Pump 11 Elite infusion Dual Syringe"
), chip = c(NA, NA, "ALiS Chip", "ANP Chip", NA, "Spark Cartridge", 
"Ignite Cartridge", "Ignite Cartridge", "Blaze Cartridge", NA, 
"Benchtop Cartridge", NA, "microfluidic ChipShop Fluidic 186 chip", 
"microfluidic ChipShop Fluidic 186 chip", "microfluidic ChipShop Fluidic 186 chip", 
"microfluidic ChipShop Fluidic 186 chip")), class = "data.frame", row.names = c(NA, 
-16L))


# ============================================================================
df_template <- structure(list(np_type = logical(0), aq_phase = logical(0), org_phase = logical(0), 
    frr_aq = logical(0), frr_org = logical(0), tfr = logical(0), 
    orgReag1_reag = logical(0), orgReag1_conc = logical(0), orgReag2_reag = logical(0), 
    orgReag2_conc = logical(0), orgReag3_reag = logical(0), orgReag3_conc = logical(0), 
    orgReag4_reag = logical(0), orgReag4_conc = logical(0), orgReag5_reag = logical(0), 
    orgReag5_conc = logical(0), orgReag6_reag = logical(0), orgReag6_conc = logical(0), 
    aqReag1_reag = logical(0), aqReag1_conc = logical(0), aqReag2_reag = logical(0), 
    aqReag2_conc = logical(0), payload = logical(0), payloadConc_mM = logical(0), 
    hdiam_nm = logical(0), pdi = logical(0), zetaPot_mV = logical(0), 
    percEE = logical(0)), class = "data.frame", row.names = integer(0))
