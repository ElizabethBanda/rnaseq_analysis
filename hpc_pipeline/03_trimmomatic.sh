#!/bin/bash
#SBATCH -t 
#SBATCH -p 
#SBATCH -o logs/multiqctrim%j.out
#SBATCH -e logs/multiqctrim%j.err
#SBATCH --array=          #set array number based on resources and cluster policy
#SBATCH -c 8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu 

# Load Conda environment with Fastq and Trimmomatic
source /GWSPH/home/g30408977/miniconda3/etc/profile.d/conda.sh
conda activate HERV_PD #modify with name of env

# Directory containing the FASTQ files
FASTQ_DIR=/scratch/cbi/PD/phase1/copy/M36_all/merged_fastq
OUTPUT_BASE_DIR=/scratch/cbi/PD/phase1/copy/M36_all/redo_trimmed_reads
LOG_DIR=redologs
mkdir -p $OUTPUT_BASE_DIR $LOG_DIR

#Select files
FASTQ_FILES=($(find $FASTQ_DIR -type f -name "*_R1.fastq.gz" | sort))
FASTQ1=${FASTQ_FILES[$SLURM_ARRAY_TASK_ID]}
FASTQ2=${FASTQ1/_R1.fastq.gz/_R2.fastq.gz}

#Output Names
BASENAME=$(basename "$FASTQ1" _R1.fastq.gz)

OUT1_PAIRED=$OUTPUT_BASE_DIR/${BASENAME}_R1_paired.fastq.gz
OUT1_UNPAIRED=$OUTPUT_BASE_DIR/${BASENAME}_R1_unpaired.fastq.gz
OUT2_PAIRED=$OUTPUT_BASE_DIR/${BASENAME}_R2_paired.fastq.gz
OUT2_UNPAIRED=$OUTPUT_BASE_DIR/${BASENAME}_R2_unpaired.fastq.gz

# Run Trimmomatic options
echo "$(date): Starting trimming for $BASENAME"

if trimmomatic PE -threads 4 -phred33 \
   $FASTQ1 $FASTQ2 \
   $OUT1_PAIRED $OUT1_UNPAIRED \
   $OUT2_PAIRED $OUT2_UNPAIRED \
   ILLUMINACLIP:/scratch/cbi/PD/phase1/copy/BL/TruSeq3-PE.fa:2:30:10 \
   SLIDINGWINDOW:4:20 MINLEN:36; then
    echo "$(date): Trimming completed for $BASENAME"
else
    echo "$(date): ERROR trimming $BASENAME" >&2
fi

#After this run multiqc after this job