#!/bin/bash -l

##this version updated 06-06-2024 to include options for outputting GFF results
##minor corrections 07-06-2024


### Note: the path to the proper GFF file needs to be provided on the command line when running this script! ###

#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=48000
#SBATCH --output="output_postProcessing.txt"
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

module load foss
module load scipy-bundle
module load pybedtools/ 
module load macs2
module load gff3-toolkit
module load bedtools

ulimit -s unlimited


GFF_file=false

if [[ $@ -ne 0 ]]; then

	while getopts ":i:g" opt; do
		case ${opt} in
			i) 
				GFF_file=${OPTARG}
				;;
			g)
				OUTPUT_GFF=true
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
	echo "Usage: $0 -i [GFF file] -g (optional, creates GFF output)"
	exit 1
fi		

if [ "$GFF_file" = false ]; then
  echo "Missing GFF file on command line"
  exit 1
fi 



#concatenate the 25 instances and call peaks
echo -e "Running post_processing_HalfonLab.sh\n\n"
/projects/academic/mshalfon/Scripts/post_processing_HalfonLab.sh $GFF_file

#this part only if GFF output is called
if [ "$OUTPUT_GFF" = true ]; then
	
	echo -e "Making GFF output: sort, merge, and convert\n\n"
	
	#sort and merge file
	bedtools sort -i peaks_AllSets.bed | bedtools merge -c 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -o max,max,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,distinct,min > peaks_AllSets.merged.bed
	
	#convert to GFF:
	awk -F'\t' '{OFS="\t"; start=$2+1; print $1, "SCRMshaw", "cis-regulatory_region", start, $3, $5, ".", ".", "ID=scrm_"$18";amplitude="$4";trainingSet="$16";method="$17";rank="$18}' peaks_AllSets.merged.bed > peaks_AllSets.merged.gff
	
	#merge the files and sort using GFF3_toolkit
	
	echo -e "concatenating and running gff3_sort\n\n"
	
	cat $GFF_file peaks_AllSets.merged.gff > tmp.gff
	gff3_sort -g tmp.gff -og combined_annotation.gff -r
	
	#clean up
	#rm tmp.gff

else
	echo -e "No GFF3 output requested\n"
fi	
	


echo "All Done!"
