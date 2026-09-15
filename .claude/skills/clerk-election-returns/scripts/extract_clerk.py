#!/usr/bin/env python3
"""Extract candidate-level vote totals from a Clerk of the House
"Statistics of the ... Election" PDF (history.house.gov).

Design notes live in SKILL.md.  The short version:

* Text is rebuilt from positioned runs (x, y, effective font size), not from
  flowed page text.  Superscript footnote markers are dropped by font size,
  which is what stops a footnote "1" from being glued onto "1,721,244".
* A vote total is emitted only when a numeric cell was actually found and the
  label/number pairing passed its consistency checks.  Otherwise the cell is
  left EMPTY and the row is flagged.  The script never guesses a number.
* Every race is cross-checked against the state's own recapitulation table.
"""
import argparse, csv, json, math, re, statistics, sys
from collections import Counter, defaultdict
from pypdf import PdfReader

# ---------------------------------------------------------------- constants
STATES = {
 "ALABAMA":"AL","ALASKA":"AK","ARIZONA":"AZ","ARKANSAS":"AR","CALIFORNIA":"CA",
 "COLORADO":"CO","CONNECTICUT":"CT","DELAWARE":"DE","FLORIDA":"FL","GEORGIA":"GA",
 "HAWAII":"HI","IDAHO":"ID","ILLINOIS":"IL","INDIANA":"IN","IOWA":"IA","KANSAS":"KS",
 "KENTUCKY":"KY","LOUISIANA":"LA","MAINE":"ME","MARYLAND":"MD","MASSACHUSETTS":"MA",
 "MICHIGAN":"MI","MINNESOTA":"MN","MISSISSIPPI":"MS","MISSOURI":"MO","MONTANA":"MT",
 "NEBRASKA":"NE","NEVADA":"NV","NEW HAMPSHIRE":"NH","NEW JERSEY":"NJ","NEW MEXICO":"NM",
 "NEW YORK":"NY","NORTH CAROLINA":"NC","NORTH DAKOTA":"ND","OHIO":"OH","OKLAHOMA":"OK",
 "OREGON":"OR","PENNSYLVANIA":"PA","RHODE ISLAND":"RI","SOUTH CAROLINA":"SC",
 "SOUTH DAKOTA":"SD","TENNESSEE":"TN","TEXAS":"TX","UTAH":"UT","VERMONT":"VT",
 "VIRGINIA":"VA","WASHINGTON":"WA","WEST VIRGINIA":"WV","WISCONSIN":"WI","WYOMING":"WY",
 "DISTRICT OF COLUMBIA":"DC","AMERICAN SAMOA":"AS","GUAM":"GU","PUERTO RICO":"PR",
 "VIRGIN ISLANDS":"VI","NORTHERN MARIANA ISLANDS":"MP",
}
TERRITORIES = {"DC","AS","GU","PR","VI","MP"}
FIFTY = {v for v in STATES.values() if v not in TERRITORIES}

OFFICE_HDR = {
 "FOR PRESIDENTIAL ELECTORS": "P",
 "FOR UNITED STATES SENATOR": "S",
 "FOR UNITED STATES REPRESENTATIVE": "H",
 "FOR DELEGATE": "H",
 "FOR RESIDENT COMMISSIONER": "H",
}
STATES_FLAT = {re.sub(r"[^A-Z]", "", k): k for k in STATES}
OFFICE_FLAT = {re.sub(r"[^A-Z]", "", k): k for k in OFFICE_HDR}

# Ballot lines that are not a person.  Matched against the WHOLE label.
# Anything that matches neither this nor "Name, Party" is flagged, never
# silently kept and never silently dropped.
NONCANDIDATE = re.compile(r"""^(
    write[-\s]?ins?(\s*\(.*\))?      | scatter\w*(\s*\(.*\))?    |
    blanks?  | voids?                | over\s*votes?             | under\s*votes? |
    all\s+others?  | others?         | miscellaneous             | invalid.*      |
    none\s+of\s+these\s+candidates   | continuing\s+ballots?      | exhausted\s+ballots |
    totals?  | not\s+designated      | no\s+candidates?.*        | unresolved.*   |
    defective.* | spoil\w*           | insufficient.*            | rejected.*     |
    under\s*/\s*over\s*votes?        | unqualified\s+write[-\s]?ins?   |
    (other|unrecorded|unattributed)\s+write[-\s]?ins?                       |
    blank\s+votes?  | over\s+and\s+under\s*votes?  | no\s+preference
)$""", re.I | re.X)

