# Task: add an election year from the Clerk of the House volume

Execute this task for the year named in the request, for example
"Execute .claude/skills/clerk-election-returns/TASK.md for 2026".
Run every command from the repo root, with `<year>` replaced by that year.

## Before you start

Read these two files in full. They govern every step below.

1. `.claude/skills/clerk-election-returns/SKILL.md`: what the pipeline produces
   and the rules that apply throughout.
2. `.claude/skills/clerk-election-returns/reference/reader.md`: the instructions
   every reader follows.

This task only creates new files under `data/clerk/` and `data/<year>/`. Do not
edit existing scripts, the guide, or data from earlier years.

## 1. Fetch the volume

```bash
curl -sL -o data/clerk/<year>election.pdf \
  "https://history.house.gov/Institution/Election-Statistics/<year>election/"
file data/clerk/<year>election.pdf
pdftotext -f 1 -l 1 data/clerk/<year>election.pdf - | grep -i november
```

The file must be a PDF and the cover must name the November <year> election.
If either check fails (the volume is usually published about four months after
the election), stop and report it.

## 2. Prepare the reader folder

```bash
Rscript .claude/skills/clerk-election-returns/scripts/prepare_reading.R <year>
```

This writes `data/clerk/claude_read/<year>/`: page images, `history.tsv`,
`party_labels.tsv`, `reader.md` and `batches.csv`.

## 3. Read the volume

For every row of `data/clerk/claude_read/<year>/batches.csv`, launch one
`general-purpose` subagent with the prompt below. Launch them all in a single
message so they run in parallel. Fill in `<start>`, `<end>`, `<context_before>`,
`<context_after>` and `<output>` from the row, and drop the `<context_after>`
page from the prompt when that cell is empty.

```
You are transcribing part of the <year> Clerk of the House "Statistics of the
Congressional Election" volume into candidate rows.

Working directory: <absolute path to data/clerk/claude_read/<year>>

1. Read `reader.md` in the working directory first and follow it exactly.
2. Your assigned pages are <start> to <end>. For each page P the image is split
   into two overlapping halves: `pages/pPPP_top.png` and `pages/pPPP_bottom.png`
   (P zero-padded to three digits). Read them with the Read tool.
3. Context pages (read only to know the state, office and district, to finish a
   candidate's cross-endorsement lines or to check a recapitulation table; do
   NOT output rows printed on them): <context_before> and <context_after>.
4. If a figure is hard to read, re-render that region at higher resolution and
   look again, e.g.
   `mkdir -p work/zoom_<start> && pdftoppm -f P -l P -r 300 -x 0 -y 0 -W 2550 -H 1100 -png -singlefile ../../<year>election.pdf work/zoom_<start>/pPPP`
   Only pdftoppm is allowed on the PDF.
5. Coding files: `history.tsv` (dataset rows from earlier years: year, state,
   office, dist, type, party, party_formal, name_snyder) and `party_labels.tsv`
   (state, party_formal, party, n). Search them with grep.
6. Use only the files named here. Do not open any other file on this computer
   and do not search the web.
7. Write the output to `<output>` exactly as specified in reader.md.

When you finish, reply briefly with the number of rows by kind, anything in
reader.md that was ambiguous, and any rows you flagged.
```

Wait for every reader to finish, then check that each `output` file in
`batches.csv` exists. Relaunch any batch whose file is missing. Do not read the
pages yourself to fill gaps, and do not change figures a reader wrote.

## 4. Check the readings

```bash
Rscript .claude/skills/clerk-election-returns/scripts/check_readings.R <year>
```

This merges the readers' files into `data/clerk/claude_rows_<year>.tsv`, checks
every row for internal consistency, and writes
`data/<year>/candidates_<year>_discrepancies.csv` and
`data/<year>/candidates_<year>_hand-entry.csv`.

## 5. Build the skeleton

```bash
Rscript .claude/skills/clerk-election-returns/scripts/build_skeleton.R <year>
```

This writes `data/<year>/candidates_<year>_skeleton.csv`.

## 6. Report back

Summarise for the user, briefly:

- rows read, by kind, and the number of skeleton rows;
- discrepancies by type, listing every one that is not a reader flag;
- hand-entry races by reason, and any unnamed ballot lines;
- anything readers reported as ambiguous in reader.md.

Do not resolve discrepancies or fill in hand-entry races. Those are coded by
hand.

## Validating on a year CAGE already covers

To check the pipeline itself, execute steps 1–5 for a year already in CAGE
(e.g. 2024; `prepare_reading.R` gives readers only earlier years' rows), then run

```bash
Rscript .claude/skills/clerk-election-returns/scripts/validate_pipeline.R <year>
```

It compares the skeleton and hand-entry list with the released CAGE rows for
that year, prints the diagnostics, and writes them to
`data/clerk/validation/<year>/`. Report the summary table and the listed
differences to the user.
