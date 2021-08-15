test_that("issue #5", {
    skip_on_cran()
    dir <- "../testdata/issue5"
    expect_error(quack(data_path = dir, db_close = TRUE), NA)
})
