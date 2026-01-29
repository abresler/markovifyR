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
      future_map_dfr(function(x) {
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
        tibble(idRow = x, UQ(output_column_name) := text_output)
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
          glue::glue("\n\n{output_column_name}: {text_output}\n\n") %>% cat(fill = T)
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
      future_map_dfr(function(x) {
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
        tibble(idRow = x, UQ(output_column_name) := text_output)
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
          glue::glue("{crayon::blue(output_column_name)}: {crayon::white(text_output)}") %>% cat(fill = T)
        })

    }

    df_text
  }



#' Combine Markov Models
#'
#' Builds a combined markov model from two separate models,
#' allowing text generation that blends characteristics from both sources.
#'
#' @param model_a A markov model object created by \code{generate_markovify_model}.
#' @param model_b A markov model object created by \code{generate_markovify_model}.
#' @param weights Numeric vector of length 2 specifying the relative weights
#' for each model. Default is \code{c(1, 1.5)}.
#'
#' @return A combined markov model Python object that can be used with
#' \code{markovify_text} and other text generation functions.
#' @export
#'
#' @examples
#' \dontrun{
#' library(markovifyR)
#'
#' # Create two separate models from different text sources
#' model_a <- generate_markovify_model(input_text = text_source_1)
#' model_b <- generate_markovify_model(input_text = text_source_2)
#'
#' # Combine models with equal weighting
#' combined_model <- combine_markov_models(model_a, model_b, weights = c(1, 1))
#'
#' # Combine models with model_b weighted more heavily
#' combined_model <- combine_markov_models(model_a, model_b, weights = c(1, 2))
#'
#' # Generate text from the combined model
#' markovify_text(combined_model, count = 10)
#' }
combine_markov_models <-
  function(model_a, model_b, weights = c(1, 1.5)) {
    mk <- reticulate::import("markovify")

    model <-
      mk$combine(models = c(model_a, model_b), weights = weights)
    model
  }

#' Generate Corpus from Markov Model
#'
#' Generates a corpus structure from a markov model and input text.
#' The corpus represents the processed text data used internally
#' by the markov chain.
#'
#' @param markov_model A markov model object created by \code{generate_markovify_model}.
#' @param input_text Character vector of input text to process into the corpus.
#'
#' @return A Python corpus object containing the processed text structure.
#' @export
#'
#' @examples
#' \dontrun{
#' library(markovifyR)
#' data("linneman_lessons")
#'
#' # Create a markov model
#' lessons <- linneman_lessons$textLesson
#' markov_model <- generate_markovify_model(input_text = lessons)
#'
#' # Generate corpus from the model
#' corpus <- generate_corpus(markov_model, input_text = lessons)
#' }
generate_corpus <-
  function(markov_model, input_text) {
   corpus <- markov_model$generate_corpus(text = input_text)
   corpus
  }

#' Generate Parsed Sentences
#'
#' Returns the parsed input text in sentence form from a markov model.
#' Useful for inspecting how the model has tokenized and processed
#' the original input text.
#'
#' @param markov_model A markov model object created by \code{generate_markovify_model}.
#'
#' @return A \code{list} containing the parsed sentences from the model's
#' internal representation.
#' @export
#'
#' @examples
#' \dontrun{
#' library(markovifyR)
#' data("linneman_lessons")
#'
#' # Create a markov model
#' lessons <- linneman_lessons$textLesson
#' markov_model <- generate_markovify_model(input_text = lessons)
#'
#' # Get parsed sentences
#' parsed <- generate_parsed_sentences(markov_model)
#'
#' # View the first few parsed sentences
#' head(parsed)
#' }
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
      purrr::possibly(generate_sentence_starting_with, tibble)

    df_text <-
      1:count %>%
      future_map_dfr(function(x){
        text_output <-
          generate_sentence_starting_with_safe(markov_model = markov_model, start_word = start_word)
        if (text_output %>% purrr::is_null()) {
          return(invisible())
        }
        tibble(idRow = x, wordStart = start_word ,UQ(output_column_name) := text_output)
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
          glue::glue("{output_column_name}: {text_output}") %>% cat(fill = T)
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
      purrr::possibly(generate_sentences_starting_with, tibble())

    all_data <-
      start_words %>%
      future_map_dfr(function(x) {
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

#' Generate Start Words
#'
#' Retrieves the available starting words from a markov model's chain.
#' These are words that can be used with \code{markovify_text} when
#' specifying \code{start_words} to begin generated sentences.
#'
#' @param markov_model A markov model object created by \code{generate_markovify_model}.
#' @param include_cumulative_distance Logical. If \code{TRUE} (default), returns
#' cumulative distance values for each starting word.
#'
#' @return A \code{tibble} with columns:
#' \itemize{
#'   \item \code{idSentence}: Integer row identifier
#'   \item \code{wordStart}: Character string of the starting word
#'   \item \code{distanceCumulative}: Numeric cumulative distance (if requested)
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' library(markovifyR)
#' data("linneman_lessons")
#'
#' # Create a markov model
#' lessons <- linneman_lessons$textLesson
#' markov_model <- generate_markovify_model(input_text = lessons)
#'
#' # Get available start words
#' start_words <- generate_start_words(markov_model)
#'
#' # Get start words without cumulative distance
#' start_words <- generate_start_words(markov_model, include_cumulative_distance = FALSE)
#'
#' # Use start words in text generation
#' selected_words <- head(start_words$wordStart, 5)
#' markovify_text(markov_model, start_words = selected_words, count = 10)
#' }
generate_start_words <-
  function(markov_model, include_cumulative_distance = TRUE) {
    start <- markov_model$chain$begin_choices

    df <-
      seq_along(start) %>%
      future_map_dfr(function(x){
        word <- start[[x]]
        tibble(idSentence = x, wordStart = word)
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
#' @param output_column_name name of the
#' @param count count of the number of sentences, default \code{50}
#' @param tries count of the number of tries to produce a coherent sentence
#' @param only_distinct if \code{TRUE} returns only distinct text
#' @param return_message if \code{TRUE} returns a message
#'
#' @return a \code{tibble}
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
#' Exports a markov model to a portable format (JSON or dictionary)
#' for storage or transfer.
#'
#' @param markov_model A markov model object created by \code{generate_markovify_model}.
#' @param format Character string specifying the export format:
#' \itemize{
#'   \item \code{"json"} (default) - returns a JSON string representation
#'   \item \code{"dict"} - returns a Python dictionary object
#' }
#'
#' @return A JSON string or Python dictionary object representing the model.
#' @export
#' @import purrr reticulate stringr tibble dplyr
#'
#' @examples
#' \dontrun{
#' library(markovifyR)
#' data("linneman_lessons")
#'
#' # Create a markov model
#' lessons <- linneman_lessons$textLesson
#' markov_model <- generate_markovify_model(input_text = lessons)
#'
#' # Export as JSON (default)
#' json_model <- export_markov_model(markov_model)
#'
#' # Export as dictionary
#' dict_model <- export_markov_model(markov_model, format = "dict")
#'
#' # Save JSON to file
#' writeLines(json_model, "my_markov_model.json")
#' }
export_markov_model <-
  function(markov_model, format = "json"){
    if (!format %>% stringr::str_to_lower() == "json"){
        output <- markov_model$to_dict()
    }
   output <-
     markov_model$to_json()
   output
  }
