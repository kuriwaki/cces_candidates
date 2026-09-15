---
name: clerk-election-returns
description: Extract candidate-level vote totals for U.S. House and Senate races from the Clerk of the House "Statistics of the Congressional Election" PDFs at history.house.gov, cross-check every race against the document's own recapitulation tables, and shape the result into the CAGE candidate schema. Use when adding a new election year (e.g. 2026) to cces_candidates, or when re-deriving vote counts for any year from 2016 onward.
---

# Clerk of the House election returns → CAGE

The Clerk of the House publishes one PDF per election cycle at
<https://history.house.gov/Institution/Election-Statistics/>. It is the
authoritative source for `candidatevotes`, `party_formal`, and the candidate
roster for `office` in `{H, S}`. This skill turns one of those PDFs into
candidate-level rows for the CAGE dataset
(`doi:10.7910/DVN/DGDRDT`, released from this repo).

## The one rule that matters

**Never write a vote total you did not read off the page.** A wrong number is
far worse than a missing one, because a missing one is visible and a wrong one
is not. Every step below is built around that: when the document is ambiguous,
the cell is left empty and the row is flagged. Leaving `candidatevotes` blank
is an accepted outcome — the CAGE codebook already blanks vote counts for
uncontested Florida races.

Concretely, you must not:

- read a number off a chart, a percentage, or a neighbouring row;
- carry a number over from another source (MEDSL, Ballotpedia, Wikipedia, a
  Secretary of State page) into a cell sourced from this PDF;
- infer a total by subtraction from a recapitulation row;
- repair a flagged row from memory of the election.

If a figure is unreadable, leave it blank, keep the flag, and say so in the
run report. Filling it in later from a named second source is a separate,
documented step — never a silent one.

## Scope

**In scope.** U.S. Representative, Delegate, Resident Commissioner, and U.S.
Senator races held on the November general election date, exactly as printed:
the candidate's name and party as the Clerk prints them, every cross-endorsed
party line, and the vote total.

**Not in scope — these are not in the PDF.** Do not attempt to source them here:

| Needed for CAGE | Where it actually comes from |
|---|---|
| **All special elections** — House specials are absent from the volume entirely, and Senate specials, though printed, are hand-entered by convention | State Secretary of State returns — see `links/sec-state_statement-of-votes.csv` |
| **Runoff results** (Georgia, Louisiana) — the volume holds the first round, and the runoff is the round CAGE keeps | State Secretary of State returns |
| Governor races | State Secretary of State returns (cf. `data/2024/2024-governor-raw.csv`) |
| President by candidate name | MEDSL (`00d_download-MEDSL-president.R`); the Clerk prints presidential electors by *party*, not by candidate |
| `name_snyder` | Prior CAGE rows, then hand-coding — see `reference/cage-mapping.md` |
| `inc` | Prior CAGE rows plus intervening special elections |

Verified against the 2024 volume: Senate specials held in November *are*
printed (marked "For unexpired term ending January 3, …"), House specials are
not, even concurrent ones such as TX-18, WI-8, CO-4 and NJ-10 in 2024.

## Procedure

### 1. Fetch the volume

```bash
YEAR=2026
curl -sL -o "data/clerk/${YEAR}election.pdf" \
  "https://history.house.gov/Institution/Election-Statistics/${YEAR}election/"
```

The path 302-redirects to `historycms.house.gov` and returns
`application/pdf`. Check the file is a PDF and not an error page before going
on. The volume appears roughly four months after the election — the 2024
edition was published 10 March 2025 — so a 2026 run before ~March 2027 will
404 or return a stale file. **Verify the cover page year** (page 1 reads
"FOR THE ELECTION OF NOVEMBER 3, 2026") before trusting anything downstream.

### 2. Extract

```bash
python3 .claude/skills/clerk-election-returns/scripts/extract_clerk.py \
  data/clerk/2026election.pdf 2026 \
  -o data/clerk/clerk_raw_2026.csv \
  --report data/clerk/clerk_report_2026.json
```

