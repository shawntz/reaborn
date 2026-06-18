"""Ground-truth constant extraction from a real seaborn install.

Run against a pinned, RELEASED seaborn venv (NOT the dev checkout) and emit a
single JSON blob of every constant reaborn must reproduce exactly. The reaborn R
code embeds / tests against this file so that colors, theme params, size ranges,
KDE bandwidths, bin edges, etc. match seaborn to the digit.

    /tmp/sbenv/bin/python data-raw/extract-constants.py > inst/extdata/seaborn_constants.json

Every block is wrapped so one failure (API drift across seaborn versions) does
not abort the whole extraction; failures are recorded under out["_errors"].
"""
import json
import numpy as np
import matplotlib as mpl
import seaborn as sns

out = {}
errors = {}


def grab(name, fn):
    try:
        out[name] = fn()
    except Exception as e:  # noqa: BLE001 - we want every failure recorded, not raised
        errors[name] = f"{type(e).__name__}: {e}"


# --- version provenance ------------------------------------------------------
grab("versions", lambda: {
    "seaborn": sns.__version__,
    "matplotlib": mpl.__version__,
    "numpy": np.__version__,
})

# --- 1. PALETTES: every named palette as hex, all sizes ----------------------
grab("palettes", lambda: {
    name: sns.color_palette(name).as_hex() for name in
    ["deep", "muted", "pastel", "bright", "dark", "colorblind",
     "deep6", "muted6", "pastel6", "bright6", "dark6", "colorblind6"]
})
grab("pal_hls", lambda: sns.color_palette("hls", 6).as_hex())
grab("pal_hls10", lambda: sns.color_palette("hls", 10).as_hex())
grab("pal_husl", lambda: sns.color_palette("husl", 6).as_hex())
grab("pal_husl10", lambda: sns.color_palette("husl", 10).as_hex())
grab("pal_cubehelix_default", lambda: sns.cubehelix_palette().as_hex())
grab("pal_ch_string", lambda: sns.color_palette("ch:s=.25,rot=-.25", 8).as_hex())
grab("pal_ch_string2", lambda: sns.color_palette("ch:2.5,-.2,dark=.3", 6).as_hex())
grab("pal_light_red", lambda: sns.light_palette("red").as_hex())
grab("pal_light_seagreen", lambda: sns.light_palette("seagreen", 8).as_hex())
grab("pal_dark_blue", lambda: sns.dark_palette("blue").as_hex())
grab("pal_dark_husl", lambda: sns.dark_palette("#69d", 6, input="husl").as_hex())
grab("pal_diverging", lambda: sns.diverging_palette(220, 20).as_hex())
grab("pal_diverging_n9", lambda: sns.diverging_palette(145, 300, s=60, n=9).as_hex())
grab("pal_blend", lambda: sns.blend_palette(["red", "green", "blue"], 7).as_hex())
grab("mpl_tab10", lambda: sns.color_palette("tab10").as_hex())
grab("mpl_Set2", lambda: sns.color_palette("Set2").as_hex())
grab("mpl_viridis6", lambda: sns.color_palette("viridis", 6).as_hex())


def color_codes():
    sns.set_color_codes("deep")
    mapping = {c: mpl.colors.to_hex(mpl.colors.colorConverter.to_rgb(c))
               for c in "bgrmyck"}
    sns.set_color_codes("muted")
    mapping_muted = {c: mpl.colors.to_hex(mpl.colors.colorConverter.to_rgb(c))
                     for c in "bgrmyck"}
    return {"deep": mapping, "muted": mapping_muted}


grab("color_codes", color_codes)

# --- 2. SEABORN COLORMAPS as 256-row hex LUTs --------------------------------
# Sample at bin MIDPOINTS (k+0.5)/256 so that floor-indexing -- matplotlib's own
# Colormap.__call__ quantization, idx = floor(x*256) -- reproduces cmap(x) exactly.
def _lut_midpoint(cmap):
    return [mpl.colors.to_hex(cmap((k + 0.5) / 256.0)) for k in range(256)]


def seaborn_cmaps():
    import seaborn.cm as scm
    names = ["rocket", "mako", "flare", "crest", "icefire", "vlag",
             "rocket_r", "mako_r", "flare_r", "crest_r", "icefire_r", "vlag_r"]
    res = {}
    for n in names:
        cm = getattr(scm, n, None)
        if cm is None:
            continue
        res[n] = _lut_midpoint(cm)
    return res


