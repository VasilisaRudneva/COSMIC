# Vasilisa A. Rudneva
# Nov 2018
# 
# Make Manhattan plot from coding mutations from COSMIC 

require("qqman")

md.c=read.table("CosmicCodingMuts.vcf.forR", header = F, sep = "\t", stringsAsFactors = F)
md.c=md.c[c("V1", "V2", "V3", "V5")]
colnames(md.c)=c("SNP", "CHR", "BP", "P")

md.c=md.c[!md.c$CHR %in% c("MT", "X", "Y"),]
md.c$CHR=as.integer(md.c$CHR)
md.c$P=as.numeric(md.c$P)

#str(md.c); head(md.c); tail(md.c)

png('Coding_mut.Manhattan.png')
manhattan(md.c, logp=F, ylab="How many samples have this mutation")
dev.off()
