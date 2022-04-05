library("sf")
library("stars")
source("code/utils/getLegend.R")

map_path = "data/clusters.tif"
vec_path = "vector/morphogenetic_zones.gpkg"
vec = sf::read_sf(vec_path, fid_column_name = "FID")

### regions ###
nclus = 20
mat = matrix(0L, nrow = nclus, ncol = nrow(vec))
for (i in seq_len(nrow(vec))) {

  tmp = tempfile(fileext = ".tif")
  writeLines(paste0(i, "/", nrow(vec)))

  # don't use `stars::st_crop` because it's slower
  # and requires MUCH more memory
  sf::gdal_utils("warp", map_path, tmp, options = c(
    "-cutline", vec_path,
    "-crop_to_cutline",
    "-cwhere", paste0("FID = ", "'", vec$FID[i], "'")
  ))

  map = stars::read_stars(tmp, proxy = FALSE)
  map[[1]] = as.integer(map[[1]])
  # `tabulate` is faster than `table`, but requires integers
  freq = tabulate(map[[1]], nbins = nclus)
  mat[, i] = freq

}

legend = getLegend("code/misc/colors.qml")
rownames(mat) = legend$label
colnames(mat) = vec$desc
write.csv2(mat, "data/crosstable.csv", row.names = TRUE)

### entire area ###
map = stars::read_stars(map_path, proxy = FALSE)
map[[1]] = as.integer(map[[1]])
freq = tabulate(map[[1]], nbins = nclus)
names(freq) = legend$label
round(prop.table(freq) * 100, 1)
