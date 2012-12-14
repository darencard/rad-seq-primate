#!/usr/bin/env Rscript 

# ========================================================================================
# === Program to gather data needed for paper ============================================
# ========================================================================================

inds = c("female12", "Cebus", "Tgelada871162", "P_trog", "H_sapiens")
inds_mapped = c("P_trog", "H_sapiens")

# ----------------------------------------------------------------------------------------
# --- READS: Reads per individual: -------------------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- READS: Reads per individual: -------------------------------------------------------\n")

total_raw_reads = 0;

for(i in 1:length(inds)) {
	cmd.read1 = paste ("wc -l data/", inds[i], ".read1.fastq | cut -d' ' -f 1", sep="");
	reads.read1 = as.numeric(system(cmd.read1, intern=TRUE)) / 4;

	cmd.readSE = paste ("wc -l data/", inds[i], "_SE.fastq | cut -d' ' -f 1", sep="");
	reads.readSE = as.numeric(system(cmd.readSE, intern=TRUE)) / 4;
	
	reads = reads.read1 + reads.readSE
	
	# Keep track of all reads from all individuals
	total_raw_reads = total_raw_reads + reads
	
	cat (paste(inds[i], " - individual raw reads:\t", reads, "\n", sep=""));
}

# ----------------------------------------------------------------------------------------
# --- READS: Total sequenced reads in all samples ----------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- READS: Total sequenced reads in all samples -----------------------------------------------\n")

cat (paste(total_raw_reads, "\n"))

# ----------------------------------------------------------------------------------------
# --- STACKS: Filtered Reads per individual ---------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- STACKS: Filtered Reads per individual: -----------------------------------------------------\n")

total_flt_reads = 0;

for(i in 1:length(inds)) {
	cmd = paste ("wc -l all_primate/", inds[i], ".CLEAN.fastq | cut -d' ' -f 1", sep="");
	ind_flt_reads = as.numeric(system(cmd, intern=TRUE)) / 4;

	# Keep track of all reads from all individuals
	total_flt_reads = total_flt_reads + ind_flt_reads
	
	cat (paste(inds[i], " - individual's reads:\t", ind_flt_reads, "\n", sep=""));
}

# ----------------------------------------------------------------------------------------
# --- STACKS: Filtered Reads Total -------------------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- STACKS: Filtered Reads Total -------------------------------------------------------\n")

cat (paste(total_flt_reads, "\n"))

# ----------------------------------------------------------------------------------------
# --- STACKS: Mean merged cov. depth and SD -----------------------------------------------------
# ----------------------------------------------------------------------------------------

cat("# --- STACKS: Mean merged cov. depth -----------------------------------------------------\n");

for(i in 1:length(inds)) {
	cmd.mean = paste ("cat stacks_output/ustacks_", inds[i], ".e* | grep 'Mean merged coverage depth' | cut -d' ' -f 8 | cut -d';' -f1", sep="");
	ind.mean = as.numeric(system(cmd.mean, intern=TRUE));

	cmd.sd = paste ("cat stacks_output/ustacks_", inds[i], ".e* | grep 'Mean merged coverage depth' | cut -d' ' -f 11 | cut -d';' -f1", sep="");
	ind.sd = as.numeric(system(cmd.sd, intern=TRUE));

	cat (paste(inds[i], " - individual's Mean merged cov. depth:\t", ind.mean, " (+/- ", ind.sd, ")\n", sep=""));
}

# ----------------------------------------------------------------------------------------
# --- STACKS: Number of stacks -----------------------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- STACKS: Number of stacks -----------------------------------------------------------\n");

total_stacks = 0;

for(i in 1:length(inds)) {
	cmd.numstacks = paste ("cat stacks_output/ustacks_", inds[i], ".e* | grep 'stacks merged into' | sed -e 's/.*stacks merged into \\([0-9]*\\) stacks.*/\\1/'", sep="");
	ind.numstacks = as.numeric(system(cmd.numstacks, intern=TRUE));

	cat (paste(inds[i], " - individual's number of stacks:\t", ind.numstacks, "\n", sep=""));
	
	total_stacks = total_stacks + ind.numstacks
}

# ----------------------------------------------------------------------------------------
# --- STACKS: Total stacks in all samples ----------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- STACKS: Total stacks in all samples -----------------------------------------------\n")

cat (paste(total_stacks, "\n"))

# ----------------------------------------------------------------------------------------
# --- STACKS: Number of SNPs -----------------------------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- STACKS: Number of SNPs -----------------------------------------------------------\n");

for(i in 1:length(inds)) {
	cmd.numsnps = paste ("wc -l all_primate/stacks/", inds[i], ".CLEAN.snps.tsv | cut -d ' ' -f 1", sep="");
	ind.numsnps = as.numeric(system(cmd.numsnps, intern=TRUE));

	cat (paste(inds[i], " - individual's number of SNPs:\t", ind.numsnps, "\n", sep=""));
	
}

# ----------------------------------------------------------------------------------------
# --- STACKS: Total SNPs in all samples ----------------------------------------
# ----------------------------------------------------------------------------------------

cat ("# --- STACKS: Total SNPs in all samples -----------------------------------------------\n")

# Assumes the last number is the shared SNP count

total_stack_snps = as.numeric(system("cat all_primate/stacks/batch_1.vcf.stats.txt | grep 'snp_count' | tail -n1 | cut -d '>' -f2 | cut -d ',' -f1", intern=TRUE));

cat (paste(total_stack_snps, "\n"))




