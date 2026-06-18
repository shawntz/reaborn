# Faithful R port of seaborn/external/husl.py (HUSL 2.1.0) plus the standard
# HLS<->RGB conversion used by hls_palette(). We inline this rather than depend
# on the CRAN 'hsluv' package, whose newer spec drifts from the version seaborn
# ships -- and palette fidelity requires the exact same numbers.

# sRGB <-> XYZ matrices and D65 reference constants (verbatim from husl.py).
.husl_m <- matrix(
  c(3.2406, -1.5372, -0.4986, -0.9689, 1.8758, 0.0415, 0.0557, -0.2040, 1.0570),
  nrow = 3,
  byrow = TRUE
)

.husl_m_inv <- matrix(
  c(0.4124, 0.3576, 0.1805, 0.2126, 0.7152, 0.0722, 0.0193, 0.1192, 0.9505),
  nrow = 3,
  byrow = TRUE
)

.husl_refX <- 0.95047
.husl_refY <- 1.00000
.husl_refZ <- 1.08883
.husl_refU <- 0.19784
.husl_refV <- 0.46834
.husl_lab_e <- 0.008856
.husl_lab_k <- 903.3

.husl_f <- function(t) {
  if (t > .husl_lab_e) t^(1 / 3) else (7.787 * t + 16 / 116)
}
.husl_f_inv <- function(t) {
  if (t^3 > .husl_lab_e) t^3 else (116 * t - 16) / .husl_lab_k
}
.husl_from_linear <- function(c) {
  if (c <= 0.0031308) 12.92 * c else (1.055 * c^(1 / 2.4) - 0.055)
}
.husl_to_linear <- function(c) {
  a <- 0.055
  if (c > 0.04045) ((c + a) / (1 + a))^2.4 else (c / 12.92)
}

.husl_max_chroma <- function(L, H) {
  hrad <- H * pi / 180
  sinH <- sin(hrad)
  cosH <- cos(hrad)
  sub1 <- (L + 16)^3 / 1560896
  sub2 <- if (sub1 > 0.008856) sub1 else (L / 903.3)
  result <- Inf
  for (i in seq_len(nrow(.husl_m))) {
    m1 <- .husl_m[i, 1]
    m2 <- .husl_m[i, 2]
    m3 <- .husl_m[i, 3]
    top <- (0.99915 * m1 + 1.05122 * m2 + 1.14460 * m3) * sub2
    rbottom <- 0.86330 * m3 - 0.17266 * m2
    lbottom <- 0.12949 * m3 - 0.38848 * m1
    bottom <- (rbottom * sinH + lbottom * cosH) * sub2
    for (t in c(0, 1)) {
      C <- L * (top - 1.05122 * t) / (bottom + 0.17266 * sinH * t)
      if (C > 0 && C < result) result <- C
    }
  }
  result
}

.husl_dot <- function(a, b) sum(a * b)

.husl_xyz_to_rgb <- function(triple) {
  xyz <- apply(.husl_m, 1, function(row) .husl_dot(row, triple))
  vapply(xyz, .husl_from_linear, numeric(1))
}

.husl_rgb_to_xyz <- function(triple) {
  rgbl <- vapply(triple, .husl_to_linear, numeric(1))
  apply(.husl_m_inv, 1, function(row) .husl_dot(row, rgbl))
}

.husl_xyz_to_luv <- function(triple) {
  X <- triple[1]
  Y <- triple[2]
  Z <- triple[3]
  if (X == 0 && Y == 0 && Z == 0) {
    return(c(0, 0, 0))
  }
  varU <- (4 * X) / (X + 15 * Y + 3 * Z)
  varV <- (9 * Y) / (X + 15 * Y + 3 * Z)
  L <- 116 * .husl_f(Y / .husl_refY) - 16
  if (L == 0) {
    return(c(0, 0, 0))
  }
  U <- 13 * L * (varU - .husl_refU)
  V <- 13 * L * (varV - .husl_refV)
  c(L, U, V)
}

.husl_luv_to_xyz <- function(triple) {
  L <- triple[1]
  U <- triple[2]
  V <- triple[3]
  if (L == 0) {
    return(c(0, 0, 0))
  }
  varY <- .husl_f_inv((L + 16) / 116)
  varU <- U / (13 * L) + .husl_refU
  varV <- V / (13 * L) + .husl_refV
  Y <- varY * .husl_refY
  X <- 0 - (9 * Y * varU) / ((varU - 4) * varV - varU * varV)
  Z <- (9 * Y - 15 * varV * Y - varV * X) / (3 * varV)
  c(X, Y, Z)
}

.husl_luv_to_lch <- function(triple) {
  L <- triple[1]
  U <- triple[2]
  V <- triple[3]
  C <- (U^2 + V^2)^(1 / 2)
  hrad <- atan2(V, U)
  H <- hrad * 180 / pi
  if (H < 0) {
    H <- 360 + H
  }
  c(L, C, H)
}

.husl_lch_to_luv <- function(triple) {
  L <- triple[1]
  C <- triple[2]
  H <- triple[3]
  Hrad <- H * pi / 180
  c(L, cos(Hrad) * C, sin(Hrad) * C)
}

.husl_to_lch <- function(triple) {
  H <- triple[1]
  S <- triple[2]
  L <- triple[3]
  if (L > 99.9999999) {
    return(c(100, 0, H))
  }
  if (L < 0.00000001) {
    return(c(0, 0, H))
  }
  mx <- .husl_max_chroma(L, H)
  C <- mx / 100 * S
  c(L, C, H)
}

.husl_lch_to_rgb <- function(lch) {
  .husl_xyz_to_rgb(.husl_luv_to_xyz(.husl_lch_to_luv(lch)))
}

.husl_rgb_to_lch <- function(rgb) {
  .husl_luv_to_lch(.husl_xyz_to_luv(.husl_rgb_to_xyz(rgb)))
}

#' @keywords internal
.husl_to_rgb <- function(h, s, l) {
  .husl_lch_to_rgb(.husl_to_lch(c(h, s, l)))
}

#' @keywords internal
.rgb_to_husl <- function(r, g, b) {
  lch <- .husl_rgb_to_lch(c(r, g, b))
  L <- lch[1]
  C <- lch[2]
  H <- lch[3]
  if (L > 99.9999999) {
    return(c(H, 0, 100))
  }
  if (L < 0.00000001) {
    return(c(H, 0, 0))
  }
  mx <- .husl_max_chroma(L, H)
  S <- C / mx * 100
  c(H, S, L)
}

# Standard HLS -> RGB (mirrors Python colorsys.hls_to_rgb), used by hls_palette().
.hls_to_rgb <- function(h, l, s) {
  if (s == 0) {
    return(c(l, l, l))
  }
  m2 <- if (l <= 0.5) l * (1 + s) else l + s - l * s
  m1 <- 2 * l - m2
  conv <- function(m1, m2, hue) {
    hue <- hue %% 1
    if (hue < 1 / 6) {
      return(m1 + (m2 - m1) * hue * 6)
    }
    if (hue < 1 / 2) {
      return(m2)
    }
    if (hue < 2 / 3) {
      return(m1 + (m2 - m1) * (2 / 3 - hue) * 6)
    }
    m1
  }
  c(conv(m1, m2, h + 1 / 3), conv(m1, m2, h), conv(m1, m2, h - 1 / 3))
}
