# From `clerk_raw_<year>.csv` to the CAGE candidate schema

CAGE's released columns, in the order `05_release-candidates.R` writes them:

```
year state office dist type nextup party party_formal name_snyder inc
candidatevotes totalvotes won runoff
```

## What each column needs

| CAGE column | Source | Notes |
|---|---|---|
| `year` | the volume | 2026 volume → `2026`. |
| `state` | `state_abb` | Two-letter, as `state.abb`. |
| `office` | `office` | `H` / `S` only from this PDF. |
| `dist` | `dist` for House; **Senate class** for Senate | The PDF never prints a Senate class. See below. |
| `type` | derived | `G`, or `S` when `unexpired_term_ending` is set. |
| `nextup` | derived | House `year + 2`; Senate `year + 6` for a full term, or the year the unexpired term ends for a special. |
| `party` | recode of `party_printed` | `00c_party-recode-functions.R`. |
| `party_formal` | recode of `party_printed` + `extra_parties` | Cross-endorsements joined with `", "`. |
| `name_snyder` | **not in this PDF** | See below. |
| `inc` | **not in this PDF** | See below. |
| `candidatevotes` | `candidatevotes` + `extra_votes` | Sum of a candidate's own line and every cross-endorsement line. Blank stays blank. |
| `totalvotes` | derived | Sum of `candidatevotes` within `year, office, state, dist, type` — **candidates only**. |
| `won` | derived | `1` for the highest `candidatevotes` in the race. |
| `runoff` | derived | Louisiana rows carry `0`; other States leave it blank. |

Rows where `kind` is `non-candidate` or `party-line` are **dropped** — they are
the Write-in / Blanks / Void / Scattering lines and the presidential-elector
party lines. Keep them in the raw file; they are what makes the cross-check add
up.

Delegates and the Resident Commissioner come out with `dist = 0`. CAGE has not
historically carried them; drop them unless the release scope changes.

## Senate class

The Clerk prints no class, so it has to be supplied:

| Election year | Regular seats up |
|---|---|
| 2024, 2030 | class 1 |
| **2026**, 2032 | **class 2** |
| 2022, 2028 | class 3 |

