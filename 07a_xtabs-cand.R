source("07_xtabs-functions.R")




# counts JS ----
jsdat %>% filter(party %in% c("D", "R")) %>%  write_numbers("all")
jsdat %>% filter(office == "G", party %in% c("D", "R")) %>% write_numbers("gov")
jsdat %>% filter(office == "H", party %in% c("D", "R")) %>% write_numbers("house")
jsdat %>% filter(office == "S", party %in% c("D", "R")) %>% write_numbers("sen")


# var example

jsdat %>%
  filter(year == 2016, state == "MO",  (office %in% c("S", "G") | dist == 5)) %>%
  mutate(party = fct_relevel(party, "D", "R"),
         office = fct_relevel(factor(office), "H", "S", "G")) %>%
  arrange(office, party) %>%
  select(-party_formal, -type) %>%
  mutate(across(c(year), as_factor)) %>%
  kable(format = "latex", booktabs = TRUE,
        format.args = list(big.mark = ","),
        linesep = "") %>%
  column_spec(seq_len(10), monospace = TRUE)  %>%
  write_lines("guides/Tables/example_candidates.tex")



# main xtab
xtabs(~ year + office, jsdat) %>%
  fmt_xtab("office") %>%
  wri_xtab("office_by-cand")



jsdat  %>%
  mutate(party_lump = fct_lump(party_short, n = 5, other_level = "Other"),
         party_lump = fct_relevel(party_lump, "D", "R", "I", "Lbt", "Grn", "")) %>%
  xtabs(~ year + party_lump, .) %>%
  fmt_xtab("party") %>%
  wri_xtab("party_by-cand")


# incumbent
jsdat %>%
  xtabs(~ year + inc, .) %>%
  fmt_xtab("inc") %>%
  wri_xtab("inc_by-cand")
