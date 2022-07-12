test_that("most basic op.", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/ica21"
    expect_error(quack(dir, db = "mydata.duckdb", db_close = TRUE), NA)
    ## clean
    unlink("mydata.duckdb")
})

## flags

test_that("verbose", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/ica21"
    ## expect_output(quack(dir, db = "mydata.duckdb", db_close = TRUE, verbose = TRUE))
    ## unlink("mydata.duckdb")
    expect_silent(quack(dir, db = "mydata.duckdb", db_close = TRUE, verbose = FALSE))
    unlink("mydata.duckdb")
})
