# scmap-scripts

This is a collection of R scripts to allow workflow-driven execution of differnt steps of the [scmap workflow](http://bioconductor.org/packages/release/bioc/vignettes/scmap/inst/doc/scmap.html).

## Commands

Currently wrapped scmap functions are described below. Each script has usage insructions available via --help, consult function documentation in scmap for further details.

### Extract test data

Input to the workflow will be a serialised single-cell experiment object. You can generate one for testing (derived from the package-provided test data) like:

```
scmap-make-test-data.R --output-object-file <output SingleCellExperiment in .rds format>
```

### Find the most informative features (genes/transcripts) for projection

```
scmap-select-features.R --input-object-file <input SingleCellExperiment in .rds format>  --n-features <number features to use> --output-object-file <output SingleCellExperiment in .rds format> --output-plot-file <optional file name in .png format, for feature selection plot>
```

### Calculate centroids of each cell type and merge them into a single table.

Here we generate a summary representation of each cluster in the indexed dataset:

```
scmap-index-cluster.R --input-object-file <input SingleCellExperiment in .rds format>  --cluster-col <column name where cell types are stored> --output-object-file <output SingleCellExperiment in .rds format> --output-plot-file <optional file name in .png format, for heatmap-style index visualisation>
```

### Project one dataset to another 

In this step we find the cluster medoid of the index dataset closest to the cells of a query:

```
scmap-scmap-cluster.R -i <cluster-indexed SingleCellExperiment in .rds format> -p <query SingleCellExperiment in .rds format> --threshold <cluster similarity threshold> --output-text-file <csv-format file to store results> --output-object-file <output SingleCellExperiment in .rds format>
```

### Create an index for a dataset to enable fast approximate nearest neighbour search

Here we generate a cell-wise index:

```
scmap-index-cell.R --input-object-file <input SingleCellExperiment in .rds format> --number-chunks <number of chunks into which the expr matrix is split> --number-clusters <number of clusters per group for k-means clustering> --output-object-file <output SingleCellExperiment in .rds format>
```

### For each cell in a query dataset, search for the nearest neighbours by cosine distance within a collection of reference datasets

Here we find the nearest 'n' neighbours in an index dataset for the cells of a query dataset. Optionally (when --cluster-col is set and corresponds to a column in the index dataset's colData()), generate a cluster identity for query cells via the cluster inenties in the index:

```
scmap-scmap-cell.R -i $index_cell_sce -p <input SingleCellExperiment in .rds format> --number-nearest-neighbours <number nearest neighbours> --cluster-col <column name where cell types are stored> --output-object-file <output SingleCellExperiment in .rds format> --output-clusters-text-file <file to store optional cluster identities> --closest-cells-text-file <csv file to store closest cells> --closest-cells-similarities-text-file <csv file to store similarity values>
```
