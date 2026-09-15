# Anatomy of a Clerk of the House election-statistics PDF

Notes taken from the 2016, 2018, 2020, 2022 and 2024 volumes. They explain why
`extract_clerk.py` works the way it does. Read this before changing the script
or before reading a page by hand.

## Structure of the volume

```
p.1        cover
p.2–…      per-State listing, in alphabetical order:
              STATE                                   (10 pt, centred)
                FOR PRESIDENTIAL ELECTORS             (small caps; presidential years only)
                  <Party> ................. <votes>   (electors are listed by PARTY, not by name)
                FOR UNITED STATES SENATOR
                  (For unexpired term ending January 3, YYYY)   <- a November special
                  <Name>, <Party> ......... <votes>
                  (For full term beginning January 3, YYYY)     <- back to the regular seat
                  <Name>, <Party> ......... <votes>
                FOR UNITED STATES REPRESENTATIVE
                  AT LARGE                            (single-district States)
                  N.  <Name>, <Party> ..... <votes>   (N = congressional district)
                        <Party> ........... <votes>   (indented = cross-endorsement of the line above)
                      Write-in / Blanks / Void / …
                FOR DELEGATE  |  FOR RESIDENT COMMISSIONER
              Recapitulation of Votes Cast in <State>  (a wide cross-tab; see below)
back matter  Electoral Votes for President …  (presidential years)
             Recapitulation of Votes Cast for United States Senators, by States
             Recapitulation of Votes Cast for United States Representatives, by States
             Political Divisions of the U.S. Senate and House … 40th–NNNth Congress
```

Continued pages repeat the heading with an em dash: `NEW YORK—Continued`,
`FOR UNITED STATES REPRESENTATIVE—Continued`.

House special elections held during the preceding term are **not** in the
volume, and neither are concurrent November House specials. Confirmed on the
2024 volume: TX-18, WI-8, CO-4, NJ-10, NY-3, NY-26, OH-6 and CA-20 all held
November 2024 specials and none appears. Senate specials *are* printed, under
the "For unexpired term" caption.

## Why flowed text extraction is not safe here

Three independent failure modes, all observed:

**1. Superscript footnote markers fuse onto figures.** 2022 volume, Georgia
Senate. The page shows `1,721,244`; `pypdf`'s default and layout modes both
return `11,721,244`. The positioned runs show why:

```
y=533.8  x=489.6  size=4.0   " 1"          <- footnote marker
y=526.4  x=61.6   size=8.0   "Herschel Junior Walker, Republican ……"
y=526.4  x=540.4  size=8.0   "1,721,244"   <- the actual figure
```

The marker is a separate run, on its own baseline, at half the body size. The
extractor therefore drops every run below 70 % of the page's modal font size.
The same trap hits Maine 2022 ME-2 (`1146,142` for `146,142`).

**2. Layout mode silently discards whole pages.** `extract_text(extraction_mode="layout")`
emits "Rotated text discovered. Output will be incomplete." and returns *only
the page number* for pages carrying a landscape recapitulation — 26 of the 87
pages of the 2024 volume. Nothing in the returned text says data is missing.

**3. Labels and figures do not share a baseline.** In the 2024 volume the
first candidate of each district block is set ~7.4 pt above its own vote cell,
while the rest of the block is aligned:

```
y=587.8  " Barry Moore, Republican ……"
y=580.4  "1."            y=580.4  "258,619"     <- district marker shares the FIGURE's baseline
y=570.8  "Tom Holmes, Democrat ……"  y=570.8  "70,929"
```

So pairing by nearest y is wrong, and pairing by y equality loses rows.

## How the extractor pairs a label with its figure

Per page:

1. Collect every text run with its position and *effective* font size
   (`hypot(m[2], m[3]) * font_size` from the composed text × CTM matrix, which
   is rotation-invariant).
2. Take the page's dominant text direction. Landscape recapitulation pages are
   set at 90°; their coordinates are rotated into reading order rather than
   skipped.
3. Drop sub-body-size runs (footnote markers). One exception is re-admitted: a
   parenthesised reference such as `(1)` standing in the vote column, which is
   how Florida and Louisiana print "no count reported". It becomes an empty
   vote with a note.
4. Split the page into segments at every State heading and every
   "Recapitulation of Votes Cast" heading. A State heading is recognised by
   font size as well as by text, so the word "Florida" wrapped inside a table
   header does not start a new State.
5. In a listing segment: take the dot-leader rows as labels and the right-hand
   numeric runs as figures, sort both top-to-bottom, and **pair by rank**.
   The pairing is accepted only if the counts match and every pair lies within
   1.6 line-heights. If either check fails, **every vote in that block is left
   blank** and a warning is emitted. The script never falls back to a guess.

## Reading a recapitulation table

The per-State recapitulation is the document's own check on itself, and it is
what makes verification possible. Its geometry varies:

- Stub (`3d district`) and figures sometimes share a baseline, sometimes sit a
  constant fraction of a row apart (2.1 pt one way, 6.9 pt the other, in the
  same 2024 table).
- Wide tables are printed as stacked **panels**, each with its own
  `Title of candidate` header and its own party columns. **Only the panel
  whose header ends in `Total` carries a usable figure** — a table continued
  onto a second page repeats the stub column but not the Total column.
- A State with an unreported race has a stub with no figures at all.

The script splits panels at `Title of candidate`, measures the stub-to-figures
offset from the page itself (trying every offset the table suggests and keeping
the one that lines every stub up with a distinct row), and then applies it.
Two safety valves: panels that disagree about the same district are both
discarded, and the House district totals must add up to the table's own `Total`
line or the whole table is dropped. A dropped table costs a cross-check; a
misread one would manufacture a false mismatch.

## The cross-check

For each race, the sum of **all** printed lines — candidates, every
cross-endorsement line, and every write-in/blank/void/scattering line — must
equal that race's row in the recapitulation's Total column.

Worked example, 2024 NY-01: 200,802 + 25,483 + 181,647 + 1,893 + 19,984 + 376
+ 275 = 430,460, which is exactly the recapitulation figure.

Note the asymmetry with CAGE: the recapitulation Total includes write-ins and
blanks, CAGE's `totalvotes` does not. Same 2024 AL-01: recapitulation Total
329,854, CAGE `totalvotes` 329,548, the 306-vote difference being write-ins.

A failed cross-check does not tell you which side is wrong. In the 2016 volume
the Oklahoma Senate listing sums to 1,448,047 while the recapitulation says
1,452,992 — a discrepancy inside the Clerk's own document, not an extraction
error. Read the page.
