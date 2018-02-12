#' Install Markovify Python module
#'
#' @return invisible
#' @export
#'
#' @examples
#'  \dontrun{
#'  install_markovify()
#' }
install_markovify <-
  function() {
    system("pip install markovify")
  }

#' Generate Markovify model
#'
#' Generate a markov model for a
#' given input text and set of model
#' parameters
#'
#' @param input_text a \code{vector} of text
#' @param max_overlap_total maximum overlap total
#' default is \code{15}
#' @param max_overlap_ratio maximum overlap ratio
#' \code{default is .7}
#' @param tries number over times to try to generate a sentence
#' @param markov_state_size markov state to use
#' \code{default} is 2
#'
#' @return a markov model in Python object form
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(markovifyR)
#' data("linneman_lessons")
#' df <- linneman_lessons
#' lessons <-
#' df %>%
#' pull(textLesson)
#' markov_model <-
#' generate_markovify_model(
#' input_text = lessons,
#' markov_state_size = 3L,
#' max_overlap_total = 15,
#' max_overlap_ratio = .8
#' )
#' markov_model
#' }
generate_markovify_model <-
  function(input_text,
           markov_state_size = 2,
           max_overlap_total = 15,
           max_overlap_ratio = .70,
           tries = 100) {

    if (max_overlap_ratio > 1) {
      stop("Overlap ratio can only be between 0 and 1")
    }

    markov_state_size <-
      as.integer(markov_state_size)

    mk <-
      reticulate::import("markovify")

      tries <- as.integer(tries)

      max_overlap_total <- as.integer(max_overlap_total)
      max_overlap_ratio <- max_overlap_ratio

    mk$text$DEFAULT_TRIES <-
      tries
    mk$text$DEFAULT_MAX_OVERLAP_TOTAL <-
      max_overlap_total
    mk$text$DEFAULT_MAX_OVERLAP_RATIO <-
      max_overlap_ratio
    markov_model <-
      mk$Text(input_text = input_text, state_size = markov_state_size)

    markov_model
  }

generate_short_sentence <-
  function(markov_model,
           output_column_name = "textLinnemanBot",
           maximum_sentence_length = 1200,
           count = 50,
           tries = 100,
           only_distinct = TRUE,
           return_message = TRUE) {

    df_text <-
      1:count %>%
      map_df(function(x) {
        text_output <-
          markov_model$make_short_sentence(max_chars = maximum_sentence_length, tries = as.integer(tries))
        ## if no result try again
        if (text_output %>% length() == 0) {
          text_output <-
            markov_model$make_short_sentence(max_chars = maximum_sentence_length)
        }

        if (text_output %>% length() == 0) {
          text_output <- NA
        }
        ## return data frame
        data_frame(idRow = x, UQ(output_column_name) := text_output)
      })

    if (only_distinct) {
      df_text <-
        df_text %>%
        select(-idRow) %>%
        distinct() %>%
        mutate(idRow = 1:n()) %>%
        select(idRow, everything())
    }
    df_text

    if (return_message) {
      1:nrow(df_text) %>%
        walk(function(x) {
          text_output <-
            df_text %>% slice(x) %>% select(2) %>% pull(UQ(output_column_name))
          glue::glue("{output_column_name}: {text_output}") %>% message()
        })

    }
    df_text
  }

generate_sentence <-
  function(markov_model,
           output_column_name = "textLinnemanBot",
           count = 50,
           tries = 100,
           only_distinct = TRUE,
           return_message = TRUE) {
    df_text <-
      1:count %>%
      map_df(function(x) {
        text_output <-
          markov_model$make_sentence()
        ## if no result try again
        if (text_output %>% length() == 0) {
          text_output <-
            markov_model$make_sentence(tries = as.integer(tries))
        }

        if (text_output %>% length() == 0) {
          text_output <- NA
        }
        ## return data frame
        data_frame(idRow = x, UQ(output_column_name) := text_output)
      })

    if (only_distinct) {
      df_text <-
        df_text %>%
        select(-idRow) %>%
        distinct() %>%
        mutate(idRow = 1:n()) %>%
        select(idRow, everything())
    }

    if (return_message) {
      1:nrow(df_text) %>%
        walk(function(x) {
          text_output <-
            df_text %>% slice(x) %>% select(2) %>% pull(UQ(output_column_name))
          glue::glue("{output_column_name}: {text_output}") %>% message()
        })

    }

    df_text
  }



#' Combine markov models
#'
#' Builds a combined
#' markov model
#'
#' @param model_a first model
#' @param model_b second model
#' @param weights numeric vector of 2 weights
#' defaults are \code{c(1, 1.5)}
#'
#' @return
#' @export
#' @examples
combine_markov_models <-
  function(model_a, model_b, weights = c(1, 1.5)) {
    mk <- reticulate::import("markovify")

    model <-
      mk$combine(models = c(model_a, model_b), weights = weights)
    model
  }

#' Generate a corpus from a
#' markov model
#'
#' @param markov_model markov model object
#' @param input_text vector of input text
#'
#' @return
#' @export
#' @examples
generate_corpus <-
  function(markov_model, input_text) {
   corpus <- markov_model$generate_corpus(text = input_text)
   corpus
  }

#' Generate parsed sentences
#'
#' This function returns the parsed input
#' text in sentence form
#'
#' @param markov_model
#'
#' @return a \code{list}
#' @export
#'
#' @examples
generate_parsed_sentences <-
  function(markov_model) {
    markov_model$parsed_sentences
  }

