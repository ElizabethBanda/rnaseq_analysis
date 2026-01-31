#!/bin/bash

#SBATCH -t 
#SBATCH -p 
#SBATCH -o logs/merge_fastqc_%A_%a.out
#SBATCH -e logs/merge_fastqc_%A_%a.err
#SBATCH --array=          #set array number based on resources and cluster policy
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu 

#This script was generated to merge/concatenate paired-end sequenced reads 

# 1. Activate Conda environment
conda activate HERV_PD #modify with name of env

# 2. Directories
RAW_DIR="/path/to/fastq"
MERGE_DIR="/path/to/merged_fastq"
FASTQC_DIR="/path/to/store/fastqc"
MULTIQC_DIR="/path/to/multiqc_report"

mkdir -p "$MERGE_DIR" "$FASTQC_DIR" "$MULTIQC_DIR" logs #creates log of array progress

# 3. Get sample ID for this array task from cleaned txt file
SAMPLE_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" sample_ids_clean.txt | tr -d '\r\n')
echo "Processing sample: $SAMPLE_ID"

cd "$RAW_DIR" || { echo "Raw FASTQ directory not found"; exit 1; }

# 4. Find all R1 and R2 files for sample across all lanes
FILES_R1=($(ls PPMI-Phase1-IR1.*"$SAMPLE_ID"*.L00*.R1.fastq.gz 2>/dev/null))
FILES_R2=($(ls PPMI-Phase1-IR1.*"$SAMPLE_ID"*.L00*.R2.fastq.gz 2>/dev/null))

if [[ ${#FILES_R1[@]} -eq 0 ]]; then
    echo "No R1 files found for $SAMPLE_ID"
    exit 0
fi

# 5. Define sample prefix (strip lane and read)
sample_prefix=$(basename "${FILES_R1[0]}" | sed -E 's/\.L00[0-9]\.R1\.fastq\.gz//')

# 6. Skip if already merged due to unexpected timeouts or failures
if [[ -f "$MERGE_DIR/${sample_prefix}_R1.fastq.gz" ]]; then
    echo "$sample_prefix already merged. Skipping."
    exit 0
fi

# 7. Merge R1 and R2
echo "Merging R1 for $sample_prefix..."
cat "${FILES_R1[@]}" > "$MERGE_DIR/${sample_prefix}_R1.fastq.gz"

echo "Merging R2 for $sample_prefix..."
cat "${FILES_R2[@]}" > "$MERGE_DIR/${sample_prefix}_R2.fastq.gz"

# 8. Run FastQC
echo "Running FastQC on $sample_prefix..."
fastqc --threads 4 -o "$FASTQC_DIR" "$MERGE_DIR/${sample_prefix}_R1.fastq.gz" "$MERGE_DIR/${sample_prefix}_R2.fastq.gz"