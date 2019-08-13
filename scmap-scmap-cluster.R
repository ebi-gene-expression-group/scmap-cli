#!/usr/bin/env Rscript 

# Projection of one dataset to another.

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
    c("-r", "--threshold"),
    action = "store",
    default = 0.7,
    type = 'numeric',
    help = 'Threshold on similarity (or probability for SVM and RF).'
  ),
  make_option(
    c("-t", "--output-text-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to text-format cell type assignments."
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'SingleCellExperiment'."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('index_object_file', 'projection_object_file', 'output_object_file', 'output_text_file'))

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

scmapCluster_results <- scmapCluster(
  projection = project_sce, 
  index_list = list(
    metadata(index_sce)$scmap_cluster_index
  )
)

# Output format anticipates multiple input indexes, let's assume a single input
# for now and convert list to a single matrix

scmapCluster_results <- data.frame(do.call(cbind, lapply(scmapCluster_results, function(x){
  if(class(x) == 'matrix'){
    x[,1]
  }else{
    x
  }
})), check.names = FALSE)

colData(project_sce) <- cbind(colData(project_sce), scmapCluster_results)

# Print introspective information
cat(capture.output(project_sce), sep='\n')

# Output assignments to a text format
write.csv(cbind(cell = colnames(project_sce), scmapCluster_results), file=opt$output_text_file, quote = FALSE)

# Output to a serialized R object
saveRDS(project_sce, file = opt$output_object_file)