# States whose general elections require a majority; a plurality winner here
# means a later runoff decided the seat, and that result is hand-entered.
MAJORITY_RULE = {"GA", "LA"}

NUMBER  = re.compile(r"^\(?[\d,]{1,15}\)?$")
DISTROW = re.compile(r"^(\d{1,2})(?:st|d|nd|rd|th)\s+district\b", re.I)
SUFFIX  = re.compile(r"^(jr\.?|sr\.?|i{1,3}|iv|vi{0,3}|2nd|3rd|m\.?d\.?|ph\.?d\.?)$", re.I)


# --------------------------------------------------------------- geometry
def _mul(a, b):
    return [a[0]*b[0]+a[1]*b[2], a[0]*b[1]+a[1]*b[3],
            a[2]*b[0]+a[3]*b[2], a[2]*b[1]+a[3]*b[3],
            a[4]*b[0]+a[5]*b[2]+b[4], a[4]*b[1]+a[5]*b[3]+b[5]]


def _group_rows(runs, body):
    """Group every run on the page (numbers included) into physical rows."""
    rs = sorted(runs, key=lambda r: (-r["y"], r["x"]))
    rows, cur = [], []
    for r in rs:
        if cur and abs(cur[-1]["y"] - r["y"]) > 0.12 * body:
            rows.append(cur); cur = []
        cur.append(r)
    if cur:
        rows.append(cur)
    out = []
    for grp in rows:
        grp.sort(key=lambda r: r["x"])
        cells = []
        for r in grp:
            t = re.sub(r"\.{2,}", " ", r["text"]).strip()
            if t:
                cells.append((r["x"], t))
        out.append({"y": grp[0]["y"],
                    "text": re.sub(r"\s+", " ", " ".join(c[1] for c in cells)).strip(),
                    "cells": cells})
    return out


