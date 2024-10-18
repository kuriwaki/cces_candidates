library(tidyverse)
library(haven)
library(glue)

orig_clerk <- read_dta("data/snyder/2024-01-28 congressional_elections_clerk_2022.dta")

states_key <- tibble(state = str_to_upper(state.name),
                     st = state.abb)

#' Function
#'
fmt_name0 <- function(name) {

  suffix <- str_extract(name, ", (Jr\\.|Sr\\.|II|III|IV)$")
  suffix_fmt <- map_chr(suffix, \(x) ifelse(is.na(x), "", str_c(", {x}")))

  name_nosuffix <- str_squish(str_remove(name, ", (Jr\\.|Sr\\.|II|III|IV)$"))

  last <- word(name_nosuffix, -1, -1)
  first_m <- word(name_nosuffix, 1, -2)

  as.character(glue("{last}, {first_m}{suffix_fmt}"))
}

# Original formatting
fmt_clerk <- orig_clerk |>
  left_join(states_key) |>
  select(-state) |>
  rename(state = st) |>
  mutate(year = 2022, type = "G", .before = 1) |>
  mutate(party_formal = recode(
    party,
    Republican = "R",
    Democrat = "D",
    Green = "Grn",
    Libertarian = "Lbt",
    Independent = "I"),
    party = recode(
      party_formal,
      R = "R",  D = "D", Grn = "Grn", Lbt = "Lbt",
      .default = "Other"
    )) |>
  tidylog::filter(!name %in%
                    c("Write-in", "Blank", "Miscellaneous",
                      "Blank Votes", "Void", "Scattering")) |>
  # names
  mutate(
    name_snyder = str_to_upper(fmt_name0(name))
  ) |>
  relocate(year, state, office, dist, type,
           party, party_formal,
           name_snyder,
           candidatevotes = votes_g)
fmt_clerk |> sample_n(10)


# Write
write_dta(fmt_clerk, "data/snyder/2024-01-28 fmt congressional_elections_clerk_2022.dta")

