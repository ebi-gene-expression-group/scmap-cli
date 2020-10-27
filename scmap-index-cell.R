#!/usr/bin/env Rscript 

# Create an index for a dataset to enable fast approximate nearest neighbour search.

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))

# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# parse options
option_list = list(
  make_option(
    c("-i", "--input-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "singleCellExperiment object containing expression values and experimental information. Must have been appropriately prepared."
  ),
  make_option(
    c("-m", "--number-chunks"),
    action = "store",
    default = NULL,
    type = 'numeric',
    help = 'Number of chunks into which the expr matrix is split.'
  ),
  make_option(
    c("-k", "--number-clusters"),
    action = "store",
    default = NULL,
    type = 'numeric',
    help = 'Number of clusters per group for k-means clustering.'
  ),
  make_option(
    c("-f", "--train-id"), 
    action = "store",
    default = NA,
    type = 'character',
    help = 'ID of the training dataset (optional)'
  ),
  make_option(
    c("-e", "--remove-mat"), 
    action = "store_true",
    default = FALSE,
    type = 'logical',
    help = 'Should expression data be removed from index object? Default: FALSE'
  ),
  make_option(
    c("-r", "--random-seed"),
    action = "store",
    default = NULL,
    type = 'numeric',
    help = 'Set random seed to make scmap-cell reproducible.'
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'SingleCellExperiment'."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_object_file'))

if (!is.null(opt$number_chunks) && opt$number_chunks == 0){
   opt$number_chunks = NULL
}
if (!is.null(opt$number_clusters) && opt$number_clusters == 0){
    opt$number_clusters = NULL
}

# Once arguments are satisfcatory, load scmap package

suppressPackageStartupMessages(require(scmap))
suppressPackageStartupMessages(require(SingleCellExperiment))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Read R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# Set random seed
if (is.null(opt$random_seed)){
    set.seed(1)
}

# Run indexing function
SingleCellExperiment <- indexCell(SingleCellExperiment, M = opt$number_chunks,
                                                        k = opt$number_clusters)

# add dataset field to the SingleCellExperiment object 
if(!is.na(opt$train_id)){
    attributes(SingleCellExperiment)$dataset = opt$train_id
    } else{
        attributes(SingleCellExperiment)$dataset = NA
}

# Remove expression matrix, if specified
if(opt$remove_mat){
    for(assay_type in c('counts', 'normcounts', 'logcounts')){
        if(assay_type %in% names(assays(SingleCellExperiment))){
            assays(SingleCellExperiment)[assay_type] = NULL
        }
    } 
}

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)
