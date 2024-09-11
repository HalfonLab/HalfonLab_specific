#!/bin/bash

#transfer_SCRMshaw_results.sh
#this script transfers results from scratch to the lab project directory
#it assumes all filenames and directories are as specified in the Halfon Lab protocol

#run this script from the /vscratch/grp-mshalfon/my_genome directory

#get the species basename from the directory name
species=$(basename $(pwd))

#make a directory in the lab "SCRMshaw_results" directory to store the data
resultsDir="/projects/academic/mshalfon/SCRMshaw_results/${species}_results"
mkdir $resultsDir
mkdir $resultsDir/logs

#move stuff
mv Slurm_$species.sh $resultsDir/

#log files
mv ${species}_*slurm_log $resultsDir/logs
mv HDtestPredictions* $resultsDir/logs
mv output_postProcRun1.text $resultsDir/logs

mv orthologer_slurm_output_log $resultsDir/logs
mv ${species}_orthologerOutputlog $resultsDir/logs
mv OM_mapping_slurm_log $resultsDir/logs
mv log_flankingMoreThanOneGenesFromAllSets.txt $resultsDir/logs

#SCRMshaw results files
mv scrmshawOutput_offset_0to240.bed $resultsDir
mv peaks_Allsets_$species.bed $resultsDir
mv SO_peaks_Allsets_$species.bed $resultsDir
mv SO_merged_peaks_Allsets_$species.bed $resultsDir

#check for GFF files, if they exist, move them
if [ -f SO_merged_peaks_AllSets_$species.gff ]; then
	mv SO_merged_peaks_AllSets_$species.gff $resultsDir
	mv combined_annotation_$species.gff $resultsDir
	mv combined_sorted_annotation_$species.gff $resultsDir
fi	


#orthologer mapping files
mv ${species}_orthologer_output/ $resultsDir
mv $species.finalEdited.gff $resultsDir