Every regular 2026 Senate race gets `dist = 2`. A November special is the class
of *that* seat, not of the cycle — in 2024 California's special (`For unexpired
term ending January 3, 2025`) is class 1 and Nebraska's (`… January 3, 2027`)
is class 2, and CAGE stores them as `dist = 1` and `dist = 2` respectively, each
with `type = "S"`.

Note that California 2024 produced **two** CAGE rows per candidate: the special
(`type = "S"`, `nextup = 2024`) and the concurrent full term (`type = "G"`,
`nextup = 2030`), with different vote totals. The extractor emits both; the
`(For full term beginning …)` caption is what separates them.

## Parties

`party_printed` is the Clerk's own wording and is *not* CAGE's `party_formal`.
Run it through `00c_party-recode-functions.R`:

- `party_oneletter()` collapses fusion strings and regional labels to `D`/`R`
  (DFL → `D`, NPL → `D`, `R, Conservative` → `R`).
- `party_fringeparties()` normalises everything else (`Libertarian` → `Lbt`,
  `Working Families` → `Wk Fam`, `Constitution` → `Const`, `Indep` → `I`).

Anything the recode does not cover appears unchanged and must be added to the
recode table deliberately — CAGE's 2024 `party_formal` values include `Const`,
`Wk Fam`, `W-I (I)`, `Unity P of CO`, `IAP` and similar house abbreviations, not
the Clerk's long ballot names.

For cross-endorsed candidates, `party` is the primary affiliation and
`party_formal` lists the lines in printed order, e.g. 2024 NY-01
`party = "R"`, `party_formal = "R, Conservative"`, `candidatevotes = 226,285`.

## `name_snyder`

`name_snyder` is `LAST, FIRST MIDDLE (NICKNAME), SUFFIX` and, with `state`,
uniquely identifies a person across the whole historical database. It is not
the name the Clerk prints. `00e_skeleton-newyear.R` fills it two ways and
records which in `name_source`.

**`history` — copied from a prior person.** For anyone already in CAGE, the
existing `name_snyder` is copied verbatim, including names kept from before a
marriage or divorce. This is the only authoritative route, because the extra
information is not on the page:

| Clerk prints | CAGE `name_snyder` |
|---|---|
| Barry Moore | `MOORE, FELIX BARRY` |
| Mike Rogers | `ROGERS, MICHAEL DENNIS (MIKE)` |
| Mike Johnson | `JOHNSON, JAMES MICHAEL (MIKE)` |
| Terri A. Sewell | `SEWELL, TERRYCINA ANDREA (TERRI)` |

The match needs both a surname that terminates the printed name — so
`WASSERMAN SCHULTZ` matches "Debbie Wasserman Schultz" — and a whole forename
or nickname in common. Initials deliberately do not count: "James D. Hooper"
and `HOOPER, DON` share a "D" and are different people, and letting that match
would fuse two people into one record.

**`reformatted` — the printed name reordered.** For everyone else the printed
name is rearranged into the convention. Nothing is added: `Steve G. Parsons`
becomes `PARSONS, STEVE G.` and not `PARSONS, STEVEN G.`; accents are folded
(`García` → `GARCIA`); `Charles "Charlie" Everette Holt, Jr.` becomes
`HOLT, CHARLES EVERETTE (CHARLIE), JR.`.

Two things this cannot do, which is why every reformatted row is listed in
`candidates_<year>_name-review.csv`:

1. **It cannot know a two-word surname.** The last whitespace-delimited token is
   taken as the surname, so a new "Clinton St. Mosley" comes out as
   `MOSLEY, CLINTON ST.` instead of `ST. MOSLEY, CLINTON`. Rows with particles
   or more than three name tokens are flagged `CHECK`.
2. **It cannot recover a fuller legal name.** CAGE has `HOVDE, ERIC D.` where
   the page prints only "Eric Hovde". Rows that lead their race, or whose
   forename is a common short form, are flagged `CHECK` for exactly this.

Do not fill a `CHECK` row from memory of the candidate. Confirm it against a
source and note which.

## `inc` — not derivable from this volume

| Code | Meaning |
|---|---|
| 0 | not an incumbent for that office |
| 1 | regular incumbent |
| 2 | incumbent who won a special election |
| 3 | appointed (Senate) |

`00e_skeleton-newyear.R` leaves `inc` as NA and offers `inc_proposed` plus
`inc_basis` beside it, derived from whether that person last won the same
office. Treat the proposal as a starting point, not an answer.

`inc` is determined from prior election results for the *same office*, including special
elections, and ignoring redistricting — Conor Lamb, who won the March 2018
PA-18 special, was an incumbent in the redrawn PA-17 that November. Since the
Clerk volume omits House specials entirely, `inc` cannot be settled from it.

## Cases to decide explicitly, not by default

- **Louisiana.** The November race is the jungle primary; a December runoff
  follows when nobody clears 50 %. CAGE stores only the deciding round, so a
  Louisiana race that goes to a runoff must have its November rows replaced by
  the December result from the Secretary of State, with `runoff = 1`. The
  December runoff is not in this volume.
- **Georgia.** Same rule for a general-election runoff; the 2022 volume's
  Senate figure is already the December runoff, flagged by a footnote.
- **Maine.** Ranked-choice. The Clerk prints the final round; the footnote gives
  round 1. CAGE 2022 used round 1 for ME-02. Pick one and record which.
- **Nevada.** "None of These Candidates" is a ballot line, not a person. The
  extractor classifies it as a non-candidate; CAGE 2022 and 2024 carried it as a
  candidate row. Decide before appending.
- **Named write-in candidates.** The Clerk names some (2024 OH Senate has four
  with 13–524 votes). CAGE's treatment is inconsistent across years. Decide once
  and apply it to the whole volume.
- **Florida and Louisiana unopposed races.** No count is printed; keep
  `candidatevotes` blank, per the repo README.

## Where the result goes

`00e_skeleton-newyear.R` writes `data/<year>/candidates_<year>_skeleton.csv`
in these columns, plus `name_printed`, `party_printed`, `name_source`,
`name_needs_review`, `inc_proposed`, `inc_basis`, `source_page` and
`clerk_flags` for provenance. Drop the provenance columns when appending.

`01_stack-sources.R` binds the House/Senate/Governor sources, computes
`totalvotes` by `year, office, state, dist, type`, and writes
`data/intermediate/prelim/candidates_stacked.rds`. Land the new year's rows
alongside the existing sources at that step, then run `02_party-recode.R`
onward. Keep `clerk_raw_<year>.csv`, its footnotes file, and its JSON report in
the repo: they are the provenance for every figure, and the flags record which
ones a human resolved.
