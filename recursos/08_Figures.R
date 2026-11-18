# Load preliminary scripts
# source("01_mfNP.R")
# source("02_rf_lipid_model.R")
# source("03_rf_PLGA_model.R")
# source("04_AlgScreening.R")
# source("05_rSHAP.R")
# source("06_GenAI.R")
# source("07_modelCompare.R")

# FIGURES ====================================================================
## SUMMARY PLOTS - NP ATTRIBUTES - LNP =======================================
p_lipidSumm <- ggplot(df_summLipid[which(df_summLipid$np_type == "Lipid Nanoparticle"),],
            aes(tfr, meanDiam, alpha=dispersity))+
  facet_grid(signif(totOrg_conc, digits=2) ~ frr, scales="free_y")+
# geom_point(data = dfLipid, mapping=aes(tfr, hdiam_nm, alpha=dispersity),
#            position = position_jitter(height=0, width=0.25))+
  geom_errorbar(data = df_summLipid[which(df_summLipid$np_type == "Lipid Nanoparticle"),],
                 mapping = aes(x = tfr,
                         ymin=meanDiam-sdDiam,
                         ymax=meanDiam+sdDiam),
                 width=0.50)+
  geom_point(size=3, shape = 21, fill="darkturquoise")+
  labs(title = "Flow rate ratio",
       tag="Total Organic Concentration (mM)")+
  scale_x_continuous(name = "Total flow rate (ml/min)")+
  scale_y_continuous(name = "Mean diameter (nm)")+
  scale_alpha_manual(values = c(1.0,0.2))+
  theme_test()+
  theme(aspect.ratio = 1,
      plot.title = element_text(hjust=0.5, size=14),
      plot.tag=element_text(angle=-90, size=14),
      plot.tag.position=c(1.0,0.5),
      axis.title=element_text(size=14),
      axis.text=element_text(size=12),
      strip.text=element_text(size=12),
      strip.background=element_rect(fill="gray95"),
      legend.position="none")

## SUMMARY PLOTS - NP ATTRIBUTES - LIPOSOMES =================================
p_lipoSumm <- ggplot(df_summLipid[which(df_summLipid$np_type == "Liposome" & #
                    df_summLipid$payload == "No payload"),],
            aes(tfr, meanDiam, alpha=dispersity))+
  facet_grid(signif(totOrg_conc, digits=2) ~ frr, scales="free_y")+
# geom_point(data = dfLipid, mapping=aes(tfr, hdiam_nm, alpha=dispersity),
#            position = position_jitter(height=0, width=0.25))+
  geom_errorbar(data = df_summLipid[which(df_summLipid$np_type == "Liposome"&#
                      df_summLipid$payload == "No payload"),],
                 mapping = aes(x = tfr,
                         ymin=meanDiam-sdDiam,
                         ymax=meanDiam+sdDiam),
                 width=0.50)+
  geom_point(size=3, shape=21, fill="paleturquoise")+
  labs(title = "Flow rate ratio",
       tag="Total Organic Concentration (mM)")+
  scale_x_continuous(name = "Total flow rate (ml/min)")+
  scale_y_continuous(name = "Mean diameter (nm)")+
  scale_alpha_manual(values = c(1.0,0.2))+
  scale_shape_manual(values = c(21,22))+
  theme_test()+
  theme(aspect.ratio = 1,
      plot.title = element_text(hjust=0.5, size=14),
      plot.tag=element_text(angle=-90, size=14),
      plot.tag.position=c(1.0,0.5),
      axis.title=element_text(size=14),
      axis.text=element_text(size=12),
      strip.text=element_text(size=12),
      strip.background=element_rect(fill="gray95"),
      legend.position="none")

## SUMMARY PLOTS - NP ATTRIBUTES - PLGA NP ===================================
p_polSumm <- ggplot(df_summPol[which(df_summPol$payload == "No payload"),],
          aes(tfr, meanDiam, alpha=dispersity))+
  facet_grid(totOrg_conc ~ frr, scales="free_y")+
  geom_errorbar(data = df_summPol[which(df_summPol$payload == "No payload"),],
                 mapping = aes(x = tfr, ymin=meanDiam-sdDiam,
                 ymax=meanDiam+sdDiam),
                 width=0.50)+
  geom_point(size=3, shape=21, fill="chartreuse3")+
  labs(title = "Flow rate ratio",
       tag="Total Organic Concentration (mM)")+
  scale_x_continuous(name = "Total flow rate (ml/min)", limits=c(2,13),
           breaks=seq(2,13,2))+
  scale_y_continuous(name = "Mean diameter (nm)")+
  scale_alpha_manual(values = c(1.0,0.2))+
  scale_shape_manual(values = c(21,22))+
  theme_test()+
  theme(aspect.ratio = 1,
        plot.title = element_text(hjust=0.5, size=14),
        plot.tag=element_text(angle=-90, size=14),
        plot.tag.position=c(1.0,0.5),
        axis.title=element_text(size=14),
        axis.text=element_text(size=12),
        strip.text=element_text(size=12),
        strip.background=element_rect(fill="gray95"),
        legend.position="none")

### Combined scatter plots ===================================================
p_summPlot_comb <- p_lipidSumm+p_lipoSumm+p_polSumm
ggsave("figs/subFigs/summaryPlot_combined.png", device="png",
       units=c("cm"), width=50, height=16, dpi=300)


