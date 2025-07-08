#!/usr/bin/env bash

#SBATCH --job-name=viral-recon 
#SBATCH --nodes=1                          # this script is designed to run on one node
#SBATCH --mem=96GB                         #total memory for job
#SBATCH --cpus-per-task=32                  #cpus per process
#SBATCH --ntasks=1                        # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=12:00:00                     # modify this number to reflect how much time to request
#SBATCH --partition=amilan                 # modify this to reflect which queue you want to use.
#SBATCH --mail-type=END                    # Keep these two lines of code if you want an e-mail sent to you when it is complete.
#SBATCH --mail-user=rtk25@colostate.edu    # add your e-mail here
#SBATCH --output=viral-recon-%j.out        # this will capture all output in a logfile with %j as the job
#SBATCH --qos=normal

# Load required modules
module purge
module load singularity nextflow

# Force known directory (or use absolute paths)
# PROJECT_DIR="/projects/$USER/proj_bioinformatics/pipeline_viralrecon_NF"
# cd "$PROJECT_DIR" || exit 1

nextflow run viralrecon -r 2.6.0 -profile singularity \
    -c conf/wnv.config \
    -params-file assets/wnv_params.yaml \
    --input input/wnv_kapa_test.csv \
    --outdir wnv-s_21-22 \
    --genome 'WNV_REF' \
    -resume
