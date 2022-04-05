# Gomorphological clustering

This repository contains the code for “*Towards geomorphometry of plains - country level unsupervised classification of low-relief areas (Poland)*” article.

## Reproduction
1. Open the `geomorph_clustering.Rproj` project file in [RStudio](https://rstudio.com/).
2. Run `01_extract.R` to generate a random sample from the rasters.
3. Run `02_clustering.R` to train the data transformer and Gaussian mixture models (GMM).
Finally, the model with the highest BIC value is selected.
4. Run `03A_predict_lowres.R` to perform spatial clustering on low resolution (downsampled) rasters.
The result will be maps with clusters (geomorphological units) and uncertainty.
5. Run `03B_predict_highres.R` to perform high resolution spatial clustering.
This operation is performed for **all** data in blocks of the specified size.
