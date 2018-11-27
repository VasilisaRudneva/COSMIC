# COSMIC
Find mutation hotspots from COSMIC data

### Download VCF file with coding mutations from [COSMIC](https://cancer.sanger.ac.uk/cosmic)
Process input VCF file
```
cat CosmicCodingMuts.vcf | grep -v "#" | awk '{print $3"\t"$1"\t"$2"\t"$8}' | perl -ne 'my @all=split(";",$_);my @res1=split("GENE=", $all[0]); @res2=split("CNT=", pop(@all)); print "$res1[0]\t$res2[1]";' > CosmicCodingMuts.vcf.forR
```

### Manhattan plot
```
cat MutHotspots.Manhattan.R | R --vanilla --slave &
```

### Merge single variants into genomic loci, in which variants are closer than 10,000 bp to each other
Split by chromosome, sort then merge mutations
```
chromosomes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT"
for c in $chromosomes
do
echo chr$c
cat CosmicCodingMuts.vcf.forR | awk -v chr=${c} '{if($2==chr) print}' | sort -k2,2n -k3,3n > CosmicCodingMuts.vcf.forR.chr${c}.txt 
perl Merge_mutations_into_loci.pl CosmicCodingMuts.vcf.forR.chr${c}.txt chr${c} 10000 
rm CosmicCodingMuts.vcf.forR.chr${c}.txt
done 
```
Merge into one BED file
```
cat CosmicCodingMuts.10000.mutations_count.chr*.txt | awk '$4>1' | awk '$5>29' | sort -k6,6n -k4,4n > CosmicCodingMuts.10000.mutations_count.all-chr.txt
rm CosmicCodingMuts.10000.mutations_count.chr*.txt
```

### Annotate with gene names from [Biomart](https://www.ensembl.org/)
Add "chr" to the beginning of each line
```
cat biomart.gene_coords.bed | awk '{print "chr"$0}' > biomart.gene_coords.CHR.bed
```
Use sort-bed tool from [BEDOPS](https://bedops.readthedocs.io/en/latest/index.html#) to sort both BED files
```
sort-bed CosmicCodingMuts.10000.mutations_count.all-chr.txt > CosmicCodingMuts.10000.mutations_count.all-chr.txt.sorted
sort-bed biomart.gene_coords.CHR.bed > biomart.gene_coords.CHR.bed.sorted
```
Use bedmap tool to make the output file Answer.txt with mutational hotspots and corresponding gene annotations
```
bedmap --echo --echo-map-id-uniq CosmicCodingMuts.10000.mutations_count.all-chr.txt.sorted biomart.gene_coords.CHR.bed.sorted | sed 's/|/   /g' | awk '$4>1' | awk '$5>29' | sort -k6,6rn -k4,4rn > Answer.txt
```



