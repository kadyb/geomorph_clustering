library("sf")
library("corrr")
library("stars")


ras_path = list.files("rasters", pattern = "\\.tif$", full.names = TRUE)
rasters = stars::read_stars(ras_path, proxy = TRUE)

varnames = basename(ras_path)
varnames = substr(varnames, 1, nchar(varnames) - 4)
varnames = substr(varnames, 4, nchar(varnames))
names(rasters) = varnames

n = 5000000
set.seed(123)
vals = sf::st_sample(rasters, n)
vals = as.data.frame(vals)[, -c(1:2)]
complete_idx = which(complete.cases(vals))
vals = vals[complete_idx, ]
rm(complete_idx)
rownames(vals) = NULL

# correlation
cor = corrr::correlate(vals)
corrr::rplot(cor, print_cor = TRUE)

if (!dir.exists("data")) dir.create("data")
saveRDS(vals, "data/sample.rds")