## PEARSON CORRELATION PLOTS =================================================
### Mixed lipids =============================================================
p_corrAllLipids <- ggcorr(subset(dfML_lipid, select=-c(payload, zetaPot_mV)),
                          low="midnightblue",
                          mid="lightblue",
                          high="chartreuse2", hjust=1.0)+
                    theme(legend.position="right",
                          aspect.ratio = 1)
ggsave("figs/subFigs/corrPlot_allLipids.pdf", device="pdf", units=c("cm"),
       width=16, height=16, dpi=300)

### LNP only =================================================================
dfCorr_lipid$totOrg <- rowSums(
  subset(dfCorr_lipid, select=-c(tfr, frr, payload, reag_payload_ratio,
                                 payloadMW, XlogP3, polarSA, hdiam_nm,
                                 pdi, zetaPot_mV, percEE)))
dfCorr_lipid <- subset(dfCorr_lipid,
  select=-c(payload, zetaPot_mV, reag_payload_ratio, XlogP3, polarSA, percEE,
            payloadMW, Cholesterol, DODAP, DSPC, DSPE.PEG2k))
dfCorr_lipid <- dfCorr_lipid[, c("totOrg", "tfr", "frr", "hdiam_nm", "pdi")]

p_corrLipid <- ggcorr(dfCorr_lipid,
            low="midnightblue",
            mid="lightblue",
            high="chartreuse2")+
          theme(legend.position = "right")
ggsave("figs/subFigs/corrPlot_lipid.pdf", device="pdf", units=c("cm"),
       width=16, height=16, dpi=300)

### Liposome only ============================================================
dfCorr_liposome$totOrg <- rowSums(
  subset(dfCorr_liposome, select=-c(tfr, frr, payload, reag_payload_ratio,
                                     payloadMW, XlogP3, polarSA, hdiam_nm, pdi,
                                     zetaPot_mV, percEE)))
dfCorr_liposome <- subset(dfCorr_liposome,
  select=-c(payloadMW, XlogP3, polarSA, Cholesterol, DPPC, DSPE.PEG2k,
           zetaPot_mV, payload))
dfCorr_liposome <- dfCorr_liposome[,c("totOrg", "tfr", "frr", #
                                      "reag_payload_ratio", "hdiam_nm",#
                                      "pdi", "percEE")]

p_corrLiposome <- ggcorr(dfCorr_liposome,
            low="midnightblue",
            mid="lightblue",
            high="chartreuse2",
            hjust=1)+
          theme(legend.position = "bottom")
ggsave("figs/subFigs/corrPlot_liposome.pdf", device="pdf", units=c("cm"),
       width=16, height=16, dpi=300)


### PLGA NP ==================================================================
p_corrPNP <- ggcorr(subset(dfML_PNP, select=-c(payload, zetaPot_mV)),
            low="midnightblue",
            mid="lightblue",
            high="chartreuse2")+
          theme(legend.position = "right")
ggsave("figs/subFigs/corrPlot_PNP.pdf", device="pdf", units=c("cm"),
       width=16, height=16, dpi=300)

## MACHINE LEARNING PLOTS ====================================================
### VARIOUS ALGORITHMS HEATMAPS ==============================================
#### LIPID-BASED NP ==========================================================
# First get the order of the algorithms
algorithm_order_ranked <- ranking_lipid |>
    arrange(desc(rank)) |>
    pull(algorithm)

df_lipid_varMod_heatmap <- rbind(
  data.frame(
    algorithm = df_lipid_varMods_rmse$algorithm,
    meas = rep("Diameter", times=length(df_lipid_varMods_rmse$algorithm)),
    normRMSE = df_lipid_varMods_rmse$normDiam_rmse,
    rsq = df_lipid_varMods_rsq$diam_rsq
  ), # Diam
  data.frame(
    algorithm = df_lipid_varMods_rmse$algorithm,
    meas = rep("PdI", times=length(df_lipid_varMods_rmse$algorithm)),
    normRMSE = df_lipid_varMods_rmse$normPdI_rmse,
    rsq = df_lipid_varMods_rsq$pdi_rsq
  ), # PdI
  data.frame(
    algorithm = df_lipid_varMods_rmse$algorithm,
    meas = rep("%EE", times=length(df_lipid_varMods_rmse$algorithm)),
    normRMSE = df_lipid_varMods_rmse$normEE_rmse,
    rsq = df_lipid_varMods_rsq$ee_rsq
  ) # %EE
)
df_lipid_varMod_heatmap$meas <- factor(df_lipid_varMod_heatmap$meas,
               levels=c("%EE", "PdI", "Diameter"))
#
df_lipid_varMod_heatmap <- df_lipid_varMod_heatmap |>
    mutate(algorithm = factor(algorithm, levels=algorithm_order_ranked))
p_lipid_varMod_heat_rmse <- ggplot(df_lipid_varMod_heatmap,
           aes(algorithm, meas, fill=normRMSE))+
  geom_tile()+
  ggtitle("Normalized RMSE")+
  labs(fill="Normalized\nRMSE")+
  scale_x_discrete(expand=c(0,0))+
  scale_y_discrete(expand=c(0,0))+
  scale_fill_viridis(option="D", limits=c(0,1))+
  theme(axis.title = element_blank())+
  coord_fixed()
