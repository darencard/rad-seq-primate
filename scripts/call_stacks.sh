#!/bin/sh

# ------------------------------------------------------------------------------
# --- Run Stacks
# ------------------------------------------------------------------------------

#STACKS=/home/cmb433/exome_macaque/bin/stacks-0.9999/build/bin
module load stacks/intel/0.9999

mkdir all_primate

# Combine SE and PE data into files in working directory

cat data/female12.read1.fastq      data/female12_SE.fastq      > all_primate/female12.fastq
cat data/Cebus.read1.fastq         data/Cebus_SE.fastq         > all_primate/Cebus.fastq
cat data/Tgelada871162.read1.fastq data/Tgelada871162_SE.fastq > all_primate/Tgelada871162.fastq
cat data/P_trog.read1.fastq        data/P_trog_SE.fastq        > all_primate/P_trog.fastq
cat data/H_sapiens.read1.fastq     data/H_sapiens_SE.fastq     > all_primate/H_sapiens.fastq

# FASTX - FASTQ Quality Filter

FASTX=/home/cmb433/exome_macaque/bin/fastx

${FASTX}/fastq_quality_filter -v -q 10 -p 100 -Q33 -i all_primate/female12.fastq      -o all_primate/female12.CLEAN.fastq
${FASTX}/fastq_quality_filter -v -q 10 -p 100 -Q33 -i all_primate/Cebus.fastq         -o all_primate/Cebus.CLEAN.fastq
${FASTX}/fastq_quality_filter -v -q 10 -p 100 -Q33 -i all_primate/Tgelada871162.fastq -o all_primate/Tgelada871162.CLEAN.fastq
${FASTX}/fastq_quality_filter -v -q 10 -p 100 -Q33 -i all_primate/P_trog.fastq        -o all_primate/P_trog.CLEAN.fastq
${FASTX}/fastq_quality_filter -v -q 10 -p 100 -Q33 -i all_primate/H_sapiens.fastq     -o all_primate/H_sapiens.CLEAN.fastq

# Stacks - Make stacks and call SNPs
# (PBS to do these)

ustacks -t fastq -f all_primate/female12.CLEAN.fastq      -o all_primate/stacks -i 1 -d -r -m 2 -p 12 -M 2
ustacks -t fastq -f all_primate/Cebus.CLEAN.fastq         -o all_primate/stacks -i 2 -d -r -m 2 -p 12 -M 2
ustacks -t fastq -f all_primate/Tgelada871162.CLEAN.fastq -o all_primate/stacks -i 3 -d -r -m 2 -p 12 -M 2
ustacks -t fastq -f all_primate/P_trog.CLEAN.fastq        -o all_primate/stacks -i 4 -d -r -m 2 -p 12 -M 2
ustacks -t fastq -f all_primate/H_sapiens.CLEAN.fastq     -o all_primate/stacks -i 5 -d -r -m 2 -p 12 -M 2

# Make catalog
# (PBS to do this)
cstacks -b 1 \
	-s all_primate/stacks/female12.CLEAN      -S 1 \
	-s all_primate/stacks/Cebus.CLEAN         -S 2 \
	-s all_primate/stacks/Tgelada871162.CLEAN -S 3 \
	-s all_primate/stacks/P_trog.CLEAN        -S 4 \
	-s all_primate/stacks/H_sapiens.CLEAN     -S 5 \
	-o all_primate/stacks -p 8 -n 15

# Compare samples back against catalog
sstacks -b 1 -c all_primate/stacks/batch_1 -s all_primate/stacks/female12.CLEAN      -S 1 -o all_primate/stacks -p 8
sstacks -b 1 -c all_primate/stacks/batch_1 -s all_primate/stacks/Cebus.CLEAN         -S 2 -o all_primate/stacks -p 8
sstacks -b 1 -c all_primate/stacks/batch_1 -s all_primate/stacks/Tgelada871162.CLEAN -S 3 -o all_primate/stacks -p 8
sstacks -b 1 -c all_primate/stacks/batch_1 -s all_primate/stacks/P_trog.CLEAN        -S 4 -o all_primate/stacks -p 8
sstacks -b 1 -c all_primate/stacks/batch_1 -s all_primate/stacks/H_sapiens.CLEAN     -S 5 -o all_primate/stacks -p 8


# Output to vcf format
populations -P all_primate/stacks/ -M stacks_pop_assign.txt -b 1 -p 2 -t 8 --vcf
# Output to phylip format
populations -P all_primate/stacks/ -M stacks_pop_assign.txt -b 1 -p 2 -t 8 --phylip --phylip_var

# --- Get stats on VCF -------------------------------------------------------------------

VCFTOOLS=/home/cmb433/exome_macaque/bin/vcftools_0.1.9/bin;
export VCFTOOLS; 

${VCFTOOLS}/vcf-stats all_primate/stacks/batch_1.vcf > all_primate/stacks/batch_1.vcf.stats.txt
cat all_primate/stacks/batch_1.vcf.stats.txt;

# --- Run RAxML --------------------------------------------------------------------------

# Do 100 runs using GTRGAMMA
/scratch/disotell/programs/RAxML-7.2.6/raxml -s all_primate/stacks/batch_1.phylip -n testrun –m GTRGAMMA -N100 -o 1

# Do 100 bootstraps
/scratch/disotell/programs/RAxML-7.2.6/raxml –f a -s all_primate/stacks/batch_1.phylip -n boot –m GTRGAMMA –x 1234 -N 100 -o 1
