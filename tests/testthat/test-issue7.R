test_that("issue #7: Empty dir", {
    dir <- academictwitteR:::.gen_random_dir()
    ## default error: FALSE
    expect_error(quack(data_path = dir, db_close = TRUE), NA)
    expect_error(quack(data_path = dir, db_close = TRUE, error = TRUE))
})
