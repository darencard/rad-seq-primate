#!/bin/bash

# ------------------------------------------------------------------------------
# --- Generate BED file of restriction enzyme-associated loci with rdbio's 
# --- restriction-finder Python script (requires BioPython)
# ------------------------------------------------------------------------------

# Run module load python/intel/2.7.2 if on NYU HPC

# Infer genome short name, like "hg19"
GENOME_CODE=$(basename $GENOME_FA | cut -d'.' -f1)

# Find RE sites and get flanks on either side
python ${RE_FINDER} \
	--fasta ${GENOME_FA} \
	--enzyme ${ENZYME} | \
	${BEDTOOLS}/flankBed -b 100 -i - \
	-g <(cut ${GENOME_FA}.fai -f1-2) \
	> reports/${GENOME_CODE}_${ENZYME}_RADtags.bed
