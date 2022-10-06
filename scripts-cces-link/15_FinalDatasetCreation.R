library(stringi)
library(stringr)
library(tidyr)
library(dplyr)
library(haven)

#######################################
# Load the data         #
#######################################

load("~/Dropbox/cces_cumulative/data/output/01_responses/candidates_key.RData")

jim_data <- read_dta("~/Dropbox/CCES_candidates/Output/CandidateLevel_Candidates.dta")
# Remove blank name candidates
jim_data <- filter(jim_data, name != "")

# As of right now rc_key has both pre and post observations, leading there to be lots of duplicates.
# We want to only keep everyone once unless they moved between pre and post.
rc_key<- rc_key  |>
  distinct_at(vars(-dataset), .keep_all = TRUE)

sc_key<- sc_key  |>
  distinct_at(vars(-dataset, -dist, -dist_up), .keep_all = TRUE)

gc_key<- gc_key  |>
  distinct_at(vars(-dataset,-dist, -dist_up), .keep_all = TRUE)

# Need to make sure not incorrectly merging on district for senate and governor
sc_key$house_dist <- sc_key$dist
sc_key$house_distup <- sc_key$dist_up
sc_key$dist <- NA
sc_key$dist_up <- NA

gc_key$house_dist <- gc_key$dist
gc_key$house_distup <- gc_key$dist_up
gc_key$dist <- NA
gc_key$dist_up <- NA

# Combine CCES House Senate and Governor
sc_key$office <- "S"
gc_key$office <- "G"
rc_key$office <- "H"

rc_key <- bind_rows(rc_key, sc_key, gc_key)

###########################################
# Clean Names in the CCES #
###########################################

rc_key <- rc_key[!is.na(rc_key$name), ]
rc_key$name_cces <- rc_key$name

rc_key$namelast[rc_key$name == "Robert Aderhold" & rc_key$year == 2012 & rc_key$office == "H"] <- "ADERHOLT"

rc_key$namelast[rc_key$name == "Robert Anderholt" & rc_key$year == 2016 & rc_key$office == "H"] <- "ADERHOLT"

rc_key$namelast[rc_key$name == "Morgan Spencer" & rc_key$year == 2012 & rc_key$office == "H"] <- "MORGAN"

rc_key$namelast[rc_key$name == "Anthony R. De Maio" & rc_key$year == 2006 & rc_key$office == "H"] <- "DE MAIO"

rc_key$namelast[rc_key$name == "Dana Rohrbacher" & rc_key$year == 2008 & rc_key$office == "H"] <- "ROHRABACHER"

rc_key$namelast[rc_key$name == "Doug La Malfa" & rc_key$year == 2012 & rc_key$office == "H"] <- "LA MALFA"

rc_key$namelast[rc_key$name == "Doug la Malfa" & rc_key$year == 2014 & rc_key$office == "H"] <- "LA MALFA"

rc_key$namelast[rc_key$name == "Pete Aguillar" & rc_key$year == 2014 & rc_key$office == "H"] <- "AGUILAR"

rc_key$namelast[rc_key$name == "Tue Phan-Quang" & rc_key$year == 2014 & rc_key$office == "H"] <- "PHAN"

rc_key$namelast[rc_key$name == "Maxine Walters" & rc_key$year == 2014 & rc_key$office == "H"] <- "WATERS"

rc_key$namelast[rc_key$name == "Grace Napokitano" & rc_key$year == 2014 & rc_key$office == "H"] <- "NAPOLITANO"

rc_key$namelast[rc_key$name == "Jaques Rene Gailot, Jr" & rc_key$year == 2012 & rc_key$office == "H"] <- "GAILLOT"

rc_key$namelast[rc_key$name == "Ileana Ros-Lehitinen" & rc_key$year == 2012 & rc_key$office == "H"] <- "ROS-LEHTINEN"

rc_key$namelast[rc_key$name == "Debbie Wasserman-Schultz" & rc_key$year == 2014 & rc_key$office == "H"] <- "SCHULTZ"

