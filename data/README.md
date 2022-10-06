# README for data folder


## `candidates_key.RData`

`candidates_key.RData` is an intermediate output from <https://github.com/kuriwaki/cces_cumulative>.

It is currently 46MB so it is not tracked on .git.

It is a bundle (rda) of three items

- `rc_key` (for House rep candidates)
- `sc_key` (for Senate candidates)
- `gc_key` (for Governor candidates)


It looks like

```
> rc_key |> select(year, case_id, st, dist, cand, name, party)
# A tibble: 2,580,768 x 7
    year case_id st     dist  cand name                 party
   <dbl>   <dbl> <chr> <int> <int> <chr>                <chr>
 1  2006  439219 NC       10     1 Richard C. Carsner   D
 2  2006  439219 NC       10     2 Patrick T. McHenry   R
 3  2006  439219 NC       10     3 NA                   NA
 4  2006  439224 OH        3     1 Stephanie Studebaker D
 5  2006  439224 OH        3     2 Michael R. Turner    R
 6  2006  439224 OH        3     3 NA                   NA
 7  2006  439228 NJ        1     1 Robert E. Andrews    D
 8  2006  439228 NJ        1     2 NA                   NA
 9  2006  439228 NJ        1     3 NA                   NA
10  2006  439237 IL        9     1 Janice D. Schakowsky D
# … with 2,580,758 more rows
```

so one row is a candidate x CCES respondent. `cand` is the number of the candidate
in the CCES question.

The purpose of this table / key is to link the `case_id` and `cand`  combination to
metadata about the candidate, specifically the name and party, within the CCES
cumualtive file.
