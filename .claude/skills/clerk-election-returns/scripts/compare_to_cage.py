#!/usr/bin/env python3
"""Regression check: compare an extracted Clerk volume against released CAGE.

Run this on a year CAGE already covers (2016-2024) before trusting a run on a
new year.  Every difference it prints is either a CAGE convention or an
extraction bug, and you should be able to name which.

    python3 compare_to_cage.py clerk_raw_2024.csv candidates_2006-2024.tab 2024

The CAGE tab file comes from
https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/DGDRDT
"""
import argparse, collections, csv


def load_clerk(path):
    races = collections.defaultdict(list)
    for r in csv.DictReader(open(path)):
        if r["kind"] != "candidate" or r["office"] not in ("H", "S"):
            continue
        if r["unexpired_term_ending"] or not r["state_abb"]:
            continue                      # specials are keyed differently
        votes, complete = 0, True
        for v in [r["candidatevotes"]] + [x for x in r["extra_votes"].split("; ") if x]:
            if v:
                votes += int(v)
            else:
                complete = False
        dist = "" if r["office"] == "S" else r["dist"]
        races[(r["state_abb"], r["office"], dist)].append(
            (r["name_printed"], votes if complete else None))
    return races


def load_cage(path, year):
    races = collections.defaultdict(list)
    for line in open(path):
        f = line.rstrip("\n").split("\t")
        if f[0] != f"{year}.0" or f[4].strip('"') != "G":
            continue
        office = f[2].strip('"')
        if office not in ("H", "S"):
            continue
        dist = "" if office == "S" else (str(int(float(f[3]))) if f[3] else "")
        races[(f[1].strip('"'), office, dist)].append(
            (f[8].strip('"'), int(float(f[10])) if f[10] else None))
    return races


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("clerk_raw_csv")
    ap.add_argument("cage_tab")
    ap.add_argument("year", type=int)
    a = ap.parse_args()

    clerk, cage = load_clerk(a.clerk_raw_csv), load_cage(a.cage_tab, a.year)
    only_cage = sorted(set(cage) - set(clerk), key=str)
    only_clerk = sorted(set(clerk) - set(cage), key=str)

    print(f"races: clerk={len(clerk)} cage={len(cage)}")
    print(f"missing from the clerk extraction ({len(only_cage)}): {only_cage}")
    print(f"in the clerk volume only ({len(only_clerk)}): {only_clerk}")
    print("  (delegates and the Resident Commissioner are expected here)")

    diffs = 0
    for key in sorted(set(clerk) & set(cage), key=str):
        got = sorted(v for _, v in clerk[key] if v is not None)
        want = sorted(v for _, v in cage[key] if v is not None)
        if got != want:
            diffs += 1
            print(f"  {key}: clerk={got}")
            print(f"  {' ' * len(str(key))}  cage ={want}")
    print(f"vote differences: {diffs}")
    return 1 if only_cage else 0


if __name__ == "__main__":
    raise SystemExit(main())