rc_key$namelast[rc_key$name == "Patrick Pilion" & rc_key$year == 2006 & rc_key$office == "H"] <- "PILLION"

rc_key$namelast[rc_key$name == "Mike Quigly" & rc_key$year == 2012 & rc_key$office == "H"] <- "QUIGLEY"

rc_key$namelast[rc_key$name == "Eric Thorsand" & rc_key$year == 2014 & rc_key$office == "H"] <- "THORSLAND"

rc_key$namelast[rc_key$name == "Robert J.Dold" & rc_key$year == 2014 & rc_key$office == "H"] <- "DOLD"

rc_key$namelast[rc_key$name == "Jackie Walorski Swihart" & rc_key$year == 2010 & rc_key$office == "H"] <- "WALORSKI"

rc_key$namelast[rc_key$name == "Brad Lookout" & rc_key$year == 2012 & rc_key$office == "H"] <- "BOOKOUT"

rc_key$namelast[rc_key$name == "Rob Lewis Hunter" & rc_key$year == 2008 & rc_key$office == "H"] <- "HUBLER"

rc_key$namelast[rc_key$name == "John Yarmouth" & rc_key$year == 2012 & rc_key$office == "H"] <- "YARMUTH"

rc_key$namelast[rc_key$name == "John LeFerla" & rc_key$year == 2012 & rc_key$office == "H"] <- "LAFERLA"

rc_key$namelast[rc_key$name == "John W. Oliver" & rc_key$year == 2006 & rc_key$office == "H"] <- "OLVER"

rc_key$namelast[rc_key$name == "John Conyers, Jr" & rc_key$year == 2012 & rc_key$office == "H"] <- "CONYERS"

rc_key$namelast[rc_key$name == "Erin Bilbray-Kohn" & rc_key$year == 2014 & rc_key$office == "H"] <- "BILBRAY"

rc_key$namelast[rc_key$name == "Annie Custer" & rc_key$year == 2016 & rc_key$office == "H"] <- "KUSTER"

rc_key$namelast[rc_key$name == "Michelle Lujan Grasham" & rc_key$year == 2012 & rc_key$office == "H"] <- "GRISHAM"

rc_key$namelast[rc_key$name == "Harold W. \"Budd\" Shroeder" & rc_key$year == 2008 & rc_key$office == "H"] <- "SCHROEDER"

rc_key$namelast[rc_key$name == "Frank Dellavalle" & rc_key$year == 2010 & rc_key$office == "H"] <- "DELLA VALLE"

rc_key$namelast[rc_key$name == "Carolyn McCarty" & rc_key$year == 2012 & rc_key$office == "H"] <- "MCCARTHY"

rc_key$namelast[rc_key$name == "Christopher Wright" & rc_key$year == 2012 & rc_key$office == "H"] <- "WIGHT"

rc_key$namelast[rc_key$name == "Martha Robinson" & rc_key$year == 2014 & rc_key$office == "H"] <- "ROBERTSON"

rc_key$namelast[rc_key$name == "Charles A. \"Charlie\" Wilson (Write In)" & rc_key$year == 2006 & rc_key$office == "H"] <- "WILSON"

rc_key$namelast[rc_key$name == "Sharon Swartz Neuhart" & rc_key$year == 2012] <- "NEUHARDT"

rc_key$namelast[rc_key$name == "Jim Conidt Jr." & rc_key$year == 2014 & rc_key$office == "H"] <- "CONDIT"

rc_key$namelast[rc_key$name == "David W.Walker" & rc_key$year == 2016 & rc_key$office == "H"] <- "WALKER"

rc_key$namelast[rc_key$name == "Donald L. Hillard" & rc_key$year == 2006 & rc_key$office == "H"] <- "HILLIARD"

rc_key$namelast[rc_key$name == "George Flinn, Jr" & rc_key$year == 2012 & rc_key$office == "H"] <- "FLINN"

rc_key$namelast[rc_key$name == "John J. Duncan, Jr" & rc_key$year == 2012 & rc_key$office == "H"] <- "DUNCAN"

rc_key$namelast[rc_key$name == "Shelley Sekula-Gibbs" & rc_key$year == 2006 & rc_key$office == "H"] <- "GIBBS"

