library(tidyverse)
library(haven)
library(fs)

#' function to add labels
paste_labels <- function(tbl, lab_df = var_labels) {
  stopifnot(all(!duplicated(var_labels$alias)))
  stopifnot(all(!duplicated(var_labels$label)))

  for (c in colnames(tbl)) {
    attr(tbl[[c]], "label") <- lab_df$label[which(lab_df$alias == c)]
  }
  tbl
}


# In dta files -----
# [X] make sure variable names are consistent across datasets
# [X] add user-friendly labels for each variable (`attr(data$w_g, "label") <- "won general" etc..`)
# [ ] use the simplest filenames

# Read from Output -----
output_dir <- "data/intermediate/"
cand_raw <- read_dta(path(output_dir, "CandidateLevel_Candidates.dta"))

warning("Did we change the values of name_snyder when merging? I don't see any, so if not, that's ok.
     But if so we should try to make the values consistent across the candidate and respondent dataset")


# remove variables from candidate -----
rmv_candvars <- c("namelast")
order_candvars <- c("year", "st", "office", "dist_up", "party", "party_formal",
                    "name_snyder", "inc", "candidatevotes", "won", "totalvotes")

cand <- cand_raw %>%
  select(-c(!!!rmv_candvars)) %>%
  rename(party_formal = party,
         party = party_short,
         candidatevotes = vote_g,
         name_snyder = name,
         won = w_g) %>%
  relocate(!!!order_candvars)

# what are the columns -----
unique(c(colnames(pre), colnames(post), colnames(cand)))


# Define labels
var_labels <- tribble(
  ~alias, ~label,
  "year",  "Year of the general election or CCES",
  "dataset", "CCES dataset. Common Content, unless suffix added",
  "case_id", "Case identifier (to be matched with CCES)",
  "st",     "State two-letter abbreviation",
  "office", "Office (H = House, S = Senate, G = Governor)",
  "dist", "Congressional district number, current",
  "dist_up", "Congressional district number in election (for House candidates)",
  "cand", "Candidate number as coded in CCES dataset",
  "party", "Candidate party affiliation (short)",
  "party_formal", "Candidate party affiliation (formal)",
  "name_snyder", "Candidate name",
  "inc", "Candidate is incumbent",
  "current_inc", "Candidate is incumbent of the current district",
  "candidatevotes", "Votes for the candidate",
  "totalvotes", "Total votes cast in the race",
  "won", "Whether the candidate won the general election",
  "data_note", "Documentation for irregular candidates",
  "type", "Type of election. (G = general, S = special)"
)



# add labels ------
cand_fmt <- paste_labels(cand)



# Save to Release ------
release_dir <- "release"

# Clear
file_delete(dir_ls(release_dir))