p_lipid_varMod_heat_rsq <- ggplot(df_lipid_varMod_heatmap,
          aes(algorithm, meas, fill=rsq))+
  geom_tile()+
  ggtitle(expression(r^2~value))+
  labs(fill=expression(r^2~value))+
  scale_x_discrete(expand=c(0,0))+
  scale_y_discrete(expand=c(0,0))+
  scale_fill_viridis(option="B", limits=c(0,1))+
  theme(axis.title = element_blank())+
  coord_fixed()

#### PLGA NP =================================================================
df_pol_varMod_heatmap <- rbind(
  data.frame(
    algorithm = df_pol_varMods_rmse$algorithm,
    meas = rep("Diameter", times=length(df_pol_varMods_rmse$algorithm)),
    normRMSE = df_pol_varMods_rmse$normDiam_rmse,
    rsq = df_pol_varMods_rsq$diam_rsq
  ), # Diam
  data.frame(
    algorithm = df_pol_varMods_rmse$algorithm,
    meas = rep("PdI", times=length(df_pol_varMods_rmse$algorithm)),
    normRMSE = df_pol_varMods_rmse$normPdI_rmse,
    rsq = df_pol_varMods_rsq$pdi_rsq
  ), # PdI
  data.frame(
    algorithm = df_pol_varMods_rmse$algorithm,
    meas = rep("%EE", times=length(df_pol_varMods_rmse$algorithm)),
    normRMSE = df_pol_varMods_rmse$normEE_rmse,
    rsq = df_pol_varMods_rsq$ee_rsq
  ) # %EE
)
df_pol_varMod_heatmap$meas <- factor(df_pol_varMod_heatmap$meas,
             levels=c("%EE", "PdI", "Diameter"))
df_pol_varMod_heatmap <- df_pol_varMod_heatmap |>
    mutate(algorithm = factor(algorithm, levels=algorithm_order_ranked))
p_pol_varMod_heat_rmse <- ggplot(df_pol_varMod_heatmap,
         aes(algorithm, meas, fill=normRMSE))+
  geom_tile()+
  ggtitle("Normalized RMSE")+
  labs(fill="Normalized\nRMSE")+
  scale_x_discrete(expand=c(0,0))+
  scale_y_discrete(expand=c(0,0))+
  scale_fill_viridis(option="D", limits=c(0,1))+
  theme(axis.title = element_blank())+
  coord_fixed()
p_pol_varMod_heat_rsq <- ggplot(df_pol_varMod_heatmap,
        aes(algorithm, meas, fill=rsq))+
  geom_tile()+
  ggtitle(expression(r^2~value))+
  labs(fill=expression(r^2~value))+
  scale_x_discrete(expand=c(0,0))+
  scale_y_discrete(expand=c(0,0))+
  scale_fill_viridis(option="B", limits=c(0,1))+
  theme(axis.title = element_blank())+
  coord_fixed()

p_varMod_heatmaps <- p_lipid_varMod_heat_rmse/p_lipid_varMod_heat_rsq/#
    p_pol_varMod_heat_rmse/p_pol_varMod_heat_rsq
ggsave("figs/subFigs/varAlg_heatmaps.pdf", device="pdf", units=c("cm"),
     width=28, height=29, dpi=300)

# PERCENT ERROR PLOTS ========================================================
p_tot_pdi_diam <- ggplot()+
  geom_point(data=df_error,
             mapping=aes(perc_error_pdi, perc_error_diam,
                         colour=model), alpha=I(0.10))+
  geom_abline(slope=1, intercept=0, color="grey50", linetype=2)+
# geom_smooth(data=df_error,
#             mapping=aes(x=perc_error_pdi, y=perc_error_diam),
#             method="lm", colour="#00AFBB", fill="#cffcff")+
  geom_errorbar(data=df_summ_error,
                mapping=aes(x=mean_pdi_error, y=mean_diam_error,
                            xmin=mean_pdi_error-sd_pdi_error,
                            xmax=mean_pdi_error+sd_pdi_error,
                            color=model), alpha=I(0.33))+
  geom_errorbar(data=df_summ_error,
                mapping=aes(x=mean_pdi_error, y=mean_diam_error,
                            ymin=mean_diam_error-sd_diam_error,
                            ymax=mean_diam_error+sd_diam_error,
                            color=model), alpha=I(0.33))+
  geom_point(data=df_summ_error,
             mapping=aes(mean_pdi_error, mean_diam_error,
                fill=model), shape=21, size=2)+
  geom_smooth(data=df_summ_error,
              mapping=aes(x=mean_pdi_error, y=mean_diam_error),
              method="lm", colour="#FF5733", fill="#FF8166",
              linewidth=0.5)+
  scale_x_continuous(name="% PdI error", limits=c(-5,100),
                     breaks=seq(0,100, 25))+
  scale_y_continuous(name="% Diameter error", limits=c(-5,100),
                     breaks=seq(0,100, 25))+
  scale_fill_manual(values=palette)+
  scale_colour_manual(values=palette)+
  theme(aspect.ratio=1,
        panel.grid=element_blank(),
        panel.background=element_rect(colour="black", fill="white"),
        legend.key = element_rect(colour="white"),
        legend.title=element_blank())
ggsave("figs/Fig4_percError_pdi_diam.png", device="png", units=c("cm"),
       width=14, height=10, dpi=300)

# SEED AND % TRAINING DATA ===================================================
## Load and clean up data ====================================================
df_split <- read.csv("data/df_split.csv")
df_split_summ <- df_split |>
  group_by(train_perc, np_class, dataset, attr) |>
  summarize(#
    mean_rmse = mean(rmse),
    sd_rmse = sd(rmse),
    mean_rsq = mean(rsq),
    sd_rsq = sd(rsq)
  )

