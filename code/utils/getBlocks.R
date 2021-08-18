getBlocks = function(path, x_window, y_window) {

  x_window = as.integer(x_window)
  y_window = as.integer(y_window)

  img = stars::read_stars(path, proxy = TRUE)
  img_rows = dim(img)[["x"]]
  img_cols = dim(img)[["y"]]

  x_vec = integer()
  y_vec = integer()
  nXSize_vec = integer()
  nYSize_vec = integer()

  for (x in seq.int(1L, img_rows, y_window)) {

    if (x + y_window < img_rows) {
      nXSize = y_window
    } else {
      nXSize = img_rows - x + 1L
    }

    for (y in seq.int(1L, img_cols, x_window)) {

      if (y + x_window < img_cols) {
        nYSize = x_window
      } else {
        nYSize = img_cols - y + 1L
      }

      x_vec = c(x_vec, x)
      y_vec = c(y_vec, y)
      nXSize_vec = c(nXSize_vec, nXSize)
      nYSize_vec = c(nYSize_vec, nYSize)
    }

  }

  mat = matrix(c(x_vec, y_vec, nXSize_vec, nYSize_vec), ncol = 4)
  colnames(mat) = c("x", "y", "nXSize", "nYSize")

  return(mat)

}
