#!/bin/bash
#SBATCH -N 1                    #number of nodes for the job
#SBATCH --cpus-per-task=10      #number of cpus per task
#SBATCH --mem=24Gb              #total memory per node in GB
#SBATCH -t 02:00:00             #amount of time for the whole job
#SBATCH -p standard             #cluster partition
#SBATCH -e slurm-%j.err         #standard error
#SBATCH --output slurm-%j.out   #standard output
#SBATCH -A kumarlab 
 
 
 
 
 
#############################################################################################################################################
##
## This script removes the adaptor sequence from the raw sequencing data
## The output will be saved in the same directory with file extention "ADRM_R1_001.fastq.gz" and "ADRM_R2_001.fastq.gz"
## 
#############################################################################################################################################
 
date +"%d %B %Y %H:%M:%S"
 
# load modules
#module load cutadapt/3.4
module load cutadapt
 
#This script removes adaptor sequence from RNASeq paired end raw file.
#Arg1 is the list of paired end files ("only name of file without "R1_001.fastq.gz" differentiating suffix")
#ARG2 is the first adaptor sequence "Adaptor-R1.txt"
#Arg3 is the second adaptor sequence "Adaptor-R2.txt"
#STAR aligner gives error when it encounters zero length or too short read. The "-m 15 option is to avoid the writing of too short reads in to new fastq output files"
#Usage bash cutadapt.sh Sample_Name Adaptor-R1.txt Adaptor-R2.txt 
 
Adaptor1=`cat $2`
Adaptor2=`cat $3`
cat $1 | while read line
        do
cutadapt -m 15 -j 8 -a $Adaptor1 -A $Adaptor2 -o $line-ADRM_R1_001.fastq.gz -p $line-ADRM_R2_001.fastq.gz $line\_R1_001.fastq.gz $line\_R2_001.fastq.gz > $line-output.err 
done
 
# unload modules
module purge
 
date +"%d %B %Y %H:%M:%S"
