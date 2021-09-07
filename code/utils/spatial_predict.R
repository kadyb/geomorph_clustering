spatial_predict = function(x, transformator, mdl) {

  df = as.data.frame(x)
  xy = df[, c(1:2)]
  df = df[, -c(1:2)]
  NA_found = anyNA(df)

  if (NA_found) {
    na_ids = which(is.na(df), arr.ind = TRUE)
    na_ids = unique(na_ids[, 1])
    df = df[-na_ids, ]
  }

  df = recipes::bake(transformator, df, composition = "data.frame")
  pred = predict(mdl, df) # TODO: make it parallel
  rm(df)
  uncertainty = numeric(nrow(pred$z))
  for (i in seq_along(uncertainty)) {
    uncertainty[i] = 1 - max(pred$z[i, ])
  }
  pred = pred$classification

  if (NA_found) {
    full_pred = rep(NA_integer_, prod(dim(x)))
    full_uncertainty = rep(NA_real_, prod(dim(x)))
    full_pred[-na_ids] = pred
    full_uncertainty[-na_ids] = uncertainty
    raster = cbind(xy, full_pred, full_uncertainty)
  } else {
    raster = cbind(xy, pred, uncertainty)
  }

  raster = st_as_stars(raster, dims = c("x", "y"))
  st_crs(raster) = st_crs(x)
  names(raster) = c("cluster", "uncertainty")
  return(raster)

}
