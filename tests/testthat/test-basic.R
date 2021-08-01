test_that("most basic op.", {
    skip_on_cran()
    dir <- "../testdata/ica21"
    expect_error(quack(dir, db = "mydata.duckdb", db_close = TRUE), NA)
    ## clean
    unlink("mydata.duckdb")
})