Requires `pypdf` only (`pip install pypdf`). Writes four files:
`clerk_raw_2026.csv`, `clerk_raw_2026_hand_entry.csv`,
`clerk_raw_2026_footnotes.csv`, and the JSON report.

Do not re-implement this by pasting page text into the conversation and
reading numbers off it. Flowed page text mis-joins footnote markers onto vote
counts and silently drops whole pages; see
`reference/document-anatomy.md` for the worked examples. Read the CSV.

### 3. Read the report before reading the data

```bash
python3 - <<'PY'
import json, collections
r = json.load(open("data/clerk/clerk_report_2026.json"))
print(r["rows"], "rows;", r["races_cross_checked"], "races cross-checked;",
      r["races_matching_recap"], "matched")
print(collections.Counter(p["level"] for p in r["problems"]))
for p in r["problems"]:
    if p["level"] == "ERROR":
        print(p)
PY
```

**Gate: `races_matching_recap` must equal `races_cross_checked`, and there
must be no ERROR entries.** Every race the script could cross-check is summed
from the printed candidate lines and compared against that state's own
recapitulation table. On the 2018–2024 volumes this check passes for every
race it covers. A single ERROR means the page and the table disagree; stop and
resolve it by looking at the page before going further.

Expected non-fatal entries:

- `no recapitulation total available to cross-check` — the state's table could
  not be read one-to-one, so the race is exported with an `UNVERIFIED` flag.
  Roughly 30–100 of ~470 races per volume. The figures are usually right, but
  they carry no second opinion; spot-check them by eye against the PDF page
  named in the row's `page` column.
- `votes left blank for this block` — the label column and the vote column on
  a page could not be matched one-to-one, so **that whole block's votes were
  blanked on purpose**. Re-key those rows by hand from the page.

### 4. Work the flags

Every row carries a `flags` column. Nothing with a non-empty flag is finished
data. Handle each kind:

| Flag | What it means | What to do |
|---|---|---|
| `RACE SUM MISMATCH` | printed lines ≠ the state's own recapitulation | Read the page. Usually the recapitulation carries a column the listing omits; occasionally it is a real Clerk erratum. Record the decision. |
| `NO MAJORITY in a runoff State` | a Georgia or Louisiana race where nobody cleared 50 % | The seat was decided in a later runoff this volume does not contain. Hand-enter it. |
| `carries a footnote marker` | the figure has a footnote attached | Read `clerk_raw_2026_footnotes.csv`. This is how runoffs and ranked-choice rounds are signalled — see traps below. |
| `footnote reference (N): no vote count printed` | the state reports no count (Florida, Louisiana: unopposed names are not on the ballot) | Leave `candidatevotes` blank. This is correct CAGE behaviour, not a defect. |
| `label is neither 'Name, Party' nor a known ballot-line label` | an unrecognised ballot line | Classify it by hand as candidate or not. In 2024 this caught exactly "Other Write-ins" and "Blank Votes". |
| `no vote cell found on this line` | a printed line with no number beside it | Re-key from the page or leave blank. |
| `UNVERIFIED: no recapitulation cross-check` | see step 3 | Spot-check. |

### 5. Check the shape of the volume

```bash
python3 - <<'PY'
import csv, collections
rows = [r for r in csv.DictReader(open("data/clerk/clerk_raw_2026.csv"))
        if r["kind"] == "candidate"]
d = collections.defaultdict(set)
for r in rows:
    if r["office"] == "H" and r["state_abb"]:
        d[r["state_abb"]].add(r["dist"])
print(sum(len(v) for k, v in d.items() if k not in
          {"DC","AS","GU","PR","VI","MP"}), "House districts (expect 435)")
print("states:", len(d))
PY
```

