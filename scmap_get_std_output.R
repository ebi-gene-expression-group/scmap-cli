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
        c("-k", "--sim-col-name"),
        action = 'store',
        default = 'scmap_cluster_siml',
        type = 'character',
        help = 'Column name of similarity scores'
    )
)

opt = wsc_parse_args(option_list, mandatory = c("predictions_file", "output_table"))
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
write.table(output, file = opt$output_table, sep="\t", row.names=FALSE)
