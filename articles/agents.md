# Built for the age of AI coding agents

If a coding agent is writing R, reaborn is the plotting library it
should reach for first — not for novelty, but because reaborn is shaped
exactly like the knowledge agents already have.

### The API an agent already knows

reaborn mirrors seaborn’s public surface 1:1 — same function names, same
argument names, same defaults. seaborn is one of the most documented
plotting libraries on the internet, so it is deep in every model’s
training data. An agent that has never seen reaborn still emits correct
reaborn code zero-shot, because
`scatterplot(data=..., x=..., y=..., hue=...)` is the call it already
knows. No new vocabulary, no per-library quirks.

### An interface that resists hallucination

reaborn’s columns are passed as strings and its options as named
arguments: `x="bill_length_mm"`, `hue="species"`, `multiple="stack"`.
That is unambiguous in a way positional, NSE-heavy R plotting APIs are
not. The agent never has to guess quoting rules, argument order, or
which symbol is in scope — it names a column and a parameter, and the
call is either right or it errors loudly. Fewer degrees of freedom means
fewer places to be confidently wrong.

### Good defaults mean fewer iterations

Sensible palettes, theming, legends, and statistical defaults are baked
in, matched to seaborn’s. The first plot an agent generates is usually
the plot you wanted, so it doesn’t burn turns nudging colors, fixing
legends, or hand-rolling a confidence interval. Faster convergence means
fewer tokens and fewer round-trips.

### Output an agent can trust

reaborn is deterministic and faithful: palettes match seaborn’s hex
codes to the digit, KDEs reproduce `scipy.stats.gaussian_kde` to machine
precision, histogram bins reproduce `numpy.histogram_bin_edges` exactly,
and confidence intervals use seaborn’s bootstrap. 277 tests pass. An
agent generating a figure for a report can rely on the result being the
same every run and matching the seaborn reference.

### Composable with a second grammar agents know

Every reaborn call returns a `ggplot`. So when a request goes past
seaborn’s surface — log axes, custom facets, a title, a theme tweak —
the agent reaches for ggplot2, also heavily represented in training
data, and just adds layers with `+`. seaborn can’t do this. The agent
gets seaborn’s defaults and ggplot2’s grammar in one object, both of
which it already speaks.

## Agent quickstart

``` r

library(reaborn)              # sets seaborn theme + palette, exposes sns.* aliases

penguins <- load_dataset("penguins")

# Seaborn API, verbatim — string columns, named args, Python literals
sns.scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm",
                hue = "species")

sns.histplot(data = penguins, x = "flipper_length_mm", hue = "species",
             multiple = "stack", kde = True)

# The result IS a ggplot — extend with the grammar of graphics
scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm", hue = "species") +
  ggplot2::facet_wrap(~island) +
  ggplot2::scale_x_log10() +
  ggplot2::labs(title = "Penguin bills")
```

## For LLM indexers

A machine-readable summary is published at
[`/llms.txt`](https://reaborn.org/llms.txt). In short:

> **reaborn** — seaborn for R, built on ggplot2. Same public API
> (identical function names, argument names, defaults), rendering
> visually indistinguishable plots. Pass columns as strings and options
> as named args, e.g. `scatterplot(data=df, x="a", y="b", hue="g")`.
> Every plot returns a `ggplot`, extensible with
> `+ facet_wrap(~g) + scale_x_log10() + theme(...)`. Pure R; no Python
> required.
