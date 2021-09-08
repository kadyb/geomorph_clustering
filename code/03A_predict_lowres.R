library("sf")
library("stars")
library("mclust")
library("recipes")
source("code/utils/spatial_predict.R")


ras_path = list.files("rasters", pattern = "\\.tif$", full.names = TRUE)
varnames = basename(ras_path)
varnames = substr(varnames, 1, nchar(varnames) - 4)
varnames = substr(varnames, 4, nchar(varnames))
varnames = tolower(varnames)

# create virtual raster with lower resolution
tmp = tempfile(fileext = ".vrt")
resolution = c("-tr", 1000, 1000)
resample = c("-r", "nearest")
gdal_utils(util = "buildvrt", source = ras_path, destination = tmp,
           options = c(resolution, resample, "-separate"))

rasters = read_stars(tmp, proxy = FALSE)
rasters = stars::st_set_dimensions(rasters, 3, values = varnames, names = "var")
rasters = split(rasters)

mdl = readRDS("GMM_model.rds")
transformator = readRDS("transformator.rds")

result = spatial_predict(rasters, transformator, mdl)

plot(result["cluster"], col = sf.colors(n = mdl$G, categorical = TRUE))
plot(result["uncertainty"], breaks = "equal")

stars::write_stars(result["cluster"], "cluster.tif", options = "COMPRESS=LZW",
                   type = "Byte", NA_value = 0)
stars::write_stars(result["uncertainty"], "uncertainty.tif",
                   options = "COMPRESS=LZW", type = "Float32", NA_value = 999)
