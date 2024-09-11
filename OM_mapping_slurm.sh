#!/bin/bash -l

## OM_mapping_slurm.sh
## version 1.0
## 07-05-2024
## bug fixes 09-09-2024, 09-11-2024

## use the -g flag and path to GFF file if GFF output is desired

#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=48000
#SBATCH --output="OM_mapping_slurm_log"
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

module load foss
module load scipy-bundle
module load gff3-toolkit
module load bedtools

ulimit -s unlimited



if [[ $# -ne 0 ]]; then

	while getopts ":g" opt; do
		case ${opt} in
			
			g)
				OUTPUT_GFF=${OPTARG}
				;;
			:)
				echo "Must supply the GFF file to option -${OPTARG}"
				;;
			?)
				echo "Invalid option: -${OPTARG}"
				exit 1
				;;
		esac					
	done
else
	OUTPUT_GFF=false
	
fi		

#get the protein file name
species=$(basename $(pwd))
protein_file="${species}_protein.fs.maptxt"

#set the OM_mappingFlyToSCRMshawPredictions.py arguments
ft="/projects/academic/mshalfon/Mapping-D.mel-Orthologs/GCF_000001215.4_Release_6_plus_ISO1_MT_feature_table.txt"

mD="${species}_orthologer_output/DMEL_protein.fs.maptxt"
mX="${species}_orthologer_output/$protein_file"
og="${species}_orthologer_output/mydata.og_map"
sp1id="${species}.finalEdited.gff"
so="peaks_AllSets.bed"

#check that these files exist
for testfile in $ft $mD $mX $og $sp1id $so; do

	if [ -f "$testfile" ]; then	
		echo "File $testfile exists; continuing..." 
	else
		echo "File $testfile not found; exiting."
		exit 1
	fi		 
done

#run the main script
echo "running main script"
python /projects/academic/mshalfon/Mapping-D.mel-Orthologs/OM_mappingFlyOrthologsToSCRMshawPredictions.py -ft $ft -mD $mD -mX $mX -og $og -sp1id $sp1id -so $so


echo "doing BEDTools merge&sort"
#make a merged version too
bedtools sort -i SO_peaks_AllSets.bed | bedtools merge -c 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -o max,max,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,min > SO_merged_peaks_AllSets.bed

echo "renaming BED files"
#rename the files
mv peaks_AllSets.bed peaks_Allsets_$species.bed
mv SO_peaks_AllSets.bed SO_peaks_AllSets_$species.bed
mv SO_merged_peaks_AllSets.bed SO_merged_peaks_AllSets_$species.bed

#--------------- GFF option ------------------------------------------#
#provide the GFF option
if [ "$OUTPUT_GFF" ]; then
	
	echo -e "Making GFF output: sort, merge, and convert\n\n"
	
	#convert to GFF:
	awk -F'\t' '{OFS="\t"; start=$2+1; print $1, "SCRMshaw", "cis-regulatory_region", start, $3, $5, ".", ".", "ID=scrm_"$18";amplitude="$4";trainingSet="$16";method="$17";rank="$18}' SO_merged_peaks_AllSets.bed > SO_merged_peaks_AllSets.gff
	
	#merge the files and sort using GFF3_toolkit
	
	echo -e "concatenating and running gff3_sort\n\n"
	
	cat $GFF_file SO_merged_peaks_AllSets.gff > tmp.gff
	
	gff3_sort -g tmp.gff -og combined_annotation.gff -r
	
	echo "renaming GFF files"
	#rename the files
	mv SO_merged_peaks_AllSets.gff SO_merged_peaks_AllSets_$species.gff
	mv tmp.gff combined_annotation_$species.gff
	mv combined_annotation.gff combined_sorted_annotation_$species.gff


else
	echo -e "No GFF3 output requested\n"
fi	




echo "All Done!"


