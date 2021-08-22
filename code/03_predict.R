library("sf")
library("stars")
library("mclust")
library("recipes")
source("code/utils/spatial_predict.R")


ras_path = list.files("rasters", pattern = "\\.tif$", full.names = TRUE)
rasters = stars::read_stars(ras_path, along = 3, proxy = TRUE)

varnames = basename(ras_path)
varnames = substr(varnames, 1, nchar(varnames) - 4)
varnames = substr(varnames, 4, nchar(varnames))
varnames = tolower(varnames)

# prepare raster with target geometry
dest = stars::st_as_stars(sf::st_bbox(rasters), dx = 500, values = 0L)
dest = do.call(c, lapply(seq_len(dim(rasters)[3]), function(x) dest))
dest = merge(dest)

# downsample rasters
rasters = stars::st_warp(rasters, dest, method = "near", use_gdal = TRUE)
rasters = stars::st_set_dimensions(rasters, 3, values = varnames, names = "var")
rasters = split(rasters)
rm(dest)

mdl = readRDS("GMM_model.rds")
transformator = readRDS("transformator.rds")

# raster with clusters
result = spatial_predict(rasters, transformator, mdl)
plot(result, col = sf.colors(20, categorical = TRUE))
stars::write_stars(result, "result.tif", options = "COMPRESS=LZW",
                   type = "UInt16", NA_value = 0)
