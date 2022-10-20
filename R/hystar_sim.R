#' Simulating data from the hysTAR model
#'
#' @description
#' The hysTAR model is defined as:
#'
#' \eqn{
#'     y_t =
#'     \begin{cases}
#'     \phi_0^{(0)} + \phi_1^{(0)} y_{t-1} + \cdots + \phi_{p_0}^{(0)}
#'     y_{t-p_0} + \sigma_{(0)} \varepsilon_t & \text{if}~R_{t} = 0 \\
#'     \phi_0^{(1)} + \phi_1^{(1)} y_{t-1} + \cdots + \phi_{p_1}^{(1)}
#'     y_{t-p_1} + \sigma_{(1)} \varepsilon_t & \text{if}~R_{t} = 1, \\
#'     \end{cases}
#' }
#'
#' where
#' \eqn{
#'     R_t = \begin{cases}
#'     0 & \mathrm{if} \, z_{t-d} \in (-\infty, r_{0}] \\
#'     R_{t-1} & \mathrm{if} \, z_{t-d} \in (r_0, r_1] \\
#'     1 & \mathrm{if} \, z_{t-d} \in (r_1, \infty), \\
#'     \end{cases}
#' }
#'
#' @param r A vector of length 2, representing the threshold values \eqn{r_0} and \eqn{r_1}.
#' @param d A number in \eqn{\{1, 2, \dots\}} representing the value of the delay parameter.
#' @param phi_R0 A vector containing the constant and autoregressive parameters
#' \eqn{(\phi_0^{(0)}, \phi_1^{(0)}, \dots, \phi_{p_0}^{(0)})} of Regime 0.
#' Note that the first value of this vector is always interpreted as the constant.
#' @param phi_R1 The same as `phi_R0`, but for Regime 1.
#' @param resvar A numeric vector of length 2 representing the residual variances
#' \eqn{\sigma_{(0)}^2} and \eqn{\sigma_{(1)}^2}.
#' @param init_vals Optionally, a vector of length \eqn{\max{d, p_0, p_1}} to provide the
#' first values of the simulated \eqn{y} variable. See Details. When omitted, the first values
#' are simulated from \eqn{\mathcal{N(\mu_i, \sigma_{(i)}^2)}}, where
#' \eqn{\mu_y = \mathbb{E}(Y_t|R_t=i) = \frac{\phi_0^{(0)}}{1 - \phi_1^{(0)} - \cdots - \phi_{p_i}^{(0)}}}
#' and \eqn{i} is the starting regime.
#' @param z
#' @param n_t
#' @param n_switches
#' @param start_regime
#'
#' @return
#' @export
#'
#' @examples
hystar_sim <- function(r, d, phi_R0, phi_R1, resvar,
                   init_vals     = NULL,
                   z             = NULL,
                   n_t           = NULL,
                   n_switches    = NULL,
                   start_regime  = NULL) {

  check_hystar_sim_input(r, d, phi_R0, phi_R1, resvar, init_vals,
                     z, n_t, n_switches, start_regime)

  if (is.matrix(r)) r <- r[1, , drop = TRUE]
  z <- if (is.null(z)) simulate_z(r, n_t, n_switches, start_regime)
  p0 <- get_order(phi_R0)
  p1 <- get_order(phi_R1)
  a  <- n_ineff(p0, p1, d)

  if (is.null(init_vals)){
    coe <- if (start_regime == 0) phi_R0 else phi_R1
    init_vals <- get_init_vals(coe, resvar[start_regime + 1], a)
  }
  init_R <- rep(start_regime, times = a)

  z_del <- z[time_del(y = z, d = d, p0, p1, d_sel = d)]
  H     <- ts_hys(z_del, r0 = r[1], r1 = r[2])
  R     <- c(init_R, ts_reg(H, start = start_regime))
  eff   <- time_eff(z, d, p0, p1)
  y_    <- c(init_vals, eff) # Placeholder, just to have the correct length
  y     <- simulate_y(y_, eff, R, phi_R0, phi_R1, resvar)

  true  <- name_true_vals(d, r, phi_R1, phi_R1, resvar)

  data  <- new_bardata(y = y,
                       z = z,
                       H = c(rep(NA, a), H == -1),
                       R = R,
                       r = r,
                       n_ineff = a)

  return(list(data = data, true_vals = true))
}


name_true_vals <- function(d, r, phi, psi, resvar) {
  names(d)   <- "delay"
  names(r)   <- c("r0", "r1")
  names(phi) <- paste0("phi_R0_", 0:(length(phi)-1))
  names(psi) <- paste0("phi_R1_", 0:(length(psi)-1))
  names(resvar) <- paste0("regime", 0:1)
  return(list(d = d, r = r, phi = phi, psi = psi, resvar = resvar))
}


