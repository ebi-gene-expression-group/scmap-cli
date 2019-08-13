#!/usr/bin/env Rscript 

# Calculates centroids of each cell type and merge them into a single table.

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
    c("-c", "--cluster-col"),
    action = "store",
    default = "cell_type1",
    type = 'character',
    help = "Column name in the 'colData' slot of the SingleCellExperiment object containing the cell classification information."
  ),
  make_option(
    c("-p", "--output-plot-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Optional file name in which to store a PNG-format heatmap-style index visualisation."
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
suppressPackageStartupMessages(require(SingleCellExperiment))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Read R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# Run indexing function
SingleCellExperiment <- indexCluster(SingleCellExperiment, cluster_col = opt$cluster_col)

if (! is.na(opt$output_plot_file)){
  png(file = opt$output_plot_file)
  heatmap(as.matrix(metadata(SingleCellExperiment)$scmap_cluster_index))
  dev.off()
}

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)
