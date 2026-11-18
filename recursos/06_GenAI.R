# Load data frame
genAI <- read.csv("data/data_genAI_v_mfNP.csv", header=TRUE)
# Replace invisible character in string class
genAI$class <- gsub("\\+AC0", "", genAI$class)
genAI$alg <- gsub("\\+AC0", "", genAI$alg)
# Rename Gemini model
genAI[which(genAI$alg == "Gemini Flash 2.0"), "alg"] = "Gemini\nFlash 2.0"
genAI[which(genAI$alg == "DeepSeek-V3"), "alg"] = "DeepSeek\nV3"
genAI[which(genAI$alg == "GPT-3.5"), "alg"] = "GPT\n3.5"
genAI[which(genAI$alg == "GPT-4o"), "alg"] = "GPT\n4o"

# Summary data frame
genAI_summ <- genAI |>
    group_by(class, group, alg) |>
    summarize(avgDiam = mean(diam),
          sdDiam = sd(diam),
          avgPdI = mean(pdi),
          sdPdI = sd(pdi))


# The scalar is a divisor to put the PdI and diameter plots on the same scale.
# Since the maximum diameter is set here to 200 nm and the maximum PdI
# value is 1, we need to create a multiplier so that the PdI values are on a
# similar scale. Therefore, every value plotted on the PdI scale needs to be
# multiplied by the scalar
scalar <- 1/200

annText <- data.frame(class="PLGA Nanoparticles",
            alg="GPT\n3.5",
            avgDiam=5)

# Set order of data
genAI$alg <- factor(genAI$alg,#
  levels=c("DeepSeek\nV3", "Bard", "Gemini\nFlash 2.0", "GPT\n3.5", "GPT\n4o", "MicrofluidicML"))
genAI_summ$alg <- factor(genAI_summ$alg,#
  levels=c("DeepSeek\nV3", "Bard", "Gemini\nFlash 2.0", "GPT\n3.5", "GPT\n4o", "MicrofluidicML"))
genAI$group = factor(genAI$group, levels=c("DeepSeek", "Google", "OpenAI", "MicrofluidicML"))
genAI_summ$group = factor(genAI_summ$group, levels=c("DeepSeek", "Google", "OpenAI", "MicrofluidicML"))
