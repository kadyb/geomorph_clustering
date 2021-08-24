spatial_predict = function(x, transformator, mdl) {

  df = as.data.frame(x)
  xy = df[, c(1:2)]
  df = df[, -c(1:2)]
  NA_found = any(is.na(df))

  if (NA_found) {
    na_ids = which(is.na(df), arr.ind = TRUE)
    na_ids = unique(na_ids[, 1])
    df = df[-na_ids, ]
  }

  pred = recipes::bake(transformator, df, composition = "data.frame")
  rm(df)
  pred = predict(mdl, pred)$classification # TODO: make it parallel

  if (NA_found) {
    full_vec = rep(NA_integer_, prod(dim(x)))
    full_vec[-na_ids] = pred
    pred = cbind(xy, full_vec)
  } else {
    pred = cbind(xy, pred)
  }

  pred = st_as_stars(pred, dims = c("x", "y"))
  st_crs(pred) = st_crs(x)
  return(pred)

}