generate_sentence_starting_with <-
  function(markov_model, start_word) {
   sentence <- markov_model$make_sentence_with_start(beginning = start_word)

   if (!'sentence' %>% exists()) {
     stop(glue::glue("Cannot start sentenc with {start_word}"))
   }
   sentence
  }

generate_sentences_starting_with <-
  function(markov_model,
           start_word,
           output_column_name = "textLinnemanBot",
           count = 50,
           tries = 100,
           only_distinct = TRUE,
           return_message = TRUE) {
    generate_sentence_starting_with_safe <-
      purrr::possibly(generate_sentence_starting_with, data_frame)

    df_text <-
      1:count %>%
      map_df(function(x){
        text_output <-
          generate_sentence_starting_with_safe(markov_model = markov_model, start_word = start_word)
        if (text_output %>% purrr::is_null()) {
          return(invisible())
        }
        data_frame(idRow = x, wordStart = start_word ,UQ(output_column_name) := text_output)
      })

    if (only_distinct) {
      df_text <-
        df_text %>%
        select(-idRow) %>%
        distinct() %>%
        mutate(idRow = 1:n()) %>%
        select(idRow, everything())
    }

    if (return_message) {
      1:nrow(df_text) %>%
        walk(function(x) {
          text_output <-
            df_text %>% slice(x) %>% select(3) %>% pull(UQ(output_column_name))
          glue::glue("{output_column_name}: {text_output}") %>% message()
        })

    }

    df_text
  }

generate_sentences_starting_with_words <-
  function(markov_model,
           start_words = c("If", "You"),
           output_column_name = "textLinnemanBot",
           count = 50,
           tries = 100,
           only_distinct = TRUE,
           return_message = TRUE) {

      generate_sentences_starting_with_safe <-
      purrr::possibly(generate_sentences_starting_with, data_frame())

    all_data <-
      start_words %>%
      map_df(function(x) {
        generate_sentences_starting_with_safe(
          markov_model = markov_model,
          start_word = x,
          output_column_name = output_column_name,
          count = count,
          tries = tries,
          only_distinct = only_distinct,
          return_message = return_message
        )
      })

    all_data
  }

#' Generate start words
#'
#' @param markov_model markov model mobject
#' @param include_cumulative_distance if \code{TRUE} returns
#' cumulative distance of the words
#'
#' @return a \code{data_frame} objects
#' @export
#' @examples
generate_start_words <-
  function(markov_model, include_cumulative_distance = TRUE) {
    start <- markov_model$chain$begin_choices

    df <-
      1:length(start) %>%
      purrr::map_df(function(x){
        word <- start[[x]]
        data_frame(idSentence = x, wordStart = word)
      })

    if (include_cumulative_distance) {
      df <-
        df %>%
        mutate(distanceCumulative = markov_model$chain$begin_cumdist)
    }
    df
  }

#' Markovify text
#'
#' Produces text output from
#' a markov model based pn user specified
#' parameters
#'
#' @param markov_model a markov model produced from \code{generate_markovify_model}
#' @param start_words a markov model produced with a list of start word terms
#' @param maximum_sentence_length the maximum length of the sentence
#' if \code{NULL} model will produce a random sentence of any length.
#' @param output_column_name name of the output column in dataframe
#' @param count count of the number of sentences, default \code{50}
#' @param tries count of the number of tries to produce a coherent sentence
#' @param only_distinct if \code{TRUE} returns only distinct text
#' @param return_message if \code{TRUE} returns a message
#'
#' @return a \code{data_frame}
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(markovifyR)
#' data("linneman_lessons")
#' df <- linneman_lessons
#' lessons <- df %>% pull(textLesson)
#' markov_model <-
#' generate_markovify_model(
#' input_text = lessons,
#' markov_state_size = 2L,
#' max_overlap_total = 15,
#' max_overlap_ratio = .8)
#'
#'markovify_text(
#'markov_model = markov_model,
#'count = 100,
#'maximum_sentence_length = 1500L,
#'output_column_name = 'linnemanBotText',
#'tries = 100,
#'only_distinct = TRUE,
#'return_message = TRUE
#')
#' }
markovify_text <-
  function(markov_model,
           maximum_sentence_length = NULL,
           start_words = NULL,
           output_column_name = "columnName",
           count = 50,
           tries = 100,
           only_distinct = TRUE,
           return_message = TRUE) {

    if (!start_words %>% purrr::is_null()) {
      data <-
        generate_sentences_starting_with_words(markov_model = markov_model,
                                             start_words = start_words,
                                             output_column_name = output_column_name,
                                             count = count,
                                             tries = tries,
                                             only_distinct = only_distinct,
                                             return_message = return_message)

      return(data)
    }

    if (maximum_sentence_length %>% purrr::is_null()) {
     data <-
       generate_sentence(markov_model = markov_model,
                       output_column_name = output_column_name,
                       count = count,
                       tries = tries,
                       only_distinct = only_distinct,
                       return_message = return_message)
     return(data)
    }

    data <-
      generate_short_sentence(
        markov_model = markov_model,
        maximum_sentence_length = maximum_sentence_length,
        output_column_name = output_column_name,
        count = count,
        tries = tries,
        only_distinct = only_distinct,
        return_message = return_message
      )

    data

  }

#' Export Markov Model
#'
#' @param markov_model a markov model object
#' @param format \itemize{
#' \item json - returns a json object
#' \item dict - returns dictionary object
#' }
#' @return a json or dictionary object
#' @export
#' @import purrr reticulate stringr tibble dplyr
#' @examples
export_markov_model <-
  function(markov_model, format = "json"){
    if (!format %>% stringr::str_to_lower() == "json"){
        output <- markov_model$to_dict()
    }
   output <-
     markov_model$to_json()
   output
  }
