#!/usr/bin/env Rscript 

# ========================================================================================
# === Program to analyze RAD coverage output of count_restr_enz_reads.sh =================
# ========================================================================================

rad.cov.file = commandArgs(trailingOnly = TRUE)[1]

final.bams = Sys.glob("results/*.passed.realn.bam")
inds = gsub("results/([^\\.]+).*", "\\1", final.bams, perl=TRUE)

rad.cov = read.table(rad.cov.file)
names(rad.cov) = c("chr", "start", "end", inds)

# ----------------------------------------------------------------------------------------
# --- Total number of RAD tags -----------------------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- Total number of RAD tags -------------------------------------------------\n")

num.rad.tags = dim(rad.cov)[1]

cat(paste("Total number of RAD tags:", num.rad.tags), "\n")

# ----------------------------------------------------------------------------------------
# --- Average reads per RAD tag per individual -------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("\n# --- Avg. number of reads per RADtag (over all possible RADtags) --------------\n")

avg.cov = as.data.frame(colMeans(rad.cov[,4:(3+length(inds))]))
names(avg.cov) = "Average_reads_per_RADtag"

print(avg.cov)

# ----------------------------------------------------------------------------------------
# --- Tags with at least N reads ---------------------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("\n# --- Tags with at least N reads -----------------------------------------------\n")

cov.thresholds = c(1, 3, 5, 10, 20, 50, 100, 1000)

all.passing = data.frame()

for (i in 1:length(cov.thresholds)) {

	passing = colSums(rad.cov[,4:(3+length(inds))] >= cov.thresholds[i])
	passing.perc = signif(passing / num.rad.tags, digits=2)
	
	all.passing = rbind(all.passing, passing)
}

names(all.passing) = inds
row.names(all.passing) = paste(cov.thresholds, "+ reads", sep="")

print(all.passing)

