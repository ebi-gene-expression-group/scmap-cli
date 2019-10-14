#!/usr/bin/env Rscript 

# package management
# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# define inputs
option_list = list(
  make_option(
    c('-d', '--input-10x-dir'),
    action = 'store',
    default = NA,
    type = 'character',
    help = 'Path to the directory with CPM-normalised 10X data.
            Directory must contain the matrix.mtx, genes.tsv (or features.tsv),
            and barcodes.tsv files provided by 10X.'
  ),
  make_option(
    c('-m', '--metadata-file'),
    action = 'store',
    default = NA,
    type = 'character',
    help = 'Path to the SDRF metadata file in .txt format.
            The first column must be cell identifier (corresponding to column
            names in the expression matrix; the second column must be (inferred)
            cell type. Further columns may be included if required.'
  ),
  make_option(
      c('-o', '--output-object'),
      action = 'store',
      default = NA,
      type = 'character',
      help = 'Output path for the produced CDS object in .rds format.'
  )
)

# check correctness of inputs 
opt = wsc_parse_args(option_list, mandatory = c('input_10x_dir',
                                                'metadata_file',
                                                'output_object'))
#print(opt)

if(! file.exists(opt$input_10x_dir)){
    stop(paste("Argument", opt$input_10x_dir, "does not exist. Execution halted.",
               sep = " "))
}

if(! file.exists(opt$metadata_file)){
    stop(paste("Argument", opt$metadata_file, "does not exist. Execution halted.",
               sep = " "))
}

# load the necessary libs 
suppressPackageStartupMessages(require(Seurat))
suppressPackageStartupMessages(require(SingleCellExperiment))


# process metadata file
cat("Processing metadata file...\n")
sdrf = read.csv(opt$metadata_file, sep = "\t")
if(FALSE %in% (names(sdrf)[1:2] == c("barcode", "cell_type1"))){
    stop(paste("Incorrect column names. First column of metadata file must be
                named 'barcode', second - 'cell_type1'."))
}

# parse the 10X directory 
cat("Parsing the 10X expression matrix...\n")
mtx = Read10X(opt$input_10x_dir)

# match the rows from raw dataset to the filtered one
filtered_cells = colnames(mtx)
all_cells = sdrf$barcode

# find indices to subset by 
idx = intersect(which(!(duplicated(all_cells))), which(all_cells %in% filtered_cells))
sdrf = sdrf[idx, ]

# check there is 1:1 matching
match = length(which(sdrf$barcode %in% filtered_cells)) == 
        length(which(filtered_cells %in% sdrf$barcode))

if(!isTRUE(match)){
    stop("Some metadata entries do not match cell barcodes. Execution halted.")
}

# make sure order is correct 
sdrf = sdrf[order(match(sdrf$barcode, filtered_cells)), ]

# update row names 
row.names(sdrf) = sdrf$barcode
sdrf$barcode = NULL

### initialise new SCE object with cell types in metadata 
cat("Initialising SCE object...\n")
sce = SingleCellExperiment(assays = list(normcounts=as.matrix(mtx)), 
                                         colData = sdrf)
logcounts(sce) = log2(normcounts(sce) + 1)
rowData(sce)$feature_symbol = rownames(sce)

saveRDS(sce, file=opt$output_object)
print(paste("CDS object written to ", opt$output_object))
