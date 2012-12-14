# Information on scripts from Bergey's RAD pipeline

## Scripts for Demultiplexing

* demultiplex.sh
    - Demultiplex PE reads
* demultiplex\_SE.sh
    - Demultiplex PE reads

---

## Scripts for Mapping analysis (using BWA)

### Scripts to be run on all individuals, one by one.
### Called by running ./indiv_analysis

* index\_genome.sh
    - Index the genome using BWA and samtools
* run\_fastqc.sh
    - Analyze reads with FastQC
* align.sh
    - Align PE reads to genome with BWA
* alignSE.sh
    - Align SE reads to genome with BWA
* sampe.sh
    - Run BWA sampe for PE reads
* samse.sh
    - Run BWA samse for SE reads
* sam2bam.sh
    - Convert SAM file to BAM file
* sort\_bam.sh
    - Sort BAM file
* index\_bam.sh
    - Index BAM file
* merge\_bam.sh
    - Merge BAM files, used to combine SE and PE reads
* get\_alignment\_stats.sh
    - Analyze BAM file using flagstat, idxstats and stats
* remove\_dups.sh (Not incorporated into pipeline)
    - Not used, but removes duplicate reads from the alignment
* fix\_mate\_pairs.sh
    - Fix mate pair info
* filter\_mapped\_reads\_paired.sh
    - Filter out unmapped reads. Also can filter for paired reads and properly paired reads
* add\_read\_groups.sh
    - Add read groups
* filter\_mapped\_reads\_quality.sh
    - Remove reads with low mapping quality
* local\_realign\_get\_targets.sh
    - Local realignment, step 1: ID realign targets
* local\_realign.sh
    - Local realignment, step 2: realign around indels
* call\_snps.sh
    - Call SNPs
* filter\_snps.sh
    - Filter SNPs for quality
* get\_snp\_stats.sh
    - Get basic stats on SNPs
* call_consensus.sh
    - Call consensus *.fq.gz file.

### Scripts to be run after individual analyses, to compare all individuals
### Called by running ./compare_analysis

* merge\_vcf.sh
    - Merge individual VCF files together
* get\_snp\_stats.sh
    - Get stats on merged VCF file (script also used in individual analysis)
* compare\_snps.sh (Not incorporated into pipeline)
    - Although not run automatically by pipeline, this script compares all individuals' VCF files.
* count\_restr\_enz\_reads.R
    - Given a BED file of RAD tag sites, tally the number of reads at each tag
* analyze\_enzyme\_count\_data.R (Not incorporated into pipeline)
	- Although not run automatically by pipeline, this R script analyzes the data output from count\_restr\_enz\_reads.sh
* vcf\_tab\_to\_fasta\_alignment.pl (Not incorporated into pipeline)
    - Never used, but possibly useful. Converts a VCF tab file output from vcf-tools to a FASTA alignment
* convert\_fasta\_to\_nexus.pl (Not incorporated into pipeline)
    - Never used, but possibly useful. Converts a FASTA alignment to NEXUS
* convert\_fasta\_to\_phylip.pl (Not incorporated into pipeline)
    - Never used, but possibly useful. Converts a FASTA alignment to phylip

---

## Scripts for Clustering analysis (using Stacks)

The Stacks calls are not yet incorporated into a Makefile. A bunch of commands are jumbled together in call_stacks.sh. There are PBS files to call the various steps but these are specific to the input files used in my analysis.

* call\_stacks.sh
    - Kind of a rough outline of the Stacks pipeline. Needs to be formalized and turned into a Makefile at some point.
* filter\_reads.sh
    - Filter out low quality reads from a FASTQ file using FASTX
* gather\_results.R
    - Quick R script to pull data out of the output files of the Stacks run. 
