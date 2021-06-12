# Candidate and Official Election Results for Federal and Statewide elections, 2006-2020

---------

<!-- badges: start -->
<!-- badges: end -->

The goal of cces_candidates is to serve as a standardized interface for U.S. candidate metadata with a particular application to merging with the CES / CCES


## Candidate Data Format


## Candidate Data Requirements

### Office (`office`)

|Code:|Office | 
|-----|-------|
|P | President |
|S | U.S. Senate |
|H | U.S. House | 
|G | Governor | 


### Election Year

`year` stands in for the year of the general election cycle. Unless otherwise noted `2016` indicates the 2016 General election in November. Odd-year general elections in VA and NJ are noted by their odd year. Run-off elections that go on till January, for example in the Georgia Senate runoffs, are *still* coded as 2020.

### State and State codes

The variable `st` refers to the two letter code given by R's `state.abb` and the variable `state` is the spelled out name given by R's `state.name`.

|`st` | `state` | 
|-----|---------|
|`"AK"` |`"Alaska"` | 
|`"WY"` | `"Wyoming"`|


### District and Senate Class (`dist`)

A number for the Congressional district for the House. For the Senate, the **Senate class** of the election. For Governor and statewide executives, this should be left blank.

The Senate class is important for distinguishing different seats in the same year when a off-cycle seat is up due to a special election.

| year | office | st| dist | special | winner |
|----|--|--|--|--|---------------|
|2020|S|GA| 2|0| OSSOFF, JON |
|2020|S|GA|3|1|WARNOCK, RAPHAEL |
|2016|S|GA|3|0|ISAKOSN, JOHNNY |
|2014|S|GA|2|0|PERDUE, DAVID|

(there is no class 1 Senate seat in Georgia)

### Congressional Districts (`cd`)

`cd` refers to the State - Congressional district number combination, combined with a hyphen. Single-digit districts must have a leading zero. At-large states should be numbered `01` instead of `00` or `-AL`. For example:

- `CA-34`: California's 34th Congressional district
- `CA-01`: California's 1st Congressional district (leading 0)
- `AK-01`: Alaska's at large Congressional district 


### Candidate Names 

Standardized candidate name from James Snyder.  The syntax is `[Last name], [First Name] [Middle name] ([Nickname]), [Jr/Sr/I/II/III]`.  Some examples of names are below, to give a sense of the syntax.
 

- `SEWELL, TERRYCINA ANDREA (TERRI)`: commonly known as Terri Sewell (AL)
- `GRASSLEY, CHARLES ERNEST (CHUCK)`: commonly known as Chuck Grassley (IA)
- `CORNYN, JOHN, III`: commonly known as John Cornyn (TX)
- `KENNEDY, JOSEPH P. (JOE), III`: commonly known as Joe Kennedy (MA)
- `WASSERMAN SCHULTZ, DEBBIE`: note the last name is not hyphenated and is two words

It is important to spell out nicknames and distinguish between hyphenated last names wherever possible, to merge across datasets. 

### Incumbency (`inc`)

Determine incumbency based on prior election results for the same office including all special elections. District numberings do not matter; Conor Lamb who won a special election to PA-18 in March 2018 is still an incumbent when he ran in November 2018 for the re-drawn PA-17. The codes are

|Code | Description|
|-----|------------|
| 0 | not an incumbent for that office|
| 1 | regular incumbent|
| 2 | incumbent who won in special election|
| 3 | incumbent who was appointed (US senate)|


## Party affiliation

Democrats are coded as `"D"`, Republicans as `"D"`. Libertarians coded as `"Lbt"`, Green party as `"Grn"`.

There are several regional and idiosyncratic party names. 

- The Minnesota DFL (Democratic–Farmer–Labor Party) are coded as `"D"`
- The North Dakota NPL (Nonpartisan League Party) are coded as `"D"`
- The Working Families Parties endorses candidates in New York, Connecticut, South Carolina, and .... that appear on the ballot. Determine the primary party affiliation and code D-WFP cross-listed or fusion candidates as `"D"`.

Write-in votes, when officially reported, are coded ____.


### Election outcome (`won`)

1 if the candidate won the election, 0 otherwise. For President, 1 if the candidate won the electoral college votes in that _state_, rather than the office. 

### Vote count (`votes`)

The official number of votes (instead of the voteshare). An integer. 

##  Related Datasets and Data Sources

- The Clerk of the House [Official Election Returns](https://history.house.gov/Institution/Election-Statistics/) is the authoritative source for vote counts and party affiliations for `P`, `S`, `H`.  It does not include `inc` or the standardized name.
- The MIT Election Data Science Lab [Dataverse](https://dataverse.harvard.edu/dataverse/medsl_election_returns) compiles this Clerk information in csv [`P`](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/PEJ5QU), [`S`](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/PEJ5QU), [`H`](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/IG0UN2) (only till 2018 as of June 2021). It has information on special elections but not `inc`. 
- State executive offices (`G`, Secretary of State, AG, etc..) are taken from official statements of the vote of the Secretary of State. I have collected the list of URLs for each state at [`sec-state_statement-of-votes.csv`](links/sec-state_statement-of-votes.csv)