rc_key$namelast[rc_key$name == "Rick BolaÃ±os" & rc_key$year == 2006 & rc_key$office == "H"] <- "BOLANOS"

rc_key$namelast[rc_key$name == "Charles A. Gonzales" & rc_key$year == 2008 & rc_key$office == "H"] <- "GONZALEZ"

rc_key$namelast[rc_key$name == "Sheila Jackson-Lee" & rc_key$year == 2006 & rc_key$office == "H"] <- "LEE"

rc_key$namelast[rc_key$name == "Sheila Jackson-Lee" & rc_key$year == 2012 & rc_key$office == "H"] <- "LEE"

rc_key$namelast[rc_key$name == "Jeb Hansarling" & rc_key$year == 2012 & rc_key$office == "H"] <- "HENSARLING"

rc_key$namelast[rc_key$name == "Ruben Hinjosa" & rc_key$year == 2012 & rc_key$office == "H"] <- "HINOJOSA"

rc_key$namelast[rc_key$name == "Blake Farenhold" & rc_key$year == 2012 & rc_key$office == "H"] <- "FARENTHOLD"

rc_key$namelast[rc_key$name == "Rob Biship" & rc_key$year == 2012 & rc_key$office == "H"] <- "BISHOP"

rc_key$namelast[rc_key$name == "Cathy McMorris Rogers" & rc_key$year == 2012 & rc_key$office == "H"] <- "RODGERS"

rc_key$namelast[rc_key$name == "Rick Larson" & rc_key$year == 2014 & rc_key$office == "H"] <- "LARSEN"

rc_key$namelast[rc_key$name == "Bob Dingethgal" & rc_key$year == 2014 & rc_key$office == "H"] <- "DINGETHAL"

rc_key$namelast[rc_key$name == "Rick Larson" & rc_key$year == 2016 & rc_key$office == "H"] <- "LARSEN"

rc_key$namelast[grepl("Dusty", rc_key$name)] <- "JOHNSON"

# These are for senate and governor
rc_key$namelast[rc_key$name == "Allen W. McColluch" & rc_key$year == 2006 & rc_key$office == "S"] <- "MCCULLOCH"

rc_key$namelast[rc_key$name == "Bob Corcker" & rc_key$year == 2012 & rc_key$office == "S"] <- "CORKER"

rc_key$namelast[rc_key$name == "Vincent Sheeheen" & rc_key$year == 2014 & rc_key$office == "G"] <- "SHEHEEN"

# Remove special elections
# this is marked as special but i think its actually the general
jim_data$type[jim_data$year == 2006 & jim_data$office == "H" & jim_data$st == "TX" & jim_data$dist_up == 22] <- "G"

# This is a special senate election that occured on the normal election day
jim_data$type[jim_data$year == 2008 & jim_data$office == "S" & jim_data$st == "MS"] <- "G"

# This is a special senate election that occured on the normal election day
jim_data$type[jim_data$year == 2010 & jim_data$office == "S" & jim_data$st == "WV"] <- "G"

# This is a special senate election that occured on the normal election day
jim_data$type[jim_data$year == 2014 & jim_data$office == "S" & jim_data$st == "HI"] <- "G"

# This is a special senate election that occured on the normal election day
jim_data$type[jim_data$year == 2010 & jim_data$office == "G" & jim_data$st == "UT"] <- "G"

jim_data <- jim_data[jim_data$type != "P" & jim_data$type != "S", ]

rc_key$namelast[rc_key$name == "Mike Ross" & rc_key$year == 2006 & rc_key$st == "AR" & rc_key$dist_up == 4 & rc_key$office == "H"] <- "M.ROSS"
rc_key$namelast[rc_key$name == "Joe Ross" & rc_key$year == 2006 & rc_key$st == "AR" & rc_key$dist_up == 4 & rc_key$office == "H"] <- "J.ROSS"

