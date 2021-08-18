library("sf")
library("corrr")
library("stars")


ras_path = list.files("rasters", pattern = "\\.tif$", full.names = TRUE)
rasters = stars::read_stars(ras_path, along = 3, proxy = TRUE)
rasters = stars::st_set_dimensions(rasters, 3, names = "var")

varnames = basename(ras_path)
varnames = substr(varnames, 1, nchar(varnames) - 4)
varnames = substr(varnames, 4, nchar(varnames))
varnames = tolower(varnames)

# create points to sample
set.seed(123)
n = 5000000L

x_smp = sample(seq.int(as.integer(st_bbox(rasters)[["xmin"]]),
                       as.integer(st_bbox(rasters)[["xmax"]]),
                       31L), n, replace = TRUE)
y_smp = sample(seq.int(as.integer(st_bbox(rasters)[["ymin"]]),
                       as.integer(st_bbox(rasters)[["ymax"]]),
                       31L), n, replace = TRUE)
pts = sf::st_as_sf(data.frame(x = x_smp, y = y_smp), coords = c("x", "y"),
               crs = st_crs(rasters))
rm(x_smp, y_smp)
pts = unique(pts) # remove duplicated rows

# select only points inside area
pixel_mask = sf::read_sf("Poland.gpkg")
pts_idx = unlist(sf::st_contains(pixel_mask, pts))
pts = pts[pts_idx, ]
rm(pts_idx)

# extract values by points
vals = stars::st_extract(rasters, pts)
vals = vals[[1]]
colnames(vals) = varnames

# check for NAs
na_found = any(apply(vals, 2, function(x) any(is.na(x))))

if (na_found) {
  complete_idx = which(complete.cases(vals))
  cat("number of missing data:",
      nrow(vals) - length(complete_idx))
  vals = vals[complete_idx, ] # get only complete cases (remove NA)
  rm(complete_idx)
}

# correlation
cor = corrr::correlate(vals)
corrr::rplot(cor, print_cor = TRUE)

saveRDS(vals, "data.rds")
