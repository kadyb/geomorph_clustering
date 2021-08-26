library("mclust")
library("future")
library("recipes")


data = readRDS("data.rds")

# transform data
rec = recipes::recipe( ~ ., data = data)
rec = recipes::step_YeoJohnson(rec, all_numeric(), -flatness)
rec = recipes::step_normalize(rec, all_numeric())

estimates = recipes::prep(rec, training = data, retain = FALSE)
saveRDS(estimates, "transformator.rds")
data_trans = recipes::bake(estimates, data, composition = "data.frame")
rm(data, rec)

# parallel clustering
clusters = 12:20 # specify the number of clusters
ncores = parallelly::availableCores(omit = 1)
if (length(clusters) < ncores) ncores = length(clusters)
future::plan(multisession, workers = ncores)

# define parallel function in local environment
mclust_par = local(
  function(data, G) {
    mdl = Mclust(data = data, G = G)
    # reduce model size
    mdl$data = mdl$data[0, ] # remove original data
    mdl$z = mdl$z[0, ] # remove probability
    mdl$classification = as.integer(mdl$classification)
    return(mdl)
  }
)

results = vector("list", length(clusters))
for (i in seq_along(clusters)) {
  results[[i]] = future::future(mclust_par(data_trans, clusters[i]),
                                seed = 123L)
}
results = future::value(results)

# select the best model
best = which.max(sapply(results, function(x) {x$bic}))
results = results[[best]]
summary(results)
saveRDS(results, "GMM_model.rds")
