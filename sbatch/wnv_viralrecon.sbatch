#!/usr/bin/env bash

#SBATCH --job-name=viral-recon 
#SBATCH --nodes=1
#SBATCH --mem=96GB
#SBATCH --cpus-per-task=32
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=amilan
#SBATCH --mail-type=END
#SBATCH --mail-user=rtk24@colostate.edu
#SBATCH --output=viral-recon-%j.out
#SBATCH --qos=normal

# Check for required arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 --input <input_csv> --output <output_directory> [additional_nextflow_args]"
    echo "Example: $0 --input samples.csv --output results_2023"
    exit 1
fi

# Load required modules
module purge
module load singularity nextflow

# Parse command line arguments
INPUT=""
OUTPUT=""
EXTRA_ARGS=()

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input) INPUT="$2"; shift ;;
        --output) OUTPUT="$2"; shift ;;
        *) EXTRA_ARGS+=("$1") ;;
    esac
    shift
done

# Verify required arguments
if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Error: Both --input and --output must be specified"
    exit 1
fi

# make the output directory if it doesn't exist if not throw message
mkdir -p "$OUTPUT" || {
    echo "Error: Failed to create output directory '$OUTPUT'"
    exit 1
}

# Run Nextflow
nextflow run nf-core/viralrecon -r 2.6.0 -profile singularity \
    -c conf/wnv.config \
    -params-file assets/wnv_params.yaml \
    --input "$INPUT" \
    --output "$OUTPUT" \
    --genome 'WNV_REF' \
    -resume \
    "${EXTRA_ARGS[@]}"