# -------------------------------------------------------------------------------------- #
# --- Makefile to run RADseq pipeline. 
# --- Called by the executable shell script, full_analysis
# -------------------------------------------------------------------------------------- #

# Get user editable variables
include config.mk

GENOME_DIR=$(dir ${GENOME_FA})

# Output files of BWA index. None of these variables are exported since they begin with "_"
_BWA_INDEX_ENDINGS = .amb .ann .bwt .pac .sa
_PROTO_BWA_INDEX = $(addprefix ${GENOME_FA}, ${BWA_INDEX_ENDINGS})
_BWA_INDEX = $(subst .fa,,${PROTO_BWA_INDEX})

# Steps. Can be called one-by-one with something like, make index_genome
# --- preliminary_steps
index_genome : ${GENOME_FA}i ${_BWA_INDEX}
# --- pre_aln_analysis_steps:
fastqc : reports/${IND_ID}.read1.stats.zip reports/${IND_ID}.read2.stats.zip
# --- alignment_steps
align : results/${IND_ID}.read1.bwa.${GENOME_NAME}.sai
sampe : results/${IND_ID}.bwa.${GENOME_NAME}.sam
sam2bam : results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam
sort_and_index_bam : results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam.sorted.bam.bai
get_alignment_stats : reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.txt
# --- post_alignment_filtering_steps
fix_mate_pairs : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.txt
filter_unmapped : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.bam.bai reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.flt.txt
remove_dups : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.bam.bai reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.flt.nodup.txt
add_read_groups : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.RG.bam
filter_bad_qual : results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam.bai reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.passed.txt
# --- snp_calling_steps
local_realign_targets : results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam.list
local_realign : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.passed.realn.txt
call_snps : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.raw.bcf
filter_snps : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.flt.vcf
get_snp_stats : reports/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.flt.vcf.stats.txt
#call_consensus : results/${IND_ID}.bwa.${GENOME_NAME}.consensus.fq.gz

# Group steps together
preliminary_steps : index_genome
pre_aln_analysis_steps : fastqc
alignment_steps : align sampe sam2bam sort_and_index_bam get_alignment_stats
post_alignment_filtering_steps : fix_mate_pairs filter_unmapped remove_dups add_read_groups filter_bad_qual
snp_calling_steps : local_realign_targets local_realign call_snps filter_snps get_snp_stats #call_consensus

all : preliminary_steps pre_aln_analysis_steps alignment_steps post_alignment_filtering_steps snp_calling_steps 

# Hack to be able to export Make variables to child scripts
# Don't export variables from make that begin with non-alphanumeric character
# After that, underscores are OK
MAKE_ENV := $(shell echo '$(.VARIABLES)' | awk -v RS=' ' '/^[a-zA-Z0-9][a-zA-Z0-9_]+$$/')
SHELL_EXPORT := $(foreach v,$(MAKE_ENV),$(v)='$($(v))')

# ====================================================================================== #
# -------------------------------------------------------------------------------------- #
# --- Preliminary Steps
# -------------------------------------------------------------------------------------- #
# ====================================================================================== #

# -------------------------------------------------------------------------------------- #
# --- Index genome
# -------------------------------------------------------------------------------------- #

# The .fai output of samtools depends on the genome, BWA, samtools, & index_genome.sh
${GENOME_FA}i : ${GENOME_FA} #${BWA}/* ${SAMTOOLS}/* #scripts/index_genome.sh
	@echo "# === Indexing genome =============================================== #";
	${SHELL_EXPORT} ./scripts/index_genome.sh ${GENOME_FA};
	@sleep 2
	@touch ${GENOME_FA}i ${_BWA_INDEX}

# The output files of bwa depend on the output of samtools.
# A hack to deal with the problem make has with multiple targets dependent on one rule
# See for details:
# http://www.cmcrossroads.com/ask-mr-make/12908-rules-with-multiple-outputs-in-gnu-make
${_BWA_INDEX} : ${GENOME_FA}i
	
# ====================================================================================== #
# -------------------------------------------------------------------------------------- #
# --- Analyze reads
# -------------------------------------------------------------------------------------- #
# ====================================================================================== #

# -------------------------------------------------------------------------------------- #
# --- Analyze reads with FastQC. Total sequence bp, Maximum possible sequence depth
# -------------------------------------------------------------------------------------- #

