#!/usr/bin/env Rscript 

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))

# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

option_list = list(
    make_option(
        c("-i", "--input-object"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Path to an SCE object in .rds format'
  ),
    make_option(
        c("-o", "--output-sce-object"),
        action = 'store',
        default = NA,
        type = 'character',
        help = "Path for the output object in .rds format"
  )
)

opt = wsc_parse_args(option_list, mandatory = c("input_object", "output_sce_object"))

suppressPackageStartupMessages(require(SingleCellExperiment))
suppressPackageStartupMessages(require(scmap))

if(!file.exists(opt$input_object)){
    stop("Input file does not exist")
}

# read in the SCE object 
SingleCellExperiment <- readRDS(opt$input_object)

# un-sparse and log-transform counts
if("normcounts" %in% names(assays(SingleCellExperiment))){
    normcounts(SingleCellExperiment) <- as.matrix(normcounts(SingleCellExperiment))
    logcounts(SingleCellExperiment) <- log2(normcounts(SingleCellExperiment) + 1)
} else if("counts" %in% names(assays(SingleCellExperiment))) {
    counts(SingleCellExperiment) <- as.matrix(counts(SingleCellExperiment))
    logcounts(SingleCellExperiment) <- log2(counts(SingleCellExperiment) + 1)
} else{
    stop("Incrorrect assay names in SCE object")
}  

# use gene names as feature symbols
rowData(SingleCellExperiment)$feature_symbol <- rownames(SingleCellExperiment)
SingleCellExperiment <- SingleCellExperiment[!duplicated(rownames(SingleCellExperiment)), ] 

# write the serialised version of SCE object into provided path 
saveRDS(SingleCellExperiment, file = opt$output_sce_object)