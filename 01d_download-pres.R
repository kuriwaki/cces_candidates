library(dataverse)
library(tidyverse)
library(tidylog)

# Dataverse
pres_raw <- get_dataframe_by_name(file = "1976-2020-president.tab",
                                  dataset = "10.7910/DVN/42MVDX",
                                  original = TRUE,
                                  server = "dataverse.harvard.edu",
                                  .f = read_csv)

# Recode party, variable names, etc..
pres_fmt <- pres_raw %>%
  filter(year >= 2006) %>%
  transmute(
    year,
    state = state_po,
    candidate,
    writein,
    party = recode(party_simplified, REPUBLICAN = "R", DEMOCRAT = "D", LIBERTARIAN = "Lbt", GREEN = "Grn", OTHER = "Other"),
    party_formal = recode(str_to_title(party_detailed), Republican = "R", Democrat = "D", Libertarian = "Lbt", Green = "Grn"),
    candidatevotes
  ) %>%
  mutate(
    party = replace(party, (writein), "W-I"),
    name = recode(
      candidate,
      `OBAMA, BARACK H.` = "OBAMA, BARACK",
      `CLINTON HILLARY` = "CLINTON, HILLARY RODHAM",
      `BIDEN, JOSEPH R. JR` = "BIDEN, JOSEPH R., JR.",
      `MCCAIN, JOHN` = "MCCAIN, JOHN S.",
      `PAUL, RONALD \"\"RON\"\"` = "PAUL, RONALD E. (RON)",
      ),
    name = str_replace(name, "\"{1,}$", ")"),
    name = str_replace(name, "\\s\"{1,}", " ("),
    inc = case_when(
      str_detect(name, "OBAMA") & year == 2012 ~ 1,
      str_detect(name, "TRUMP") & year == 2020 ~ 1,
      TRUE ~ 0
    )
  ) %>%
  select(-writein, -candidate) %>%
  relocate(year, state,
           party, party_formal,
           name,
           inc,
           candidatevotes)


# drop
# - candidates with less than 10 votes
# - blank votes, overvotes, scatterings, etc..
pres_sel <- pres_fmt %>%
  filter(candidatevotes >= 10) %>%
  filter(!is.na(party_formal))



# write to intermediate
write_csv(pres_sel, "data/intermediate/2008-2020_pres.csv")