def page_segments(page):
    raw = []
    def visit(text, cm, tm, font_dict, font_size):
        if not text or not text.strip():
            return
        m = _mul(tm, cm)
        raw.append((m, font_size or 0.0,
                    text.replace("\xa0", " ").replace("\n", " ")))
    try:
        page.extract_text(visitor_text=visit)
    except Exception as exc:
        return [], {"error": str(exc)}
    if not raw:
        return [], {"error": None, "blank": True}

    # Landscape tables (several recapitulations per volume) are set at 90 deg.
    # Work in the dominant reading direction of the page.
    angles = Counter(int(round(math.degrees(math.atan2(m[1], m[0])) / 90.0)) % 4
                     for m, _fs, _t in raw)
    quad = angles.most_common(1)[0][0]
    th = math.radians(90 * quad)
    cos, sin = math.cos(th), math.sin(th)

    runs = []
    for m, fs, text in raw:
        if int(round(math.degrees(math.atan2(m[1], m[0])) / 90.0)) % 4 != quad:
            continue                      # stray text in another direction
        X, Y = m[4], m[5]
        runs.append({"x":  cos * X + sin * Y,
                     "y": -sin * X + cos * Y,
                     "size": math.hypot(m[2], m[3]) * fs,
                     "text": text})
    if not runs:
        return [], {"error": None, "blank": True}

    sizes = [round(r["size"], 1) for r in runs if r["size"] >= 5]
    body = statistics.mode(sizes) if sizes else 8.0
    # Superscript footnote markers are set well below the body size; dropping
    # them is what stops a marker '1' from being read as part of '1,721,244'.
    # The one exception is a parenthesised reference standing in the vote
    # column in place of a count - that one has to be kept, as a blank.
    small = [r for r in runs if r["size"] < 0.7 * body]
    runs = [r for r in runs if r["size"] >= 0.7 * body]
    footnote_cells = [r for r in small if re.fullmatch(r"\(\d{1,3}\)", r["text"].strip())]
    marks = [r for r in small if re.fullmatch(r"\d{1,3}", r["text"].strip())]
    n_small = len(small) - len(footnote_cells)

    try:
        width = float(page.mediabox.width if quad % 2 == 0 else page.mediabox.height)
    except Exception:
        width = 612.0
    xs = [r["x"] for r in runs]
    left = min(xs)
    right_edge = left + 0.58 * (width - left)

    numbers, markers, textruns = [], [], []
    for r in footnote_cells:
        if r["x"] > right_edge:
            numbers.append((r["y"], r["x"], r["text"].strip()))
    for r in runs:
        t = r["text"].strip()
        core = re.sub(r"\.{2,}", "", t).strip()
        if core and NUMBER.match(core) and r["x"] > right_edge:
            numbers.append((r["y"], r["x"], core))
        elif re.fullmatch(r"\d{1,2}\.", t) and r["x"] < 0.25 * width:
            markers.append((r["y"], r["x"], t[:-1]))
        else:
            textruns.append(r)

    allrows = _group_rows(runs, body)
    textruns.sort(key=lambda r: (-r["y"], r["x"]))
    lines, cur = [], []
    for r in textruns:
        if cur and abs(cur[-1]["y"] - r["y"]) > 0.12 * body:
            lines.append(cur); cur = []
        cur.append(r)
    if cur:
        lines.append(cur)
    linerecs = []
    for grp in lines:
        grp.sort(key=lambda r: r["x"])
        txt = re.sub(r"\s+", " ", "".join(r["text"] for r in grp)).strip()
        linerecs.append({"y": grp[0]["y"], "x0": grp[0]["x"], "text": txt,
                         "size": max(r["size"] for r in grp)})

    def _is_recap_hdr(t):
        return t.lower().startswith("recapitulation of votes cast")

    def _is_state_hdr(line):
        if line["size"] < body + 1.0:
            return False
        base = re.sub(r"[\u2014-]{1,2}\s*(Continued|Cont'd\.?)\s*$", "",
                      line["text"]).strip(" .")
        u = base.upper()
        return u in STATES or re.sub(r"[^A-Z]", "", u) in STATES_FLAT

    cuts = sorted((l["y"] for l in linerecs
                   if _is_recap_hdr(l["text"]) or _is_state_hdr(l)),
                  reverse=True)
    bounds = [float("inf")] + cuts + [float("-inf")]
    segs = []
    for i in range(len(bounds) - 1):
        hi, lo = bounds[i], bounds[i + 1]
        sl = [l for l in linerecs if lo < l["y"] <= hi]
        segs.append({
            "marks":   [m for m in marks if lo < m["y"] <= hi],
            "is_recap": bool(sl) and _is_recap_hdr(sl[0]["text"]),
            "rows":    [r for r in allrows if lo < r["y"] <= hi],
            "lines":   sl,
            "numbers": [n for n in numbers if lo < n[0] <= hi],
            "markers": [m for m in markers if lo < m[0] <= hi],
            "body": body,
        })
    notes = []
    for m in marks:
        cand = [l for l in linerecs
                if abs(l["y"] - m["y"]) <= 0.8 * body and l["x0"] >= m["x"] - 1.0
                and len(l["text"]) > 40]
        if cand:
            notes.append({"marker": m["text"].strip(),
                          "text": min(cand, key=lambda l: l["x0"])["text"]})
    return segs, {"error": None, "footnotes": notes, "body": round(body, 2),
                  "dropped_superscripts": n_small, "quadrant": quad,
                  "n_lines": len(linerecs), "n_numbers": len(numbers)}


