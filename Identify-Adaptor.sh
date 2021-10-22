#!/bin/bash
#SBATCH -N 1                    #number of nodes for the job
#SBATCH --cpus-per-task=4      #number of cpus per task
#SBATCH --mem=20Gb    		#total memory per node in GB
#SBATCH -t 01:00:00     	#amount of time for the whole job
#SBATCH -p standard             #cluster partition
#SBATCH -e slurm-%j.err		#standard error
#SBATCH --output slurm-%j.out  	#standard output
#SBATCH -A kumarlab 

#############################################################################################################################################
##
## Author: Pankaj Kumar
## Email: pk7z@virginia.edu
## Location: Bioinformatics Core
##
## This script runs a custum script for Adaptor sequence identification
## The output will be saved in current working directory
## For paired end read this script identifies two adaptor sequence named "Adaptor-R1.txt" and "Adaptor-R2.txt". 
## Look for Adaptor sequence in the current working directory 
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

#Arg1 is the list of file name
#Arg2 is the suffix name of read1. If the fastq file name is "Naive-memory-sample-1_R1_001.fastq.gz" then the suffix would be "_R1_001.fastq.gz" 
#Arg3 is the suffix name of read2. If the fastq file name is "Naive-memory-sample-1_R2_001.fastq.gz" then the suffix would be "_R2_001.fastq.gz"
#Note Change the command zcat or cat if your fastq file is not zipped 
#Usage Identify-Adaptor.sh  _R1_001.fastq.gz _R2_001.fastq.gz 
cat $1 | while read line
	do
	zcat $line$2 | paste - - - - | awk '{print $3}' | cut -c 100-150 | head -1000000 | sort | uniq -c | sort -nk1 | tail -1 > $line-AdaptorR1.txt 	
	zcat $line$3 | paste - - - - | awk '{print $3}' | cut -c 100-150 | head -1000000 | sort | uniq -c | sort -nk1 | tail -1 > $line-AdaptorR2.txt 
done	

cat *AdaptorR1.txt | awk '{print $2}' | cut -c 1-22 | sort | uniq -c | sort -nk1 | tail -1 | awk '{print $2}' > Adaptor-R1.txt
cat *AdaptorR2.txt | awk '{print $2}' | cut -c 1-22 | sort | uniq -c | sort -nk1 | tail -1 | awk '{print $2}' > Adaptor-R2.txt

#Adaptor-R1.txt has R1 adaptor sequence 
#Adaptor-R2.txt has R2 adaptor sequence 
rm *-AdaptorR1.txt
rm *-AdaptorR2.txt
date +"%d %B %Y %H:%M:%S"
