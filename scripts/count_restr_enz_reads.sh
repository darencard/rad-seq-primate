#!/bin/sh

# ------------------------------------------------------------------------------
# --- Count sequence coverage (# reads) at restriction enzyme-associated loci
# ------------------------------------------------------------------------------

BEDTOOLS=/home/cmb433/exome_macaque/bin/BEDTools-Version-2.13.4/bin

ALL_BAM=$(ls results/*.passed.realn.bam)

${BEDTOOLS}/multiBamCov \
	-bams	${ALL_BAM} \
	-bed data/PspXI_hg19.bed \
	> reports/RAD_coverage.txt