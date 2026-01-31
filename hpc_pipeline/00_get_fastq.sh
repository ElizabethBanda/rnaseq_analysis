#!/bin/bash

#SBATCH -t 00:00:00       #select appropriate time allocation based on resources
#SBATCH -p                #select appropriate node
#SBATCH -o QC_test%j.out
#SBATCH -e QC_test%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@institution.edu 

#Step 1: This sample script was used to transfer the raw files from the import space to the target directory.
# We filtered through the RNA metadata csv to obtain participant IDs to idenitfy and select through the 64 TB of raw files.  

# Directory variables to retrieve and store data
# Modify paths as needed for your environment
METADATA="/path/to/csv"
RAW_DIR="/path/to/rawfiles"
DEST_DIR="/path/to/store/files"
mkdir -p "$DEST_DIR"

# Filter metadata: Phase1 + BL + target disease statuses
awk -F',' 'NR > 1 {
    gsub(/"/, "", $8);  # Phase
    gsub(/"/, "", $14); # Clinical Event
    gsub(/"/, "", $4);  # PATNO
    gsub(/"/, "", $9);  # Disease Status

    if ($14 == "BL" && tolower($8) == "phase1" &&
        ($9 == "Genetic PD" || $9 == "Genetic Unaffected" ||
         $9 == "Healthy Control" || $9 == "Idiopathic PD")) {
        gsub(/^PP-/, "", $4);
        print $4 "," $9;
    }
}' "$METADATA" | sort | \
awk -F, '{count[$2]++; if (count[$2] <= 5) print $1 "," $2 }' > qc_test.txt

echo "Filtered sample list written to qc_test.txt"

# Copy matching FASTQ files only Phase1 and BL
while IFS=, read -r sampleid status; do
    echo "Looking for sample $sampleid files..."
    matches=$(find "$RAW_DIR" -type f -name "*Phase1-IR1.${sampleid}.BL.*.fastq.gz")

    if [[ -z "$matches" ]]; then
        echo "WARNING: No files found for sample $sampleid"
    else
        echo "Found files:"
        echo "$matches"
        for file in $matches; do
            cp "$file" "$DEST_DIR/"
            echo "Copied $file"
        done
    fi
done < qc_test.txt
#output: generated sample list and FASTQ files will be in a destination directory.

echo "Done."