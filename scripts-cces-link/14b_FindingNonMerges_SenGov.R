library(stringi)
library(stringr)
library(tidyr)
library(dplyr)
library(haven)
library(readr)
library(readxl)

#######################################
# Set the working directory         #
#######################################

setwd("~/Dropbox/cces_cumulative/")

#######################################
# Load the data         #
#######################################

load("data/candidates_key.RData")
sc_key_2018 <- sc_key[sc_key$dataset=="2018",]
sc_key <- sc_key |>
  filter(dataset %in% c("2006", "2008", "2010", "2012", "2014", "2016"))

gc_key_2018 <- gc_key[gc_key$dataset=="2018",]
gc_key <- gc_key |>
  filter(dataset %in% c("2006", "2008", "2010", "2012", "2014", "2016"))

jim_data <- read_dta("~/Dropbox/CCES_candidates/Input/election_results_2006_2016.dta")

###########################################
# Rename Variables and Pull out Last Names #
###########################################

#rename soe variables
jim_data <- jim_data  |>
  rename(dist_up=dist,
         st=state)

#pull out the last names of candidates in jim's data
jim_data$namelast <- gsub(",.*$", "", jim_data$name)
jim_data$namelast <- word(jim_data $namelast, -1)
jim_data$namelast <- trimws(jim_data $namelast)


########################################
# Merge the two datasets together     #
########################################

#Senate
fulldata_senate <- anti_join(sc_key, jim_data[jim_data$office=="S",], by=c("st", "namelast", "year"))

#get a dataframe of unique candidate names that aren't merging
fulldata_senate <- fulldata_senate[!duplicated(fulldata_senate[c("name","year")]), ]
fulldata_senate <- fulldata_senate[!is.na(fulldata_senate$name), ]

setwd("~/Dropbox/CCES_candidates/Output/")
write_csv(fulldata_senate,'NonMergingCandidates_senate2007to2016_raw.csv')

#Governor
fulldata_gov <- anti_join(gc_key, jim_data[jim_data$office=="G",], by=c("st", "namelast", "year"))

#get a dataframe of unique candidate names that aren't merging
fulldata_gov <- fulldata_gov[!duplicated(fulldata_gov[c("name","year")]), ]
fulldata_gov <- fulldata_gov[!is.na(fulldata_gov$name), ]

setwd("~/Dropbox/CCES_candidates/Output/")
write_csv(fulldata_gov,'NonMergingCandidates_governor2007to2016_raw.csv')


