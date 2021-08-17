library(tidyverse)
library(haven)


# Loading in Snyder candidates data ---------------------------------------


cand20 <- read_dta("data/intermediate/2020_uspresident-congress_JC-SK.dta")

cand20 <- cand20 %>%  # Creating last name variable
  rename(dist_up = dist, # Standardizing district and state abb variables
         st = state) %>%
  mutate(namelast = gsub(",.*$", "", name),
         namelast = word(namelast, -1),
         namelast = trimws(namelast),
         party_short = recode(party, # Jaclyn Kavolsky Party Recodes
                              Indep = "I",
                              IDP = "I",
                              L = "Lbt",
                              Refomr = "Rfm",
                              DFL = "D",
                              "D,WF" = "D",
                              "D,Wk Fam" = "D",
                              "D, I, Wk Fam, Women's Equality" = "D",
                              "D, Reform, Wk Fam" = "D",
                              "D, Reform, Wk Fam, Women's Equality" = "D",
                              "D, Wk Fam" = "D",
                              "D, Wk Fam, Women's Equality" = "D",
                              "D, Women's Equality" = "D",
                              "D,C,Indep,WF" = "D",
                              "D,I,WF" = "D",
                              "D,IDP,WF" = "D",
                              "D,Indep,WF" = "D",
                              "D,R" = "D",
                              "D,WF" = "D",
                              "D,WF,IDP" = "D",
                              "D,WF,Indep" = "D",
                              "D,Wk Fam" = "D",
                              "D, I, Reform, Wk Fam, Women's Equality" = "D",
                              "R, Reform" = "R",
                              "R,C" = "R",
                              "R,C,I" = "R",
                              "R,C,Indep" = "R",
                              "R,C,Lbt" = "R",
                              "R,C,SCC" = "R",
                              "R,C,Taxp" = "R",
                              "R,CR" = "R",
                              "R,CRV" = "R",
                              "R,CRV,IDP" = "R",
                              "R,I" = "R",
                              "R,IDP" = "R",
                              "R,Indep" = "R",
                              "R,Lbt" = "R",
                              "R,Tax" = "R",
                              "R,Tax,C,Indep" = "R",
                              "R,Taxp" = "R",
                              "I, R" = "R",
                              "Conservative, R" = "R",
                              "Conservative, R, Reform" = "R",
                              "Conservative, I, R" = "R",
                              "Conservative, I, R, Reform" = "R",
                              "Conservative, I, R, Reform, Tax Revolt" = "R",

                              #Jaclyn's add ons
                              "Indep Pty" = "I",
                              "Indep P" = "I",
                              "independent" = "I",
                              "Indp" = "I"),
         dist_up = case_when( # Standardizing at-large dist coding
           dist_up == 0 ~ 1,
           TRUE ~ dist_up
         ))

h_cand20 <- cand20 %>% # Creating a House subset
  filter(office == "H")

# Loading in RC Key data --------------------------------------------------


load("data/candidates_key.RData")

rc_key_2020 <- rc_key %>%
  filter(dataset == "2020",
         !is.na(name))


# Merging Candidate Key and Candidates data
df <- left_join(rc_key_2020,
                h_cand20,
                by = c("st", "dist_up", "namelast", "year"))

# Isolating unique merge conflicts
check <- anti_join(rc_key_2020,
                   h_cand20,
                   by = c("st", "dist_up", "namelast", "year"))

uq_check <- check %>%
  distinct(name,
           .keep_all = TRUE)
