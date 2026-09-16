# Updating CAGE House and Senate rows with Claude Code

Claude Code reads the Clerk of the House *Statistics of the Congressional
Election* volume for a year, codes party and `name_snyder`, and writes a CAGE
skeleton plus lists of rows to check and races to code by hand. `TASK.md` holds
the steps Claude follows; `SKILL.md` and `reference/reader.md` hold the rules.

## Requirements

- The `2026-update` branch (or wherever this skill lives) checked out.
- `data/intermediate/candidates_2006-2024.rds` locally (gitignored). Readers get
  its rows from years before the one being read, for name matching.
- R with `tidyverse`, `fs`, `pdftools` and `dataverse`; poppler (`pdftoppm`,
  `pdftotext`); `curl`.
- The Clerk volume must be published. It usually appears about four months
  after the election (the 2024 volume came out 10 March 2025).

## Add a new year

Open Claude Code in the repo root and type:

> Execute `.claude/skills/clerk-election-returns/TASK.md` for 2026

Claude then:

1. downloads the volume to `data/clerk/2026election.pdf` and checks the cover year;
2. prepares `data/clerk/claude_read/2026/` (page images, earlier-year history, page batches);
3. launches about 9 reader agents in parallel, one per 10 pages;
4. merges and checks their rows (`check_readings.R`);
5. builds the skeleton (`build_skeleton.R`);
6. reports counts, discrepancies, hand-entry races and anything readers found ambiguous.

A full volume takes about 10 minutes and about 1.2 million tokens.

### Outputs

| File | Contents |
|---|---|
| `data/2026/candidates_2026_skeleton.csv` | Candidate rows in CAGE columns plus provenance columns (`name_printed`, `party_lines`, `line_votes`, `name_basis`, `source_page`, `flags`) |
| `data/2026/candidates_2026_discrepancies.csv` | Rows to check on the PDF page: internal inconsistencies and reader flags |
| `data/2026/candidates_2026_hand-entry.csv` | Special elections, runoffs and ranked-choice rounds to code from Secretary of State returns |
| `data/clerk/claude_rows_2026.tsv` | Every printed ballot line as read, the provenance for every figure |

### After the run

1. Check each row in the discrepancies file against the PDF page it names.
2. Code the hand-entry races, and add House special elections (never printed in the volume).
3. Review names built from the printed name (`name_basis = reformatted`), especially winners.
4. Code `inc`.
5. Append the skeleton at `01_stack-sources.R`, dropping the provenance columns, and run `02_party-recode.R` onward.

## Validate on a year CAGE already covers

To check the pipeline itself, run it on a year already released (2006–2024) and
compare with CAGE:

> Execute `.claude/skills/clerk-election-returns/TASK.md` for 2024, then validate it against CAGE

After the steps above, Claude runs `validate_pipeline.R 2024`. It downloads CAGE
v4.1 from Dataverse, prints a summary (rows found, party, `name_snyder`, votes,
`totalvotes`, `won`, `dist`, `nextup`) followed by every difference, and writes
`summary.csv`, `candidates.csv` and `cage_scope.csv` to
`data/clerk/validation/2024/`.

- Readers only see history from before the year being validated.
- The full end-to-end test so far is 2024. Volumes before 2016 may be laid out differently.
- To validate a year after 2024, update `CAGE_FILE` and `CAGE_VERSION` in
  `scripts/validate_pipeline.R` to a release that contains it.

## Running the scripts yourself

Every step except the reading can be run from the repo root without Claude:

```bash
Rscript .claude/skills/clerk-election-returns/scripts/prepare_reading.R 2026
# step 3, the reading, needs Claude Code (see TASK.md)
Rscript .claude/skills/clerk-election-returns/scripts/check_readings.R 2026
Rscript .claude/skills/clerk-election-returns/scripts/build_skeleton.R 2026
Rscript .claude/skills/clerk-election-returns/scripts/validate_pipeline.R 2024   # validation years only
```

## What to commit

- **New year:** `data/clerk/claude_read/<year>/out/`, `batches.csv`,
  `data/clerk/claude_rows_<year>.tsv` and the three `data/<year>/` files. They
  are the record of what was read.
- **Validation year:** nothing. Diagnostics in `data/clerk/validation/` are
  gitignored. Once you have kept any results you need, delete
  `data/clerk/claude_read/<year>/`, `data/clerk/claude_rows_<year>.tsv` and the
  `data/<year>/candidates_<year>_*` files so they are not committed by accident.
- Page images, zoom renders and the copied history files are gitignored.
