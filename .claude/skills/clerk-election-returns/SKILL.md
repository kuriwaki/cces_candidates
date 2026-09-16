---
name: clerk-election-returns
description: Build candidate-level U.S. House and Senate rows for a new election year (e.g. 2026) from the Clerk of the House "Statistics of the Congressional Election" PDF at history.house.gov. Claude reads the page images and codes party and name_snyder, the rows are checked for consistency, and the run produces a CAGE skeleton plus discrepancy and hand-entry lists. Use when adding a new election year to cces_candidates; the steps are in TASK.md.
---

# Clerk of the House election returns → CAGE

The Clerk of the House publishes one PDF per election cycle at
<https://history.house.gov/Institution/Election-Statistics/>. It is the
authoritative source for `candidatevotes`, `party_formal`, and the candidate
roster for `office` in `{H, S}`. This skill turns one of those PDFs into
candidate-level rows for the CAGE dataset (`doi:10.7910/DVN/DGDRDT`, released
from this repo).

**To run it:** "Execute `.claude/skills/clerk-election-returns/TASK.md` for 2026".

## The one rule that matters

**Never write a vote total you did not read off the page.** A wrong number is
far worse than a missing one, because a missing one is visible and a wrong one
is not. When the document is ambiguous, the cell is left empty and the row is
flagged. Leaving `candidatevotes` blank is an accepted outcome; the CAGE
codebook already blanks vote counts for uncontested Florida races.

Concretely, no step may:

- read a number off a chart, a percentage, or a neighbouring row;
- carry a number over from another source (MEDSL, Ballotpedia, Wikipedia, a
  Secretary of State page) into a cell sourced from this PDF;
- infer a total by subtraction from a recapitulation row;
- repair a flagged row from memory of the election;
- add name information (middle names, legal first names, suffixes) that is not
  on the page or in earlier CAGE rows.

If a figure is unreadable, leave it blank, keep the flag, and say so in the run
report. Filling it in later from a named second source is a separate,
documented step, never a silent one.

## Pipeline

| Step | Done by | Writes |
|---|---|---|
| 1. Fetch the volume, check the cover year | shell | `data/clerk/<year>election.pdf` |
| 2. Prepare the reader folder | `scripts/prepare_reading.R` | `data/clerk/claude_read/<year>/`: page images, `history.tsv` (earlier years only), `party_labels.tsv`, `batches.csv` |
| 3. Read the pages and code party and names | Claude subagents, one per 10-page batch, following `reference/reader.md` | `data/clerk/claude_read/<year>/out/pages_*.tsv` |
| 4. Check the readings | `scripts/check_readings.R` | `data/clerk/claude_rows_<year>.tsv`, `data/<year>/candidates_<year>_discrepancies.csv`, `data/<year>/candidates_<year>_hand-entry.csv` |
| 5. Build the skeleton | `scripts/build_skeleton.R` | `data/<year>/candidates_<year>_skeleton.csv` |
| Validation (years CAGE already covers) | `scripts/validate_pipeline.R` | printed diagnostics and `data/clerk/validation/<year>/` |

Readers check their own figures against each state's recapitulation table in
the PDF and flag any race that does not add up.

## Outputs

### `candidates_<year>_discrepancies.csv`

Rows a person should look at on the PDF page named in `page`.

| `type` | Meaning |
|---|---|
| `unexpected code in state, office, special or kind` | a value outside the reader.md codes |
| `party missing or not one of D, R, I, Lbt, Grn, Other` | a candidate row with no valid `party` |
| `candidate without name_snyder` | a named candidate with no `name_snyder` |
| `line appears more than once` | the same line transcribed twice in a race |
| `party lines and figures do not line up` | `party_lines` and `line_votes` have different lengths |
| `candidatevotes is not the sum of line_votes` | a candidate's total disagrees with their lines |
| `figure missing with no flag or footnote` | a blank figure the reader did not explain |
| `reader flag` | a reader was unsure: a possible history match, a surname split, a coding call, a race that did not add up |

### `candidates_<year>_hand-entry.csv`

Races coded by hand from Secretary of State returns, not taken from this volume.
Rows with `scope = race` list every line of the race; the whole race is kept out
of the skeleton.

| `reason` | Why |
|---|---|
| `special election` | printed under "For unexpired term ending …"; specials are hand-entered by convention |
| `runoff state with no majority` | Georgia or Louisiana race where nobody cleared 50%; the deciding runoff is not in the volume |
| `figure may not be the November first round` | a footnote or ranked-choice lines (Continuing/Exhausted Ballots) say the printed round is not the first |
| `ballot line with no candidate name printed` (`scope = line`) | e.g. just "Green .... 57,442"; the candidate has to be identified |

