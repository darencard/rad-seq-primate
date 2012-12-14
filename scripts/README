# Information on scripts from Bergey's RAD pipeline

## Scripts for Demultiplexing

    * demultiplex.sh
        - Demultiplex PE reads
    * demultiplex_SE.sh
        - Demultiplex PE reads

## Scripts for Mapping analysis (using BWA)

### Scripts to be run on all individuals, one by one.
### Called by running ./indiv_analysis

    * index_genome.sh
	    - Index the genome using BWA and samtools
    * run_fastqc.sh
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
    * sort_bam.sh
        - Sort BAM file
    * index_bam.sh
        - Index BAM file
    * merge_bam.sh
        - Merge BAM files, used to combine SE and PE reads
    * get_alignment_stats.sh
        - Analyze BAM file using flagstat, idxstats and stats
    * remove_dups.sh (Not incorporated into pipeline)
        - Not used, but removes duplicate reads from the alignment
    * fix_mate_pairs.sh
        - Fix mate pair info
    * filter_mapped_reads_paired.sh
        - Filter out unmapped reads. Also can filter for paired reads and properly paired reads
    * add_read_groups.sh
        - Add read groups
    * filter_mapped_reads_quality.sh
        - Remove reads with low mapping quality
    * local_realign_get_targets.sh
        - Local realignment, step 1: ID realign targets
    * local_realign.sh
        - Local realignment, step 2: realign around indels
    * call_snps.sh
        - Call SNPs
    * filter_snps.sh
        - Filter SNPs for quality
    * get_snp_stats.sh
        - Get basic stats on SNPs
	* call_consensus.sh
        - Call consensus *.fq.gz file.

### Scripts to be run after individual analyses, to compare all individuals
### Called by running ./compare_analysis

    * merge_vcf.sh
        - Merge individual VCF files together
    * get_snp_stats.sh
        - Get stats on merged VCF file (script also used in individual analysis)
    * compare_snps.sh (Not incorporated into pipeline)
        - Although not run automatically by pipeline, this script compares all individuals' VCF files.
    * count_restr_enz_reads.R
        - Given a BED file of RAD tag sites, tally the number of reads at each tag
    * analyze_enzyme_count_data.R (Not incorporated into pipeline)
    	- Although not run automatically by pipeline, this R script analyzes the data output from count_restr_enz_reads.sh
    * vcf_tab_to_fasta_alignment.pl (Not incorporated into pipeline)
        - Never used, but possibly useful. Converts a VCF tab file output from vcf-tools to a FASTA alignment
    * convert_fasta_to_nexus.pl (Not incorporated into pipeline)
        - Never used, but possibly useful. Converts a FASTA alignment to NEXUS
    * convert_fasta_to_phylip.pl (Not incorporated into pipeline)
        - Never used, but possibly useful. Converts a FASTA alignment to phylip
    
## Scripts for Clustering analysis (using Stacks)

The Stacks calls are not yet incorporated into a Makefile. A bunch of commands are jumbled together in call_stacks.sh. There are PBS files to call the various steps but these are specific to the input files used in my analysis.

    * call_stacks.sh
        - Kind of a rough outline of the Stacks pipeline. Needs to be formalized and turned into a Makefile at some point.
    * filter_reads.sh
        - Filter out low quality reads from a FASTQ file using FASTX
    * gather_results.R
        - Quick R script to pull data out of the output files of the Stacks run. 
