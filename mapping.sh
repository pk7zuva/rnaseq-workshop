#!/bin/bash
#SBATCH -N 1                    #number of nodes for the job
#SBATCH --cpus-per-task=20      #number of cpus per task
#SBATCH --mem=96Gb    		#total memory per node in GB
#SBATCH -t 24:00:00     	#amount of time requested for the complete job
#SBATCH -p standard             #cluster partition
#SBATCH -e slurm-%j.err		#standard error
#SBATCH --output slurm-%j.out  	#standard output
#SBATCH -A kumarlab 

#############################################################################################################################################
##
## This script runs mapping of reads to genome and transcriptome
## The output will be saved in current working directory
## The final file 
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
#Arg10 is File that has gene length information "Mus_musculus.GRCm38.91.chr.gtf.geneid-ensembleid-start-end.totalexonssize.bed" 
#Arg11 is Count matrix file "rnaseq_workshop_count_matrix.txt" 

date +"%d %B %Y %H:%M:%S"

# load modules
module load star/2.7.2b
#star/2.7.9a
module load samtools
module load parallel/20200322
module load bioconda/py3.8


# Step 1: Indexing the genome
#rm -rf $6
#mkdir $6
#STAR --runThreadN $8 --runMode genomeGenerate --genomeDir $6 --genomeFastaFiles $5 --sjdbOverhang $7 --sjdbGTFfile $9 --runThreadN $8
#STAR --runMode genomeGenerate --genomeDir Mus_musculus.GRCm38.91.chr.gtf_for75bpreads --genomeFastaFiles Mus_musculus.GRCm38.dna.primary_assembly.fa --sjdbOverhang 74 --sjdbGTFfile Mus_musculus.GRCm38.91.chr.gtf --runThreadN 24


# Step 2: Alignment 1st Pass.


exec<$1
while read SAMPLES
	do
cd $2
mkdir $SAMPLES
STAR --genomeDir $6 \
--readFilesIn ${SAMPLES}$3 ${SAMPLES}$4 \
--runThreadN $8 \
--outFilterMultimapScoreRange 1 \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 10 \
--alignIntronMax 500000 \
--alignMatesGapMax 1000000 \
--sjdbScore 2 \
--alignSJDBoverhangMin 1 \
--genomeLoad NoSharedMemory \
--readFilesCommand zcat \
--outFilterMatchNminOverLread 0.33 \
--outFilterScoreMinOverLread 0.33 \
--sjdbOverhang $7 \
--outSAMstrandField intronMotif \
--outSAMtype None \
--outSAMmode None \
--outFileNamePrefix ${SAMPLES}
done

#Step 3: Intermediate Index Generation.

exec<$1
while read SAMPLES
	do
cd $2
STAR --runMode genomeGenerate \
--genomeDir $2/$SAMPLES \
--genomeFastaFiles $5 \
--sjdbOverhang $7 \
--runThreadN $8 \
--sjdbFileChrStartEnd $2/${SAMPLES}SJ.out.tab
done


#Step 4: Alignment 2nd Pass.
exec<$1
while read SAMPLES
        do

cd $2/${SAMPLES}
STAR --genomeDir $6 \
--readFilesIn $2/${SAMPLES}$3 $2/${SAMPLES}$4 \
--runThreadN $8 \
--outFilterMultimapScoreRange 1 \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 10 \
--alignIntronMax 500000 \
--alignMatesGapMax 1000000 \
--sjdbScore 2 \
--alignSJDBoverhangMin 1 \
--genomeLoad NoSharedMemory \
--limitBAMsortRAM 39128494295 \
--readFilesCommand zcat \
--outFilterMatchNminOverLread 0.33 \
--outFilterScoreMinOverLread 0.33 \
--sjdbOverhang $7 \
--quantMode TranscriptomeSAM GeneCounts \
--outSAMstrandField intronMotif \
--outSAMattributes NH HI NM MD AS XS \
--outSAMunmapped Within \
--outSAMtype BAM SortedByCoordinate \
--outSAMheaderHD @HD VN:1.4 \
--outSAMattrRGline ID:${SAMPLES} SM:${SAMPLES}
done

#Calculating FPKM and adding gene name
bash /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/ensemble-v27-geneid-count-fpkm.MM10.sh $1 $10 $2

#Making count matrix
bash /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/make-count-matrix.sh $1 $11

# unload modules
module purge
date +"%d %B %Y %H:%M:%S"
