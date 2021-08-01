## require(academictwitteR)
## x <- bind_tweets("~/dev/einfach/tests/testdata/ica21", output_format = "tidy")

.ls_files <- function(data_path, pattern) {
    files <- list.files(path = file.path(data_path), pattern = pattern, recursive = TRUE, include.dirs = TRUE, full.names = TRUE)
    if (length(files) < 1) {
        stop(paste0("There are no files matching the pattern `", pattern, "` in the specified directory."), call. = FALSE)
    }
    return(files)
}


## sanity check
## all(.gen_aux_filename(data_files) %in% .ls_files(data_path, "^users_"))
## data_path <- "~/dev/einfach/tests/testdata/ica21"
## db <- ":memory:"
##schema_file <- "../inst/extdata/schema.sql"

## library(DBI)
## library(duckdb)

#' Convert data collected with academictwitteR into DuckDB
#'
#' This function coverts data collected with academictwitteR into DuckDB.
#' @param data_path path to the directory hosting data collected with academictwitteR
#' @param db path to the DuckDB; the default value ":memory:" converts the data into a DuckDB in main memory
#' @param db_close whether to close the DuckDB after the operation. It is better to set it to TRUE, if `db` is not ":memory:"
#' @param return_con whether or not to return the connnection object
#' @export
quack <- function(data_path, db = ":memory:", db_close = FALSE, return_con = TRUE) {
    files <- .ls_files(data_path, "^data_.+\\.json")
    empty_str <- structure(list(tweet_id = character(0), user_username = character(0),
                                text = character(0), possibly_sensitive = logical(0), lang = character(0),
                                conversation_id = character(0), source = character(0), author_id = character(0),
                                created_at = character(0), in_reply_to_user_id = character(0), 
                                user_description = character(0), user_profile_image_url = character(0), 
                                user_location = character(0), user_protected = logical(0), 
                                user_verified = logical(0), user_url = character(0), user_created_at = character(0), 
                                user_pinned_tweet_id = character(0), user_name = character(0), 
                                retweet_count = integer(0), like_count = integer(0), quote_count = integer(0), 
                                user_tweet_count = integer(0), user_list_count = integer(0), 
                                user_followers_count = integer(0), user_following_count = integer(0), 
                                sourcetweet_type = character(0), sourcetweet_id = character(0), 
                                sourcetweet_text = character(0), sourcetweet_lang = character(0), 
                                sourcetweet_author_id = character(0)), row.names = integer(0), class = c("tbl_df", 
                                                                                                         "tbl", "data.frame"))

    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = db , read_only = FALSE)
    ## con@driver@read_only
    ## "duckdb_connection" %in% class(con)
    rubbish <- DBI::dbExecute(con, readLines(system.file("extdata", "schema.sql", package = "academicquacker")))
    purrr::walk(files, ~DBI::dbWriteTable(con, "tweets", dplyr::bind_rows(empty_str, convert_json(.)), append = TRUE))
    if (db_close) {
        DBI::dbDisconnect(con, shutdown = TRUE)
        return(db)
    }
    if (return_con) {
        return(con)
    }
    return(db)
}
