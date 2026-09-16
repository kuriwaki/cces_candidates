# Reading a Clerk of the House election-statistics volume

You are transcribing and coding candidate rows from page images of the Clerk of
the House *Statistics of the Congressional Election* for one election year. You
work on an assigned range of pages and write one TSV file.

## Ground rules

- Read the page images yourself. Do not run text-extraction tools on the PDF
  (`pdftotext`, `pdfinfo`, `pypdf`, OCR libraries) and do
  not look anything up online. `pdftoppm` is allowed for re-rendering a page at
  higher resolution.
- Use only the files named in your task. Do not open other files on this computer.
  Put any helper files you create under `work/` in the working directory.
- **Never write a vote figure you did not read on the page.** Do not compute a
  figure by subtraction, carry one over from elsewhere, or fill one from memory.
  If a figure is unreadable, leave it blank and say so in `flags`. A blank is
  visible; a wrong number is not.
- **Never add name information that is not on the page or in the history file.**
  No middle names, legal first names or suffixes from your own knowledge.

## How the volume is laid out

```
STATE                                       (bold, centred; "STATE—Continued" on later pages)
  FOR PRESIDENTIAL ELECTORS                 (skip: parties, not people)
  FOR UNITED STATES SENATOR
    (For unexpired term ending January 3, YYYY)   <- special election rows follow
    Name, Party .................... 123,456
    (For full term beginning January 3, YYYY)     <- regular seat rows follow
  FOR UNITED STATES REPRESENTATIVE
    AT LARGE                                (single-district state: district 1)
 1. Name, Party .................... 123,456   <- district number left of the first candidate
    Name, Party .................... 98,765
          Party .................... 4,321    <- indented, no name: cross-endorsement of the line above
    Write-in ....................... 12       <- ballot line that is not a person
  FOR DELEGATE / FOR RESIDENT COMMISSIONER  (district 0)
  Recapitulation of Votes Cast in STATE     (a table: skip, do not transcribe)
```

Pages may also carry footnotes at the bottom of a state's section, and the back
of the volume has national summary tables. A page that holds only
recapitulation or summary tables produces no rows.

`page` is always the PDF page number (the cover is page 1), not the number
printed at the top of the page.

## Reading traps

1. **Footnote markers are not digits.** A small raised number next to a name or
   a figure is a footnote marker. `¹1,234,567` is 1234567 with footnote 1. Read
   the footnote text and put it in `footnote`.
2. **A footnote or the ballot lines can change what the figure is.** Some
   footnotes say the printed figure is from a runoff or a ranked-choice round,
   and ranked-choice races may print "Continuing Ballots" or "Exhausted Ballots"
   lines. Add `flags: figure is not the November first round` to every line of
   such a race.
3. **`(1)` in the vote column is not a count.** Some states print a footnote
   reference instead of a number for unopposed candidates. Leave the votes blank
   and record the footnote.
4. **Indentation decides cross-endorsements.** An indented line with only a party
   name belongs to the candidate above it. A line with a name is a separate
   candidate, even if it only names a party-like label after the comma.
   Some states print several parties on one line with a single figure
   ("Name, Republican, Libertarian"); that is one line.
5. **Continued pages.** A page can start in the middle of a state, an office or a
   district. Use the context pages you are given to know which state, office and
   district you are in.
6. **The two image halves overlap by a few lines.** Do not output a row twice.
7. **Lines that are not people:** Write-in (without a name), Scattering, Blank(s),
   Void, Over/Under Votes, Other Write-ins, All Others, Miscellaneous, None of
   These Candidates, Continuing Ballots, Exhausted Ballots, Spoiled Votes and
   similar. Record them as `kind = nonvote`. A printed "Total" line is also
   `nonvote`; it repeats the race total and must not be counted as votes.
8. **A party label with no name** (for example just "Green .... 12,345") is a
   real ballot line whose candidate is not named. Record it as
   `kind = unnamed` with a flag.
9. **The recapitulation table is a check, not a source.** You may add up a
   race's lines and compare with the state's recapitulation table. If they
   disagree, re-read the listing at higher resolution; if they still disagree,
   keep what the listing shows and flag it. Never take a figure from the table.

## Coding rules

### `party` (one of D, R, I, Lbt, Grn, Other)

`party_labels.tsv` lists, for each state, the party labels already used in the
dataset with the `party` code each received and how often. **If the same party
label has been coded before in the same state, follow that coding**, even where
it differs from the general rules below (for example, a state Green party the
dataset has always coded `Other`).

Otherwise code from the candidate's **first** printed party line:

- Democrat, Democratic, Democratic-Farmer-Labor, Democratic-Nonpartisan League → `D`
- Republican, GOP → `R`
- Libertarian, including state parties such as "Libertarian Party of Florida" → `Lbt`
- Green → `Grn`
- Independent and no-party labels (No Party Affiliation, No Party, No Political
  Party, Unaffiliated, Unenrolled, Nonaffiliated, No Party Preference) → `I`