For 2026 expect **435 House districts across 50 states**, plus 5 delegates
(DC, AS, GU, VI, MP — Puerto Rico's Resident Commissioner is elected only in
presidential years), and the **33 regular Senate races of Senate class 2** (plus any
November special for a class 1 or class 3 seat, printed under "For unexpired
term ending January 3, …").
A midterm volume has **no** `FOR PRESIDENTIAL ELECTORS` sections. If the
district count is off, a state header was missed — do not proceed.

### 6. Pull out the hand-entry worklist

Runoff and special-election results are entered by hand in this project, not
taken from the Clerk volume. The extractor marks those rows in a `hand_entry`
column and copies them to `clerk_raw_2026_hand_entry.csv`, which is the
worklist. Three reasons, and a row can carry more than one:

- `special election` — printed under "For unexpired term ending January 3, ...".
  Senate specials only; House specials are not in the volume at all, so build
  that list separately from the States that held them.
- `runoff expected` — a Georgia or Louisiana race where no candidate reached a
  majority, so a later runoff decided the seat. The figures in the volume are
  the first round.
- `footnote - check which round this is` — the figure carries a footnote.
  Sometimes the footnote says the printed number *is already* the runoff or a
  ranked-choice final round, in which case it is usable but its `type` and
  `runoff` coding differ. Read `clerk_raw_2026_footnotes.csv` before deciding.

**Drop every `hand_entry` row from the automatic append** and work the list
separately against Secretary of State returns. Sanity-check the count against
past volumes: 4 rows in 2024, 10 in 2022, 52 in 2020 (Arizona and both Georgia
Senate seats, plus LA-05), 45 in 2016 (the Louisiana Senate seat, LA-03 and
LA-04).

### 7. Dry-run the toolchain on a year you can already check

Before trusting a run on a new year, run the whole pipeline on a year CAGE
already covers and confirm nothing has drifted:

```bash
curl -sL -o /tmp/2024election.pdf \
  "https://history.house.gov/Institution/Election-Statistics/2024election/"
python3 .claude/skills/clerk-election-returns/scripts/extract_clerk.py \
  /tmp/2024election.pdf 2024 -o /tmp/clerk_raw_2024.csv --report /tmp/rep.json
python3 .claude/skills/clerk-election-returns/scripts/compare_to_cage.py \
  /tmp/clerk_raw_2024.csv release/candidates_2006-2024.tab 2024
```

Expect `missing from the clerk extraction (0)`, the six delegate seats as
clerk-only, and exactly the three known CAGE-convention differences listed
under *Validation status*. Anything else means the toolchain changed
behaviour and the new year's output cannot be trusted yet.

### 8. Build the skeleton

`00e_skeleton-newyear.R` sits in this repo's numbered sequence, just before
`01_stack-sources.R`. It turns the raw Clerk rows into CAGE-shaped rows:

```bash
Rscript 00e_skeleton-newyear.R 2026
# or, with explicit paths:
# Rscript 00e_skeleton-newyear.R 2026 data/clerk/clerk_raw_2026.csv \
#         data/intermediate/candidates_2006-2024.rds data/2026
```

It writes into `data/2026/`:

| File | What it is |
|---|---|
| `candidates_2026_skeleton.csv` | the CAGE columns, ready for `01_stack-sources.R` |
| `candidates_2026_name-review.csv` | names that need a human eye |
| `candidates_2026_party-review.csv` | party strings that fell through to `Other` |
| `candidates_2026_hand-entry.csv` | the runoff and special rows from step 6 |

`name_snyder` is filled two ways and a `name_source` column always says which:

- **`history`** — the row matched exactly one prior person in the same State and
  that person's existing `name_snyder` was copied verbatim. A surname match
  alone is never enough: a whole forename or nickname must also agree, because
  "Justin Lee" must not inherit the identity of `LEE, BARBARA J.`
- **`reformatted`** — nobody matched, so the printed name was reordered into
  `LAST, FIRST MIDDLE (NICKNAME), SUFFIX`. This *rearranges* what the Clerk
  printed and adds nothing: initials stay initials, accents are folded, a
  quoted nickname moves into parentheses, a trailing suffix stays a suffix.

Measured against the released CAGE names, with the history truncated to the
prior cycle so the run is honest:

| Volume | Exact match | From history | Reformatted |
|---|---|---|---|
| 2024 | 1,216 / 1,256 (96.8 %) | 628 / 631 | 588 / 625 |
| 2022 | 1,184 / 1,286 (92.1 %) | 550 / 556 | 634 / 730 |

2022 scores lower because redistricting brought in many new candidates, and
almost every remaining difference is a name CAGE enriched from outside the
Clerk volume — `MURKOWSKI, LISA A.` where the page prints "Lisa Murkowski",
`CRANE, ELIJAH (ELI)` where it prints "Eli Crane". No rule reading only this
PDF can produce those, which is why they go to review rather than being
invented.

**Treat every `reformatted` name as a proposal.**
`candidates_2026_name-review.csv` lists all of them, and `priority` only orders
the work: `CHECK` marks a row that leads its race (likely a new member whose
full legal name will matter in future cycles), uses a short forename that
usually stands for a longer one, or has a surname that may be more than the
last token ("Clinton St. Mosley", "Wasserman Schultz"). On 2024 and 2022 that
flag sat on about half the rows that turned out to differ from CAGE, so it is a
work order, not a guarantee — do the CHECK rows first, then sweep the rest.

Rows marked `history` are the ones you can lean on: 1,178 of 1,187 correct
across the two volumes, and the handful that differ are cases where the match
to the earlier person looks right and CAGE's own entry is the odd one
(`MCGOVERN, JAMES JOSEPH (JAY)` vs a fresh `MCGOVERN, JAY`).

### 9. Fill the derived columns

The skeleton leaves `totalvotes`, `won` and `inc` as NA on purpose: none of
them is printed in the volume. Fill the first two here, as one reviewed pass —
and **only for races whose candidate votes are all present**, so a blank never
propagates into a total that looks complete:

```r
library(tidyverse)
filled <- read_csv("data/2026/candidates_2026_skeleton.csv") |>
  group_by(year, state, office, dist, type) |>
  mutate(
    complete   = all(!is.na(candidatevotes)),
    totalvotes = if_else(complete, sum(candidatevotes), NA_integer_),
    won        = if_else(complete,
                         as.integer(candidatevotes == max(candidatevotes)),
                         NA_integer_)
  ) |>
  ungroup() |>
  select(-complete)

# a tie at the top means two rows carry won == 1; resolve by hand
filled |> group_by(state, office, dist) |>
  summarise(winners = sum(won, na.rm = TRUE), .groups = "drop") |>
  filter(winners != 1)
```

On the 2024 volume this reproduces CAGE's `won` for all 1,256 rows and its
`totalvotes` for 1,245; the 11 differences all sit in the three races where
CAGE's candidate set itself differs (see *Validation status*).

`inc` stays NA. The script offers `inc_proposed` and `inc_basis` alongside it —
derived from whether that person last won the same office — but the real code
needs the House specials that this volume omits, so a human sets `inc`. Codes
are in `reference/cage-mapping.md`.

### 10. Land it

Append the filled rows at `01_stack-sources.R`, then run `02_party-recode.R`
onward. Keep `clerk_raw_<year>.csv`, its footnotes file, its JSON report and
the review files in the repo: together they are the provenance for every
figure, and they record which rows a person resolved by hand.

Full column-by-column mapping, party recoding, Senate classes and the
State-specific decisions are in `reference/cage-mapping.md`.

## The five traps in this document

All five are handled by the script; they are listed so you can recognise them
if you ever work a page by hand, or if a future volume changes typography.

1. **Superscript footnote markers glue onto vote counts.** In the 2022 volume
   Herschel Walker's Senate total reads `1,721,244` on the page, but flowed
   text extraction returns `11,721,244` — the footnote marker "1" fused to the
   front. Nine-digit plausibility makes this invisible. The script drops runs
   set below 70 % of the page's body font size, which removes markers while
   keeping figures, and the recapitulation cross-check catches any survivor.

2. **The printed round is not always the November first round.** Georgia and
   Louisiana decide general elections by majority, so a plurality leader in the
   volume means a runoff settled the seat afterwards; CAGE keeps the deciding
   round, so the extractor marks those races `runoff expected` for hand entry.
   Footnotes cut the other way too: the 2022 Georgia Senate figure printed in
   the volume is *already* the December runoff, and Maine's 2022 ME-02 figures
   are ranked-choice round 2 with round 1 given only in the footnote. Never
   accept a flagged figure without reading its footnote.

3. **Cross-endorsement lines are separate printed lines.** In New York a
   candidate's Conservative or Working Families votes are printed on their own
   indented line under the candidate. CAGE's `candidatevotes` is the **sum**
   (2024 NY-01: LaLota 200,802 + 25,483 = 226,285) and `party_formal` lists
   the lines (`"R, Conservative"`). Indentation, not punctuation, is what
   separates a cross-endorsement from a distinct candidate: in 2024 NY-05
   `Conservative, Common Sense` is one candidate's second and third lines,
   while in NY-10 `Paul J. Briscoe, Conservative` is a different person.

4. **Non-candidate ballot lines are not uniform across states.** Write-in,
   Blank(s), Void, Scattering, All Others, Others, Miscellaneous, Over/Under
   Votes, Other Write-ins, Blank Votes, None of These Candidates (Nevada),
   Continuing Ballots and Exhausted Ballots (Maine RCV) all appear. CAGE
   excludes them from `candidatevotes` and from `totalvotes`; the state
   recapitulation *includes* them in its Total column. Anything the script
   cannot classify is flagged rather than guessed.

5. **Some states report no count at all.** Florida and Louisiana do not print
   unopposed candidates on the ballot, so the vote column holds a footnote
   reference such as `(1)` instead of a number. CAGE leaves those blank.

## Files

- `../../../00e_skeleton-newyear.R` — the skeleton builder, in the repo's own
  numbered script sequence (step 8 above).
- `scripts/compare_to_cage.py` — regression check against a released CAGE file.
- `scripts/extract_clerk.py` — the extractor. Read its module docstring before
  changing it; several constants encode findings from the 2016–2024 volumes.
- `reference/document-anatomy.md` — how the PDF is built, why naive text
  extraction fails, and the validation design.
- `reference/cage-mapping.md` — raw columns → CAGE columns, including what has
  to come from elsewhere.

## Validation status

The extractor was checked against the released CAGE file
(`candidates_2006-2024.tab`, v4.1) for five volumes:

| Volume | Races cross-checked vs. the PDF's own tables | Mismatches | vs. CAGE |
|---|---|---|---|
| 2024 | 440 / 440 | 0 | all 468 CAGE races present; 3 differences, all CAGE-side conventions |
| 2022 | 433 / 433 | 0 | all 469 present; 5 differences, all explained |
| 2020 | 375 / 375 | 0 | all present |
| 2018 | 386 / 386 | 0 | all present |
| 2016 | 401 / 402 | 1 (OK Senate, a real listing-vs-table discrepancy in the Clerk's own document) | all present |

The differences against CAGE are conventions, not extraction errors: CAGE
drops small named write-in candidates the Clerk lists, treats Nevada's "None
of These Candidates" as a candidate, and for Maine 2022 uses RCV round 1 where
the Clerk prints round 2.

**Volumes from 2016 onward are supported.** 2010 and 2000 were tried and parse
only partially (no recapitulation cross-check, ~half the rows); they need a
different approach and must not be run through this skill unsupervised.
