#############################################################
##
## Author: Pankaj Kumar
## Email: pk7z@virginia.edu
## Location: Bioinformatics Core
##
############################################################

#Arg1 is the list of sample name "Sample_Name"
#Arg2 output file name "rnaseq_workshop_count_matrix.txt" 
cat $1 | awk '{printf ("%s\t",$1)}' | awk '{printf ("Ensembl-Gene-Id\tGene-Id\t%s\n",$0)}'> $2
PASTE2=`cat $1 | awk '{printf ("%s/*gene_id-fpkm.out ",$1)}'`
echo "paste $PASTE2" > Foo.sh

sh ./Foo.sh | awk '{for (i=6; i<=NF; i=i+6) if(i==6) {printf ("%s\t%s\t%.1f\t",$1,$(i-3),$(i-4))} else if (i>6 && i<NF) {printf ("%.1f\t",$(i-4))}  else if (i==NF) {printf ("%.1f\n",$(i-4))}}' >> $2
