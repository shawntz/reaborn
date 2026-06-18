# Ground-truth palette and color constants, extracted verbatim from seaborn
# (see data-raw/extract-constants.py). These define reaborn's color identity and
# must match seaborn to the digit. Do not hand-edit hex values; regenerate.

# The six named qualitative seaborn palettes (10-color form) and their 6-color
# variants. Source: seaborn.palettes.SEABORN_PALETTES.
SEABORN_PALETTES <- list(
  deep = c(
    "#4C72B0",
    "#DD8452",
    "#55A868",
    "#C44E52",
    "#8172B3",
    "#937860",
    "#DA8BC3",
    "#8C8C8C",
    "#CCB974",
    "#64B5CD"
  ),
  deep6 = c("#4C72B0", "#55A868", "#C44E52", "#8172B3", "#CCB974", "#64B5CD"),
  muted = c(
    "#4878D0",
    "#EE854A",
    "#6ACC64",
    "#D65F5F",
    "#956CB4",
    "#8C613C",
    "#DC7EC0",
    "#797979",
    "#D5BB67",
    "#82C6E2"
  ),
  muted6 = c("#4878D0", "#6ACC64", "#D65F5F", "#956CB4", "#D5BB67", "#82C6E2"),
  pastel = c(
    "#A1C9F4",
    "#FFB482",
    "#8DE5A1",
    "#FF9F9B",
    "#D0BBFF",
    "#DEBB9B",
    "#FAB0E4",
    "#CFCFCF",
    "#FFFEA3",
    "#B9F2F0"
  ),
  pastel6 = c("#A1C9F4", "#8DE5A1", "#FF9F9B", "#D0BBFF", "#FFFEA3", "#B9F2F0"),
  bright = c(
    "#023EFF",
    "#FF7C00",
    "#1AC938",
    "#E8000B",
    "#8B2BE2",
    "#9F4800",
    "#F14CC1",
    "#A3A3A3",
    "#FFC400",
    "#00D7FF"
  ),
  bright6 = c("#023EFF", "#1AC938", "#E8000B", "#8B2BE2", "#FFC400", "#00D7FF"),
  dark = c(
    "#001C7F",
    "#B1400D",
    "#12711C",
    "#8C0800",
    "#591E71",
    "#592F0D",
    "#A23582",
    "#3C3C3C",
    "#B8850A",
    "#006374"
  ),
  dark6 = c("#001C7F", "#12711C", "#8C0800", "#591E71", "#B8850A", "#006374"),
  colorblind = c(
    "#0173B2",
    "#DE8F05",
    "#029E73",
    "#D55E00",
    "#CC78BC",
    "#CA9161",
    "#FBAFE4",
    "#949494",
    "#ECE133",
    "#56B4E9"
  ),
  colorblind6 = c(
    "#0173B2",
    "#029E73",
    "#D55E00",
    "#CC78BC",
    "#ECE133",
    "#56B4E9"
  )
)

# Single-letter color code remapping used by set_color_codes() (b, g, r, m, y, c, k).
# Source: seaborn.palettes.set_color_codes for the "deep" and "muted" palettes.
SEABORN_COLOR_CODES <- list(
  deep = c(
    b = "#4C72B0",
    g = "#55A868",
    r = "#C44E52",
    m = "#8172B3",
    y = "#CCB974",
    c = "#64B5CD",
    k = "#1A1A1A"
  ),
  muted = c(
    b = "#4878D0",
    g = "#6ACC64",
    r = "#D65F5F",
    m = "#956CB4",
    y = "#D5BB67",
    c = "#82C6E2",
    k = "#1A1A1A"
  )
)

# The matplotlib default qualitative tab10 / Set2 (seaborn falls back to mpl for
# unknown palette names). Extracted via seaborn.color_palette().
MPL_QUAL_PALS <- list(
  tab10 = c(
    "#1F77B4",
    "#FF7F0E",
    "#2CA02C",
    "#D62728",
    "#9467BD",
    "#8C564B",
    "#E377C2",
    "#7F7F7F",
    "#BCBD22",
    "#17BECF"
  ),
  Set2 = c(
    "#66C2A5",
    "#FC8D62",
    "#8DA0CB",
    "#E78AC3",
    "#A6D854",
    "#FFD92F",
    "#E5C494",
    "#B3B3B3"
  )
)

# Default sizes and constant factors (resolved from a real seaborn install).
SEABORN_DEFAULTS <- list(
  markersize = 6, # lines.markersize (notebook context)
  linewidth = 1.5, # lines.linewidth (notebook context)
  axes_linewidth = 1.25,
  saturation = 0.75, # categorical default desaturation
  box_width = 0.8,
  whis = 1.5,
  strip_jitter = 0.1,
  swarm_buffer = 1.05,
  luminance_threshold = 0.408 # heatmap annotation text color cutoff
)

# Gray-level shorthand: seaborn/matplotlib accept ".15" meaning gray15. Helper
# expands a string like ".15" to its hex form.
rb_gray <- function(level) {
  v <- as.numeric(level)
  grDevices::rgb(v, v, v)
}
