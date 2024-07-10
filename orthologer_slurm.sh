#!/bin/bash -l

## orthologer_slurm.sh
## version 1.0
## this version updated 07-06-2024

##this script should be executed from an EMPTY "Project_OM" directory

## Note: the path to the species-specific protein fasta needs to be provided on the command line when running this script! 

#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48000
#SBATCH --output="../orthologer_slurm_output_log"
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

#check for command line
if [ -z $1 ]; then	#this syntax checks if there is a value for the first argument 
    echo "Path to the species-specific protein fasta needs to be provided on the command line"
    exit 1
fi

#check that directory is empty (or Orthologer set up will fail)
if [ "$(ls -A "$(pwd)")" ]; then
	echo "Current directory is not empty--please work from an empty directory"
	exit 1
fi


PROTEIN_FASTA=$1
SPECIES=$(basename "$PROTEIN_FASTA")
SPECIES=$(echo "$SPECIES" | sed 's/_protein\.fs//')

echo "Slurm output log for orthologer with $SPECIES"
echo "see $OUTPUTLOG for Orthologer output"

OUTPUTLOG="../${SPECIES}_orthlogerOutputlog"
echo "Log files for Orthologer for $SPECIES vs DMEL" &> $OUTPUTLOG
echo "---------------------------------------------------------------------------------" &> $OUPUTLOG

#load the orthologer environment
singularity exec -H $(pwd):/odbwork /projects/academic/mshalfon/ezlabgva_orthologer_v3.2.2-2024-06-26-a665d1ab91da.sif orthologer -c create &>> $OUTPUTLOG

#add the protein fasta files
mkdir protein_files

cp /projects/academic/mshalfon/DMEL_protein.fs ./protein_files
cp $PROTEIN_FASTA ./protein_files

for x in $(ls protein_files/*.fs); do echo "+$(basename $x .fs) $x"; done > mydata.txt

#run the orthologer steps
singularity exec -H $(pwd):/odbwork /projects/academic/mshalfon/ezlabgva_orthologer_v3.2.2-2024-06-26-a665d1ab91da.sif  ./orthologer.sh manage -f mydata.txt &>> $OUTPUTLOG

singularity exec -H $(pwd):/odbwork /projects/academic/mshalfon/ezlabgva_orthologer_v3.2.2-2024-06-26-a665d1ab91da.sif ./orthologer.sh -t todo/mydata.todo -r all  &>> $OUTPUTLOG


#move the results
newdir="${SPECIES}_orthologer_output"
mkdir ../$newdir
cp Cluster/mydata.og_map Rawdata/*_protein.fs.maptxt ../$newdir

#######################################

echo "All done!"