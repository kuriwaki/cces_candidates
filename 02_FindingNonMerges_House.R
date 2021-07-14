library(stringi)
library(stringr)
library(dplyr)
library(readxl)


#load in the cces candidate data from shiro
load("data/candidates_key.RData")
rc_key_2018 <- rc_key[rc_key$dataset=="2018",]
rc_key <- rc_key[rc_key$dataset=="2006" | rc_key$dataset=="2008"| rc_key$dataset=="2010"|rc_key$dataset=="2012"|rc_key$dataset=="2014"|rc_key$dataset=="2016",]

#load in the election data from Jim
jim_data <- read.dta13("~/Dropbox/CCES_candidates/Input/election_results_2006_2016.dta")

#rename some variables
jim_data <- jim_data  %>%
  rename(dist_up=dist,
         st=state)

#pull out the last names of candidates for the merge
jim_data$namelast <- gsub(",.*$", "", jim_data$name)
jim_data$namelast <- word(jim_data $namelast, -1)
jim_data$namelast <- trimws(jim_data $namelast)

#merge the two datasets together
rc_key <- rc_key[!is.na(rc_key$name),]
fulldata <- left_join(rc_key[rc_key$year < 2017,], jim_data[jim_data$office=="H",], by=c("st", "dist_up", "namelast", "year"))
fulldata_check <- anti_join(rc_key[rc_key$year < 2017,], jim_data[jim_data$office=="H",], by=c("st", "dist_up", "namelast", "year"))

#get a dataframe of unique candidate names that aren't merging
fulldata_check_cands <- fulldata_check[!duplicated(fulldata_check[c("name","year")]), ]

#save the data so that we can see what's going on
setwd("~/Dropbox/CCES_candidates/Output")
write.csv(fulldata_check_cands,'NonMergingCandidates_2006to2017_raw.csv')

#now working on 2018

#load in the 2018 election data from shiro
cands_2018 <- read_excel("~/Dropbox/CCES_candidates/Input/js-extension_by-cand_2018.xlsx")
cands_2018$year <-2018

#limit the data to vaiables we need
cands_2018 <- cands_2018 %>%
  select(cd, name, year, candidatevotes, inc, w_g, u_g)

#create some variables for the merge
cands_2018 <- cands_2018 %>%
  separate(cd, c("st","dist_up"), sep = "-")
cands_2018$dist_up <- as.numeric(cands_2018$dist_up)

#make candidate names upper case
cands_2018$name_caps <- toupper(cands_2018$name)

#remove words that might make it difficult to merge on last names
cands_2018$name_caps<- gsub(", JR.$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(" JR.$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(" JR$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(" IV$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(" III$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(",II$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(" II$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(", SR.$", " ", cands_2018$name_caps) # Remove spans
cands_2018$name_caps<- gsub(", $", " ", cands_2018$name_caps) # Remove spans

#remove extra white space
cands_2018$name_caps <- str_squish(cands_2018$name_caps)

#pull out the last name
cands_2018$namelast <- word(cands_2018$name_caps, -1)

#merge the datasets together
fulldata_2018 <- left_join(rc_key_2018, cands_2018, by=c("st", "dist_up", "namelast", "year"), all.x=TRUE)
fulldata_2018_check <- anti_join(rc_key_2018, cands_2018, by=c("st", "dist_up", "namelast", "year"))

#get a dataframe of unique candidate names that aren't merging
fulldata_check_cands_2018 <- fulldata_2018_check[!duplicated(fulldata_2018_check[c("name","year")]), ]
fulldata_check_cands_2018 <- fulldata_check_cands_2018[!is.na(fulldata_check_cands_2018$name),]
setwd("~/Dropbox/CCES_candidates/Output")
write.csv(fulldata_check_cands_2018,'NonMergingCandidates_2018_raw.csv')




