library(tidyverse)
library(markovifyR)
setwd("~")
bap <- read_lines("Downloads/bap.txt", skip_empty_rows = T)

tbl_bap <- tibble(bapism = bap) %>%
  mutate(bapism = str_replace_all(bapism, '[\"]', '')) %>%
  separate(
    bapism,
    into = c("bapism", "speaker"),
    sep = "\\ - ",
    extra = "merge",
    fill = "right"
  ) %>%
  mutate(speaker = speaker %>% coalesce("BAP"))

sexy_bap <-
  tbl_bap %>%
  filter(speaker == "BAP") %>%
  dplyr::select(bapism) %>%
  pull()


markov_model <-
  generate_markovify_model(
    input_text = sexy_bap,
    markov_state_size = 3L,
    max_overlap_total = 35,
    max_overlap_ratio = .95
  )


bap_bot <- markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  output_column_name = 'bap_bot',
  count = 50,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)

markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  output_column_name = 'bap_bot',
  count = 50,
  tries = 100,
  start_words = c("Wuhan", "Communists"),
  only_distinct = TRUE,
  return_message = TRUE
)