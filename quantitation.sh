#!/bin/bash
#SBATCH -N 1                    #number of nodes for the job
#SBATCH --cpus-per-task=10      #number of cpus per task
#SBATCH --mem=48Gb    		#total memory per node in GB
#SBATCH -t 24:00:00     	#amount of time requested for the complete job
#SBATCH -p standard             #cluster partition
#SBATCH -e slurm-%j.err		#standard error
#SBATCH --output slurm-%j.out  	#standard output
#SBATCH -A kumarlab 

#############################################################################################################################################
##
## This script runs mapping of reads to genome and transcriptome
## The output will be saved in FASTQC directory
## 
#############################################################################################################################################

#Arg1 is the list of samples
#Arg2 is the name of present working directory
#Arg3 is the first read suffix "_R1_001.fastq.gz"
#Arg4 is 2nd read suffix "_R2_001.fastq.gz"
#Arg5 is the genome fasta file. In our case the file "Mus_musculus.GRCm38.dna.primary_assembly.fa" is gtf file.  
#Arg6 is name of the folder where index related files will be saved. For example Mus_musculus.GRCm38.91.chr.gtf_for150bpreads
#Arg7 is the subject overhang. This should be length of read minus one. In our case length of the read is 150 so this value should be 149
#Arg8 is number of cores. In our case this should be 10 because each workshop participants are approved for 10 cores and 24 cores to use.
#Arg9 is gtf file. In this case "Mus_musculus.GRCm38.91.chr.gtf"  



date +"%d %B %Y %H:%M:%S"

# load modules
module load star/2.7.2b
#star/2.7.9a
module load samtools
module load parallel/20200322
module load bioconda/py3.8

#Step 5: Quantitation
exec<$1
while read SAMPLES
        do
echo "cd $2/${SAMPLES}; samtools view -F 4 Aligned.sortedByCoord.out.bam | htseq-count -m intersection-nonempty -i gene_id -r pos -s no - $9 > $SAMPLES-gene_id.out"
done | parallel -k -j 20


# unload modules
module purge
date +"%d %B %Y %H:%M:%S"


#Step 5: Quantitation
exec<$1
while read SAMPLES
        do
echo "cd $2/${SAMPLES}; samtools view -F 4 Aligned.sortedByCoord.out.bam | htseq-count -m intersection-nonempty -i gene_id -r pos -s no - $9 > $SAMPLES-gene_id.out"
done | parallel -k -j 20


#Adding the gene-name, gene length, gene type and calculating FPKM

bash /project/UVABX-PK-temp/BIOINFO3/RNASEQ/RNASEQ-PIPELINE-STAR-HTSEQ-COUNT/compute-geneid-ensemble-v27.fpkm.sh Sample_Name /project/UVABX-PK-temp/BIOINFO3/RNASEQ/RNASEQ-PIPELINE-STAR-HTSEQ-COUNT/gencode.v27.geneid-ensembleid-start-end.totalexonssize.bed

