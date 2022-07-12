test_that("Withdata basic", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/issue5"
    db <- "mydata.duckdb"
    expect_error(quack(data_path = dir, db = db, db_close = TRUE), NA)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = db)
    created_at <- DBI::dbGetQuery(con, "SELECT created_at FROM tweets")
    pre_n <- nrow(created_at)
    DBI::dbDisconnect(con, shutdown = TRUE)
    dir2 <- "../testdata/ica21"
    expect_error(quack(data_path = dir2, db = db, db_close = TRUE), NA)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = db)
    created_at2 <- DBI::dbGetQuery(con, "SELECT created_at FROM tweets")
    post_n <- nrow(created_at2)
    expect_true(post_n > pre_n)
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink(db)
})

test_that("override convert_date", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/issue5"
    db <- "mydata.duckdb"
    expect_error(quack(data_path = dir, db = db, db_close = TRUE, convert_date = TRUE), NA)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = db)
    created_at <- DBI::dbGetQuery(con, "SELECT created_at FROM tweets")
    pre_n <- nrow(created_at)
    DBI::dbDisconnect(con, shutdown = TRUE)
    expect_error(quack(data_path = dir, db = db, db_close = TRUE, convert_date = FALSE), NA)
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = db)
    created_at2 <- DBI::dbGetQuery(con, "SELECT created_at FROM tweets")
    expect_true("POSIXt" %in% class(created_at2$created_at))
    post_n <- nrow(created_at2)
    expect_true(post_n > pre_n)
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink(db)    
})
