#############################################################
##
## Author: Pankaj Kumar
## Email: pk7z@virginia.edu
## Location: Bioinformatics Core
##
############################################################

#Step 1
#Login to Rivanna

ssh pk7z@rivanna.hpc.virginia.edu # Replace the pk7z with your computing id

#Step 2
#Change directory 

cd /scratch/$USER


# I am adding this additional step without step number to clean the previous data

rm -rf rnaseq_workshop


#Step 3
#Make a new directory named "rnaseq_workshop"

mkdir rnaseq_workshop

#Step 4
#Change to rnaseq_workshop directory 

cd rnaseq_workshop


#Step 5
#Make a symlink of all the fastq files so you could see them in your directory without creating additional copy. Please do not copy these files to your personal computer.

#ln -s /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/fastq/* .
ln -s /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/fastq/*fastq.gz .


#Notes: without copying the data now you could see all the fastq files in your directory. The idea is to have all the raw sequencing files in your working directory.


#Step 6 (Time: 10 min)
#Check the quality of the raw sequencing data (RNA-seq data)
#We are going to use fastqc program for this

#sbatch /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/fastqc.sh 

sbatch /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/fastqc.sh 


#Step 7
#Combine the fastqc report using multiqc (this program is not installed on Rivanna). Type the below two command one by one on your terminal

module load bioconda/py3.8

multiqc .



#Step 8 Review the multiqc report. 

cp multiqc_report.html /home/$USER/.

#############################################################################################################################################
##
## Accessing multiqc report
##
## 1. Open a web browser and go to https://rivanna-portal.hpc.virginia.edu
## 2. Use your Netbadge credentials to log in.
## 3. Click on the "files" tab and select mutiqc.html in your working directory
## 4. Right click on file and open it in new tab
##
#############################################################################################################################################


#Step 9
#Making sample list. 

ls *_R1_001.fastq.gz | sed -e s/_R1_001.fastq.gz//g > Sample_Name

#Step 10
#Check the sample name. Sample name should be unique.

cat Sample_Name

#Step 11 (Time: 4 min) 
#After reviewing the multiqc report it was found that a significant fraction of reads are contaminated with adaptor sequence. Why? Any idea?
#We are going to use cutadapt for the adaptor removal. But before that we need to find the adaptor sequence. In the current case we have paired-end reads so we have to identify two adaptors.

#sbatch /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/Identify-Adaptor.sh Sample_Name _R1_001.fastq.gz _R2_001.fastq.gz 

sbatch /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/Identify-Adaptor.sh Sample_Name _R1_001.fastq.gz _R2_001.fastq.gz

###################################################################
##
## Adaptor-R1.txt has R1 adaptor sequence 
## Adaptor-R2.txt has R2 adaptor sequence 
## Inspect Adaptor sequence (Have fun!)
##
##################################################################

cat Adaptor-R1.txt
cat Adaptor-R2.txt


zcat Naive-memory-sample-4_R2_001.fastq.gz | head -500 | grep AGATCGGAAGAGCGTCGTGTAG 
#Inspect sequence upstream and downstream from the Adaptor sequence. Can you see any pattern?  


#Step 12 (Time: 10 min)
#Remove the adaptor sequence from the raw sequencing data. 

#sbatch /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/cutadapt.sh Sample_Name Adaptor-R1.txt Adaptor-R2.txt 

sbatch /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/cutadapt.sh Sample_Name Adaptor-R1.txt Adaptor-R2.txt 



#Step 13 
#Making index, mapping the reads to genome and transcriptome and finally quantitation
#https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/
#Arg1 is the list of /scratch/$USER/rnaseq_workshop/Sample_Name
#Arg2 is the name of present working directory. Type pwd in your terminal. copy and paste that path in place of $2
#Arg3 is the first read suffix "_R1_001.fastq.gz"
#Arg4 is 2nd read suffix "_R2_001.fastq.gz"
#Arg5 is the genome fasta file. In our case the file "Mus_musculus.GRCm38.dna.primary_assembly.fa" is gtf file.  
#Arg6 is name of the folder where index related files will be saved. For example Mus_musculus.GRCm38.91.chr.gtf_for150bpreads
#Arg7 is the subject overhang. This should be length of read minus one. In our case length of the read is 150 so this value should be 149
#Arg8 is number of cores. In our case this should be 10 because each workshop participants are approved for 10 cores and 24 cores to use.
#Arg9 is gtf file. In this case "Mus_musculus.GRCm38.91.chr.gtf"  



#sbatch /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/mapping.sh /scratch/$USER/rnaseq_workshop/Sample_Name /scratch/$USER/rnaseq_workshop -ADRM_R1_001.fastq.gz -ADRM_R2_001.fastq.gz /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.dna.primary_assembly.fa  /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp 149 20 /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.91.chr.gtf 

sbatch /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/mapping.sh /scratch/$USER/rnaseq_workshop/Sample_Name /scratch/$USER/rnaseq_workshop -ADRM_R1_001.fastq.gz -ADRM_R2_001.fastq.gz /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.dna.primary_assembly.fa  /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp 149 20 /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.91.chr.gtf 


#Workshop Day 2

#Step 14
#Calculate FPKM

#bash /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/ensemble-v27-geneid-count-fpkm.MM10.sh /scratch/$USER/rnaseq_workshop/Sample_Name /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.91.chr.gtf.geneid-ensembleid-start-end.totalexonssize.bed /scratch/$USER/rnaseq_workshop
bash /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/ensemble-v27-geneid-count-fpkm.MM10.sh /scratch/$USER/rnaseq_workshop/Sample_Name /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.91.chr.gtf.geneid-ensembleid-start-end.totalexonssize.bed /scratch/$USER/rnaseq_workshop


#Step 15
#Making count matrix

#bash /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/make-count-matrix.sh /scratch/$USER/rnaseq_workshop/Sample_Name /scratch/$USER/rnaseq_workshop/rnaseq_workshop_count_matrix.txt
bash /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/make-count-matrix.sh /scratch/$USER/rnaseq_workshop/Sample_Name /scratch/$USER/rnaseq_workshop/rnaseq_workshop_count_matrix.txt


#Step 16
#Making fpkm matrix

#bash /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/make-fpkm-matrix.sh /scratch/$USER/rnaseq_workshop/Sample_Name /scratch/$USER/rnaseq_workshop/rnaseq_workshop_fpkm_matrix.txt


bash /project/rivanna-training/rna-seq_21/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/make-fpkm-matrix.sh /scratch/$USER/rnaseq_workshop/Sample_Name /scratch/$USER/rnaseq_workshop/rnaseq_workshop_fpkm_matrix.txt

############################################################################################
##
## You just generated a count matrix that yoy will use in RNA-Seq workshp Day 2
## Check file "rnaseq_workshop_count_matrix.txt in "/scratch/$USER/rnaseq_workshop/" folder
## Happy Computing!
############################################################################################


 
 

