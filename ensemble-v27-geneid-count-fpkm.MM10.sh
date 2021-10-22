#############################################################
##
## Author: Pankaj Kumar
## Email: pk7z@virginia.edu
## Location: Bioinformatics Core
##
############################################################

#Arg1 is list of sample "Sample_Name"
#Arg2 is file /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.91.chr.gtf.geneid-ensembleid-start-end.totalexonssize.bed
#ARG3 is present working directory "/scratch/$USER/rnaseq_workshop" 
#Usage bash /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/script/ensemble-v27-geneid-count-fpkm.MM10.sh Sample_Name /project/UVABX-PK/BIOINFORMATICS-CORE-RNASEQ-WORKSHOP-OCT-NOV-2021/REFERENCE-GENOME-STAR-INDEZ-150bp/Mus_musculus.GRCm38.91.chr.gtf.geneid-ensembleid-start-end.totalexonssize.bed /scratch/$USER/rnaseq_workshop 
exec<$1
while read line
        do
        cd $3/$line
        awk 'NR>4' ReadsPerGene.out.tab | sort -dk1 | awk '!x[$1]++' | awk '{print $1,$2}' > TeMp1
awk '{print $5}' $2 | awk 'BEGIN {FS="\."} {print $1}' > TeMp4

paste $2 TeMp4 > TeMp5

        sort -dk9 TeMp5 | awk '!x[$9]++' > TeMp2
        paste TeMp1 TeMp2 | awk '$1==$11 {print $1,$2,$9,$10,$11}' > TeMp3
        TPCRALL=`awk '{f2+=\$2} END {print f2}' TeMp3`
        paste TeMp1 TeMp2 | awk '$1==$11 && $8=="protein_coding" {print $1,$2,$9,$10,$11}' > TeMp3
        TPCR=`awk '{f2+=\$2} END {print f2}' TeMp3`
        paste TeMp1 TeMp2 | awk ' {print $1,$2,$9,$10,$11,$8}' > TeMp3
echo $line $TPCR $TPCRALL
        echo "awk '{print \$1,\$2,\$3,\$4,(\$2*1000000000)/(\$4*$TPCR),\$6}' TeMp3" > Foo.sh
        sh ./Foo.sh | awk '{printf ("%s\t%6d\t%10s\t%6d\t%6.1f\t%s\n",$1,$2,$3,$4,$5,$6)}' > $line-gene_id-fpkm.out
rm TeMp1 TeMp2 TeMp3 TeMp4 TeMp5
done
