test_that("convert_date correction", {
    skip_if(!dir.exists("../testdata"))
    db <- "hello.db"
    dir <- "../testdata/issue5"
    quack(data_path = dir, db = db, db_close = TRUE, convert_date = TRUE, return_con = FALSE)
    dir <- "../testdata/commtwitter"
    quack(data_path = dir, db = db, db_close = TRUE, convert_date = TRUE, return_con = FALSE)

    require(DBI)
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = db , read_only = FALSE)
all_data <- DBI::dbGetQuery(con, "SELECT * FROM tweets")

    expect_true(lubridate::ymd_hms("2016-01-01 10:04:53 UTC") == all_data$created_at[1])
    DBI::dbDisconnect(con, shutdown = TRUE)
    unlink(db)
})

