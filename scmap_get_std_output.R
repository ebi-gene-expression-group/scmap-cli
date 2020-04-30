#!/usr/bin/env Rscript
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))

### create final output in standard format
option_list = list(
    make_option(
        c("-i", "--predictions-file"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Path to the predictions file in text format'
    ),
    make_option(
        c("-o", "--output-table"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Path to the final output file in text format'
    ), 
    make_option(
        c("-s", "--include-scores"),
        action = 'store_true',
        default = FALSE,
        type = 'logical',
        help = 'Should prediction scores be included in output? Default: FALSE'
    ),
    make_option(
        c("-l", "--index"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Path to the index object in .rds format (Optional; required to add dataset of origin to output table)'
    ),
    make_option(
        c("-t", "--tool"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'What tool produced output? scmap-cell or scmap-cluster'
    ),  
    make_option(
        c("-k", "--sim-col-name"),
        action = 'store',
        default = 'scmap_cluster_siml',
        type = 'character',
        help = 'Column name of similarity scores'
    )
)


opt = wsc_parse_args(option_list, mandatory = c("predictions_file", "output_table", "tool"))
data = read.csv(file=opt$predictions_file)
output = data[, c('cell', 'combined_labs')]
# provide scores if specified
if(!is.na(opt$include_scores)){
    score = as.character(data[, opt$sim_col_name])
    output = cbind(output, score)
    col_names = c("cell_id", "predicted_label", "score")
} else{
    col_names = c("cell_id", "predicted_label")
}
colnames(output) = col_names

# add metadata if classifier is specified 
tool = tolower(opt$tool)
if(!tool %in% c("scmap-cell", "scmap-cluster")) stop("Incorrect tool name provided")
system(paste("echo '# tool", tool, "' >", opt$output_table))
if(!is.na(opt$index)){
    cl = readRDS(opt$index)
    dataset = attributes(cl)$dataset
    system(paste("echo '# dataset'", dataset, ">>", opt$output_table))
}
write.table(output, file = opt$output_table, sep="\t", row.names=FALSE, append=TRUE)

