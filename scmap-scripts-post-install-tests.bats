#!/usr/bin/env bats

# Extract the test data

@test "Prepare test SingleCellExperiment" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$test_sce" ]; then
        skip "$test_sce exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $test_sce && scmap-make-test-data.R --output-object-file $test_sce 

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$test_sce" ]
}

@test "Find the most informative features (genes/transcripts) for projection" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$select_features_sce" ]; then
        skip "$select_features_sce exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $select_features_sce && scmap-select-features.R --input-object-file $test_sce --n-features $n_features --output-object-file $select_features_sce --output-plot-file $select_features_plot

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$test_sce" ]
}


@test "Calculate centroids of each cell type and merge them into a single table." {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$index_cluster_sce" ]; then
        skip "$index_cluster_sce exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $index_cluster_sce && scmap-index-cluster.R --input-object-file $select_features_sce --cluster-col $cluster_col --output-object-file $index_cluster_sce --output-plot-file $index_cluster_plot

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$select_features_sce" ]
}


@test "Project one dataset to another." {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$project_sce" ]; then
        skip "$project_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -rf $project_sce && scmap-scmap-cluster.R -i $index_cluster_sce -p $test_sce --threshold $cluster_similarity_threshold --output-text-file $project_csv --output-object-file $project_sce

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$project_sce" ]
}
