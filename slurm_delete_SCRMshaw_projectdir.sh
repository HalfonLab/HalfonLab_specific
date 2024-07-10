#!/bin/bash -l

## slurm_delete_SCRMshaw_projectdir.sh
## version 1.2
## this version updated 07-08-2024

##=====================================##
## ONLY RUN THIS SCRIPT IF YOU HAVE COPIED
## ALL THE RELEVANT DATA TO THE LAB PROJECT
## SPACE USING THE "transfer_SCRMshaw_results.sh"
## SCRIPT AND HAVE CONFIRMED SUCCESSFUL TRANSFER
## OF ALL RESULTS!!
##=====================================##

#this script should be called by the wrapper 'delete_SCRMshaw_projectdir.sh'

##the path to the SCRMshaw project directory in scratch space should go on the command line, followed by the basename of the directory


#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=48000
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

PROJECT_DIR=$1
echo "deleting the directory $PROJECT_DIR"

rm -r $PROJECT_DIR

echo "directory deleted, exiting with exit status $?"