df_split_summ_lipid_diam <- df_split_summ[#
  which(df_split_summ$attr=="Diameter" & df_split_summ$np_class=="Lipid-based NP"),]
df_split_summ_lipid_diam <- na.omit(df_split_summ_lipid_diam)
df_split_summ_pol_diam <- df_split_summ[#
  which(df_split_summ$attr=="Diameter" & df_split_summ$np_class=="PLGA NP"),]
df_split_summ_pol_diam <- na.omit(df_split_summ_pol_diam)

## Seed/split plot ===========================================================
p_split_seed_rmse_lipid_diam <- ggplot()+
  geom_ribbon(data=df_split_summ_lipid_diam,
    mapping=aes(x = train_perc, ymin=mean_rmse-sd_rmse,
      ymax=mean_rmse+sd_rmse, fill=dataset),
    alpha=I(0.25))+
#  geom_point(data=df_split[which(df_split$np_class=="Lipid-based NP" &#
#    df_split$attr=="Diameter"),],
#    mapping=aes(train_perc, rmse, colour=dataset),#
#    alpha=I(0.5))+
  geom_line(data=df_split_summ_lipid_diam,
    mapping=aes(train_perc, mean_rmse,colour=dataset))+
  geom_point(data=df_split_summ_lipid_diam,
    mapping=aes(train_perc, mean_rmse, fill=dataset),
    shape=21, colour="#3e3e3e")+
  scale_x_continuous(name="% Training data")+
  scale_y_continuous(name="RMSE (nm)", limits=c(0,40))+
  labs(tag=bquote(bold("A")))+
  theme_bw()+
  theme(aspect.ratio=1,
        panel.grid=element_blank(),
        plot.title=element_text(hjust=0.5, size=10, face="bold"),
        axis.title.x=element_blank(),
        legend.title=element_blank(),
        legend.position="none",
        plot.tag.position=c(0.0,0.91),
        strip.text = element_text(face="bold"),
        strip.background=element_rect(colour="white", fill="white"))
p_split_seed_rsq_lipid_diam <- ggplot()+
  geom_ribbon(data=df_split_summ_lipid_diam,
    mapping=aes(x = train_perc, ymin=mean_rsq-sd_rsq,
      ymax=mean_rsq+sd_rsq, fill=dataset),
    alpha=I(0.25))+
  geom_line(data=df_split_summ_lipid_diam,
    mapping=aes(train_perc, mean_rsq,colour=dataset))+
  geom_point(data=df_split_summ_lipid_diam,
    mapping=aes(train_perc, mean_rsq, fill=dataset),
    shape=21, colour="#3e3e3e")+
  scale_x_continuous(name="% Training data")+
  scale_y_continuous(limits=c(0,1))+
  labs(y=bquote(r^2~value))+
  theme_bw()+
  theme(aspect.ratio=1,
        panel.grid=element_blank(),
        plot.title=element_text(hjust=0.5, size=10, face="bold"),
        axis.title.x=element_blank(),
        legend.title=element_blank(),
        legend.position="none",
        strip.text = element_text(face="bold"),
        strip.background=element_rect(colour="white", fill="white"))

p_split_seed_rmse_pol_diam <- ggplot()+
  geom_ribbon(data=df_split_summ_pol_diam,
    mapping=aes(x = train_perc, ymin=mean_rmse-sd_rmse,
      ymax=mean_rmse+sd_rmse, fill=dataset),
    alpha=I(0.25))+
  geom_line(data=df_split_summ_pol_diam,
    mapping=aes(train_perc, mean_rmse,colour=dataset))+
  geom_point(data=df_split_summ_pol_diam,
    mapping=aes(train_perc, mean_rmse, fill=dataset),
    shape=21, colour="#3e3e3e")+
  scale_x_continuous(name="% Training data")+
  scale_y_continuous(name="RMSE (nm)", limits=c(0,40))+
  labs(tag=bquote(bold("B")))+
  theme_bw()+
  theme(aspect.ratio=1,
        panel.grid=element_blank(),
        plot.title=element_text(hjust=0.5, size=10, face="bold"),
        legend.title=element_blank(),
        legend.position="none",
        plot.tag.position=c(0.0,0.91),
        strip.text = element_text(face="bold"),
        strip.background=element_rect(colour="white", fill="white"))
p_split_seed_rsq_pol_diam <- ggplot()+
  geom_ribbon(data=df_split_summ_pol_diam,
    mapping=aes(x = train_perc, ymin=mean_rsq-sd_rsq,
      ymax=mean_rmse+sd_rmse, fill=dataset),
    alpha=I(0.25))+
  geom_line(data=df_split_summ_pol_diam,
    mapping=aes(train_perc, mean_rsq,colour=dataset))+
  geom_point(data=df_split_summ_pol_diam,
    mapping=aes(train_perc, mean_rsq, fill=dataset),
    shape=21, colour="#3e3e3e")+
  scale_x_continuous(name="% Training data")+
  scale_y_continuous(limits=c(0,1))+
  labs(y=bquote(r^2~value))+
  theme_bw()+
  theme(aspect.ratio=1,
        panel.grid=element_blank(),
        plot.title=element_text(hjust=0.5, size=10, face="bold"),
        legend.title=element_blank(),
        legend.position="bottom",
        strip.text = element_text(face="bold"),
        strip.background=element_rect(colour="white", fill="white"))

