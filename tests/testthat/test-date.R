test_that("date; it runs", {
    skip_on_cran()
    dir <- "../testdata/ica21"
    expect_error(quack(dir, db = "mydata.duckdb", db_close = TRUE, convert_date = TRUE), NA)
    ## check
    require(dbplyr)
    require(dplyr)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = "mydata.duckdb")
    tbl(con, "tweets") %>%  select(created_at) %>% head %>% collect -> created_at
    expect_true("POSIXct" %in% class(created_at$created_at))
    expect_true("POSIXt" %in% class(created_at$created_at))
    tbl(con, "tweets") %>%  select(user_created_at) %>% head %>% collect -> created_at
    expect_true("POSIXct" %in% class(created_at$user_created_at))
    expect_true("POSIXt" %in% class(created_at$user_created_at))
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink("mydata.duckdb")
})

test_that("date; reverse", {
    skip_on_cran()
    dir <- "../testdata/ica21"
    expect_error(quack(dir, db = "mydata.duckdb", db_close = TRUE, convert_date = FALSE), NA)
    ## check
    require(dbplyr)
    require(dplyr)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = "mydata.duckdb")
    tbl(con, "tweets") %>%  select(created_at) %>% head %>% collect -> created_at
    expect_false("POSIXct" %in% class(created_at$created_at))
    expect_false("POSIXt" %in% class(created_at$created_at))
    tbl(con, "tweets") %>%  select(user_created_at) %>% head %>% collect -> created_at
    expect_false("POSIXct" %in% class(created_at$user_created_at))
    expect_false("POSIXt" %in% class(created_at$user_created_at))
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink("mydata.duckdb")
})
