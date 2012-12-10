#!/bin/sh

# ------------------------------------------------------------------------------
# --- Merge VCF files from individual SNP calling
# ------------------------------------------------------------------------------

export PATH=$PATH:$TABIX

ALL_VCF_GZ=$(ls results/*.bwa.rhesus.passed.realn.bam.RG.flt.vcf.gz)

${VCFTOOLS}/vcf-merge \
	${ALL_VCF_GZ} \
	> results/merged.flt.vcf

exit;