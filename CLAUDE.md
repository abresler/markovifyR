# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

**markovifyR** (v0.102) - R wrapper for the Python [Markovify](https://github.com/jsvine/markovify) library for Markov chain text generation.

## Prerequisites

Python and markovify must be installed:

```bash
pip install markovify
```

Or from R:
```r
system("pip install markovify")
# or use the package function:
markovifyR::install_markovify()
```

## Common Commands

```bash
# Regenerate documentation (NAMESPACE and man/)
Rscript -e "devtools::document()"

# Load package for development
Rscript -e "devtools::load_all()"

# Install locally
Rscript -e "devtools::install()"

# Full package check
Rscript -e "devtools::check()"

# Build tarball
R CMD build .
```

No formal test suite exists - the `tests/` directory is empty.

## Architecture

### Python Bridge via reticulate

The package uses `reticulate::import("markovify")` to access the Python markovify module. The bridge works by:

1. Creating Python markovify Text objects that persist as R objects
2. Calling Python methods directly on these objects (e.g., `markov_model$make_sentence()`)
3. Converting Python return values to R types (strings, lists)

Key pattern in `markovify.R`:
```r
mk <- reticulate::import("markovify")
markov_model <- mk$Text(input_text = input_text, state_size = markov_state_size)
```

### Exported Functions (9 total)

| Function | Purpose |
|----------|---------|
| `generate_markovify_model()` | Build markov model from text vector |
| `markovify_text()` | Generate text from model (main entry point) |
| `generate_start_words()` | Get available starting words from model |
| `combine_markov_models()` | Merge two models with weights |
| `export_markov_model()` | Export model to JSON or dict |
| `generate_corpus()` | Get processed corpus structure |
| `generate_parsed_sentences()` | Get model's parsed sentence list |
| `get_data_linneman_lessons()` | Fetch sample data from web |
| `install_markovify()` | Install Python markovify via pip |

### Internal Functions (not exported)

- `generate_sentence()` - unlimited length text generation
- `generate_short_sentence()` - length-constrained generation
- `generate_sentence_starting_with()` - single start word
- `generate_sentences_starting_with()` - batch start word generation
- `generate_sentences_starting_with_words()` - multiple start words

### Typical Workflow

```r
# 1. Build model from text vector
model <- generate_markovify_model(
  input_text = text_vector,
  markov_state_size = 2L,
  max_overlap_total = 15,
  max_overlap_ratio = 0.7
)

# 2. Generate text
markovify_text(model, count = 25, return_message = TRUE)

# 3. Optional: constrain by start words or length
markovify_text(model, start_words = c("The", "If"), count = 10)
markovify_text(model, maximum_sentence_length = 100, count = 10)
```

### Data

`linneman_lessons` - bundled tibble with 101 Peter Linneman life lessons for demo purposes.

## Dependencies

**Imports:** reticulate, glue, dplyr, purrr, stringr, tibble, furrr, rlang, future

The package uses `furrr::future_map_dfr()` for parallel text generation when a future plan is set.
