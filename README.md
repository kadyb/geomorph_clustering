# Gomorphological clustering

This repository contains the code for “[*Toward geomorphometry of plains - Country-level unsupervised classification of low-relief areas (Poland)*](https://www.sciencedirect.com/science/article/pii/S0169555X22002665)” article.

## Reproduction
1. Open the `geomorph_clustering.Rproj` project file in [RStudio](https://rstudio.com/).
2. Run `01_extract.R` to generate a random sample from the rasters.
3. Run `02_clustering.R` to train the data transformer and Gaussian mixture models (GMM).
Finally, the model with the highest BIC value is selected.
4. Run `03A_predict_lowres.R` to perform spatial clustering on low resolution (downsampled) rasters.
The result will be maps with clusters (geomorphological units) and uncertainty.
5. Run `03B_predict_highres.R` to perform high resolution spatial clustering.
This operation is performed for **all** data in blocks of the specified size.

## Dataset
The final high-resolution maps with geomorphological units and uncertainty, Gaussian mixture model and data transformation model, and low-resolution rasters (500 m) with geomorphometric variables are available in the Zenodo repository: https://zenodo.org/record/6415362.
Note that in the project, rasters with 30 m resolution were used as input data.
The "*input_rasters*" folder in the archive should be renamed to "*rasters*" to work with the shared code.
