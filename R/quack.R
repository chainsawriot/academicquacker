## require(academictwitteR)
## x <- bind_tweets("~/dev/einfach/tests/testdata/ica21", output_format = "tidy")

.ls_files <- function(data_path, pattern, error = TRUE) {
    files <- list.files(path = file.path(data_path), pattern = pattern, recursive = TRUE, include.dirs = TRUE, full.names = TRUE)
    if (length(files) < 1) {
        if (error) {
            stop(paste0("There are no files matching the pattern `", pattern, "` in the specified directory."), call. = FALSE)
        } else {
            return(NULL)
        }
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

.exe_sqlfile <- function(sqlfile, con) {
    sql_statement <- paste(readLines(system.file("extdata", sqlfile, package = "academicquacker")), collapse = "")
    rubbish <- DBI::dbExecute(con, sql_statement)
    invisible(sqlfile)
}

#' Convert data collected with academictwitteR into DuckDB
#'
#' This function coverts data collected with academictwitteR into DuckDB.
#' @param data_path path to the directory hosting data collected with academictwitteR
#' @param db path to the DuckDB; the default value ":memory:" converts the data into a DuckDB in main memory
#' @param db_close whether to close the DuckDB after the operation. It is better to set it to TRUE, if `db` is not ":memory:"
#' @param return_con whether or not to return the connnection object; if false, the argument db is returned invisibly.
#' @param convert_date whether or not `created_at` and `user_created_at` should be converted to date
#' @param verbose whether to display a progress bar
#' @param error whether to raise error if there is no data
#' @export
quack <- function(data_path, db = ":memory:", db_close = FALSE, convert_date = FALSE, return_con = TRUE, verbose = TRUE, error = FALSE) {
    files <- .ls_files(data_path, "^data_.+\\.json", error = error)
    if (is.null(files)) {
        return(invisible(db))
    }
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
    if ("tweets" %in% DBI::dbListTables(con)) {
        db_exists <- TRUE
        created_at <- DBI::dbGetQuery(con, "SELECT created_at FROM tweets limit 1")
        if ("POSIXct" %in% class(created_at$created_at)) {
            convert_date <- TRUE
        } else {
            convert_date <- FALSE
        }
    } else {
        db_exists <- FALSE
    }
    if (convert_date) {
        empty_str$created_at <- as.POSIXct(empty_str$created_at)
        empty_str$user_created_at <- as.POSIXct(empty_str$user_created_at)        
    }
    if (convert_date) {
        sqlfile <- "schema_timestamp.sql"
    } else {
        sqlfile <- "schema.sql"
    }
    if (!db_exists) {
        .exe_sqlfile("seq.sql", con)
        .exe_sqlfile(sqlfile, con)
    }
    .insert(files = files, con = con, empty_str = empty_str, convert_date = convert_date, verbose = verbose)
    if (db_close) {
        DBI::dbDisconnect(con, shutdown = TRUE)
        invisible(db)
    }
    if (return_con) {
        return(con)
    }
    invisible(db)
}

.convert <- function(file, convert_date = FALSE) {
    res <- academictwitteR::convert_json(file)
    if (convert_date) {
        res$created_at <- lubridate::ymd_hms(res$created_at)
        res$user_created_at <- lubridate::ymd_hms(res$user_created_at)
    }
    return(res)
}

.insert <- function(files, con, empty_str, convert_date = FALSE, verbose = TRUE) {
    if (verbose) {
        cli::cli_progress_bar("Converting data", total = length(files))
            for (file in files) {
                DBI::dbWriteTable(con, "tweets", dplyr::bind_rows(empty_str, .convert(file, convert_date = convert_date)), append = TRUE)
                cli::cli_progress_update()
            }
        cli::cli_progress_done()
    } else {
        purrr::walk(files, ~DBI::dbWriteTable(con, "tweets", dplyr::bind_rows(empty_str, .convert(., convert_date = convert_date)), append = TRUE))
    }
    invisible(files)
}
