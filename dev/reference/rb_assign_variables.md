# Assign plot variables from data + role references

Assign plot variables from data + role references

## Usage

``` r
rb_assign_variables(data = NULL, ...)
```

## Arguments

- data:

  A data frame, or `NULL` when passing vectors directly.

- ...:

  Named role assignments (`x=`, `y=`, `hue=`, ...). Each value is either
  a length-1 column name found in `data`, or a vector of values.

## Value

A list with `data` (tidy frame, columns named by role), `names` (role
-\> original variable name), and `types` (role -\> variable type).
