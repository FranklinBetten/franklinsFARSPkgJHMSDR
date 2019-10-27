

#' @title Read A Year of FARS Data Into a Dataframe
#'
#' @param filename is a string which represnts the name of a .csv file
#'
#' @return When successful this fxn returns a data frame containing data from specificed .csv
#'      Returns a string "file _____ does not exist" when it cannot find the file
#' @importFrom dplyr tbl_df
#' @importFrom readr read_csv
#'
#' @export
#'
#' @examples
#' \dontrun{
#' farsTibble <- fars_read("accident_2013.csv.bz2")
#' }
fars_read <- function(filename) {
  if(!file.exists(filename))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(filename, progress = FALSE)
  })
  dplyr::tbl_df(data)
}



#' @title Make a FARS Data File Name Using Only The Year
#'
#' @param year can be a string or integer and must be 2013, 2014, or 2015
#'
#' @return this fxn returns a string that is the name of a fars data file of the specified year
#'       in the format "accident_<year>.csv.bz2
#' @export
#'
#' @examples
#' \dontrun{
#' make_filename("2014")
#' }
make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("accident_%d.csv.bz2", year)
}


#' @title Aggregate a List Of Years Worth of FARS Data Into a List of Dataframes
#'
#'@description This function makes a combined dataframe of the selected years given
#'    using lapply, make_filename, fars_Read, and daplyr. It adds a new column for each year.
#'    It has built in error checking to check that all the years selected are valid.
#'    If an invalid year is selected it will return "invalid year:<year>".
#' @param years
#'
#' @return this file returns a list of data frames when successful.
#'    Each data frame of the list contains accident data for a single year selected.
#'    The the date frames are filtered so they only have the month and the year of each accident
#'    On error the function returns a string reading "invalid year:<year>".
#' @importFrom dplyr mutate select
#' @export
#'
#' @examples
#' \dontrun{
#' yrsAccdnts <- fars_read_years(c(2013:2015))
#' }
fars_read_years <- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)
    tryCatch({
      dat <- fars_read(file)
      dplyr::mutate(dat, year = year) %>%
        dplyr::select(MONTH, year)
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}



#' @title Summarize The Total Number of Accidents by Month for Each Year Selected
#'
#' @description This function collects that data for the selected years and makes a summary table.
#'     The summary shows the number of accidents for each year by month. It does ths using
#'     fars_read_years adn then grouping by year and month and summarizing the data.
#'
#' @param years is a vector of years expressed as numerical values
#'
#' @return This function returns a data table of the form MONTH year1, ...YearN. This table
#'     has data summarizingn the total number of accidents for each year by MONTH.
#' @import dplyr
#' @import tidyr
#' @export
#'
#' @examples
#' \dontrun{
#' smryFrsYrs <- fars_summarize_years(c(2013:2015))
#' }
fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}



#' @title Plot A Year Of Accidents Geographically on a Map of the State they Happened In
#'
#' @param state.num Integer value from 1 to 50 to select the state to map accidents for
#' @param year The year of accident data you wish to plot as an integer (2013, 2014, or 2015)
#'
#' @return This function returns a map of the state and scatter plots accidents on it geographically
#'
#' @import dplyr
#' @import maps
#' @import graphics
#'
#' @export
#'
#' @examples
#' \dontrun{
#' fars_map_state(5,2013)
#' }
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}

