
# Save
write_dta(cand_fmt, path(release_dir, "candidates_2006-2020.dta"))

pre  <- read_dta(path(output_dir, "RespondentLevel_Pre.dta"))
post <- read_dta(path(output_dir, "RespondentLevel_Post.dta"))

pre_fmt <- paste_labels(pre)
post_fmt <- paste_labels(post)

write_dta(pre_fmt, path(release_dir, "cces_candidates_pre.dta"))
write_dta(post_fmt, path(release_dir, "cces_candidates_post.dta"))
