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

    ## textLinnemanBot: “What is the bet?” is the bet?” is the outcome of hard work every day; not a eureka experience

    ## textLinnemanBot: Your job in life that can’t be fixed, so don’t go crazy when things break

    ## textLinnemanBot: Putting profits before power will generally result in a life of power

    ## textLinnemanBot: Members of the people you love

    ## textLinnemanBot: Generosity is cheap over the long term, as you will never realize it was your fault; then ask how you feel about them

    ## textLinnemanBot: Life isn’t fair, so don’t go crazy when things are unfair

    ## textLinnemanBot: “What is the right thing simply because it is what it is what it is the right thing simply because it is the bet?” is the outcome of hard work every day; not a eureka experience

    ## textLinnemanBot: Just when you are doing something, and do it Then it is learned as you wrinkle

    ## textLinnemanBot: Let the people you love

    ## textLinnemanBot: Genius is the critical question

    ## textLinnemanBot: Genius is the bet?” is the bet?” is the critical question

    ## textLinnemanBot: Enjoy what you do not respect yourself, why should anyone else respect you

    ## textLinnemanBot: In the battle between fear and greed, greed wins about 80% of the people you love

    ## textLinnemanBot: Assume it was your fault; then ask how you feel about them

    ## textLinnemanBot: Stick to what you do not feel so special

    ## textLinnemanBot: People are the problem

    ## textLinnemanBot: To interview well, think of yourself like a stripper; you need to be me and us; most people want it to be mean and they will view it as a very nasty statement

    ## textLinnemanBot: Why ever do less than the sadness of their life rather than the sadness of their life rather than the best you that you can be

    ## textLinnemanBot: Take ownership of your death, so do not love yourself, there is no reason others should love you

    ## textLinnemanBot: Stick to what you do not love yourself, there is no reason others should love you

    ## textLinnemanBot: There are very few things in life that can’t be fixed, so don’t take it personally if yours are strange and difficult; so don’t take it personally if yours are strange and difficult

    ## textLinnemanBot: Find out who you are If people don’t like it, that’s their problem

    ## textLinnemanBot: There are just a humble school teacher”

    ## textLinnemanBot: Life isn’t fair, so don’t take it personally if yours are strange and difficult

    ## textLinnemanBot: The machine is rarely the problem; the people you love

    ## # A tibble: 25 x 2
    ##    idRow textLinnemanBot                                                                                               
    ##    <int> <chr>                                                                                                         
    ##  1     1 "“What is the bet?” is the bet?” is the outcome of hard work every day; not a eureka experience"              
    ##  2     2 "Your job in life that can’t be fixed, so don’t go crazy when things break"                                   
    ##  3     3 "Putting profits before power will generally result in a life of power"                                       
    ##  4     4 "Members of the people you love"                                                                              
    ##  5     5 "Generosity is cheap over the long term, as you will never realize it was your fault; then ask how you feel a…
    ##  6     6 "Life isn’t fair, so don’t go crazy when things are unfair"                                                   
    ##  7     7 "“What is the right thing simply because it is what it is what it is the right thing simply because it is the…
    ##  8     8 "Just when you are doing something, and do it Then it is learned as you wrinkle"                              
    ##  9     9 "Let the people you love"                                                                                     
    ## 10    10 "Genius is the critical question"                                                                             
    ## # ... with 15 more rows

#### Step 4 -- Other Features

Generate random sentence starting with.

``` r
markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  start_words = c("The", "You", "Life"),
  output_column_name = 'textLinnemanBot',
  count = 25,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)
```

    ## textLinnemanBot: The machine is rarely the problem; the people you love

    ## textLinnemanBot: The machine is rarely the problem; the people who matter know how you feel about them

    ## textLinnemanBot: The machine is rarely the problem; the people operating the machine are the ultimate assets

    ## textLinnemanBot: The machine is rarely the problem; the people who matter know how you could have made it better

    ## textLinnemanBot: You may never get a second chance to tell people how you could have made it better

    ## textLinnemanBot: Life isn’t fair, so don’t be upset when things break

    ## textLinnemanBot: Life isn’t fair, so don’t take it personally if yours are strange and difficult

    ## textLinnemanBot: Life will end; face it and embrace the joy of their life rather than the best you can?

    ## textLinnemanBot: Life isn’t fair, so don’t go crazy when things are unfair

    ## textLinnemanBot: Life isn’t fair, so don’t go crazy when things break

    ## textLinnemanBot: Life will end; face it and embrace the joy of their life rather than the sadness of their life rather than the best you can?

    ## textLinnemanBot: Life will end; face it and embrace the joy of their life rather than the sadness of their life rather than the sadness of their life rather than the sadness of their death

    ## textLinnemanBot: Life isn’t fair, so don’t take it personally if yours are strange and difficult; so don’t go crazy when things break

    ## textLinnemanBot: Life will end; face it and embrace the joy of their life rather than the best you that you can be

    ## textLinnemanBot: Life will end; face it and embrace the joy of their life rather than the sadness of their life rather than the sadness of their life rather than the best you that you can be

    ## # A tibble: 15 x 3
    ##    idRow wordStart textLinnemanBot                                                                                     
    ##    <int> <chr>     <chr>                                                                                               
    ##  1     1 The       "The machine is rarely the problem; the people you love"                                            
    ##  2     2 The       "The machine is rarely the problem; the people who matter know how you feel about them"             
    ##  3     3 The       "The machine is rarely the problem; the people operating the machine are the ultimate assets"       
    ##  4     4 The       "The machine is rarely the problem; the people who matter know how you could have made it better"   
    ##  5     1 You       "You may never get a second chance to tell people how you could have made it better"                
    ##  6     1 Life      "Life isn’t fair, so don’t be upset when things break"                                              
    ##  7     2 Life      "Life isn’t fair, so don’t take it personally if yours are strange and difficult"                   
    ##  8     3 Life      "Life will end; face it and embrace the joy of their life rather than the best you can?"            
    ##  9     4 Life      "Life isn’t fair, so don’t go crazy when things are unfair"                                         
    ## 10     5 Life      "Life isn’t fair, so don’t go crazy when things break"                                              
    ## 11     6 Life      "Life will end; face it and embrace the joy of their life rather than the sadness of their life rat…
    ## 12     7 Life      "Life will end; face it and embrace the joy of their life rather than the sadness of their life rat…
    ## 13     8 Life      "Life isn’t fair, so don’t take it personally if yours are strange and difficult; so don’t go crazy…
    ## 14     9 Life      "Life will end; face it and embrace the joy of their life rather than the best you that you can be" 
    ## 15    10 Life      "Life will end; face it and embrace the joy of their life rather than the sadness of their life rat…

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