p_splitSeed_comb <- (p_split_seed_rmse_lipid_diam+p_split_seed_rsq_lipid_diam)/#
  (p_split_seed_rmse_pol_diam+p_split_seed_rsq_pol_diam)
ggsave("figs/subFigs/split_training.pdf", device="pdf", units=c("cm"),
     width=16, height=18, dpi=300)

# MODEL PERFORMANCE - CORRELATION PLOTS ======================================
## TRAINING DATA =============================================================
### LIPID - DIAMETER =========================================================
p_diamCorr_lipid <- result_diam_lipid[#
            which(result_diam_lipid$dataset == "training data"),] |>
    ggplot()+
        labs(tag=bquote(bold("A")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_diam, hdiam_nm), fill="#58DEE0",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_diam, hdiam_nm), alpha=I(0.5),
           shape=21, fill="#58DEE0", colour="black")+
        scale_x_continuous(name = "Predicted Diameter (nm)",
            limits = c(0, 300))+
        scale_y_continuous(name = "Measured Diameter (nm)",
            limits = c(0, 300))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
              strip.text=element_text(face="bold"),
              strip.background=element_rect(fill="grey95",colour="black"),
              plot.tag.position=c(0.02,0.97),
              panel.grid=element_blank())
p_diamCorr_lipid <- p_diamCorr_lipid + geom_text(data = df_diamRSQ_lipid[#
    which(df_diamRSQ_lipid$dataset == "training data"),],
    mapping = aes(-Inf, 300,
      label = lab), hjust=-0.20, parse=TRUE)

### LIPID - PDI ==========================================================
p_pdiCorr_lipid <- result_pdi_lipid[#
            which(result_pdi_lipid$dataset == "training data"),] |>
    ggplot()+
    labs(title=bquote(bold("PdI")))+
    geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
    geom_smooth(aes(pred_pdi, pdi), fill="#58DEE0", linewidth=0.5,
        method="lm")+
    geom_point(aes(pred_pdi, pdi), fill="#58DEE0", shape=21, alpha=I(0.5))+
    scale_x_continuous(name = "Predicted PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    scale_y_continuous(name = "Measured PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    theme_bw()+
    theme(aspect.ratio=1,
          plot.title=element_text(hjust=0.5),
          legend.position="none",
    panel.grid=element_blank())
p_pdiCorr_lipid <- p_pdiCorr_lipid +
  geom_text(data = df_pdiRSQ_lipid[#
    which(df_pdiRSQ_lipid$dataset == "training data"),],
    mapping = aes(pred_pdi, 1.0, label = lab),
            hjust=0, parse=TRUE)

### LIPID - % EE =========================================================
p_eeCorr_lipid <- result_ee_lipid[#
    which(result_ee_lipid$dataset == "training data"),] |>
        ggplot()+
        labs(title = bquote(bold("%EE")),
       tag=bquote(bold("Lipid-based Nanoparticles")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_ee, percEE), fill="#58DEE0",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_ee, percEE),
                   shape=21, fill="#58DEE0", alpha=I(0.5))+
        scale_x_continuous(name = "Predicted %EE",
            limits = c(0, 120), breaks=seq(0,120,20))+
        scale_y_continuous(name = "Measured %EE",
            limits = c(0, 120), breaks=seq(0,120,20))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
        plot.tag = element_text(angle=-90),
              plot.tag.position=c(1.05,0.50),
        plot.title = element_text(hjust=0.5),
        panel.grid=element_blank())
p_eeCorr_lipid <- p_eeCorr_lipid +
    geom_text(data = df_eeRSQ_lipid[#
    which(df_eeRSQ_lipid$dataset == "training data"),],
    mapping = aes(-Inf, 120, label = lab),
    hjust=-0.20, parse=TRUE)

### PLGA - DIAMETER ======================================================
p_diamCorr_pol <- result_diam_pol[#
            which(result_diam_pol$dataset == "training data"),] |>
    ggplot()+
        labs(tag=bquote(bold("B")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_diam, hdiam_nm), fill="chartreuse3",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_diam, hdiam_nm), alpha=I(0.5),
           shape=21, fill="chartreuse3", colour="black")+
        scale_x_continuous(name = "Predicted Diameter (nm)",
            limits = c(0, 300))+
        scale_y_continuous(name = "Measured Diameter (nm)",
            limits = c(0, 300))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
              strip.text=element_text(face="bold"),
              strip.background=element_rect(fill="grey95",colour="black"),
              plot.tag.position=c(0.02,0.97),
              panel.grid=element_blank())
p_diamCorr_pol <- p_diamCorr_pol + geom_text(data = df_diamRSQ_pol[#
    which(df_diamRSQ_pol$dataset == "training data"),],
    mapping = aes(-Inf, 300, label = lab), 
    hjust=-0.20, parse=TRUE)

