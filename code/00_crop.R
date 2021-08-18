# files
files = list.files("data", pattern = ".tif", full.names = TRUE)
mask = "vector/Poland.gpkg"

# parameters
target_EPSG = "-t_srs EPSG:2180"
multithreads = "-multi"
crop = "-crop_to_cutline"
vector = paste("-cutline", mask)
output_path = "rasters"
nodata = "-dstnodata -999"

for (file in seq_along(files)) {

  # print iteration
  writeLines(paste0(file, "/", length(files)))

  input_raster = files[file]
  output_raster = paste0(output_path, "/", basename(files[file]))

  system(paste("gdalwarp", multithreads, target_EPSG, vector,
               crop, nodata, input_raster, output_raster))

}
