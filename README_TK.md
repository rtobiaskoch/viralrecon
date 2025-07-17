#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#MODIFICATIONS FOR RUNNING VIRALRECON PIPELINE FOR WNV ON ALPINE
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DESC: documentation of all changes required to take repository nf-core/viralrecon
and repurpose it for WNV or potentially any other pathogen sequenced on illumina
using an amplicon approach and run it on the alpine cluster

NOTE: all paths are relative to being in the viralrecon as your working directory

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## P A T H   S E T T I N G S : ~/.bashrc
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DESC: allows for changes in default cluster settings and commands 

KEY FUNCTION 4 Pipeline:
- sets paths out of your home directory to avoid home storage limits

export NXF_WORK="/scratch/alpine/$USER/.nf_work"
export NXF_HOME="/scratch/alpine/$USER/.nextflow"
export NXF_SINGULARITY_CACHEDIR="/scratch/alpine/$USER/.singularity_cache"
export SINGULARITY_CACHEDIR="/scratch/alpine/$USER/.singularity_cache"
mkdir -p "$NXF_SINGULARITY_CACHEDIR" 2>/dev/null || echo "Warning: Failed to create cache dir"

# Nextflow optimizations
export NXF_SINGULARITY_PULL_TIMEOUT="60m"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## C O N F I G U R A T I O N : conf/wnv.config
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DESC: 
- overwrite default processes arguments 
- fix random @$$ errors that arose in pipeline:

KEY FUNCTION 4 Pipeline:
-  Fixes Error that input and output files were the same for samtools


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## W N V   R E F E E R E N C E: assets/wnv_params.yaml & reference/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DESC: allows user to alter default parameters, specify required ones and skip
processes.

KEY FUNCTIONS 4 PIPELINE: 
- specifies sequencing platform (illumina) & protocol (amplicon)
- POINTS TO PATHOGEN SPECIFIC REFERENCE FILES WHEN --genome 'WNV_REF'
- points to pathogen specific reference files when --genome 'WNV_REF' is used
- skips unnecessary processes (ex pangolin & nextclade which are for SC2)
- skips bfctools which was causing error (subject to change 07-08-25)
- specifies certain processes to use

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## W N V   R E F E E R E N C E: reference/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DESC: provide files not available in available in provided organisms.

KEY FUNCTION: provides files are called in assets/wnv_params.yaml 
when --genome 'WNV_REF' argument is called:

      fasta           = "reference/west_nile_virus.fasta"
      gff             = "reference/west_nile_virus.gff"
      primer_bed      = "reference/WNVic.primers_NC_009942_1.bed"  
      primer_fasta    = "reference/wnv_primers.fasta"          
      bowtie2_index   = "reference/west_nile_virus.fasta.fai

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## S B A T C H: sbatch/wnv_viralrecon.sbatch
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DESC: allows user to submit viralrecon as a job

KEY FUNCTIONS 4 PIPELINE:
1. increase memory for bowtie2 (min 48GB)
2. Determine input and output directories
3. loads nextflow and singularity

#SBATCH --mem=96GB                         #total memory for job
#SBATCH --cpus-per-task=32                  #cpus per process
#see full SBATCH in the file

nextflow run nf-core/viralrecon -r 2.6.0 -profile singularity \
    -c conf/wnv.config \
    -params-file assets/wnv_params.yaml \
    --input "$INPUT" \
    --outdir "$OUTDIR" \
    --genome 'WNV_REF' \
    -resume \
    "${EXTRA_ARGS[@]}"





#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## R U N N I N  G   O N   C L U S T E R 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### S T E P  1: START SESSION
--------------------------------------------------------------------------------

#start Interacive session
sinteractive --partition=csu --time=4:00:00 --ntasks=1 --qos=normal

### S T E P  2: SET UP/NAVIGATE TO VIRALRECON DIRECTORY
--------------------------------------------------------------------------------
cd path/to/viralrecon

if you don't have viralrecon installed git clone it from me (Toby)
https://github.com/rtobiaskoch/viralrecon

or from the master:
https://github.com/nf-core/viralrecon

NOTES:
- If you clone it from the master you will need to add changes above yourself
- If you haven't run viralrecon before I suggest running there test to install 
  environment using singularity to ensure basic pipeline is working
  
nextflow run nf-core/viralrecon -profile test,singularity --outdir test

### S T E P  3: MAKE SAMPLESHEET
--------------------------------------------------------------------------------

use the make_sample_sheet.sh to create a sample sheet from your directory that 
contains your raw reads (FASTQ) and put it in viralrecon/input
with the format:
#sample, fastq_1, fastq_2
#ID, path/to/r1, path/to/r2

# Usage: sbatch/make_sample_sheet_symlink.sh /path/to/fastq_dir /path/to/viralrecon prefix


### S T E P  4: RUN SBATCH
--------------------------------------------------------------------------------
Using the output from make_sample_sheet as your input 
run sbatch/wnv_viralrecon.sbatch and specify the input and desired output directory

USAGE: 
test sbatch --test-only sbatch/wnv_viralrecon.sbatch --input input/<sample_sheet.csv> --output <run_id>
sbatch sbatch/wnv_viralrecon.sbatch --input input/<sample_sheet.csv> --output <run_id>



