#!/bin/bash
#SBATCH -t 
#SBATCH -p 
#SBATCH -o logs/BL_telescope_%A_%a.out
#SBATCH -e logs/BL_telescope_%A_%a.err
#SBATCH --array=                  #set array number based on resources and cluster policy
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu 

#Step 6: Quantify trasnposable element expression from BAM files and the annotation GTF.

# Activate Conda environment 
conda activate HERV_PD #modify with conda env name

# Define directories and files
BAM_DIR="/path/to/bam_files"
BAM_LIST="/path/to/bam_files_list.txt"
OUT_DIR="${BAM_DIR}/path/to/telescope_output"
ANNOTATION_GTF="${BAM_DIR}/path/to/.gtf"

mkdir -p "$OUT_DIR" logs

# Load BAM prefix for this task
mapfile -t BAM_ARRAY < "$BAM_LIST"
BAM_PREFIX="${BAM_ARRAY[$((SLURM_ARRAY_TASK_ID-1))]}"
BAM_FILE="${BAM_DIR}/${BAM_PREFIX}_collated.bam"

echo "[$(date)] Processing sample: ${BAM_PREFIX}"
echo "BAM file path: ${BAM_FILE}"

if [[ ! -f "$BAM_FILE" ]]; then
  echo "Error: BAM file not found at $BAM_FILE"
  exit 1
fi

# Define sample ID 
SAMPLE=$(basename "$BAM_FILE" _collated.bam)

# Run Telescope on bam files
telescope assign "$BAM_FILE" "$ANNOTATION_GTF" --outdir "$OUT_DIR" --exp_tag "$SAMPLE"

echo "[$(date)] Telescope finished for: ${SAMPLE}"