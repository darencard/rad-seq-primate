# Information on Bergey's RAD pipeline

## Quick Start Instructions

Here's the rough outline of how I used the scripts in this project to do the RADseq data analysis. It involves two main parts, the mapping analysis which uses BWA, and the clustering analysis which uses Stacks.

* Put uncompressed FASTQ file in folder `data/`
* Demultiplex reads with `scripts/demultiplex.sh` and/or `scripts/demultiplex\_SE.sh`
* MAPPING ANALYSIS - INDIVIDUALS
    - For each individual:
        - Edit variables in `config.mk`, especially the variables in "Paths to input files"
        - Call the individual analysis Makefile via the shell script by running `sh indiv_analysis`
    - When all individuals have been processed\:
        - Call the comparative analysis Makefile via the shell script by running `sh compare_analysis`
* CLUSTERING ANALYSIS
    - This has never really been formalized into a Makefile. 
    - `call\_stacks.sh` is kind of a rough outline of the Stacks pipeline. 
    - `filter\_reads.sh` should be called first to filter out low quality reads
    - `gather\_results.R` is a handy R script to pull data out of the output files of the Stacks run. 
    - `pbs/` contains PBS files for submitting jobs for the different parts of the Stacks analysis.

---

# Main Directory Structure

* compare\_analysis
    - Calls the Makefile in comparative analysis mode, to be run after all individuals have been processed.
* config.mk
    - User-defined variables such as paths to input FASTQ files
* data/
    - Contains FASTQ files, plus barcode data for demultiplexing, BED files of restriction enzyme cut sites, and population assignment file for Stacks.
* full\_analysis.mk
    - The Makefile for the Mapping analysis. Called via `sh indiv_analysis` or `sh compare_analysis`
* genomes/
    - Contains folders, each containing an indexed genome.
* indiv\_analysis
    - Calls the Makefile in individual analysis mode, to be run once per individual.
* paper/
    - Summary paper and figures
* pbs/
    - Example PBS files for submitting jobs for the different parts of the Stacks analysis
* reports/
    - Informational reports generated as the pipeline runs
* results/
    - Output files generated as the pipeline runs
* scripts/
    - Contains all programs needed for the pipeline. See `scripts/README.md` for info on each script in particular.
