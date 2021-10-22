#!/bin/bash
#SBATCH -N 1                    #number of nodes for the job
#SBATCH --cpus-per-task=10      #number of cpus per task
#SBATCH --mem=20Gb    		#total memory per node in GB
#SBATCH -t 01:00:00     	#amount of time for the whole job
#SBATCH -p standard             #cluster partition
#SBATCH -e slurm-%j.err		#standard error
#SBATCH --output slurm-%j.out  	#standard output
#SBATCH -A kumarlab 
#SBATCH --mail-user=$USER@virginia.edu

#############################################################################################################################################
##
## Author: Pankaj Kumar
## Email: pk7z@virginia.edu
## Location: Bioinformatics Core
##
############################################################
## This script runs fastqc files in the current working directory 
## The output will be saved in FASTQC directory
## 
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"
# load modules
module load fastqc

mkdir FASTQC
fastqc -t 10 *.gz -o FASTQC

# unload modules
module purge
date +"%d %B %Y %H:%M:%S"