def pair_segment(seg):
    """Pair dot-leader labels with vote cells.  Returns (headers, entries, warn).

    entries: [(y, label_text, x0, votes_or_empty, note)]
    On any sign that the pairing is unsafe, every vote in the segment is
    returned EMPTY with a warning, rather than returning a wrong number.
    """
    body = seg["body"] or 8.0
    headers, labels = [], []
    for l in seg["lines"]:
        (labels if re.search(r"\.{3,}", l["text"]) else headers).append(l)
    labs = sorted(labels, key=lambda l: -l["y"])
    nums = sorted(seg["numbers"], key=lambda n: -n[0])
    blank = [(l["y"], l["text"], l["x0"], "", "") for l in labs]

    if not labs and not nums:
        return headers, [], ""
    if len(labs) != len(nums):
        return headers, blank, (f"{len(labs)} dot-leader rows vs {len(nums)} vote "
                                f"cells - votes left blank for this block")
    marked = set()
    marks = seg.get("marks", [])
    if marks and nums:
        best, hits = None, 0
        for mk in marks:
            for n in nums:
                d = mk["y"] - n[0]
                if abs(d) > 2.5 * body:
                    continue
                h = sum(1 for m2 in marks
                        if any(abs((m2["y"] - n2[0]) - d) <= 1.0 for n2 in nums))
                if h > hits:
                    best, hits = d, h
        if best is not None and hits == len(marks):
            for mk in marks:
                for n in nums:
                    if abs((mk["y"] - n[0]) - best) <= 1.0:
                        marked.add(round(n[0], 2))

    entries = []
    for l, n in zip(labs, nums):
        if abs(l["y"] - n[0]) > 1.6 * body:
            return headers, blank, (f"label/number drift at y={l['y']:.0f} "
                                    f"({l['text'][:40]!r} vs {n[2]})"
                                    f" - votes left blank for this block")
        raw = n[2]
        if raw.startswith("(") and raw.endswith(")"):
            entries.append((l["y"], l["text"], l["x0"], "",
                            f"footnote reference {raw}: no vote count printed"))
        else:
            note = ("carries a footnote marker - read the footnote before using "
                    "this figure") if round(n[0], 2) in marked else ""
            entries.append((l["y"], l["text"], l["x0"], raw.replace(",", ""), note))
    return headers, entries, ""


def clean(s):
    s = re.sub(r"\.{2,}", " ", s)
    return re.sub(r"\s+", " ", s).replace("’", "'").strip(" .—-")



RECAP_STUB = re.compile(r"""^(
      (?P<d>\d{1,2})(?:st|d|nd|rd|th)\s+district
    | at\s+large
    | senator
    | delegate | resident\s+commissioner
    | presidential\s+electors?
    | total
)\b""", re.I | re.X)


def _has_num(row):
    return any(re.fullmatch(r"[\d,]+", c[1]) for c in row["cells"])


def parse_recap(seg, pno, state):
    """Split a state's recapitulation into its panels and read each one.

    A wide recapitulation is printed as several stacked panels, each with its
    own "Title of candidate" header and its own set of party columns.  Only
    the panel that carries the Total column yields a usable figure, so the
    panels have to be read separately.
    """
    rows = seg["rows"]
    heads = [i for i, r in enumerate(rows)
             if re.match(r"^title of\b", clean(r["text"]), re.I)]
    if not heads:
        panels = [rows]
    else:
        starts = []
        for i in heads:
            j = i
            while (j > 0 and not _has_num(rows[j - 1])
                   and not RECAP_STUB.match(clean(rows[j - 1]["text"]))
                   and not rows[j - 1]["text"].lower().startswith("recapitulation")):
                j -= 1
            starts.append(j)
        starts = sorted(set(starts))
        panels = [rows[starts[k]: (starts[k + 1] if k + 1 < len(starts) else len(rows))]
                  for k in range(len(starts))]

    out, seen = [], {}
    for panel in panels:
        for rec in _recap_panel(panel, pno, state):
            key = (rec["office"], rec["dist"])
            if key in seen and seen[key] != rec["total"]:
                seen[key] = None              # panels disagree: trust neither
            elif key not in seen:
                seen[key] = rec["total"]
                out.append(rec)
    return [r for r in out if seen.get((r["office"], r["dist"])) is not None]


