test_that("date; it runs", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/ica21"
    expect_error(quack(dir, db = "mydata.duckdb", db_close = TRUE, convert_date = TRUE), NA)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = "mydata.duckdb")
    created_at <- DBI::dbGetQuery(con, "SELECT created_at, user_created_at FROM tweets")
    expect_true("POSIXct" %in% class(created_at$created_at))
    expect_true("POSIXt" %in% class(created_at$created_at))    
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink("mydata.duckdb")
})

test_that("date; reverse", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/ica21"
    expect_error(quack(dir, db = "mydata.duckdb", db_close = TRUE, convert_date = FALSE), NA)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = "mydata.duckdb")
    created_at <- DBI::dbGetQuery(con, "SELECT created_at, user_created_at FROM tweets")
    expect_false("POSIXct" %in% class(created_at$created_at))
    expect_false("POSIXt" %in% class(created_at$created_at))    
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink("mydata.duckdb")
})
