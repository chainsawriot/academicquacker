test_that("issue #5", {
    skip_if(!dir.exists("../testdata"))
    dir <- "../testdata/issue5"
    expect_error(quack(data_path = dir, db_close = TRUE), NA)
})
