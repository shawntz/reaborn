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

## Value

These objects are exported constants, not functions. Referencing one
yields its stored value: `True` is the length-one logical vector `TRUE`,
`False` is the length-one logical vector `FALSE`, and `None` is `NULL`.
They exist only so that seaborn code containing Python's `True`,
`False`, and `None` literals evaluates in R unchanged.