rc_key$namelast[rc_key$name == "Fred Johnson" & rc_key$year == 2008 & rc_key$st == "MI" & rc_key$dist_up == 2 & rc_key$office == "H"] <- "F.JOHNSON"
rc_key$namelast[rc_key$name == "Dan Johnson" & rc_key$year == 2008 & rc_key$st == "MI" & rc_key$dist_up == 2 & rc_key$office == "H"] <- "D.JOHNSON"

# These candidates are not included in the cces
rc_key$namelast[rc_key$name == "Coby Williams" & rc_key$year == 2012 & rc_key$st == "MS" & rc_key$dist_up == 2 & rc_key$office == "H"] <- "C.WILLIAMS"
rc_key$namelast[rc_key$name == "Lajena Williams" & rc_key$year == 2012 & rc_key$st == "MS" & rc_key$dist_up == 2 & rc_key$office == "H"] <- "L.WILLIAMS"

# These candidates are not included in the cces
rc_key$namelast[rc_key$name == "Bill Collins" & rc_key$year == 2010 & rc_key$st == "TX" & rc_key$dist_up == 16 & rc_key$office == "H"] <- "W.COLLINS"
rc_key$namelast[rc_key$name == "Tim Collins" & rc_key$year == 2010 & rc_key$st == "TX" & rc_key$dist_up == 16 & rc_key$office == "H"] <- "T.COLLINS"

rc_key$namelast[rc_key$name == "Adam Smith" & rc_key$year == 2018 & rc_key$st == "WA" & rc_key$dist_up == 9 & rc_key$office == "H"] <- "A.SMITH"
rc_key$namelast[rc_key$name == "Sarah Smith" & rc_key$year == 2018 & rc_key$st == "WA" & rc_key$dist_up == 9 & rc_key$office == "H"] <- "S.SMITH"

# Doug smith is not in the cces data
rc_key$namelast[rc_key$name == "Tom Smith" & rc_key$year == 2012 & rc_key$st == "PA" & rc_key$office == "S"] <- "T.SMITH"

# Julian hatch is not in the cces data
rc_key$namelast[rc_key$name == "Orrin G. Hatch" & rc_key$year == 2006 & rc_key$st == "UT" & rc_key$office == "S"] <- "O.HATCH"

# Robert burke is not in the cces data
rc_key$namelast[rc_key$name == "Mary Burke" & rc_key$year == 2014 & rc_key$st == "WI" & rc_key$office == "G"] <- "M.BURKE"



########################################
# Merge the two datasets together     #
########################################


# Actually merge the cces data and election results
fulldata <- left_join(rc_key, jim_data, by = c("st", "dist_up", "namelast", "office", "year"))

stopifnot(nrow(fulldata) == nrow(rc_key)) # there should be no new rows created

######################################################################
# Load in the Dataset of Explanations for Non-Merging Candidates     #
######################################################################

# House 2006 to 2016
problem_cands_house <- read.csv("~/Dropbox/CCES_candidates/Input/NonMergingCandidates_2006to2017.csv")
problem_cands_house$office <- "H"
problem_cands_house$votes_ifmissing <- as.character(problem_cands_house$votes_ifmissing)

# House 2018
problem_cands2018 <- read.csv("~/Dropbox/CCES_candidates/Input/NonMergingCandidates_2018.csv")
problem_cands2018$office <- "H"
problem_cands2018 <- problem_cands2018[, -1]
problem_cands2018$votes_ifmissing <- as.character(problem_cands2018$votes_ifmissing)

# Senate
problem_cands_senate <- read.csv("~/Dropbox/CCES_candidates/Input/NonMergingCandidates_senate2006to2017.csv")
problem_cands_senate$office <- "S"
problem_cands_senate$votes_ifmissing <- as.character(problem_cands_senate$votes_ifmissing)

# Governor
problem_cands_gov <- read.csv("~/Dropbox/CCES_candidates/Input/NonMergingCandidates_governor2006to2017.csv")
problem_cands_gov$office <- "G"
problem_cands_gov$votes_ifmissing <- as.character(problem_cands_gov$votes_ifmissing)

# Combine
problem_cands_total <- bind_rows(problem_cands_house, problem_cands2018, problem_cands_senate, problem_cands_gov)