grab("cmaps", seaborn_cmaps)


def mpl_cmaps():
    names = ["magma", "inferno", "plasma", "viridis", "cividis",
             "coolwarm", "RdBu_r", "RdBu", "Spectral", "Blues", "Reds",
             "BuGn", "PuBuGn", "GnBu", "YlGnBu", "tab10", "tab20"]
    res = {}
    for n in names:
        try:
            cmap = mpl.colormaps[n]
        except Exception:
            cmap = mpl.cm.get_cmap(n)
        res[n] = _lut_midpoint(cmap)
    return res


grab("mpl_cmaps", mpl_cmaps)


# --- 2b. matplotlib NAMED COLOR tables (R's col2rgb disagrees, e.g. green) ----
def mpl_named_colors():
    import matplotlib.colors as mc
    res = {}
    res["base"] = {k: mc.to_hex(v) for k, v in mc.BASE_COLORS.items()}
    res["css4"] = {k: v for k, v in mc.CSS4_COLORS.items()}
    res["tab"] = {k: mc.to_hex(v) for k, v in mc.TABLEAU_COLORS.items()}
    return res


grab("named_colors", mpl_named_colors)

# --- 3. RESOLVED rcParams: style dicts + merged context state ----------------
grab("rc_style", lambda: {
    style: dict(sns.axes_style(style))
    for style in ["darkgrid", "whitegrid", "dark", "white", "ticks"]
})
grab("rc_context_raw", lambda: {
    ctx: dict(sns.plotting_context(ctx))
    for ctx in ["paper", "notebook", "talk", "poster"]
})


def rc_context_merged():
    res = {}
    for ctx in ["paper", "notebook", "talk", "poster"]:
        sns.set_theme(context=ctx, style="darkgrid")
        keys = sns.plotting_context().keys()
        res[ctx] = {k: mpl.rcParams[k] for k in keys}
    sns.set_theme()  # restore
    return res


grab("rc_context_merged", rc_context_merged)


def rc_resolved_default():
    sns.set_theme()
    keys = ["lines.markersize", "lines.linewidth", "lines.markeredgewidth",
            "patch.linewidth", "patch.edgecolor", "patch.force_edgecolor",
            "axes.linewidth", "font.sans-serif", "legend.fontsize",
            "axes.facecolor", "axes.edgecolor", "grid.color", "grid.linewidth",
            "xtick.major.size", "ytick.major.size", "image.cmap"]
    res = {}
    for k in keys:
        try:
            res[k] = mpl.rcParams[k]
        except KeyError:
            pass
    return res


grab("rc_resolved_default", rc_resolved_default)
grab("prop_cycle", lambda: [
    mpl.colors.to_hex(c) for c in mpl.rcParams["axes.prop_cycle"].by_key()["color"]
])

# --- 4. SCATTER size range + filled-marker table -----------------------------
def scatter_sizes():
    sns.set_theme()
    ms = mpl.rcParams["lines.markersize"]
    return {
        "default_markersize": ms,
        "default_size_range_pts2": list(np.r_[.5, 2] * np.square(ms)),
        "line_default_size_range": list(np.r_[.5, 2] * mpl.rcParams["lines.linewidth"]),
    }


grab("scatter_sizes", scatter_sizes)


def marker_filled():
    from matplotlib.markers import MarkerStyle
    markers = list("os^v<>pP*XDdh8") + ["o", "x", "+", "|", "_", "1", "2", "3", "4", "."]
    res = {}
    for m in markers:
        try:
            res[m] = MarkerStyle(m).is_filled()
        except Exception:
            pass
    return res


grab("marker_filled", marker_filled)

# --- 5. KDE bandwidth ground truth (validate the scipy port) -----------------
def kde_truth():
    from scipy.stats import gaussian_kde
    rng = np.random.default_rng(0)
    x = rng.standard_normal(100)
    k = gaussian_kde(x, bw_method="scott")
    grid = np.linspace(-4, 4, 9)
    return {
        "n": 100,
        "data_std_ddof1": float(np.std(x, ddof=1)),
        "data_std_ddof0": float(np.std(x, ddof=0)),
        "scott_factor": float(k.factor),
        "silverman_factor": float(gaussian_kde(x, "silverman").factor),
        "effective_bw_1d": float(k.factor * np.std(x, ddof=0)),
        "grid_x": list(grid),
        "grid_density": list(k(grid)),
        "data": list(x),
    }


grab("kde", kde_truth)