def _recap_panel(rows, pno, state):
    """Pull per-race Total figures out of a state's recapitulation table.

    Only a panel whose header row ends in "Total" is used: a recapitulation
    split across pages repeats the stub column but carries the Total column on
    its last panel only.

    In some volumes the stub ("3d district") and its figures share a baseline.
    In others the stub column is typeset on its own baselines, a constant
    fraction of a row away from the figures it labels.  The offset is measured
    from the leading run of district stubs and then applied to the rest of the
    table, so the pairing is derived from the page, not assumed.  If the offset
    is not consistent the table is skipped: a missing cross-check is safe, a
    wrong one is not.
    """
    if not any(re.search(r"\btotal\s*$", r["text"].strip(), re.I) and
               not re.search(r"\d", r["text"]) and len(r["cells"]) >= 2
               for r in rows):
        return []

    stubs, data, both = [], [], []
    for r in rows:
        nums = [c[1].replace(",", "") for c in r["cells"]
                if re.fullmatch(r"[\d,]+", c[1])]
        m = RECAP_STUB.match(clean(r["text"]))
        if m and nums:
            both.append((m, nums))
        elif m:
            stubs.append((r["y"], m))
        elif nums:
            data.append((r["y"], nums))

    out = []
    grand = {}

    def emit(m, nums):
        if m.group("d"):
            key = ("H", int(m.group("d")))
        else:
            lab = m.group(0).lower()
            if lab.startswith("at large"):
                key = ("H", 1)
            elif lab.startswith("senator"):
                key = ("S", None)
            elif lab.startswith(("delegate", "resident")):
                key = ("H", 0)
            elif lab.startswith("total"):
                grand["total"] = int(nums[-1])
                return
            else:
                return                       # Presidential electors
        out.append({"page": pno, "state": state, "office": key[0],
                    "dist": key[1], "total": int(nums[-1])})

    for m, nums in both:
        emit(m, nums)
    if not stubs or not data:
        return out

    stubs.sort(key=lambda t: -t[0])
    data.sort(key=lambda t: -t[0])

    pitch = abs(statistics.median([data[i][0] - data[i + 1][0]
                                   for i in range(len(data) - 1)])) if len(data) > 1 else 9.0

    # Measure the constant stub-to-figures offset from the page itself: try
    # every offset the table suggests and keep the one that lines every stub
    # up with a distinct row.  If none does, skip the table.
    best, best_hits = None, 0
    for ys, _m in stubs:
        for yd, _n in data:
            d = yd - ys
            if abs(d) > 1.2 * pitch:
                continue
            used, hits = set(), 0
            for ys2, _m2 in stubs:
                cand = [i for i, (yd2, _n2) in enumerate(data)
                        if abs(yd2 - ys2 - d) <= 0.35 * pitch and i not in used]
                if len(cand) == 1:
                    used.add(cand[0]); hits += 1
            if hits > best_hits:
                best, best_hits = d, hits
    # A stub with no figures at all (an uncontested race whose count the State
    # does not report) legitimately has no row, so allow a few gaps - but the
    # offset must still be corroborated by most of the table.
    if best is None or best_hits < 2 or best_hits < len(stubs) - 3:
        return out

    used = set()
    for ys, m in stubs:
        cand = [i for i, (yd, _n) in enumerate(data)
                if abs(yd - ys - best) <= 0.35 * pitch and i not in used]
        if len(cand) == 1:
            used.add(cand[0])
            emit(m, data[cand[0]][1])

    # Self-check: the House district totals we just read must add up to the
    # table's own "Total" line.  If they do not, this table was misread and is
    # dropped - the listing then simply goes out without a cross-check, rather
    # than being contradicted by a bad one.
    house = [r["total"] for r in out if r["office"] == "H"]
    if "total" in grand and house and sum(house) != grand["total"]:
        return [r for r in out if r["office"] != "H"]
    return out


