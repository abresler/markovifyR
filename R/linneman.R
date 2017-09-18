#' Newest Linneman lessons
#'
#' @return a \code{data_frame}
#' @export
#' @references \url{asbcllc.com/reflections/peter_linneman/}
#' @examples
#' get_data_linneman_lessons()
get_data_linneman_lessons <-
  function() {
    lessons <-
      "http://asbcllc.com/reflections/peter_linneman/linnemen_lessons.txt" %>%
      readr::read_lines()

    tibble(textLesson = lessons) %>%
      mutate(idLesson = 1:n()) %>%
      select(idLesson, everything())
  }
