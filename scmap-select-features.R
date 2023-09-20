#!/usr/bin/env Rscript 

# Find the most informative features (genes/transcripts) for projection

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
    c("-n", "--n-features"),
    action = "store",
    default = 500,
    type = 'numeric',
    help = 'Number of the features to be selected.'
  ),
  make_option(
    c("-p", "--output-plot-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Optional file name in which to store a PNG-format plot of log(expression) versus log(dropout) distribution for all genes. Selected features are highlighted with the red colour."
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

# Once arguments are satisfcatory, load scmap package

suppressPackageStartupMessages(require(scmap))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Read R object
SingleCellExperiment <- readRDS(opt$input_object_file)

if (is.na(opt$output_plot_file)){
  SingleCellExperiment <- selectFeatures(SingleCellExperiment, n_features = opt$n_features, suppress_plot = TRUE)
}else{
  png(file = opt$output_plot_file)
  SingleCellExperiment <- selectFeatures(SingleCellExperiment, n_features = opt$n_features, suppress_plot = FALSE)
  dev.off()
}

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)
