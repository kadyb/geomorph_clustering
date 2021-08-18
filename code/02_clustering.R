library("mclust")
library("recipes")
library("cluster")


data = readRDS("data.rds")

# transform data
rec = recipes::recipe( ~ ., data = data)
rec = recipes::step_YeoJohnson(rec, all_numeric(), -flatness)
rec = recipes::step_normalize(rec, all_numeric())

estimates = recipes::prep(rec, training = data, retain = FALSE)
saveRDS(estimates, "transformator.rds")
data_trans = recipes::bake(estimates, data, composition = "data.frame")
rm(rec)

# clustering
set.seed(123)
mdl = mclust::Mclust(data_trans, G = 10:20)
summary(mdl)

# reduce model size
mdl$data = mdl$data[0, ] # remove original data from model
mdl$classification = as.integer(mdl$classification)
saveRDS(mdl, "GMM_model.rds")