# Make missing votes numeric
problem_cands_total$votes_ifmissing <- as.numeric(gsub(",", "", problem_cands_total$votes_ifmissing))

# Only keep errors that are not spelling mistakes or issues with two last names, as I fixed these above
problem_cands_total$TwoLastNamesError[is.na(problem_cands_total$TwoLastNamesError)] <- 0
problem_cands_total <- problem_cands_total[problem_cands_total$SpellingMistake == 0 & problem_cands_total$TwoLastNamesError == 0, ]

# Limit the data to vaiables we need
problem_cands_total <- problem_cands_total |>
  select(year, st, dist_up, cong, cong_up, office, namelast, Reason.for.Not.Merging, NotonGeneralBallot, votes_ifmissing, inc_ifmissing, Notes)
problem_cands_total$dist_up[problem_cands_total$office == "S" | problem_cands_total$office == "G"] <- NA

######################################################################
# Merge in the Reasons for Issues to the Final Dataset    #
######################################################################

fulldata2 <- left_join(fulldata, problem_cands_total, by = c("st", "office", "dist_up", "namelast", "year", "cong", "cong_up"))

# Limit the data to vaiables we need
fulldata2 <- fulldata2 |>
  select(case_id, year, dataset, st, dist, dist_up, cong, cong_up, cand, 
         name.y, name_cces, namelast, party.y, 
         inc, 
         party_short,
         vote_g, totalvotes, w_g, office, Reason.for.Not.Merging, 
         NotonGeneralBallot, votes_ifmissing, inc_ifmissing, Notes,
         house_dist, house_distup)


# Rename some variables
fulldata2 <- fulldata2 |>
  rename(
    name = name.y,
    party = party.y,
    issue = Reason.for.Not.Merging,
    not_on_general = NotonGeneralBallot,
  ) |>
  mutate(
    inc = replace(inc, inc_ifmissing == 1, 1),
    inc = replace(inc, inc_ifmissing == 0, 0),
    office = replace(office, is.na(office), "H"),
  ) |>
  as_tibble()

# Make a column explaining the issues with non-merging candidates
fulldata2$data_note <- NA

fulldata2 <- fulldata2 |>
  mutate(
    data_note = replace(data_note, issue == "Candidate ran in Minnesota, Not Massachusettes", "Incorrect Candidate Match"),
    data_note = replace(data_note, issue == "candidate withdrew from the race after the primary", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "did not appear on the ballot", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "did not get enough votes to make it to the general election", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "did not file for the general election", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "did not run in this election", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "did not submit enough signatures to get on the ballot", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "disqualified before primary", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "dropped out of the race prior to the general", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "failed to file for the primary", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "in oklahoma unopposed candidates do not appear on the ballot", "Unopposed in Oklahoma"),
    data_note = replace(data_note, issue == "missing from Jim data", "Candidate Missing from Election Data"),
    data_note = replace(data_note, Notes == "This is the general election vote. Did not appear in the runoff!!!", "Candidate Missing from Election Data. Note that this candidate was not in the final runoff election."),
    data_note = replace(data_note, issue == "not on the ballot", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "online write-in campaign, did not appear on the ballot", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "ran as a write-in candidate", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "ran for state senator not house", "Incorrect Candidate Match"),
    data_note = replace(data_note, issue == "ran in district 3", "Incorrect Candidate Match"),
    data_note = replace(data_note, issue == "ran in district 4", "Incorrect Candidate Match"),
    data_note = replace(data_note, issue == "was candidate in district 16, not 11", "Incorrect Candidate Match"),
    data_note = replace(data_note, issue == "was disqualified proir to the election", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "withdrew after the primary", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "withdrew from the race", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "withdrew from the race, was still on ballot but replaced with Joe Negron", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "withdrew prior to the primary", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "died before the general election", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "withdrew before the general", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "withdrew before the primary", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "does not appear to be on the ballot", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "disqualified before the general election", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "ran as liutenant governor", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "did not make it to the runoff", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "dropped out of the race", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "not on general election ballot", "Not on General Election Ballot"),
    data_note = replace(data_note, issue == "not on the general election ballot", "Not on General Election Ballot")
  ) |>
  as_tibble()


