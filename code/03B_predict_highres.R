library("stars")
library("mclust")
library("recipes")
source("utilis/getBlocks.R")
source("utilis/spatial_predict.R")


mdl = readRDS("GMM_model.rds")
transformator = readRDS("transformator.rds")

ras_path = list.files("rasters", pattern = "\\.tif$", full.names = TRUE)
varnames = basename(ras_path)
varnames = substr(varnames, 1, nchar(varnames) - 4)
varnames = substr(varnames, 4, nchar(varnames))
varnames = tolower(varnames)

blocks = getBlocks(ras_path[1], 5400, 4700)

if (!dir.exists("tiles")) dir.create("tiles")
for (bl in seq_len(nrow(blocks))) {

  # print iteration
  writeLines(paste0(bl, "/", nrow(blocks)))

  rasterio = list(nXOff = blocks[bl, "x"], nYOff = blocks[bl, "y"],
                  nXSize = blocks[bl, "nXSize"], nYSize = blocks[bl, "nYSize"])
  tile = stars::read_stars(ras_path, RasterIO = rasterio, proxy = FALSE)
  names(tile) = varnames
  result = spatial_predict(tile, transformator, mdl)

  # save cluster
  save_path = file.path("tiles", paste0("cluster_", bl, ".tif"))
  stars::write_stars(result["cluster"], save_path, options = "COMPRESS=LZW",
                     type = "Byte", NA_value = 0, chunk_size = dim(tile))

  # save uncertainty
  save_path = file.path("tiles", paste0("uncertainty_", bl, ".tif"))
  stars::write_stars(result["uncertainty"], save_path, options = "COMPRESS=LZW",
                     type = "Float32", NA_value = 999, chunk_size = dim(tile))

}

# merge tiles for cluster
tiles_path = list.files("tiles", pattern = "cluster+.+\\.tif$", full.names = TRUE)
tmp = tempfile(fileext = ".vrt")
gdal_utils(util = "buildvrt", source = tiles_path, destination = tmp)
gdal_utils(util = "translate", source = tmp,
           destination = "clusters.tif",
           options = c("-co", "COMPRESS=LZW"))

# merge tiles for uncertainty
tiles_path = list.files("tiles", pattern = "uncertainty+.+\\.tif$", full.names = TRUE)
tmp = tempfile(fileext = ".vrt")
gdal_utils(util = "buildvrt", source = tiles_path, destination = tmp)
gdal_utils(util = "translate", source = tmp,
           destination = "uncertainty.tif",
           options = c("-co", "COMPRESS=LZW"))