# ---------------------------------------------------------------- parsing
def _row(page, state, office, dist, kind, name, party, votes, note, unexpired):
    return {"page": page, "state": state, "state_abb": STATES.get(state, ""),
            "office": office, "dist": dist, "kind": kind,
            "name_printed": name, "party_printed": party,
            "extra_parties": [], "extra_votes": [], "votes": votes,
            "unexpired_term_ending": unexpired, "hand_entry": "",
            "flags": ([note] if note else [])}


def parse(path):
    reader = PdfReader(path)
    rows, recap, problems, pages_meta, footnotes = [], [], [], [], []
    state = office = None
    dist = None
    unexpired = ""
    last_cand = None
    last_x = None

    for pno, page in enumerate(reader.pages, start=1):
        segs, meta = page_segments(page)
        meta["page"] = pno
        for note in meta.pop("footnotes", []) or []:
            footnotes.append({"page": pno, "state": state,
                              "marker": note["marker"], "text": note["text"]})
        pages_meta.append(meta)
        if meta.get("error"):
            problems.append({"level": "ERROR", "page": pno,
                             "msg": f"page unreadable: {meta['error']}"})
            continue
        if not segs:
            continue

        page_text = " ".join(l["text"] for s in segs for l in s["lines"])
        if re.search(r"Recapitulation of Votes Cast for ", page_text) or \
           re.search(r"Political Divisions of the U\.S\. Senate", page_text) or \
           re.search(r"Electoral Votes for President and Vice President", page_text):
            state = office = None
            continue
        # National summary tables: a 'State | Republican | Democratic ...' header
        if re.search(r"\bState\s+Republican\s+Democratic\b", page_text):
            state = office = None
            continue

        for seg in segs:
            if seg["is_recap"]:
                got = parse_recap(seg, pno, state)
                if not got:
                    problems.append({"level": "INFO", "page": pno,
                                     "msg": f"recapitulation panel for {state} not "
                                            f"usable as a cross-check"})
                recap.extend(got)
                last_cand = None
                office = None
                continue

            headers, entries, warn = pair_segment(seg)
            if warn:
                problems.append({"level": "WARN", "page": pno, "msg": warn})

            # The district number "12." is printed to the left of the first
            # candidate of the block, but its baseline does not always match
            # that candidate's.  Attach each marker to the nearest entry.
            dist_at = {}
            body_h = seg["body"] or 8.0
            for my, mx, mnum in seg["markers"]:
                near = [e for e in entries if abs(e[0] - my) <= 1.6 * body_h]
                if not near:
                    continue
                best = min(near, key=lambda e: (abs(e[0] - my), -e[0]))
                dist_at[round(best[0], 2)] = int(mnum)

            items = ([("H", h["y"], h) for h in headers] +
                     [("E", e[0], e) for e in entries])
            items.sort(key=lambda t: -t[1])

            for kind, y, obj in items:
                if kind == "H":
                    t = obj["text"]
                    base = re.sub(r"[—-]{1,2}\s*(Continued|Cont'd\.?)\s*$", "", t).strip(" .")
                    up = base.upper()
                    flat = re.sub(r"[^A-Z]", "", up)
                    if up not in STATES and flat in STATES_FLAT:
                        up = STATES_FLAT[flat]
                    if up not in OFFICE_HDR and flat in OFFICE_FLAT:
                        up = OFFICE_FLAT[flat]
                    if flat == "ATLARGE":
                        up = "AT LARGE"
                    if up in STATES and obj["size"] < seg["body"] + 1.0:
                        continue          # state name inside a table heading
                    if up in STATES:
                        state, office, dist, last_cand = up, None, None, None
                        unexpired = ""
                    elif up in OFFICE_HDR:
                        office = OFFICE_HDR[up]
                        dist = 0 if up in ("FOR DELEGATE", "FOR RESIDENT COMMISSIONER") else None
                        last_cand = None
                        unexpired = ""
                    elif up == "AT LARGE":
                        if office == "H":
                            dist = 1
                    else:
                        m = re.match(r"^\(For unexpired term ending "
                                     r"January 3, (\d{4})\)$", base)
                        if m:
                            unexpired = m.group(1)
                        elif re.match(r"^\(For (the )?full term", base, re.I):
                            unexpired = ""
                    continue

                _y, label, x0, votes, note = obj
                label = clean(label)
                if not label or state is None or office is None:
                    continue
                marked = dist_at.get(round(_y, 2))
                if marked is not None and office == "H":
                    dist = marked
                    last_cand = None

                if office == "P":
                    rows.append(_row(pno, state, "P", None, "party-line",
                                     "", label, votes, note, unexpired))
                    continue

                if NONCANDIDATE.match(label):
                    rows.append(_row(pno, state, office, dist, "non-candidate",
                                     "", label, votes, note, unexpired))
                    continue

                # fusion continuation: bare party name, indented past the name column
                if last_cand is not None and last_x is not None and x0 > last_x + 4:
                    last_cand["extra_parties"].append(label)
                    last_cand["extra_votes"].append(votes)
                    if note:
                        last_cand["flags"].append(f"cross-endorsement '{label}': {note}")
                    elif not votes:
                        last_cand["flags"].append(f"cross-endorsement '{label}': no vote cell")
                    continue

                # "First Last, Party" - but a line can carry a suffix
                # ("Michael J. LiPetri, Jr., Republican") and Vermont prints
                # cross-endorsements inline ("Mark Coester, Republican,
                # Libertarian"), so split on every comma and keep only a
                # trailing suffix with the name.
                parts = [x.strip() for x in label.split(",")]
                k = 1
                while k < len(parts) and SUFFIX.match(parts[k]):
                    k += 1
                if k < len(parts):
                    name = ", ".join(parts[:k])
                    party = ", ".join(parts[k:])
                else:
                    name, party = label, ""
                rec = _row(pno, state, office, dist, "candidate", name, party,
                           votes, note, unexpired)
                if not party:
                    rec["flags"].append("label is neither 'Name, Party' nor a known "
                                        "ballot-line label - classify by hand")
                if not votes and not note:
                    rec["flags"].append("no vote cell found on this line")
                rows.append(rec)
                last_cand, last_x = rec, x0

    return rows, recap, problems, pages_meta, footnotes


