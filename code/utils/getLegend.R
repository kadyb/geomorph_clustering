getLegend = function(file) {

  x = xml2::read_xml(file)
  x = xml2::as_list(x)
  x = x[["qgis"]][["pipe"]][["rasterrenderer"]][["colorPalette"]]

  df = data.frame(color = character(), alpha = character(),
                  label = character(), value = character())

  for (i in seq_along(x)) {
    df = rbind(df, attributes(x[[i]]))
  }
  df$alpha = as.integer(df$alpha)
  df$value = as.integer(df$value)
  return(df)

}
