#!/usr/bin/env bash

script_dir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
script_name=$0

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: scmap-scripts-post-install-tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_working_dir=`pwd`/'post_install_tests'

# Clean up if specified

if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi 

# Initialise directories

output_dir=$test_working_dir/outputs

mkdir -p $test_working_dir
mkdir -p $output_dir

################################################################################
# List tool outputs/ inputs
################################################################################

export test_sce=$output_dir'/test_sce.rds'
export train_idf=$test_working_dir/'E-ENAD-16.idf.txt'
export test_sce_processed=$output_dir'/test_sce_processed.rds'
export select_features_sce=$output_dir'/select_features.rds'
export select_features_plot=$output_dir'/select_features.png'
export index_cluster_sce=$output_dir'/index_cluster.rds'
export index_cluster_plot=$output_dir'/index_cluster.png'
export project_sce=$output_dir'/project_cluster.rds'
export project_csv=$output_dir'/project_cluster.csv'

export index_cell_sce=$output_dir'/index_cell.rds'
export project_cell_sce=$output_dir'/project_cell.rds'
export closest_cells_text_file=$output_dir'/closest_cells.csv'
export closest_cells_similarities_text_file=$output_dir'/closest_cells_similarities.csv'
export closest_cells_clusters_sce=$output_dir'/closest_cells_clusters.rds'
export closest_cells_clusters_csv=$output_dir'/closest_cells_clusters.csv'
export scmap_output_tbl=$output_dir'/scmap_output_tbl.txt'

## Test parameters- would form config file in real workflow. DO NOT use these
## as default values without being sure what they mean.

### Workflow parameters

export n_features=500
export cluster_col='cell_type1'
export cluster_similarity_threshold=0.7

export random_seed=1
export cells_number_chunks=50
export cells_number_clusters=9
export cell_number_nearest_neighbours=5

################################################################################
# Test individual scripts
################################################################################

# Make the script options available to the tests so we can skip tests e.g.
# where one of a chain has completed successfullly.

export use_existing_outputs

# Import IDF file 
wget "ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/atlas/sc_experiments/E-ENAD-16/E-ENAD-16.idf.txt" -P $test_working_dir

# Derive the tests file name from the script name

tests_file="${script_name%.*}".bats

# Execute the bats tests
$tests_file