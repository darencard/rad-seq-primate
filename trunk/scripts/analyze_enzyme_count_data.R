
rad_counts=read.table("RAD_coverage.txt")
names(rad_counts)=c("chr","start","end", "enz", "len", "str", "Allenopithecus", "Coast_langur", "CTA", "Mmulatta1", "Papio19349", "Tgelada871162")

rad_counts_only = rad_counts[,7:12]

rad_present = rad_counts_only > 0
rad_gt3     = rad_counts_only >= 3

rad_sums = rowSums(rad_present)
rad_sums_gt3 = rowSums(rad_gt3)

#	length(rad_sums[rad_sums == 6]) # 13456
#	length(rad_sums[rad_sums == 5]) # 23350
#	length(rad_sums[rad_sums == 4]) # 22890
#	length(rad_sums[rad_sums == 3]) # 18488
#	length(rad_sums[rad_sums == 2]) # 12136
#	length(rad_sums[rad_sums == 1]) # 10818
#	length(rad_sums[rad_sums == 0]) # 7590
#	
#	length(rad_sums[rad_sums >= 6]) # 13456
#	length(rad_sums[rad_sums >= 5]) # 36806
#	length(rad_sums[rad_sums >= 4]) # 59696
#	length(rad_sums[rad_sums >= 3]) # 78184
#	length(rad_sums[rad_sums >= 2]) # 90320
#	length(rad_sums[rad_sums >= 1]) # 101138
#	length(rad_sums[rad_sums >= 0]) # 108728

x = 0:6

### One or more reads --------------------------------------------------------------------

counts = lapply(x, get_counts <- function(c) length(rad_sums[rad_sums == c]))
counts = c(do.call("cbind",counts)) 
counts
pdf("~/RADseq_primates/RADprimates/paper/figs/seq_site_coverage_by_ind.pdf", height=4, width=4)
barplot(counts, 
	ylab="Count of Possible Sequencing Sites", 
	xlab="Number of Individuals with at Least One Read",
	names=x,
	col=1)
dev.off()

cumu_counts = lapply(x, get_cumu_counts <- function(c) length(rad_sums[rad_sums >= c]))
cumu_counts = c(do.call("cbind",cumu_counts)) 
cumu_counts
plot(cumu_counts ~ x)

cumu_pct = lapply(x, get_cumu_pct <- function(c) length(rad_sums[rad_sums >= c]) / 108728)
cumu_pct = c(do.call("cbind",cumu_pct)) 
cumu_pct
plot(cumu_pct ~ x)

### Greater than or equal to 3 reads -----------------------------------------------------

counts = lapply(x, get_counts <- function(c) length(rad_sums_gt3[rad_sums_gt3 == c]))
counts = c(do.call("cbind",counts)) 
counts
plot(counts ~ x)

cumu_counts = lapply(x, get_cumu_counts <- function(c) length(rad_sums_gt3[rad_sums_gt3 >= c]))
cumu_counts = c(do.call("cbind",cumu_counts)) 
cumu_counts
plot(cumu_counts ~ x)

cumu_pct = lapply(x, get_cumu_pct <- function(c) length(rad_sums_gt3[rad_sums_gt3 >= c]) / 108728)
cumu_pct = c(do.call("cbind",cumu_pct)) 
cumu_pct
plot(cumu_pct ~ x)

### One or more reads by Individual ------------------------------------------------------


colSums(rad_present)
#Allenopithecus   Coast_langur            CTA      Mmulatta1     Papio19349  Tgelada871162 
#         62824          47516          48440          77798          74582          68440 

colSums(rad_gt3)
#Allenopithecus   Coast_langur            CTA      Mmulatta1     Papio19349  Tgelada871162 
#         40244          24052          13104          32302          39062          50656 