- named write-in candidates (label starts with "Write-in") → `Other`
- anything else → `Other`

When several parties are printed on one line, code from the first one named.

### `party_formal`

The candidate's party lines in printed order, joined with `", "`, each written
as the dataset's existing label when one fits (`party_labels.tsv`, preferring
labels already used in the same state): for example `D`, `R`, `Lbt`, `Grn`,
`I`, `Wk Fam`, `C` for Conservative, `Const` for Constitution. A New York
Republican also on the Conservative line is `R, C`. If no existing label fits,
use the printed label.

In Minnesota, a Democratic candidate's first label is `DFL` whether the volume
prints "Democrat" or "Democratic-Farmer-Labor".

For a named write-in, `party_formal` is `W-I`, followed by the party in the
parentheses as a dataset code when there is one: "Write-in (Democratic)" →
`W-I (D)`, "Write-in (Unaffiliated)" → `W-I (I)`, "Write-in (Other)" → `W-I`.

### `name_snyder`

Format: `LAST, FIRST MIDDLE (NICKNAME), SUFFIX`, upper case, accents removed,
straight apostrophes, a period after each initial. Examples:
`SEWELL, TERRYCINA ANDREA (TERRI)`, `CORNYN, JOHN, III`,
`KELLY, GEORGE J. (MIKE), JR.`, `WASSERMAN SCHULTZ, DEBBIE`,
`JACKSON LEE, SHEILA`.

Together with the state, `name_snyder` identifies a person across all years, so
**a returning candidate must get exactly the name they already have**.

1. **Look for the person in `history.tsv`** (earlier years only), searching the
   same state for the surname. Allow for compound or respelled surnames
   (Ana De La Rosa / DE LA ROSA-GARZA, RedHorse / RED HORSE), nickname forms
   (Bobby / ROBERT (BOB)), spelling variants (Katherine / KATHRYN) and initials
   (J. R. / JOHN R. (J.R.)).
2. **Decide whether it is the same person**, using district or office, party,
   years and suffixes. Fathers and sons share names: a printed "Jr.", a
   different middle initial, or a different party and office point to a
   different person (a printed "John A. Doe, Jr." is not `DOE, JOHN A.`).
3. **If one earlier record is clearly the same person**, copy its `name_snyder`
   exactly. If the history spells that same person more than one way, use the
   spelling that appears in the most years (the most recent one if tied). A
   record for any office counts (a governor running for Senate keeps their
   governor record's name). Set `name_basis` to
   `history: <year> <office>-<dist> <party>`, where `<dist>` is the record's
   `dist` value (the Senate class for Senate records; omit `-<dist>` when empty)
   and `<party>` is the record's `party` code.
4. **Otherwise, build the name from the printed name only.** Decide the surname
   with judgment (particles such as De La, Van, St. are part of the surname).
   Quoted nicknames go in parentheses after the given names; a printed suffix
   goes last. Set `name_basis` to `reformatted`, and add
   `flags: possible match <name_snyder>` when a history record was close but you
   could not confirm it is the same person.

## Output

Write one tab-separated file, UTF-8, with this header and one row per printed
ballot line in your assigned pages (`kind` below). Leave a cell empty when it
does not apply. Do not use tabs or line breaks inside cells.

| column | content |
|---|---|
| `year` | election year |
| `page` | PDF page number where the line is printed |
| `state` | two-letter postal code |
| `office` | `S` or `H` (House, delegate, resident commissioner); skip presidential electors |
| `dist` | House district number; at large = 1; delegate or resident commissioner = 0; empty for Senate |
| `special` | 1 under an "(For unexpired term ending …)" caption, else 0 |
| `kind` | `candidate` (named person, not a write-in); `writein` (named person whose label starts with "Write-in"); `unnamed` (party label with no name); `nonvote` (lines that are not people) |
| `name_printed` | the name exactly as printed (curly quotes and accents included), without the party; empty for `unnamed` and `nonvote` |
| `party_lines` | each printed line's party label for this candidate, own line first, joined with ` ; `; for `unnamed` and `nonvote`, the line's label |
| `line_votes` | the figure on each of those lines, digits only, same order, joined with ` ; ` |
| `candidatevotes` | sum of `line_votes`; empty if any figure is blank |
| `footnote` | footnote text that applies to this line |
| `party` | coding rule above (`candidate`, `writein` and `unnamed` rows; empty for `nonvote`) |
| `party_formal` | coding rule above (empty for `nonvote`) |
| `name_snyder` | coding rule above (`candidate` and `writein` rows) |
| `name_basis` | `history: …` or `reformatted` |
| `flags` | anything uncertain: unreadable figures, possible matches, runoff or ranked-choice notes |

Rows appear in printed order. A cross-endorsement line is never its own row;
it is part of the candidate row above it.

Before finishing, check each race you transcribed: every candidate has a party,
every line has a figure or a flag, and no line appears twice.