### PLGA - PDI ===========================================================
p_pdiCorr_pol <- result_pdi_pol[#
  which(result_pdi_pol$dataset == "training data"),] |>
    ggplot()+
    geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
    geom_smooth(aes(pred_pdi, pdi), fill="chartreuse3", linewidth=0.5,
        method="lm")+
    geom_point(aes(pred_pdi, pdi), fill="chartreuse3", shape=21, alpha=I(0.5))+
    scale_x_continuous(name = "Predicted PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    scale_y_continuous(name = "Measured PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    theme_bw()+
    theme(aspect.ratio=1,
          plot.title=element_text(hjust=0.5),
          legend.position="none",
    panel.grid=element_blank())
p_pdiCorr_pol <- p_pdiCorr_pol +
  geom_text(data = df_pdiRSQ_pol[#
    which(df_pdiRSQ_pol$dataset == "training data"),],
    mapping = aes(pred_pdi, 1.0, label = lab),
            hjust=0, parse=TRUE)

### PLGA - % EE ==========================================================
p_eeCorr_pol <- result_ee_pol[#
    which(result_ee_pol$dataset == "training data"),] |>
        ggplot()+
        labs(tag=bquote(bold("PLGA Nanoparticles")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_ee, percEE), fill="chartreuse3",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_ee, percEE),
                   shape=21, fill="chartreuse", alpha=I(0.5))+
        scale_x_continuous(name = "Predicted %EE",
            limits = c(-1, 100), breaks=seq(0,100,20))+
        scale_y_continuous(name = "Measured %EE",
            limits = c(-1, 100), breaks=seq(0,100,20))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
        plot.tag = element_text(angle=-90),
              plot.tag.position=c(1.05,0.50),
        plot.title = element_text(hjust=0.5),
        panel.grid=element_blank())
p_eeCorr_pol <- p_eeCorr_pol +
    geom_text(data = df_eeRSQ_pol[#
    which(df_eeRSQ_pol$dataset == "training data"),],
    mapping = aes(-Inf, max(result_ee_pol[#
      which(result_ee_pol$dataset == "training data"),
      c("percEE","pred_ee")]), label = lab),
    hjust=-0.2, parse=TRUE)

## All correlation plots combined
### Required '08_Figures.R' to be run
p_corrCombo <- ((p_diamCorr_lipid+labs(title=bquote(bold("Diameter")))+
                 theme(plot.title=element_text(hjust=0.5)))+
                p_pdiCorr_lipid+p_eeCorr_lipid)/#
              (p_diamCorr_pol+p_pdiCorr_pol+p_eeCorr_pol)
ggsave("figs/Fig6_corrPlot_training_combo.png", device="png", units=c("cm"),
  width=24, height=16, dpi=300)


## TESTING DATA ==============================================================
### LIPID - DIAMETER ==========================================================
p_diamCorr_lipid_test <- result_diam_lipid[#
            which(result_diam_lipid$dataset == "testing data"),] |>
    ggplot()+
        labs(tag=bquote(bold("A")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_diam, hdiam_nm), fill="#58DEE0",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_diam, hdiam_nm), alpha=I(0.5),
           shape=21, fill="#58DEE0", colour="black")+
        scale_x_continuous(name = "Predicted Diameter (nm)",
            limits = c(0, max(result_diam_lipid[which(result_diam_lipid$dataset == "testing data"),c("hdiam_nm","pred_diam")])))+
        scale_y_continuous(name = "Measured Diameter (nm)",
            limits = c(0, max(result_diam_lipid[which(result_diam_lipid$dataset == "testing data"),c("hdiam_nm","pred_diam")])))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
              strip.text=element_text(face="bold"),
              strip.background=element_rect(fill="grey95",colour="black"),
              plot.tag.position=c(0.02,0.97),
              plot.title=element_text(hjust=0.5),
        panel.grid=element_blank())
p_diamCorr_lipid_test <- p_diamCorr_lipid_test + geom_text(data = df_diamRSQ_lipid[#
    which(df_diamRSQ_lipid$dataset == "testing data"),],
    mapping = aes(-Inf, max(result_diam_lipid[#
      which(result_diam_lipid$dataset == "testing data"),
        c("hdiam_nm","pred_diam")]),
      label = lab), hjust=-0.20, parse=TRUE)

### LIPID - PDI ==========================================================
p_pdiCorr_lipid_test <- result_pdi_lipid[#
            which(result_pdi_lipid$dataset == "testing data"),] |>
    ggplot()+
    labs(title=bquote(bold("PdI")))+
    geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
    geom_smooth(aes(pred_pdi, pdi), fill="#58DEE0", linewidth=0.5,
        method="lm")+
    geom_point(aes(pred_pdi, pdi), fill="#58DEE0", shape=21, alpha=I(0.5))+
    scale_x_continuous(name = "Predicted PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    scale_y_continuous(name = "Measured PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    theme_bw()+
    theme(aspect.ratio=1,
          plot.title=element_text(hjust=0.5),
          legend.position="none",
    panel.grid=element_blank())
p_pdiCorr_lipid_test <- p_pdiCorr_lipid_test +
  geom_text(data = df_pdiRSQ_lipid[#
    which(df_pdiRSQ_lipid$dataset == "testing data"),],
    mapping = aes(pred_pdi, 1.0, label = lab),
            hjust=0, parse=TRUE)

### LIPID - % EE =========================================================
p_eeCorr_lipid_test <- result_ee_lipid[#
    which(result_ee_lipid$dataset == "testing data"),] |>
        ggplot()+
        labs(title = bquote(bold("%EE")),
       tag=bquote(bold("Lipid-based Nanoparticles")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_ee, percEE), fill="#58DEE0",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_ee, percEE),
                   shape=21, fill="#58DEE0", alpha=I(0.5))+
        scale_x_continuous(name = "Predicted %EE",
            limits = c(0, 120), breaks=seq(0,120,20))+
        scale_y_continuous(name = "Measured %EE",
            limits = c(0, 120), breaks=seq(0,120,20))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
        plot.tag = element_text(angle=-90),
              plot.tag.position=c(1.05,0.50),
        plot.title = element_text(hjust=0.5),
        panel.grid=element_blank())
