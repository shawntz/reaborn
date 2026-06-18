# Python literal compatibility values

`True`, `False`, and `None` are provided so that seaborn Python code
pasted into R (e.g. `histplot(data = df, x = "a", kde = True)`) runs
unchanged. They are exactly `TRUE`, `FALSE`, and `NULL`.

## Usage

``` r
True

False

None
```

## Format

`True` and `False` are length-one logicals; `None` is `NULL`.
