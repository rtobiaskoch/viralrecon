#!/usr/bin/env bash

#SBATCH --job-name=nf-core 
#SBATCH --nodes=1                          # this script is designed to run on one node
#SBATCH --ntasks=6                         # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=0:15:00                    # modify this number to reflect how much time to request
#SBATCH --partition=amilan                 # modify this to reflect which queue you want to use.
#SBATCH --mail-type=END                    # Keep these two lines of code if you want an e-mail sent to you when it is complete.
#SBATCH --mail-user=rtk25@colostate.edu           # add your e-mail here
#SBATCH --output=nf-core-%j.out     # this will capture all output in a logfile with %j as the job 


nextflow run nf-core/viralrecon -profile test,singularity --outdir test
