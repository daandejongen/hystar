plot.bar <- function(x, y = NULL,
                     xlab = "time", ylab = "y",
                     ...) {

  time <- attr(x, "eff")
  R <- attr(x, "R")
  y <- attr(x, "y_eff")
  r <- attr(x, "r")
  mar <- 0.1 * abs(max(y) - min(y))

  plot(NA,
       xlab = xlab,
       ylab = ylab,
       xlim = c(eff[1], eff[length(eff)]),
       ylim = c(min(y)-mar, max(y)+mar),
       ...
       )

  abline(
    v = which(R == 1),
    col = "grey95",
    lwd = 10
    )

  lines(y,
        lwd = 3,
        col = "#428bca")

  abline(
    h   = r,
    col = "red2",
    lwd = 2,
    lty = 3
  )
}