# FastQC reports depend on read files, FastQC, and run_fastqc.sh
reports/${IND_ID}.read1.stats.zip : ${READ1} ${FASTQC}/* #scripts/run_fastqc.sh
	@echo "# === Analyzing quality of reads (1st pair) before filtering ================== #";
	${SHELL_EXPORT} ./scripts/run_fastqc.sh ${READ1} ${IND_ID}.read1.stats;
reports/${IND_ID}.read2.stats.zip : ${READ2} ${FASTQC}/* #scripts/run_fastqc.sh
	@echo "# === Analyzing quality of reads (2nd pair) before filtering ================== #";
	${SHELL_EXPORT} ./scripts/run_fastqc.sh ${READ2} ${IND_ID}.read2.stats;
	
# ====================================================================================== #
# -------------------------------------------------------------------------------------- #
# --- Mapping to reference genomes
# -------------------------------------------------------------------------------------- #
# ====================================================================================== #

# -------------------------------------------------------------------------------------- #
# --- Align reads to genome with BWA
# -------------------------------------------------------------------------------------- #

# Alignment output (*.sai) depends on bwa, the filtered reads FASTAs, the genome (index), and align.sh
# Using the first read as a stand in for the both 
results/${IND_ID}.read1.bwa.${GENOME_NAME}.sai : ${BWA}/* ${READ1} ${READ2} ${GENOME_FA}i #scripts/align.sh
	@echo "# === Aligning reads to genome ========================================== #";
	${SHELL_EXPORT} ./scripts/align.sh ${GENOME_FA} ${GENOME_NAME};

# Read 2 depends on read 1
results/${IND_ID}.read2.bwa.${GENOME_NAME}.sai : results/${IND_ID}.read1.bwa.${GENOME_NAME}.sai

# -------------------------------------------------------------------------------------- #
# --- Run sampe to generate SAM files
# -------------------------------------------------------------------------------------- #

# sampe output (*.sam) depends on *.sai files and sampe.sh
# Using the first read as a stand in for the both
results/${IND_ID}.bwa.${GENOME_NAME}.sam : results/${IND_ID}.read1.bwa.${GENOME_NAME}.sai #scripts/sampe.sh
	@echo "# === Combining reads to make SAM file ======================= #";
	${SHELL_EXPORT} ./scripts/sampe.sh ${GENOME_FA} ${GENOME_NAME};

# -------------------------------------------------------------------------------------- #
# --- Convert SAM file to BAM file
# -------------------------------------------------------------------------------------- #

# BAM file depends on SAM file, samtools, genome .fai index, and scripts/sam2bam.sh
results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam : results/${IND_ID}.bwa.${GENOME_NAME}.sam ${SAMTOOLS}/* ${GENOME_FA}i #scripts/sam2bam.sh
	@echo "# === Converting SAM file to BAM file ======================== #";
	${SHELL_EXPORT} ./scripts/sam2bam.sh ${GENOME_FA}i ${GENOME_NAME};

# -------------------------------------------------------------------------------------- #
# --- Sort and index BAM
# -------------------------------------------------------------------------------------- #

# Sorted BAM file index depends on unsorted BAM file, scripts/sort_bam, and scripts/index_bam.sh
results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam.sorted.bam.bai : results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam #scripts/sort_bam scripts/index_bam.sh
	@echo "# === Sorting and Indexing BAM file ========================== #";
	${SHELL_EXPORT} ./scripts/sort_bam.sh results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam;
	${SHELL_EXPORT} ./scripts/index_bam.sh results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam.sorted.bam;

# -------------------------------------------------------------------------------------- #
# --- Analyze alignment output with flagstat, idxstats, and stats
# -------------------------------------------------------------------------------------- #

# Align stats report depends on the sorted BAM and scripts/get_alignment_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.txt : results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam.sorted.bam #scripts/get_alignment_stats.sh
	@echo "# === Analyzing alignment output ============================= #";
	${SHELL_EXPORT} ./scripts/get_alignment_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam.sorted.bam reports/${IND_ID}.bwa.${GENOME_CODE}.aln_stats.txt	

# ====================================================================================== #
# -------------------------------------------------------------------------------------- #
# --- Post-alignment filtering steps
# -------------------------------------------------------------------------------------- #
# ====================================================================================== #

# -------------------------------------------------------------------------------------- #
# --- Fix mate pairs info
# -------------------------------------------------------------------------------------- #

# BAM with fixed mate pair info depends on output BAM from sort_and_index.sh, Picard, and scripts/fix_mate_pairs.sh
results/${IND_ID}.bwa.${GENOME_NAME}.fixed.bam : results/${IND_ID}.bwa.${GENOME_NAME}.sam.bam.sorted.bam ${PICARD}/* # scripts/fix_mate_pairs.sh
	@echo "# === Fixing mate pair info ======================== #";
	${SHELL_EXPORT} ./scripts/fix_mate_pairs.sh ${GENOME_NAME};

# Align stats report depends on the BAM with fixed mate pair info and scripts/get_alignment_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.txt : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.bam #scripts/get_alignment_stats.sh
	@echo "# === Analyzing alignment output (post mate pair fix) ======== #";
	${SHELL_EXPORT} ./scripts/get_alignment_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.fixed.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.txt;

# -------------------------------------------------------------------------------------- #
# --- Filtering for mapped and paired
# -------------------------------------------------------------------------------------- #

# Filtered BAM [index file] depends on output BAM from fix_mate_pairs.sh, BAMtools, and scripts/filter_mapped_reads_paired.sh
results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.bam.bai : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.bam ${BEDTOOLS}/* # scripts/filter_mapped_reads_paired.sh
	@echo "# === Filtering unpaired reads mapped ========================= #";
	${SHELL_EXPORT} ./scripts/filter_mapped_reads_paired.sh ${GENOME_NAME};
	${SHELL_EXPORT} ./scripts/index_bam.sh results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.bam;

# Align stats report depends on filtered BAM and scripts/get_alignment_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.flt.txt : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.bam #scripts/get_alignment_stats.sh
	@echo "# === Analyzing alignment output (filtered for paired) ======= #";
	${SHELL_EXPORT} ./scripts/get_alignment_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.flt.txt;

# -------------------------------------------------------------------------------------- #
# --- Remove duplicates
# -------------------------------------------------------------------------------------- #

# BAM sans dups [index file] depends on output BAM from filter_mapped_reads_paired.sh, Picard, and scripts/remove_dups.sh
results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.bam.bai : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.bam ${PICARD}/* # scripts/remove_dups.sh
	@echo "# === Removing duplicate reads mapped ========================= #";
	${SHELL_EXPORT} ./scripts/remove_dups.sh ${GENOME_NAME};
	${SHELL_EXPORT} ./scripts/index_bam.sh results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.bam;

# Align stats report depends on BAM sans dups and scripts/get_alignment_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.flt.nodup.txt : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.bam #scripts/get_alignment_stats.sh
	@echo "# === Analyzing alignment output (duplicates removed) ======== #";
	${SHELL_EXPORT} ./scripts/get_alignment_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.pairsfix.flt.nodup.txt;

# -------------------------------------------------------------------------------------- #
# --- Add read groups
# -------------------------------------------------------------------------------------- #

# BAM without RGs depends on output BAM from remove_dups.sh, Picard, and scripts/add_read_groups.sh
results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.RG.bam : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.bam ${PICARD}/* # scripts/add_read_groups.sh
	@echo "# === Adding read groups ===================== #";
	${SHELL_EXPORT} ./scripts/add_read_groups.sh ${GENOME_NAME};

# -------------------------------------------------------------------------------------- #
# --- Remove reads with low mapping quality
# -------------------------------------------------------------------------------------- #

# Filtered BAM depends on output BAM from add_read_groups.sh, BAMtools, and scripts/filter_mapped_reads_quality.sh
results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam.bai : results/${IND_ID}.bwa.${GENOME_NAME}.fixed.filtered.nodup.RG.bam ${BEDTOOLS}/* # scripts/filter_mapped_reads_quality.sh
	@echo "# === Filtering low quality reads mapped to genome ====================== #";
	${SHELL_EXPORT} ./scripts/filter_mapped_reads_quality.sh ${GENOME_NAME};
	${SHELL_EXPORT} ./scripts/index_bam.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam;

# Align stats report depends on quality-filtered BAM and scripts/get_alignment_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.passed.txt : results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam #scripts/get_alignment_stats.sh
	@echo "# === Analyzing alignment output (after qual filtering) ====== #";
	${SHELL_EXPORT} ./scripts/get_alignment_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.passed.txt;

# ====================================================================================== #
# -------------------------------------------------------------------------------------- #
# --- SNP calling methods
# -------------------------------------------------------------------------------------- #
# ====================================================================================== #

# -------------------------------------------------------------------------------------- #
# --- Local realignment, step 1: ID realign targets
# -------------------------------------------------------------------------------------- #

# List of intervals to realign depends on BAM of reads that passed filtering, GATK, and scripts/local_realign_get_targets.sh
results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam.list : results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam ${GATK}/* #scripts/local_realign.sh
	@echo "# === Identifying intervals in need or local realignment ===== #";
	${SHELL_EXPORT} ./scripts/local_realign_get_targets.sh ${GENOME_NAME} ${GENOME_FA};

# -------------------------------------------------------------------------------------- #
# --- Local realignment, step 2: realign around indels
# -------------------------------------------------------------------------------------- #

# Realigned BAM depends on list of realign targets, BAM of reads that passed filtering, GATK, and scripts/local_realign.sh
results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam : results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam.list results/${IND_ID}.bwa.${GENOME_NAME}.passed.bam ${GATK}/* #scripts/local_realign.sh
	@echo "# === Doing local realignment ================================ #";
	${SHELL_EXPORT} ./scripts/local_realign.sh ${GENOME_NAME} ${GENOME_FA};

# Align stats report depends on realigned BAM and scripts/get_alignment_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.passed.realn.txt : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam #scripts/get_alignment_stats.sh
	@echo "# === Analyzing alignment output (locally realigned) ========= #";
	${SHELL_EXPORT} ./scripts/get_alignment_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam reports/${IND_ID}.bwa.${GENOME_NAME}.aln_stats.passed.realn.txt;

# -------------------------------------------------------------------------------------- #
# --- Call SNPs
# -------------------------------------------------------------------------------------- #

# Raw SNPs file depends on realigned BAM, VCFtools, BCFtools, and scripts/call_snps.sh
results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.raw.bcf : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam ${VCFTOOLS}/* ${BCFTOOLS}/* #scripts/call_snps.sh
	@echo "# === Calling raw SNPs relative to genome =============================== #";
	${SHELL_EXPORT} ./scripts/call_snps.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam ${GENOME_FA};
	
# -------------------------------------------------------------------------------------- #
# --- Filter SNPs for quality
# -------------------------------------------------------------------------------------- #

# Filtered SNP file depends on raw SNP file, BCFtools, and scripts/filter_snps.sh
results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.flt.vcf : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.raw.bcf ${BCFTOOLS}/* #scripts/filter_snps.sh
	@echo "# === Filtering raw SNPs ============================= #";
	${SHELL_EXPORT} ./scripts/filter_snps.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.raw.bcf;

# -------------------------------------------------------------------------------------- #
# --- Get basic stats on SNPs
# -------------------------------------------------------------------------------------- #

# File of SNP stats depends on VCF file, VCFtools, and scripts/get_snp_stats.sh
reports/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.flt.vcf.stats.txt : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.flt.vcf ${VCFTOOLS}/* #scripts/get_snp_stats.sh
	@echo "# === Getting basic SNPs stats =============================== #";
	${SHELL_EXPORT} ./scripts/get_snp_stats.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.flt.vcf;

# -------------------------------------------------------------------------------------- #
# --- Call consensus sequence
# -------------------------------------------------------------------------------------- #

# Consensus sequence depends on realigned BAM, SAMtools, BCFtools, and scripts/call_consensus.sh
results/${IND_ID}.bwa.${GENOME_NAME}.consensus.fq.gz : results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam ${SAMTOOLS}/* ${BCFTOOLS}/* #scripts/call_consensus.sh
	@echo "# === Calling consensus sequence ===================== #";
	${SHELL_EXPORT} ./scripts/call_consensus.sh results/${IND_ID}.bwa.${GENOME_NAME}.passed.realn.bam ${GENOME_FA} ${GENOME_NAME};

