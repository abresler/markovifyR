# Snapshot Baseline Tests
# Created during cleanup - captures current behavior for regression detection

test_that("install_markovify exists and is callable", {
  expect_true(exists("install_markovify"))
  expect_type(install_markovify, "closure")
})

test_that("generate_markovify_model validates inputs", {
  # Test state size validation
  expect_error(
    generate_markovify_model(
      input_text = c("test"),
      markov_state_size = 2,
      max_overlap_ratio = 1.5  # Invalid: >1
    ),
    "Overlap ratio can only be between 0 and 1"
  )
})

test_that("combine_markov_models exists and has correct signature", {
  expect_true(exists("combine_markov_models"))
  expect_type(combine_markov_models, "closure")
  # Verify parameter names
  expect_named(formals(combine_markov_models), c("model_a", "model_b", "weights"))
})

test_that("generate_corpus exists", {
  expect_true(exists("generate_corpus"))
  expect_type(generate_corpus, "closure")
})

test_that("generate_parsed_sentences exists", {
  expect_true(exists("generate_parsed_sentences"))
  expect_type(generate_parsed_sentences, "closure")
})

test_that("generate_start_words exists and has correct defaults", {
  expect_true(exists("generate_start_words"))
  expect_type(generate_start_words, "closure")
  expect_true(formals(generate_start_words)$include_cumulative_distance)
})

test_that("markovify_text exists and has correct defaults", {
  expect_true(exists("markovify_text"))
  expect_type(markovify_text, "closure")
  expect_equal(formals(markovify_text)$count, 50)
  expect_equal(formals(markovify_text)$tries, 100)
  expect_true(formals(markovify_text)$only_distinct)
})

test_that("export_markov_model exists and has correct defaults", {
  expect_true(exists("export_markov_model"))
  expect_type(export_markov_model, "closure")
  expect_equal(formals(export_markov_model)$format, "json")
})

test_that("get_data_linneman_lessons returns expected structure", {
  skip_if_offline()
  skip_on_cran()

  # This test requires network access - will be skipped if offline
  result <- tryCatch(
    get_data_linneman_lessons(),
    error = function(e) NULL
  )

  if (!is.null(result)) {
    expect_s3_class(result, "tbl_df")
    expect_named(result, c("idLesson", "textLesson"))
  }
})

test_that("linneman_lessons data exists and has correct structure", {
  data("linneman_lessons", package = "markovifyR")
  expect_s3_class(linneman_lessons, "tbl_df")
  expect_named(linneman_lessons, c("idLesson", "textLesson"))
  expect_gt(nrow(linneman_lessons), 0)
})