# --- 6. HISTOGRAM binning ground truth (bins="auto" = max(sturges, fd)) -------
def hist_truth():
    rng = np.random.default_rng(1)
    data = rng.standard_normal(200)
    res = {"data": list(data)}
    for rule in ["auto", "fd", "sturges", "scott", "rice", "sqrt", "doane"]:
        try:
            edges = np.histogram_bin_edges(data, bins=rule)
            res[f"{rule}_edges"] = list(edges)
            res[f"{rule}_nbins"] = len(edges) - 1
        except Exception as e:
            res[f"{rule}_error"] = str(e)
    return res


grab("hist", hist_truth)

# --- 7. BOOTSTRAP CI fixtures (tolerance targets) ----------------------------
def bootstrap_truth():
    rng = np.random.default_rng(1)
    data = rng.standard_normal(200)
    res = {"data": list(data)}
    try:
        from seaborn.algorithms import bootstrap
        boot = bootstrap(data, func="mean", n_boot=1000, seed=0)
        res["mean_ci95"] = list(np.percentile(boot, [2.5, 97.5]))
        res["boot_mean"] = float(boot.mean())
        res["boot_std"] = float(boot.std())
    except Exception as e:
        res["bootstrap_error"] = str(e)
    try:
        from seaborn._statistics import EstimateAggregator
        import pandas as pd
        agg = EstimateAggregator("mean", ("ci", 95), n_boot=1000, seed=0)
        r = agg(pd.DataFrame({"x": data}), "x")
        res["estimate_aggregator"] = {
            "est": float(r["x"]), "min": float(r["xmin"]), "max": float(r["xmax"])
        }
    except Exception as e:
        res["aggregator_error"] = str(e)
    return res


grab("bootstrap", bootstrap_truth)

# --- 8. HEATMAP luminance / text-color + fmt ---------------------------------
def heatmap_truth():
    from seaborn.utils import relative_luminance
    return {
        "luminance_threshold": 0.408,
        "luminance_samples": {
            c: float(relative_luminance(c))
            for c in ["#4C72B0", "#FFFEA3", "#000000", "#FFFFFF"]
        },
        "fmt_examples": {
            repr(v): format(v, ".2g")
            for v in [0.0, 1.5, 12345.0, 0.00012, 100, -3.14159]
        },
    }


grab("heatmap", heatmap_truth)

# --- 9. CATEGORICAL computed constants ---------------------------------------
grab("categorical", lambda: {
    "saturation_default": 0.75,
    "box_width": 0.8,
    "whis": 1.5,
    "pointplot_markersize_factor": float(np.sqrt(2 * np.pi)),
    "swarm_buffer": 1.05,
    "boxen_flier_size": 25,
    "strip_jitter_default": 0.1,
})

# --- 10. ggplot2 unit constants to mirror exactly ----------------------------
grab("unit_notes", lambda: {
    "matplotlib_pt_to_mm": 25.4 / 72.0,
    "ggplot2_pt_to_mm": 25.4 / 72.27,
    "ggplot2_dot_pt": 72.27 / 25.4,
    "ggplot2_stroke": 96 / 25.4,
})

# --- 11. DATASET categorical orderings (bake into bundled data/) -------------
def dataset_orders():
    res = {}
    for ds in ["tips", "titanic", "diamonds", "flights", "exercise", "penguins"]:
        try:
            df = sns.load_dataset(ds)
            res[ds] = {
                "columns": list(df.columns),
                "dtypes": {c: str(df[c].dtype) for c in df.columns},
                "orders": {
                    c: (df[c].cat.categories.tolist()
                        if str(df[c].dtype) == "category" else None)
                    for c in df.columns
                },
                "nrow": int(len(df)),
            }
        except Exception as e:
            res[ds] = {"error": str(e)}
    return res


grab("dataset_orders", dataset_orders)

# --- 12. HUSL round-trip samples (validate the inlined port) -----------------
def husl_samples():
    from seaborn.external import husl
    pts = [(120, 90, 65), (0, 100, 50), (260, 75, 40)]
    return {
        "husl_to_rgb": {str(p): list(husl.husl_to_rgb(*p)) for p in pts},
        "rgb_to_husl": {
            str(c): list(husl.rgb_to_husl(*c))
            for c in [(.2, .5, .8), (.9, .1, .1), (.3, .3, .3)]
        },
    }


grab("husl", husl_samples)

out["_errors"] = errors
print(json.dumps(out, default=str, indent=None))
