#!/bin/sh

# ------------------------------------------------------------------------------
# --- Count sequence coverage (# reads) at restriction enzyme-associated loci
# ------------------------------------------------------------------------------

ALL_BAM=$(ls results/*.passed.realn.bam)

${BEDTOOLS}/multiBamCov \
	-bams	${ALL_BAM} \
	-bed ${RAD_TAG_BED} \
	> reports/RAD_coverage.txt