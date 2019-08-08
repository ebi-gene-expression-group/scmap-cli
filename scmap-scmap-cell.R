#!/usr/bin/env Rscript 

# For each cell in a query dataset, we search for the nearest neighbours by cosine distance within a collection of reference datasets..

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))

# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# parse options
option_list = list(
  make_option(
    c("-i", "--index-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "'SingleCellExperiment' object previously prepared with the scmap-index-cluster.R script."
  ),
  make_option(
    c("-p", "--projection-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "'SingleCellExperiment' object to project."
  ),
  make_option(
    c("-w", "--number-nearest-neighbours"),
    action = "store",
    default = 10,
    type = 'numeric',
    help = 'A positive integer specifying the number of nearest neighbours to find.'
  ),
  make_option(
    c("-c", "--closest-cells-text-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store the top cell IDs of the cells of the reference dataset that a given cell of the projection dataset is closest to."
  ),
  make_option(
    c("-s", "--closest-cells-similarities-text-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store cosine similarities for the top cells of the reference dataset that a given cell of the projection dataset is closest to."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('index_object_file', 'projection_object_file', 'closest_cells_text_file', 'closest_cells_similarities_text_file'))

# Once arguments are satisfcatory, load scmap package

suppressPackageStartupMessages(require(scmap))
suppressPackageStartupMessages(require(SingleCellExperiment))

# Check parameter values defined
if ( ! file.exists(opt$index_object_file)){
  stop((paste('File object', opt$index_object_file, 'does not exist')))
}

if ( ! file.exists(opt$projection_object_file)){
  stop((paste('Projection object', opt$projection_object_file, 'does not exist')))
}

# Read R object
index_sce <- readRDS(opt$index_object_file)
project_sce <- readRDS(opt$projection_object_file)

# Run the projection

scmapCell_results <- scmapCell(
  projection = project_sce, 
  w = opt$number_nearest_neighbours,
  index_list = list(
    metadata(index_sce)$scmap_cell_index
  )
)

# Output format anticipates multiple input indexes, let's assume a single input
# for now and convert list to a single matrix

scmapCell_results <- data.frame(do.call(cbind, lapply(scmapCell_results, function(x){
  if(class(x) == 'matrix'){
    x[,1]
  }else{
    x
  }
})), check.names = FALSE)

# Print introspective information
cat(capture.output(project_sce), sep='\n')

# Output assignments to a text format
write.csv(scmapCell_results[[1]]$cells, file=opt$closest_cells_text_file, quote = FALSE)
write.csv(scmapCell_results[[1]]$similarities, file=opt$closest_cells_similarities_text_file, quote = FALSE)