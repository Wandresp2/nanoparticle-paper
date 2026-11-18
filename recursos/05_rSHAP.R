# SHAP ANALYSIS ======================================================
# Get data frames
df_shap_diam_lipid <- subset(dfML_lipid,
                             select=-c(payload, zetaPot_mV, percEE, pdi))
df_shap_pdi_lipid <- subset(dfML_lipid,
                            select=-c(payload, zetaPot_mV, percEE, hdiam_nm))
df_shap_ee_lipid <- subset(dfML_lipid,
                           select=-c(payload, zetaPot_mV, hdiam_nm, pdi))

df_shap_diam_pol <- subset(dfML_PNP,
                           select=-c(payload, zetaPot_mV, percEE, pdi))
df_shap_pdi_pol <- subset(dfML_PNP,
                          select=-c(payload, zetaPot_mV, percEE, hdiam_nm))
df_shap_ee_pol <- subset(dfML_PNP,
                         select=-c(payload, zetaPot_mV, hdiam_nm, pdi))

# Get SHAP -- lipids ========================================================
## Diameter 
shap_diam_lipid <- kernelshap(diam_fit_lipid,
                             subset(df_shap_diam_lipid, select=-c(hdiam_nm)),
                             bg_X=df_shap_diam_lipid) |> shapviz()
colnames(shap_diam_lipid) <- gsub("tfr","TFR",colnames(shap_diam_lipid))
colnames(shap_diam_lipid) <- gsub("frr","FRR",colnames(shap_diam_lipid))
colnames(shap_diam_lipid) <- gsub("payloadMW","Payload MW",colnames(shap_diam_lipid))
colnames(shap_diam_lipid) <- gsub("reag_payload_ratio","Reagent:Payload\nRatio",
                                  colnames(shap_diam_lipid))
colnames(shap_diam_lipid) <- gsub("polarSA","Payload Polar\nSurface Area",colnames(shap_diam_lipid))

## PdI
shap_pdi_lipid <- kernelshap(pdi_fit_lipid,
                             subset(df_shap_pdi_lipid, select=-c(pdi)),
                             bg_X=df_shap_pdi_lipid) |> shapviz()
colnames(shap_pdi_lipid) <- gsub("tfr","TFR",colnames(shap_pdi_lipid))
colnames(shap_pdi_lipid) <- gsub("frr","FRR",colnames(shap_pdi_lipid))
colnames(shap_pdi_lipid) <- gsub("payloadMW","Payload MW",colnames(shap_pdi_lipid))
colnames(shap_pdi_lipid) <- gsub("reag_payload_ratio","Reagent:Payload\nRatio",
                                  colnames(shap_pdi_lipid))
colnames(shap_pdi_lipid) <- gsub("polarSA","Payload Polar\nSurface Area",colnames(shap_pdi_lipid))

# % EE
shap_ee_lipid <- kernelshap(ee_fit_lipid,
                             subset(df_shap_ee_lipid, select=-c(percEE)),
                             bg_X=df_shap_ee_lipid) |> shapviz()
colnames(shap_ee_lipid) <- gsub("tfr","TFR",colnames(shap_ee_lipid))
colnames(shap_ee_lipid) <- gsub("frr","FRR",colnames(shap_ee_lipid))
colnames(shap_ee_lipid) <- gsub("payloadMW","Payload MW",colnames(shap_ee_lipid))
colnames(shap_ee_lipid) <- gsub("reag_payload_ratio","Reagent:Payload\nRatio",
                                  colnames(shap_ee_lipid))
colnames(shap_ee_lipid) <- gsub("polarSA","Payload Polar\nSurface Area",colnames(shap_ee_lipid))

# Get SHAP -- PLGA ==========================================================
## Diameter
shap_diam_pol <- kernelshap(diam_fit_pol,
                             subset(df_shap_diam_pol, select=-c(hdiam_nm)),
                             bg_X=df_shap_diam_pol) |> shapviz()
colnames(shap_diam_pol) <- gsub("tfr","TFR",colnames(shap_diam_pol))
colnames(shap_diam_pol) <- gsub("frr","FRR",colnames(shap_diam_pol))
colnames(shap_diam_pol) <- gsub("payloadMW","Payload MW",colnames(shap_diam_pol))
colnames(shap_diam_pol) <- gsub("reag_payload_ratio","Reagent:Payload\nRatio",
                                  colnames(shap_diam_pol))
colnames(shap_diam_pol) <- gsub("polarSA","Payload Polar\nSurface Area",colnames(shap_diam_pol))

## PdI
shap_pdi_pol <- kernelshap(pdi_fit_pol,
                             subset(df_shap_pdi_pol, select=-c(pdi)),
                             bg_X=df_shap_pdi_pol) |> shapviz()
colnames(shap_pdi_pol) <- gsub("tfr","TFR",colnames(shap_pdi_pol))
colnames(shap_pdi_pol) <- gsub("frr","FRR",colnames(shap_pdi_pol))
colnames(shap_pdi_pol) <- gsub("payloadMW","Payload MW",colnames(shap_pdi_pol))
colnames(shap_pdi_pol) <- gsub("reag_payload_ratio","Reagent:Payload\nRatio",
                                  colnames(shap_pdi_pol))
colnames(shap_pdi_pol) <- gsub("polarSA","Payload Polar\nSurface Area",colnames(shap_pdi_pol))

## % EE
shap_ee_pol <- kernelshap(ee_fit_pol,
                             subset(df_shap_ee_pol, select=-c(percEE)),
                             bg_X=df_shap_ee_pol) |> shapviz()
colnames(shap_ee_pol) <- gsub("tfr","TFR",colnames(shap_ee_pol))
colnames(shap_ee_pol) <- gsub("frr","FRR",colnames(shap_ee_pol))
colnames(shap_ee_pol) <- gsub("payloadMW","Payload MW",colnames(shap_ee_pol))
colnames(shap_ee_pol) <- gsub("reag_payload_ratio","Reagent:Payload\nRatio",
                                  colnames(shap_ee_pol))
colnames(shap_ee_pol) <- gsub("polarSA","Payload Polar\nSurface Area",colnames(shap_ee_pol))