# Fix some additional people who did not merge
fulldata2$data_note[fulldata2$name_cces == "Chad \"Chig\" Martin" & fulldata2$year == 2018] <- "Not on General Election Ballot"
fulldata2$data_note[fulldata2$name_cces == "Bob Walsh" & fulldata2$year == 2018] <- "Not on General Election Ballot"


fulldata2$data_note[fulldata2$st == "IN" & fulldata2$dist_up == 1 & fulldata2$year == 2014 & fulldata2$name_cces == "Josh Dill"] <- "Incorrect Candidate Match"
fulldata2$data_note[fulldata2$st == "FL" & fulldata2$dist_up == 19 & fulldata2$year == 2014 & fulldata2$name_cces == "Timothy Rossano"] <- "Not on General Election Ballot"
fulldata2$data_note[fulldata2$name_cces == "David Lashar" & fulldata2$year == 2018] <- ""

fulldata2$data_note[fulldata2$st == "DC"] <- "Candidate Missing from Election Data"

fulldata2$inc[fulldata2$data_note == "Candidate Missing from Election Data" & is.na(fulldata2$inc) & fulldata2$st != "DC"] <- 0
fulldata2$inc[fulldata2$data_note == "Candidate Missing from Election Data" & fulldata2$st == "DC" & fulldata2$name_cces != "Eleanor Holmes Norton"] <- 0
fulldata2$inc[fulldata2$data_note == "Candidate Missing from Election Data" & fulldata2$st == "DC" & fulldata2$name_cces == "Eleanor Holmes Norton"] <- 1


# Limit the data to variables we need
fulldata2 <- fulldata2 |>
  select(case_id, year, dataset, st, dist, dist_up, cand, name, name_cces, namelast, 
         party, party_short, inc, vote_g, totalvotes, w_g, office, data_note, house_dist, house_distup)

# Re-mark special senate elections as special
# jim_data$type[jim_data$year == 2008 & jim_data$office == "S" & jim_data$st == "MS" & jim_data$name == "MUSGROVE, RONNIE"] <- "S"
# jim_data$type[jim_data$year == 2008 & jim_data$office == "S" & jim_data$st == "MS" & jim_data$name == "WICKER, ROGER F."] <- "S"
# jim_data$type[jim_data$year == 2010 & jim_data$office == "S" & jim_data$st == "WV"] <- "S"
# jim_data$type[jim_data$year == 2014 & jim_data$office == "S" & jim_data$st == "HI"] <- "S"
# jim_data$type[jim_data$year == 2010 & jim_data$office == "G" & jim_data$st == "UT"] <- "S"

# Reorder some variables
fulldata2 <- fulldata2 |>
  relocate(year, dataset, case_id, st, dist, dist_up, office) |>
  rename(votes = vote_g,
         name_snyder = name)

fulldata3 <- select(fulldata2,  -name_cces)

fulldata3 <- fulldata3  |>
  distinct_at(vars(-dataset), .keep_all = TRUE)


# Remove variables we do not need -----

# Separate into pre and post -------
data_pre   <- filter(fulldata3, !str_detect(dataset, "_post"))
data_post1 <- filter(fulldata3, str_detect(dataset, "_post"))

# For the post dataset I need to add everyone back in who had the values as in the pre dataset, as before I was dropping duplicates.

# This keeps people that switched from pre to post
data_post2 <- semi_join(data_post1, data_pre, by = c("case_id", "year", "office", "cand"))

# This keeps people that had the same as pre and post (or were just in pre, need to account for this later)
data_post3 <- anti_join(data_pre, data_post1, by = c("case_id", "year", "office", "cand"))

# This keeps people only in post
data_post4 <- anti_join(data_post1, data_pre, by = c("case_id", "year", "office", "cand"))

# Combine them to get a full post dataset
data_post <- bind_rows(data_post2, data_post3, data_post4)
  


#####################################################
######## Make an incumbent variable to merge ########
#####################################################