# ------------------------------------------------------------- validation
def _mark(row, reason):
    """Record a reason this row has to be hand-entered.  Reasons accumulate:
    a Georgia Senate special that also went to a runoff is both."""
    have = [x for x in row.get("hand_entry", "").split("; ") if x]
    if reason not in have:
        have.append(reason)
    row["hand_entry"] = "; ".join(have)


def validate(rows, recap, problems):
    by_race = defaultdict(list)
    for r in rows:
        if r["office"] == "P" or not r["state_abb"]:
            continue
        by_race[(r["state_abb"], r["office"], r["dist"])].append(r)

    lookup = {}
    for rc in recap:
        lookup[(STATES.get(rc["state"], ""), rc["office"], rc["dist"])] = rc["total"]

    checked = matched = 0
    for key, rs in sorted(by_race.items(), key=str):
        exp = lookup.get(key)
        if exp is None and key[1] == "S":
            exp = lookup.get((key[0], "S", None))
        total, complete = 0, True
        for r in rs:
            for v in [r["votes"]] + r["extra_votes"]:
                if v == "":
                    complete = False
                else:
                    total += int(v)
        if exp is None:
            problems.append({"level": "WARN", "race": key,
                             "msg": "no recapitulation total available to cross-check"})
            for r in rs:
                r["flags"].append("UNVERIFIED: no recapitulation cross-check")
            continue
        if not complete:
            problems.append({"level": "WARN", "race": key,
                             "msg": f"at least one vote missing; partial sum {total} "
                                    f"vs recapitulation {exp}"})
            continue
        checked += 1
        if total == exp:
            matched += 1
        else:
            problems.append({"level": "ERROR", "race": key,
                             "msg": f"printed lines sum to {total} but the "
                                    f"recapitulation says {exp}"})
            for r in rs:
                r["flags"].append(f"RACE SUM MISMATCH: parsed {total} vs recap {exp}")

    # Runoff and special-election results are hand-entered into CAGE, not taken
    # from this volume, so mark those rows instead of letting them flow into an
    # append.  In a majority-rule State a plurality leader means the seat was
    # decided later, in a runoff this volume does not contain.
    for key, rs in by_race.items():
        cands = [r for r in rs if r["kind"] == "candidate"]
        if key[0] in MAJORITY_RULE and cands:
            tally = []
            for r in cands:
                vs = [r["votes"]] + r["extra_votes"]
                tally.append(sum(int(v) for v in vs if v) if all(vs) else None)
            if all(t is not None for t in tally) and sum(tally) > 0:
                if max(tally) * 2 <= sum(tally):
                    for r in rs:
                        _mark(r, "runoff expected")
                        r["flags"].append(
                            f"NO MAJORITY in a runoff State ({key[0]}): this volume "
                            f"holds the first round only - hand-enter the runoff")
                    problems.append({"level": "WARN", "race": key,
                                     "msg": "no candidate reached a majority in a "
                                            "runoff State; hand-enter the runoff result"})
    for r in rows:
        if r["unexpired_term_ending"]:
            _mark(r, "special election")
        if any("footnote marker" in f for f in r["flags"]):
            _mark(r, "footnote - check which round this is")

    seen = {r["state_abb"] for r in rows if r["state_abb"]}
    for miss in sorted(FIFTY - seen):
        problems.append({"level": "ERROR", "state": miss,
                         "msg": "state never appeared in the parse"})
    return checked, matched


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("pdf")
    ap.add_argument("year", type=int)
    ap.add_argument("-o", "--out", default="clerk_raw.csv")
    ap.add_argument("--report", default="clerk_report.json")
    a = ap.parse_args()

    rows, recap, problems, pages_meta, footnotes = parse(a.pdf)
    checked, matched = validate(rows, recap, problems)

    with open(a.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["year","state","state_abb","office","dist","kind","name_printed",
                    "party_printed","extra_parties","candidatevotes","extra_votes",
                    "unexpired_term_ending","hand_entry","page","flags"])
        for r in rows:
            w.writerow([a.year, r["state"], r["state_abb"], r["office"],
                        "" if r["dist"] is None else r["dist"], r["kind"],
                        r["name_printed"], r["party_printed"],
                        "; ".join(r["extra_parties"]), r["votes"],
                        "; ".join(r["extra_votes"]), r["unexpired_term_ending"],
                        r.get("hand_entry", ""), r["page"], " | ".join(r["flags"])])

    hand = [r for r in rows if r.get("hand_entry")]
    hand_path = a.out.rsplit(".", 1)[0] + "_hand_entry.csv"
    with open(hand_path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["state_abb", "office", "dist", "reason", "name_printed",
                    "party_printed", "first_round_votes", "page"])
        for r in hand:
            w.writerow([r["state_abb"], r["office"],
                        "" if r["dist"] is None else r["dist"], r["hand_entry"],
                        r["name_printed"], r["party_printed"], r["votes"], r["page"]])

    fn_path = a.out.rsplit(".", 1)[0] + "_footnotes.csv"
    with open(fn_path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["page", "state", "marker", "text"])
        for f in footnotes:
            w.writerow([f["page"], f["state"], f["marker"], f["text"]])

    json.dump({"pdf": a.pdf, "year": a.year, "rows": len(rows),
               "footnotes": footnotes,
               "races_cross_checked": checked, "races_matching_recap": matched,
               "problems": problems, "pages": pages_meta},
              open(a.report, "w"), indent=1, default=str)
    errs = sum(1 for p in problems if p["level"] == "ERROR")
    print(f"rows={len(rows)}  races cross-checked={checked} matched={matched}  "
          f"problems={len(problems)} (errors={errs})  "
          f"rows needing hand entry={len(hand)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
