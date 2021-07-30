
<!-- README.md is generated from README.Rmd. Please edit that file -->

# academicquacker

<!-- badges: start -->

<!-- badges: end -->

If it collects tweets like a duck, binds tweets like a duck, and quacks
like a duck, then it probably *is* an academic.

The goal of this (experimental) package is to convert raw data collected
by [academictwitteR](https://github.com/cjbarrie/academictwitteR) into
[DuckDB](https://github.com/duckdb/duckdb) in a memory efficient manner.
This package also serves as a test bed for rolling out experimental
features of `bind_tweets` in `academictwitteR`.

Why DuckDB? Because it quacks… I mean, [it
rocks](https://duckdb.org/docs/why_duckdb)\!

Why isn’t the last R capitalized? Because the developer always forgets
which “r” in the word “academicquacker” to capitalize.

## Installation

You can install the development version of academicquacker with:

``` r
remotes::install_github("chainsawriot/academicquacker")
```

## Example

Suppose `dir` is a directory hosting json files collected with
academictwitteR.

``` r
library(academicquacker)
con <- quack(dir, db = "mydata.duckdb", db_close = TRUE)
```

It won’t fill up all main memory in your computer.

## Analysis

Now you can do analysis with the database. For example, you can use
dplyr like you usually do with dataframes.

``` r
library(DBI)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
con <- dbConnect(duckdb::duckdb(), dbdir = "mydata.duckdb")

tbl(con, "tweets") %>% count(user_username, sort = TRUE)
#> # Source:     lazy query [?? x 2]
#> # Database:   duckdb_connection
#> # Ordered by: desc(n)
#>    user_username      n
#>    <chr>          <dbl>
#>  1 ICA_CAT          409
#>  2 DevinaSarwatay   324
#>  3 SMandPBot        313
#>  4 LSawyerED        261
#>  5 katypearce       188
#>  6 poli_com         155
#>  7 claesdevreese    143
#>  8 solecheler       138
#>  9 Journalism_ICA   118
#> 10 monrodriguez     113
#> # … with more rows
```
