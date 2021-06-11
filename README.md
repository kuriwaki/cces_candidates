
# cces_candidates

<!-- badges: start -->
<!-- badges: end -->

The goal of cces_candidates is to serve as a standardized interface for U.S. candidate metadata with a particular application to merging with the CES / CCES


# Candidate Data Format


# Candidate Data Requirements

## Office (`office`)

|Code:|Office | 
|-----|-------|
|P | President |
|S | U.S. Senate |
|H | U.S. House | 
|G | Governor | 


## State and State codes

The variable `st` refers to the two letter code given by R's `state.abb` and the variable `state` is the spelled out name given by R's `state.name`.

|`st` | `state` | 
|-----|---------|
|`"AK"` |`"Alaska"` | 
|`"WY"` | `"Wyoming"`|




## Congressional Districts (`cd`)

`cd` refers to the State - Congressional district number combination, combined with a hyphen. Single-digit districts must have a leading zero. At-large states should be numbered `01` instead of `00` or `-AL`. For example:

- `CA-34`: California's 34th Congressional district
- `CA-01`: California's 1st Congressional district (leading 0)
- `AK-01`: Alaska's at large Congressional district 


## Candidate Names 

Standardized candidate name from James Snyder.  The syntax is `[Last name], [First Name] [Middle name] ([Nickname]), [Jr/Sr/I/II/III]`.  Some examples of names are below, to give a sense of the syntax.
 

- `SEWELL, TERRYCINA ANDREA (TERRI)`: commonly known as Terri Sewell (AL)
- `GRASSLEY, CHARLES ERNEST (CHUCK)`: commonly known as Chuck Grassley (IA)
- `CORNYN, JOHN, III`: commonly known as John Cornyn (TX)
- `KENNEDY, JOSEPH P. (JOE), III`: commonly known as Joe Kennedy (MA)
- `WASSERMAN SCHULTZ, DEBBIE`: note the last name is not hyphenated and is two words

It is important to spell out nicknames and distinguish between hyphenated last names wherever possible, to merge across datasets. 

## Incumbency (`inc`)

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


## Election outcome (`won`)


## Vote count (`won`)
# Related Datasets and Data Sources