# Load in data from Jim that goes farther back than 2006 so we can make a lagged district variable
elections <- haven::read_dta("~/Dropbox/CCES_candidates/Input/js_us_house_1980_2016.dta")

# Load in the 2018 data
elections2018 <- jim_data |> filter(year == 2018) |> rename(state=st, dist=dist_up)

# Bind the two and only keep the House
elections_total <- bind_rows(elections, elections2018)
elections_total <- filter(elections_total, office == "H")

# Fix some errors in the 2018 code
elections_total$name[elections_total$name=="PETERS, SCOTT"] <- "PETERS, SCOTT H."
elections_total$name[elections_total$name=="KELLY, MIKE"] <- "KELLY, GEORGE J. (MIKE), JR."
elections_total$name[elections_total$name=="RICE, TOM"] <- "RICE, HUGH THOMPSON (TOM), JR."
elections_total$name[elections_total$name=="RUTHERFORD, JOHN"] <- "RUTHERFORD, JOHN H."
elections_total$name[elections_total$name=="MARSHALL, ROGER"] <- "MARSHALL, ROGER W."
elections_total$name[elections_total$name=="WALKER, MARK"] <- "WALKER, BRADLEY MARK"
elections_total$name[elections_total$name=="SCOTT, AUSTIN"] <- "SCOTT, JAMES AUSTIN"
elections_total$name[elections_total$name=="PALMER, GARY"] <- "PALMER, GARY J."
elections_total$name[elections_total$name=="CARBAJAL, SALUD"] <- "CARBAJAL, SALUD O."
elections_total$name[elections_total$name=="LEE, SHEILA JACKSON"] <- "JACKSON LEE, SHEILA"
elections_total$name[elections_total$name=="BEUTLER, JAIME HERRERA"] <- "HERRERA BEUTLER, JAIME"
elections_total$name[elections_total$name=="MOONEY, ALEXANDER X. (ALEX)"] <- "MOONEY, ALEX X."
elections_total$name[elections_total$name=="ROCHESTER, LISA BLUNT"] <- "BLUNT ROCHESTER, LISA"
elections_total$name[elections_total$name=="HILL, FRENCH"] <- "HILL, J. FRENCH"
elections_total$name[elections_total$name=="GOTTHEIMER, JOSHUA S."] <- "GOTTHEIMER, JOSHUA S. (JOSH)"
elections_total$name[elections_total$name=="CORREA, LOU (LOIS)"] <- "CORREA, JOSE LUIS (LOU)"
elections_total$name[elections_total$name=="KENNEDY, JOSEPH P., III"] <- "KENNEDY, JOSEPH P. (JOE), III"
elections_total$name[elections_total$name=="MOOLENAAR, JOHN"] <- "MOOLENAAR, JOHN R."
elections_total$name[elections_total$name=="WEBER, RANDY K., SR."] <- "WEBER, RANDY"
elections_total$name[elections_total$name=="THOMPSON, MIKE"] <- "THOMPSON, C. MICHAEL (MIKE)"


# Rename some variables and only keep one row per candidate
elections_total <- elections_total  |>
  distinct(name, year,.keep_all = TRUE)  |>
  rename(name_snyder = name) |>
  arrange(name_snyder, year)

# Generate a lagged district varaible. Need to do it this more complicated way so we only keep consecutive terms
elections_total <- elections_total |>
  group_by(name_snyder, group = cumsum(c(TRUE, diff(year) != 2))) |>
  mutate(lag_dist = lag(dist)) |>
  select(-group)

# The elections data doesn't have special elections so need to fill these in ourselves. 

elections_total$lag_dist[!is.na(elections_total$inc) & elections_total$inc == 2] <- elections_total$dist[elections_total$inc == 2 & !is.na(elections_total$inc) ]
elections_total$lag_dist[elections_total$name_snyder == "HOCHUL, KATHLEEN COURTNEY (KATHY)" & elections_total$year == 2012] <- 26
elections_total$lag_dist[elections_total$name_snyder == "LAMB, CONOR JAMES" & elections_total$year == 2018] <- 18

