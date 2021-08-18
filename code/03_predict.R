library("sf")
library("stars")
library("mclust")
library("recipes")


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

# predict
pred = function(x, transformator, mdl) {

  NA_idx = is.na(x)
  NA_idx = unlist(NA_idx, use.names = FALSE)
  dim(NA_idx) = c(prod(dim(x)), length(x))
  NA_idx = apply(NA_idx, 1, any)
  dim(NA_idx) = c(nrow(x), ncol(x))

  df = as.data.frame(x)[, -(1:2)]
  df = na.omit(df)
  df = recipes::bake(transformator, df, composition = "data.frame")
  x$cluster = rep(NA_integer_, prod(dim(x)))
  x$cluster[!NA_idx] = predict(mdl, df)$classification
  x["cluster"]

}

# raster with clusters
test = pred(rasters, transformator, mdl)
plot(test, col = sf.colors(20, categorical = TRUE))
stars::write_stars(test, "result.tif", options = "COMPRESS=LZW",
                   type = "UInt16", NA_value = 0)
