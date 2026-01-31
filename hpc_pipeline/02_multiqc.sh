#!/bin/bash
#SBATCH -t 
#SBATCH -p 
#SBATCH -o logs/multiqc%.out
#SBATCH -e logs/multiqc%.err
#SBATCH --array=          #set array number based on resources and cluster policy
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu

#This script can be used both before and after trimming based on QC results.

# Load Conda environment with MultiQC
conda activate HERV_PD

#  Create output directory 
mkdir -p /path/to/mutliqc/results

#  Run MultiQC on all files
multiqc .