p_eeCorr_lipid_test <- p_eeCorr_lipid_test +
    geom_text(data = df_eeRSQ_lipid[#
    which(df_eeRSQ_lipid$dataset == "testing data"),],
    mapping = aes(-Inf, 120, label = lab),
    hjust=-0.20, parse=TRUE)


## All training correlation plots combined
### Required '08_Figures.R' to be run
p_corrCombo <- ((p_diamCorr_lipid+labs(title=bquote(bold("Diameter")))+
                 theme(plot.title=element_text(hjust=0.5)))+
                p_pdiCorr_lipid+p_eeCorr_lipid)/#
              (p_diamCorr_pol+p_pdiCorr_pol+p_eeCorr_pol)
ggsave("figs/Fig6_corrPlot_training_combo.png", device="png", units=c("cm"),
  width=24, height=16, dpi=300)


### PLGA - DIAMETER ======================================================
p_diamCorr_pol_test <- result_diam_pol[#
            which(result_diam_pol$dataset == "testing data"),] |>
    ggplot()+
        labs(tag=bquote(bold("B")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_diam, hdiam_nm), fill="chartreuse3",
          linewidth=0.5, method="lm")+
        geom_point(mapping=aes(pred_diam, hdiam_nm),
          shape=21, fill="chartreuse3", colour="black")+
        scale_x_continuous(name = "Predicted Diameter (nm)",
            limits = c(0, 200))+
        scale_y_continuous(name = "Measured Diameter (nm)",
            limits = c(0, 200))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
              strip.text=element_text(face="bold"),
              strip.background=element_rect(fill="grey95",colour="black"),
              plot.tag.position=c(0.02,0.97),
              plot.title=element_text(hjust=0.5),
        panel.grid=element_blank())
p_diamCorr_pol_test <- p_diamCorr_pol_test + geom_text(data = df_diamRSQ_pol[#
    which(df_diamRSQ_pol$dataset == "testing data"),],
    mapping = aes(-Inf, 200,
      label = lab), hjust=-0.20, parse=TRUE)

### PLGA - PDI ===========================================================
p_pdiCorr_pol_test <- result_pdi_pol[#
  which(result_pdi_pol$dataset == "testing data"),] |>
    ggplot()+
    geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
    geom_smooth(aes(pred_pdi, pdi), fill="chartreuse3", linewidth=0.5,
        method="lm")+
    geom_point(aes(pred_pdi, pdi), fill="chartreuse3", shape=21, alpha=I(0.5))+
    scale_x_continuous(name = "Predicted PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    scale_y_continuous(name = "Measured PdI",
                       limits=c(0.0, 1.0),
                       breaks=seq(0,1,0.2))+
    theme_bw()+
    theme(aspect.ratio=1,
          plot.title=element_text(hjust=0.5),
          legend.position="none",
    panel.grid=element_blank())
p_pdiCorr_pol_test <- p_pdiCorr_pol_test +
  geom_text(data = df_pdiRSQ_pol[#
    which(df_pdiRSQ_pol$dataset == "testing data"),],
    mapping = aes(pred_pdi, 1.0, label = lab),
            hjust=0, parse=TRUE)


### PLGA - % EE ==========================================================
p_eeCorr_pol_test <- result_ee_pol[#
    which(result_ee_pol$dataset == "testing data"),] |>
        ggplot()+
        labs(tag=bquote(bold("PLGA Nanoparticles")))+
        geom_abline(slope=1, intercept=0, linetype=2, colour="grey75")+
        geom_smooth(aes(pred_ee, percEE), fill="chartreuse3",
                    linewidth=0.5, method="lm")+
        geom_point(aes(pred_ee, percEE),
                   shape=21, fill="chartreuse", alpha=I(0.5))+
        scale_x_continuous(name = "Predicted %EE",
            limits = c(-1, 100), breaks=seq(0,100,20))+
        scale_y_continuous(name = "Measured %EE",
            limits = c(-1, 100), breaks=seq(0,100,20))+
        theme_bw()+
        theme(aspect.ratio=1,
              legend.position="none",
        plot.tag = element_text(angle=-90),
              plot.tag.position=c(1.05,0.50),
        plot.title = element_text(hjust=0.5),
        panel.grid=element_blank())
p_eeCorr_pol_test <- p_eeCorr_pol_test +
    geom_text(data = df_eeRSQ_pol[#
    which(df_eeRSQ_pol$dataset == "testing data"),],
    mapping = aes(-Inf, max(result_ee_pol[#
      which(result_ee_pol$dataset == "training data"),
      c("percEE","pred_ee")]), label = lab),
    hjust=-0.2, parse=TRUE)

## Combined all
p_corrCombo_test <- ((p_diamCorr_lipid_test+labs(title=bquote(bold("Diameter")))+
                 theme(plot.title=element_text(hjust=0.5)))+
                p_pdiCorr_lipid_test+p_eeCorr_lipid_test)/#
              (p_diamCorr_pol_test+p_pdiCorr_pol_test+p_eeCorr_pol_test)
