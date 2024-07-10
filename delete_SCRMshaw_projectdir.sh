 #!/bin/bash -l

## delete_SCRMshaw_projectdir.sh
## version 1.2
## this version updated 07-08-2024

#'here' doc to print this block to STDOUT
cat <<EOF

######################################################
## ONLY RUN THIS SCRIPT IF YOU HAVE COPIED ALL THE  ##
## RELEVANT DATA TO THE LAB PROJECT SPACE USING THE ##
## "transfer_SCRMshaw_results.sh" SCRIPT AND HAVE   ##
## CONFIRMED SUCCESSFUL TRANSFER OF ALL RESULTS!!   ##
######################################################

EOF


#this is a wrapper for a slurm script that will do the actual deleting

##the path to the SCRMshaw project directory in scratch space should go on the command line

PROJECT_DIR=$1

if [ ! -d "$PROJECT_DIR" ]; then
	echo "$0: valid directory not specified on command line"
	exit 1
fi

#grab basename for later
mydir=$(basename "$PROJECT_DIR")
OUTFILE="/vscratch/grp-mshalfon/${mydir}_delete.log"

#make sure that you want to clean this directory:
echo "SCRMshaw project directory is $mydir"
echo -n "Are you sure you want to delete this entire directory? [y/n] "

read -n 1 confirmation

echo " "

if [ "$confirmation" != "y" ]; then
        exit 2
else
       echo -e "\ndeleting the directory $PROJECT_DIR"
       echo -e "log file will be $OUTFILE"
       
       sbatch --output="$OUTFILE" /projects/academic/mshalfon/Scripts/slurm_delete_SCRMshaw_projectdir.sh $PROJECT_DIR 

fi
	