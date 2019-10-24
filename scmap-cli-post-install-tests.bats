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

@test "Pre-process SCE object for further scmap analysis" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$test_sce" ]; then
        skip "$test_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $test_sce_processed && scmap-preprocess-sce.R\
                           --input-object $test_sce\
                           --output-sce-object $test_sce_processed 

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$test_sce_processed" ]

}

@test "Find the most informative features (genes/transcripts) for projection" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$select_features_sce" ]; then
        skip "$select_features_sce exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $select_features_sce && scmap-select-features.R --input-object-file $test_sce_processed --n-features $n_features --output-object-file $select_features_sce --output-plot-file $select_features_plot

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$select_features_sce" ]
}

@test "Calculate centroids of each cell type and merge them into a single table." {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$index_cluster_sce" ]; then
        skip "$index_cluster_sce exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $index_cluster_sce && scmap-index-cluster.R --input-object-file $select_features_sce --cluster-col $cluster_col --output-object-file $index_cluster_sce --output-plot-file $index_cluster_plot

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$index_cluster_sce" ]
}

@test "Project one dataset to another." {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$project_sce" ]; then
        skip "$project_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -rf $project_sce && scmap-scmap-cluster.R -i $index_cluster_sce -p $test_sce_processed --threshold $cluster_similarity_threshold --output-text-file $project_csv --output-object-file $project_sce

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$project_sce" ]
}

@test "Create an index for a dataset to enable fast approximate nearest neighbour search" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$index_cell_sce" ]; then
        skip "$index_cell_sce exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $index_cell_sce && scmap-index-cell.R\
                                 --input-object-file $select_features_sce\
                                 --output-object-file $index_cell_sce\
                                 --number-chunks $cells_number_chunks\
                                 --number-clusters $cells_number_clusters\
                                 --random-seed $random_seed

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$index_cell_sce" ]
}

@test "For each cell in a query dataset, search for the nearest neighbours by cosine distance within a collection of reference datasets." {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$closest_cells_similarities_text_file" ]; then
        skip "$closest_cells_similarities_text_file exists and use_existing_outputs is set to 'true'"
    fi

    run rm -rf $closest_cells_similarities_text_file && scmap-scmap-cell.R -i $index_cell_sce -p $test_sce_processed --number-nearest-neighbours $cell_number_nearest_neighbours --cluster-col $cluster_col --output-object-file $closest_cells_clusters_sce --output-clusters-text-file $closest_cells_clusters_csv --closest-cells-text-file $closest_cells_text_file --closest-cells-similarities-text-file $closest_cells_similarities_text_file

    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$closest_cells_similarities_text_file" ]
}