ggsave("figs/Fig7_corrPlot_test_combo.png", device="png", units=c("cm"),
  width=24, height=16, dpi=300)


# SHAP Plots =================================================================
## Lipid plots -- Bee ========================================================
p_shapbee_diam_lipid <- sv_importance(shap_diam_lipid, kind="bee", alpha=0.45)+
    labs(title=bquote("d"[italic("H")]),
       tag=bquote(bold("A  Lipid-based Nanoparticles")))+
    scale_colour_viridis_c()+
    theme_bw()+
    theme(aspect.ratio=1,
        plot.title = element_text(hjust = 0.5),
        plot.tag.position=c(0.305,1.05),
        legend.position="none",
        panel.grid=element_blank())

p_shapbee_pdi_lipid <- sv_importance(shap_pdi_lipid, kind="bee", alpha=0.45)+
    labs(title="PdI")+
    scale_colour_viridis_c()+
    theme_bw()+
    theme(aspect.ratio=1,
        plot.title = element_text(hjust = 0.5),
        legend.position="none",
        panel.grid=element_blank())

p_shapbee_ee_lipid <- sv_importance(shap_ee_lipid, kind="bee", alpha=0.45)+
    labs(title="%EE")+
    scale_colour_viridis_c()+
    theme_bw()+
    theme(aspect.ratio=1,
        plot.title = element_text(hjust = 0.5),
        panel.grid=element_blank())+
    labs(colour="Normalized\nfeature value")

## PLGA plots -- Bee =========================================================
p_shapbee_diam_pol <- sv_importance(shap_diam_pol, kind="bee", alpha=0.45)+
    labs(#title=bquote("d"[italic("H")]),
#      y="PLGA Nanoparticles",
       tag=bquote(bold("B  PLGA Nanoparticles")))+
    scale_colour_viridis_c()+
    theme_bw()+
    theme(aspect.ratio=1,
        plot.tag.position=c(0.23,1.05),
        legend.position="none",
        panel.grid=element_blank())

p_shapbee_pdi_pol <- sv_importance(shap_pdi_pol, kind="bee", alpha=0.45)+
#   labs(title="PdI")+
    scale_colour_viridis_c()+
    theme_bw()+
    theme(aspect.ratio=1,
        legend.position="none",
        panel.grid=element_blank())

p_shapbee_ee_pol <- sv_importance(shap_ee_pol, kind="bee", alpha=0.45)+
#   labs(title="%EE")+
    scale_colour_viridis_c()+
    theme_bw()+
    theme(aspect.ratio=1,
        panel.grid=element_blank())+
    labs(colour="Normalized\nfeature value")

## Combined plot
p_combSHAP <- (p_shapbee_diam_lipid+p_shapbee_pdi_lipid+p_shapbee_ee_lipid)/#
  (p_shapbee_diam_pol+p_shapbee_pdi_pol+p_shapbee_ee_pol)
ggsave("figs/Fig8_plot_SHAP_comb.png", device="png", units=c("cm"),
     width=38, height=22, dpi=300)
system2(command = "magick",
    args    = c('figs/Fig8_plot_SHAP_comb.png', "-trim",
          'figs/Fig8_plot_SHAP_comb.png')
        )


# GENERATIVE AI COMPARISON PLOT ==============================================
p_ai <- ggplot()+
  facet_wrap(~class)+
# Diameter plot
  geom_bar(data = genAI_summ,
           mapping=aes(alg, avgDiam, fill=group),
           colour="#5a5a5a",
           stat = "identity", position = position_dodge())+
  #geom_col(data = genAI_summ,
  # mapping=aes(interaction(alg,group), avgDiam, fill=group),
  # colour = "#5A5A5A")+
  geom_errorbar(data = genAI_summ,
          mapping=aes(alg, ymin=avgDiam-sdDiam,
                ymax=avgDiam+sdDiam),
          colour="#3A3A3A", width=0.1)+
  geom_hline(yintercept=100, linetype=2, colour="#5A5A5A")+
# PdI plot
  geom_errorbar(data=genAI_summ,
          mapping=aes(x=alg, ymin=avgPdI/scalar-sdPdI/scalar,
                ymax=avgPdI/scalar+sdPdI/scalar),
          width=0.1)+
  geom_point(data=genAI_summ, shape=21, fill="white", colour="black",
         mapping=aes(alg, avgPdI/scalar),
         size=2)+
# Theme/formatting
  scale_y_continuous(name = "Diameter (nm)",
    limit=c(0,210), breaks=seq(0,210, 40),
      sec.axis=sec_axis(~.*scalar, name="PdI", breaks=seq(0,1.2,0.2)))+
  scale_fill_manual(values=c(#
    "#4f6cfd", # DeepSeek
    "#9177C7", # Gemini
    "#74AA9C", # ChatGPT
    "#faa61a" ))+ # Dept. Pharmacy
  theme_bw()+
  theme(aspect.ratio = 0.66,
#   panel.grid = element_blank(),
    axis.title.x=element_blank(),
#   axis.text.x = element_blank(),
    strip.text = element_text(face="bold"),
    strip.background=element_blank(),
    legend.title = element_blank(),
    legend.position="bottom")
p_ai <- p_ai + geom_text(data=annText, mapping=aes(alg, avgDiam),
         label="N.A.")
ggsave("figs/Fig9_genAI.png", device="png", units=c("cm"),
       width=24, height=10, dpi=300)
