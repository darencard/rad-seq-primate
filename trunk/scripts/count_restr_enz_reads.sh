#!/bin/sh

# ------------------------------------------------------------------------------
# --- Count sequence coverage (# reads) at restriction enzyme-associated loci
# ------------------------------------------------------------------------------

ALL_BAM=$(ls results/*.passed.realn.bam)

${BEDTOOLS}/multiBamCov \
	-bams	${ALL_BAM} \
	-bed reports/${GENOME_CODE}_${ENZYME}_RADtags.bed \
	> reports/${GENOME_CODE}_${ENZYME}_RAD_coverage.txt

