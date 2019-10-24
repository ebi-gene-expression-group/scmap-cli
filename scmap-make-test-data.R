#!/usr/bin/env Rscript 

# Create a test data object as per the scMap vignette

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))

# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

option_list = list(
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "file name in which to store serialized R object of type 'SingleCellExperiment'."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('output_object_file'))

# Once arguments are satisfcatory, load scmap package
suppressPackageStartupMessages(require(SingleCellExperiment))
suppressPackageStartupMessages(require(scmap))

# Create the test object
SingleCellExperiment <- SingleCellExperiment(assays = list(normcounts = as(as.matrix(yan), "dgCMatrix")), colData = ann)

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)