House special elections are not printed in the volume at all, so they never
appear here; build that list separately from the states that held them.

### `candidates_<year>_skeleton.csv`

CAGE columns, ready to append at `01_stack-sources.R` after review:
`year state office dist type nextup party party_formal name_snyder inc
candidatevotes totalvotes won runoff`, followed by provenance columns
(`name_printed party_lines line_votes name_basis source_page flags`) that are
dropped when appending.

- Named candidates and named write-ins in regular House and Senate races;
  hand-entry races, non-vote lines and delegates are left out.
- `dist` is the House district, or the Senate class for Senate rows.
- `candidatevotes` sums a candidate's own line and cross-endorsement lines.
- `totalvotes` and `won` are filled only when every candidate in the race has a
  figure; an unopposed candidate with no printed count gets `won = 1`.
- `inc` is left empty for hand coding.
- `name_basis` says whether `name_snyder` was copied from an earlier CAGE row
  (`history: …`) or built from the printed name (`reformatted`). Treat
  reformatted names as proposals: CAGE often carries fuller legal names that
  are not printed in the volume.

### Validation diagnostics

`validate_pipeline.R <year>` compares the skeleton and hand-entry list with the
released CAGE rows for that year. It prints a summary table (counts, party,
names, votes, other columns) followed by every difference: rows found on only
one side, races missing or misrouted, party, `name_snyder`, vote, `totalvotes`,
`won`, `dist` and `nextup` differences. The same results are written to
`data/clerk/validation/<year>/summary.csv`, `candidates.csv` and
`cage_scope.csv`.

## Scope

**In scope.** U.S. Representative, Delegate, Resident Commissioner, and U.S.
Senator races held on the November general election date, exactly as printed:
the candidate's name and party as the Clerk prints them, every cross-endorsed
party line, and the vote total.

**Not in scope, because it is not in the PDF:**

| Needed for CAGE | Where it actually comes from |
|---|---|
| **All special elections**: House specials are absent from the volume entirely, and Senate specials, though printed, are hand-entered by convention | State Secretary of State returns; see `links/sec-state_statement-of-votes.csv` |
| **Runoff results** (Georgia, Louisiana): the volume holds the first round, and the runoff is the round CAGE keeps | State Secretary of State returns |
| Governor races | State Secretary of State returns (cf. `data/2024/2024-governor-raw.csv`) |
| President by candidate name | MEDSL (`00d_download-MEDSL-president.R`); the Clerk prints presidential electors by *party*, not by candidate |
| `inc` | Prior CAGE rows plus intervening special elections |

The volume appears roughly four months after the election (the 2024 edition
was published 10 March 2025), so a 2026 run before about March 2027 will fail
the cover-year check.

## After the run

1. Work the discrepancies file against the PDF pages.
2. Hand-enter the races on the hand-entry list, and add House specials.
3. Review reformatted names, especially race winners.
4. Code `inc`.
5. Append the skeleton at `01_stack-sources.R` and run `02_party-recode.R` onward.

Keep `claude_rows_<year>.tsv`, the readers' `out/` files and the three
`data/<year>/` files: together they are the provenance for every figure.

## Files

- `TASK.md`: the step-by-step task Claude executes for a year.
- `reference/reader.md`: transcription and coding rules for the readers.
- `scripts/prepare_reading.R`, `scripts/check_readings.R`,
  `scripts/build_skeleton.R`: steps 2, 4 and 5.
- `scripts/validate_pipeline.R`: diagnostics against CAGE for a year it covers.

## Validation status

2024, run end to end with this TASK.md: readers saw only page images, CAGE rows
from before 2024 and the party labels. Compared with CAGE v4.1:

| | Result |
|---|---|
| Scored CAGE rows found in the skeleton | 1,266 of 1,268 (99.8%) |
| `candidatevotes` identical | 1,264 of 1,264 |
| `won` identical | 1,266 of 1,266 |
| `party` identical | 98.8%; D and R 913 of 913, no Democrat and Republican swapped |
| `party_formal` identical | 95.1% |
| `name_snyder` identical | 97.0% |
| Returning candidates linked to their CAGE record | 643 of 649 (99.1%) |

Almost every remaining difference is a CAGE convention or inconsistency: named
write-ins CAGE drops in one race and keeps in others, Nevada's "None of these
candidates", a duplicate row, no-party labels coded `I` in some states and
`Other` in others, fuller legal names added outside the volume, and Senate
class 2 on the 2024 Maine and Vermont rows. The 9 readers took about 7 minutes
in parallel and about 1.1 million tokens.
