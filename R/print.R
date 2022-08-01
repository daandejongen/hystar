#' @export
print.bar <- function(x) {

  n <- unname(attr(x, "n"))
  coe <- round(attr(x, "coe"), 2)
  rv <- attr(x, "resvar")

  d <- attr(x, "d")
  r0 <- round(attr(x, "r")[1, 1], 2)
  r1 <- round(attr(x, "r")[1, 2], 2)

  cat(paste0("BAR model fitted on ", n[1], " observations."),
      "\n\n",
      "if R[t] = 0:\n", make_formula(coe[1, , drop = TRUE], rv[1]),
      "\n\n",
      "if R[t] = 1:\n", make_formula(coe[2, , drop = TRUE], rv[2]),
      "\n\n",
      hys_switch(d, r0, r1),
      "\n\n",
      " and e[t] ~ N(0, 1)."
  )

}


# Helpers

make_formula <- function(coe, rv) {
  coe <- coe[coe != 0]
  p <- length(coe) - 1
  lags_str <- if (p == 0) NULL else paste0("y[t-", 1:p, "]")

  plusmin <- ifelse(coe[-1] > 0, " + ", " - ")
  coe <- abs(coe)

  a <- paste0("y[t] = ", coe[1])
  b <- paste0(plusmin, coe[-1], " ", lags_str, collapse = "")

  paste0(a, b, " + ", round(sqrt(rv), 2), " e[t]")
}


hys_switch <- function(d, r0, r1) {
  ztd <- paste0("z[t-", d, "]")
  paste0("Where:\n",
         "R[t] = 0 \t if ", ztd, " <= ", r0, "\n",
         "R[t] = R[t-1] \t if ", r0, " < ", ztd, " <= ", r1, "\n",
         "R[t] = 1 \t if ", r1, " < ", ztd)
}




