source("07_xtabs-functions.R")



rdat      <- read_dta("release/RespondentLevel_Pre.dta")
rdat_post <- read_dta("release/RespondentLevel_Post.dta")


count_rdat(rdat, "counts_pre")
count_rdat(rdat_post, "counts_post")



# Example data ----
rdat %>%
  filter(case_id == 304099877) %>%
  select(year, case_id, st, dist, office, totalvotes, cand, name_snyder, party, inc, votes) %>%
  mutate(across(c(year, case_id), as_factor)) %>%
  kable(format = "latex", booktabs = TRUE,
        format.args = list(big.mark = ","),
        linesep = "") %>%
  column_spec(seq_len(11), monospace = TRUE) %>%
  add_header_above(c("Respondent-Level Information" = 4,
                     "Race-Level" = 2,
                     "Candidate-Level Information" = 5)) %>%
  write_lines("guide/Tables/example_rows.tex")


# xtabs

# Variable tables ---
# case id count
case_count <- rdat %>%
  group_by(year) %>%
  summarize(`Rows` = n(), `Unique Cases` = n_distinct(case_id), .groups = "drop")

case_tbl <- as.data.frame(case_count[, 2:3])
rownames(case_tbl) <- as.character(case_count$year)

case_tbl %>%
  fmt_xtab("case ID") %>%
  wri_xtab("case_id")


#

# cand
xtabs(~ year + cand, rdat) %>%
  fmt_xtab("cand") %>%
  wri_xtab("cand_by-resp")

