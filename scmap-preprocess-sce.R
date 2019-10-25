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

# Matrix-ify any e.g. sparse matrices in assays
assays(SingleCellExperiment) <- lapply(assays(SingleCellExperiment), function(x){
    if (! is.matrix(x)){
        x <- as.matrix(x)
    }
    x
})

assay_names <- names(assays(SingleCellExperiment))

# We need counts for dropout detection. If normcounts is present, just reassign those

if (! 'counts' %in% assay_names){
    if ( 'normcounts' %in% assay_names){
        names(assays(SingleCellExperiment))[names(assays(SingleCellExperiment)) == 'normcounts'] <- 'counts'
        assay_names <- names(assays(SingleCellExperiment))
    }else{
        stop("Neither 'counts' nor 'normcounts' are populated in input object. An unlogged matrix is necessary for dropout rate calculations and I can't proceed without one of these.")
    }
}
# We need the logcounts() slot, so calculate it if it's not present
if (! 'logcounts' %in% assay_names){
    if("normcounts" %in% assay_names ){
        logcounts(SingleCellExperiment) <- log2(normcounts(SingleCellExperiment) + 1)
    } else if("counts" %in% names(assays(SingleCellExperiment))) {
        logcounts(SingleCellExperiment) <- log2(counts(SingleCellExperiment) + 1)
    } 
}

# use gene names as feature symbols
rowData(SingleCellExperiment)$feature_symbol <- rownames(SingleCellExperiment)
SingleCellExperiment <- SingleCellExperiment[!duplicated(rownames(SingleCellExperiment)), ] 

# write the serialised version of SCE object into provided path 
saveRDS(SingleCellExperiment, file = opt$output_sce_object)
