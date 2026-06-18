# Load an example dataset from the seaborn-data repository

Port of `seaborn.load_dataset`. Bundled datasets (penguins, tips, iris,
flights) load offline; others download from the seaborn-data repo and
cache.

## Usage

``` r
load_dataset(name, cache = TRUE, data_home = NULL, ...)

get_dataset_names()
```

## Arguments

- name:

  Name of the dataset (the stem of a `.csv` in seaborn-data).

- cache:

  Whether to use the local cache (and bundled data).

- data_home:

  Optional cache directory.

- ...:

  Reserved for compatibility.

## Value

A data.frame, with categorical columns coerced to ordered factors
matching seaborn.

For `get_dataset_names`, a character vector of available dataset names.
