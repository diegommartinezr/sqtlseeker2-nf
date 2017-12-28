#!/usr/bin/env Rscript

#### Test gene/SNP association (nominal pass)

## 1. Load libraries and arguments

library(optparse)
library(sQTLseekeR2)

option_list <- list(
    make_option(c("-t", "--transcript_expr"), type = "character",
                help = "Prepared transcript expression RData file", metavar = "FILE"),
    make_option(c("-i", "--indexed_geno"), type = "character",
                help = "Indexed genotype file", metavar = "FILE"),
    make_option(c("-g", "--gene_location"), type = "character",
                help = "gene location chunk file", metavar = "FILE"),
    make_option(c("-o", "--output_file"), type = "character", help = "output file", 
                metavar = "FILE"),
    make_option(c("-l", "--ld"), type = "numeric", 
                help = "Cluster SNPs in LD >= ld [default %default]", 
                metavar = "NUMERIC", default = NULL),
    make_option(c("-S", "--Seed"), type = "numeric", 
                help = "Set seed for random processess", 
                metavar = "NUMERIC", default = 123),
    make_option(c("-s", "--svqtl"), action = "store_true", 
                help = "svQTL test will be performed [default %default]", 
                default = FALSE),
    make_option(c("-v", "--verbose"), action = "store_true", 
                help = "print genes and transcripts filtered out [default %default]",
                default = FALSE)
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

## 2. Input files: prepared transcript expression, genotypes (indexed) and gene location (chunk) 

trans.expr.p.f <- opt$transcript_expr
indexed.geno.f <- opt$indexed_geno
gene.loc.chunk <- opt$gene_location 
output.f <- opt$output_file
svqtl<- opt$svqtl
LD <- opt$ld

if ( is.null(trans.expr.p.f) || is.null (indexed.geno.f) || is.null(gene.loc.chunk) || is.null (output.f) ){
    print_help(opt_parser)
    stop("Missing/not found input files", call.= FALSE)
}

load(trans.expr.p.f)                                                            # Load tre.df
genes.bed <- read.table(gene.loc.chunk, header = FALSE, as.is = TRUE)           # Load chunk
colnames(genes.bed) <- c("chr", "start", "end", "geneId")                       # Name chunk
genes <- genes.bed$geneId                                                       # Get gene names
tre.df <- subset(tre.df, geneId %in% genes)                                     # Subset tre.df


## 3. Run association test and write result

set.seed(opt$Seed)
res.df <- sqtl.seeker(tre.df, indexed.geno.f, genes.bed, 
                      svQTL = svqtl, verbose = opt$verbose, ld.filter = LD)

write.table(res.df, file = output.f, quote = FALSE,
            row.names = FALSE, 
            col.names = ifelse(output.f == "nominal_out.1", TRUE, FALSE), 
            sep = "\t")

#### END