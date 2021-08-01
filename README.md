
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

Most retweeted original content that is not from @icahdq

``` r
tbl(con, "tweets") %>% arrange(desc(retweet_count)) %>% filter(is.na(sourcetweet_id) & user_username != "icahdq") %>% select(user_username, text, retweet_count)
#> # Source:     lazy query [?? x 3]
#> # Database:   duckdb_connection
#> # Ordered by: desc(retweet_count)
#>    user_username text                                              retweet_count
#>    <chr>         <chr>                                                     <int>
#>  1 claesdevreese "🚨HASHTAG HELP🚨\n\nTake part of the #ica21 con…            50
#>  2 shannimcg     "In the year of our Lord 2021, there is a sessio…            34
#>  3 LSawyerED     "Hey #ica21! Is everyone ready for a bigggggg th…            33
#>  4 akaka15       "My article Suing the #Algorithm is finally out.…            32
#>  5 poli_com      "Our division's flagship journal, Political Comm…            29
#>  6 katypearce    "More senior #ICA21 folks -- please try to leave…            27
#>  7 tdienlin      "In their systematic review of digital skills, @…            23
#>  8 Andreas_Hepp  "At #ica21 we have a panel \"Beyond Californian …            22
#>  9 claesdevreese "IT'S A WRAP. My @icahdq Presidential term is ov…            20
#> 10 olivermb      "Hi all @icahdq friends!! I'm so excited to anno…            20
#> # … with more rows
```

Calculate average retweets per original tweet by user who wrote at least
three tweets

``` r
tbl(con, "tweets") %>% filter(is.na(sourcetweet_id)) %>% group_by(user_username) %>% summarise(avg_rt = sum(retweet_count, na.rm = TRUE) / n(), n = n()) %>% filter(n > 2) %>% arrange(desc(avg_rt))
#> # Source:     lazy query [?? x 3]
#> # Database:   duckdb_connection
#> # Ordered by: desc(avg_rt)
#>    user_username avg_rt     n
#>    <chr>          <dbl> <dbl>
#>  1 icahdq            12    85
#>  2 tamigraph          6     4
#>  3 Luk_O              6     4
#>  4 ProfKevinCoe       5     5
#>  5 SummerDHarlow      5     3
#>  6 CAP_Ltd            5     4
#>  7 olivermb           4    10
#>  8 MiriamSiemon       4     3
#>  9 lara_schreurs      4     4
#> 10 DaystarUni         4    31
#> # … with more rows
```

You can find more information about this in the [“Introduction to
dbplyr”](https://dbplyr.tidyverse.org/articles/dbplyr.html) Vignette
of tidyverse
