#!/bin/bash
#SBATCH -t 
#SBATCH -p 
#SBATCH -o logs/featurecounts_%A_%a.out
#SBATCH -e logs/featurecounts_%A_%a.err
#SBATCH --array=          #set array number based on resources and cluster policy

#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu 
#SBATCH --cpus-per-task=8  

# Activate Conda environment
conda activate HERV_PD #modify with name of env

# Directories
BAM_LIST="/path/to/bam_files_list.txt"
OUT_DIR="/path/to/output"
ANNOTATION="/path/to/.gtf"

mkdir -p logs
mkdir -p "${OUT_DIR}"

#Select BAM for this array task
BAM_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${BAM_LIST}")

# If list contains sample IDs instead of full BAM paths
if [[ ! "${BAM_FILE}" == *.bam ]]; then
  BAM_FILE="/scratch/cbi/PD/phase1/copy/M36_all/redo_trimmed_reads/bam_files/${BAM_FILE}_aligned.sorted.bam"
fi

#Output naming
SAMPLE=$(basename "${BAM_FILE%_aligned.sorted.bam}")
OUTPUT_FILE="${OUT_DIR}/${SAMPLE}.counts.txt"

echo "[$(date)] SLURM job ID: ${SLURM_JOB_ID}"
echo "[$(date)] Array task ID: ${SLURM_ARRAY_TASK_ID}"
echo "[$(date)] Processing sample: ${SAMPLE}"
echo "[$(date)] BAM file: ${BAM_FILE}"
echo "[$(date)] Output file: ${OUTPUT_FILE}"

# Run featureCounts for paired-end RNA-seq
featureCounts \
  -p \
  -s 2 \
  -t exon \
  -T "${SLURM_CPUS_PER_TASK}" \
  -a "${ANNOTATION}" \
  -o "${OUTPUT_FILE}" \
  "${BAM_FILE}"

echo "[$(date)] featureCounts completed"