elections_total$lag_dist[elections_total$name_snyder == "LATTA, ROBERT EDWARD (BOB)" & elections_total$year == 2008] <- 5
elections_total$lag_dist[elections_total$name_snyder == "LAMPSON, NICHOLAS V. (NICK)" & elections_total$year == 2008] <- 22
elections_total$lag_dist[elections_total$name_snyder == "BROUN, PAUL COLLINS" & elections_total$year == 2008] <- 10


# Only keep incumbents and 2006 on
elections_total <- elections_total |> 
  filter(inc > 0, year > 2004) |> 
  select(name_snyder, year, lag_dist, office)


# Merge with the pre dataset
total_pre <- left_join(data_pre, elections_total, by = c("name_snyder", "year", "office"))

# Generate the variable of interest
total_pre$current_inc[total_pre$office=="H" & total_pre$inc>0] <-0
total_pre$current_inc[total_pre$lag_dist==total_pre$dist] <- 1

# Merge with the post dataset
total_post <- left_join(data_post, elections_total, by = c("name_snyder", "year", "office"))

# Generate the variable of interest
total_post$current_inc[total_post$office=="H" & total_post$inc>0] <-0
total_post$current_inc[total_post$lag_dist==total_post$dist] <- 1

#replace missing district values for senate and governor, need to do the post version later
total_pre$dist[!is.na(total_pre$house_dist)] <- total_pre$house_dist[!is.na(total_pre$house_dist)]
total_pre$dist_up[!is.na(total_pre$house_distup)] <- total_pre$house_distup[!is.na(total_pre$house_distup)]


# Limit the data to variables we need -----
rmv_vars <- c("group", "lag_dist", "namelast", "house_dist", "house_distup")
order_vars <- c("year", "dataset", "case_id", "st", "dist", "dist_up", "office", "cand", "name_snyder", "inc", "current_inc")

final_pre <- total_pre |>
  select(-c(!!!rmv_vars)) |>
  rename(party_formal = party,
         party = party_short,
         candidatevotes = votes,
         won   =  w_g) |> 
  relocate(!!!order_vars)

final_post <- total_post |>
  select(-c(!!!rmv_vars)) |>
  rename(party_formal = party,
         party = party_short,
         candidatevotes = votes,
         won   =  w_g) |> 
  relocate(!!!order_vars)


# Now we account for getting rid of people in the post dataset who were only in pre. 
# To do so I need to reload in the original data
load("~/Dropbox/cces_cumulative/data/output/01_responses/candidates_key.RData")
rc_key$office <- "H"
sc_key$office <- "S"
gc_key$office <- "G"
rc_key <- bind_rows(rc_key, sc_key, gc_key)

rc_key <- rc_key |>
  rename(house_dist = dist,
         house_distup = dist_up)  |> 
  select(case_id, year, dataset, office, cand, house_dist, house_distup) |> 
  filter(str_detect(dataset, "_post")) 

final_post <- inner_join(final_post, rc_key, by = c("case_id", "year", "cand", "office"))

final_post$dist[!is.na(final_post$house_dist)] <- final_post$house_dist[!is.na(final_post$house_dist)]
final_post$dist_up[!is.na(final_post$house_distup)] <- final_post$house_distup[!is.na(final_post$house_distup)]


final_post <- final_post |>
  select(-dataset.x, -house_dist, -house_distup, -st, -dist)|>
  rename(dataset = dataset.y)|>
  relocate(year, dataset)

final_pre <- final_pre |>
  select(-st, -dist)

final_pre$current_inc[final_pre$office=="G" & final_pre$inc>0] <- 1
final_pre$current_inc[final_pre$office=="S" & final_pre$inc>0] <- 1
final_post$current_inc[final_post$office=="G" & final_post$inc>0] <- 1
final_post$current_inc[final_post$office=="S" & final_post$inc>0] <- 1

# Save the data
write_dta(final_pre, "~/Dropbox/CCES_candidates/Output/RespondentLevel_Pre.dta")
write_dta(final_post, "~/Dropbox/CCES_candidates/Output/RespondentLevel_Post.dta")




