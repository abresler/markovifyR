#' Newest Linneman Lessons
#'
#' Fetches the newest Peter Linneman life lessons from the web.
#'
#' @return A \code{tibble} with columns:
#' \itemize{
#'   \item \code{idLesson}: Integer lesson identifier
#'   \item \code{textLesson}: Character string containing the lesson text
#' }
#' @export
#' @references \url{https://asbcllc.com/reflections/peter_linneman/}
#'
#' @examples
#' \dontrun{
#' # Fetch lessons from web
#' lessons <- get_data_linneman_lessons()
#'
#' # Use in markov model
#' markov_model <- generate_markovify_model(input_text = lessons$textLesson)
#' }
get_data_linneman_lessons <-
  function() {
    lessons <-
      "https://asbcllc.com/reflections/peter_linneman/linnemen_lessons.txt" %>%
      readLines()

    tibble(textLesson = lessons) %>%
      mutate(idLesson = 1:n()) %>%
      select(idLesson, everything())
  }
