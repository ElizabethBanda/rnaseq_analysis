#!/bin/bash
#SBATCH -t 
#SBATCH -p 
#SBATCH --array=          #set array number based on resources and cluster policy
#SBATCH -c 8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu 
#SBATCH -o logs/hisat2_%A_%a.out
#SBATCH -e logs/hisat2_%A_%a.err

# Load conda
conda activate HERV_PD #modify with name of env

# Get sample prefix from list
sample=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" samfiles_samples.txt)

# Output directory
mkdir -p logs
mkdir -p bam_files

# Expected BAM path
bam_out="bam_files/${sample}_aligned.sorted.bam"

# Skip if BAM already exists
if [[ -f "$bam_out" ]]; then
  echo "✅ $bam_out already exists, skipping $sample"
  exit 0
fi

# Run HISAT2 and stream directly to BAM
echo "▶ Running HISAT2 for $sample..."
hisat2 -x grch38/genome \
  -p 8 \
  -1 ${sample}_R1_paired.fastq.gz \
  -2 ${sample}_R2_paired.fastq.gz \
  | samtools view -bS - \
  | samtools sort -@ 8 -o "$bam_out"

samtools index "$bam_out"
echo "✅ Finished $sample"