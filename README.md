MarkovifyR
================

`markovifyR` : R wrapper for Markovify

Ref: <https://github.com/jsvine/markovify>

> *"Markovify is a simple, extensible Markov chain generator. Right now, its main use is for building Markov models of large corpora of text, and generating random sentences from that."*

This package requires Python and markovify to be installed.

To install markovify in R you can run:

``` r
system("pip install markovify")
```

The following functions are implemented:

-   `generate_markovify_model:` Generates a markov model
-   `markovify_text`: Generates text from a markov model
-   `generate_sentence_starting_with`: Generates text, if possible, with your specified start word
-   `generate_start_words`: Produces a data frame with the starting words for each input sentence
-   

### Installation

``` r
devtools::install_github("abresler/markovifyR")
```

``` r
options(width=120)
```

### Usage

``` r
library(markovifyR)
library(dplyr)
```

### Generate New Peter Linneman "Life Lessons""

Here we are going to showcase how to use the package to create new [Life Lessons](asbcllc.com/reflections/peter_linneman/) from my favorite professor from college Peter Linneman.

#### Step 1 -- Build the Corpus

``` r
data("linneman_lessons")

lessons <-
  linneman_lessons %>% 
  pull(textLesson)

lessons %>% str()
```

    ##  chr [1:101] "You always have time for what is important to you" ...

#### Step 2 -- Build the Model

``` r
markov_model <-
  generate_markovify_model(
    input_text = lessons,
    markov_state_size = 2L,
    max_overlap_total = 25,
    max_overlap_ratio = .85
  )
```

### Step 3 -- Generate the Text

``` r
markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  output_column_name = 'textLinnemanBot',
  count = 25,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)
```

    ## textLinnemanBot: Issues are much easier to see reality

    ## textLinnemanBot: Your job in life is to convey who you are and stay true to your core; be patient as shortly thereafter something wonderful and amazing will happen

    ## textLinnemanBot: It is meant to be me and us

    ## textLinnemanBot: And not more than about a dozen people will truly cry when they hear of your mistakes but also forgive yourself for making mistakes

    ## textLinnemanBot: Pick your conflicts; most disputes are not linear, so be open to unexpected changes

    ## textLinnemanBot: Assume it was your fault; then ask how you feel about them

    ## textLinnemanBot: Just when you are If people don’t like it, that’s their problem

    ## textLinnemanBot: And not more than about a dozen people will truly cry when they hear of your death, so do not open the door when opportunity knocks, you will receive benefits many times over during your life

    ## textLinnemanBot: Just be the best you can?

    ## textLinnemanBot: “What is the bet?” is the bet?” is the outcome of hard work every day; not a eureka experience

    ## textLinnemanBot: Generosity is cheap over the long term, as you wrinkle

    ## textLinnemanBot: Don’t engage in mental masturbation; focus on decisions that matter in life is to convey who you are and show them your assets

    ## textLinnemanBot: Assess your audience before you got here, and will get along fine when you think you have is your reputation

    ## textLinnemanBot: Just when you think you have is your reputation

    ## textLinnemanBot: Genius is the right thing simply because it is what it is the critical question

    ## textLinnemanBot: It’s the journey – not the things – that matter in life and good things can happen

    ## textLinnemanBot: Being subtle is not a eureka experience

    ## textLinnemanBot: Life isn’t fair, so don’t take it personally if yours are strange and difficult

    ## textLinnemanBot: Remember that the world did just fine before you start to speak

    ## textLinnemanBot: Decide what you know, but keep learning

    ## textLinnemanBot: You may never get a second chance to tell people how you could have made it better

    ## textLinnemanBot: All you have figured out life, along comes something horrible that shakes you to your values

    ## textLinnemanBot: Open doors in life is to convey who you are gone.

    ## textLinnemanBot: Enjoy what you know, but keep learning

    ## # A tibble: 24 x 2
    ##    idRow textLinnemanBot                                                                                               
    ##    <int> <chr>                                                                                                         
    ##  1     1 "Issues are much easier to see reality"                                                                       
    ##  2     2 "Your job in life is to convey who you are and stay true to your core; be patient as shortly thereafter somet…
    ##  3     3 "It is meant to be me and us"                                                                                 
    ##  4     4 "And not more than about a dozen people will truly cry when they hear of your mistakes but also forgive yours…
    ##  5     5 "Pick your conflicts; most disputes are not linear, so be open to unexpected changes"                         
    ##  6     6 "Assume it was your fault; then ask how you feel about them"                                                  
    ##  7     7 "Just when you are If people don’t like it, that’s their problem"                                             
    ##  8     8 "And not more than about a dozen people will truly cry when they hear of your death, so do not open the door …
    ##  9     9 "Just be the best you can?"                                                                                   
    ## 10    10 "“What is the bet?” is the bet?” is the outcome of hard work every day; not a eureka experience"              
    ## # ... with 14 more rows

#### Step 4 -- Other Features

Generate random sentence starting with.

``` r
generate_sentence_starting_with(markov_model = markov_model, start_word = "If")
```

    ## [1] "If you do and success will follow"

Look at corpus start-words

``` r
generate_start_words(markov_model = markov_model)
```

    ## # A tibble: 63 x 3
    ##    idSentence wordStart distanceCumulative
    ##         <int> <chr>                  <int>
    ##  1          1 There                      3
    ##  2          2 Travel,                    4
    ##  3          3 Genius                     5
    ##  4          4 Take                       9
    ##  5          5 You                       14
    ##  6          6 Analyze                   15
    ##  7          7 Careers                   16
    ##  8          8 Remember                  17
    ##  9          9 Be                        21
    ## 10         10 Life                      23
    ## # ... with 53 more rows
