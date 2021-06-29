# Candidate and Official Election Results for Federal and Statewide elections, 2006-2020

Shiro Kuriwaki

<!-- badges: start -->
<!-- badges: end -->

The goal of cces_candidates is to serve as a standardized interface for U.S. candidate metadata with a particular application to merging with the CES / CCES.

Although these data formally only cover 2006 and onwards, the coding rules are written so that they are mostly consistent with a historical database mainly constructed by Jim Snyder.



## Candidate Data Format


Candidate data is stored in "long" (as opposed to wide) format, with each row representing a candidate in a particular race. Each row is represented by `office`, `state`, `dist`,  and `candidatename`.


A combination of `state` and `candidatename` uniquely identifies a candidate. Note that we do not use `office` or `party` here, because that can change across time. For example, House members run to become Senators, and in rare occasions candidates change their party (e.g. Charlie Crist, Kyrsten Sinema).



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

### Special Elections and Runoff Elections

A "normal" special election, when an incumbent retires or dies before their term is up, can be listed as `1`. A general election that happens on the first Tuesday of November for a seat where the term is up is listed as `0`.


"[T]wo states --- Georgia and Louisiana --- require runoff elections in a general election when no candidate receives a majority of the vote. In every other state, a candidate can win a general election with a plurality of the vote." (Ballotpedia).  

Several corner cases are worth enumerating:

In **Louisiana** for Non-Presidential elections, starting from 1977, there is a jungle primary in the first **November election**, when all 49 states have their general elections ([Ballotpedia](https://ballotpedia.org/Jungle_primary)).  Unless a candidate wins with the majority of the vote, the top two candidates go to a runoff often in December. I am still deliberating how to code this. 

- For example in November 2014, neither Bill Cassidy (R) and incumbent Mary Landrieu (D) got a majority in the first round, with 5 other Democrat or Republican candidates on the ballot. A runoff was held in December with the two candidates and Cassidy won with 55 percent of the vote. In 2020, Cassidy won 59 percent of the jungle primary vote and won re-election outright.

We code these as `type = G` or `type = R` for the runoff (if applicable), and treat these as separate rows. We check the Clerk and state SOS results for those elections.


### Candidate Names (`candidatename`) 

Standardized candidate name following Jim Snyder's coding rules. The specifics of this variable are important for overtime tracking because __name and state uniquely identify a unique person__ across all his Congressional candidate data (at least 1950 to the present). The syntax is 

`[Last name], [First Name] [Middle name] ([Nickname]), [Jr./Sr./I/II/III]`


For example:

- `SEWELL, TERRYCINA ANDREA (TERRI)`: commonly known as Terri Sewell (AL)
- `GRASSLEY, CHARLES ERNEST (CHUCK)`: commonly known as Chuck Grassley (IA)
- `CORNYN, JOHN, III`: commonly known as John Cornyn (TX)
- `KENNEDY, JOSEPH P. (JOE), III`: commonly known as Joe Kennedy (MA)
- `KELLY, GEORGE J. (MIKE), JR.`, commonly known as Mike Kelly (PA). Note the use of periods for abbreviation and comma before the JR.
- `WASSERMAN SCHULTZ, DEBBIE`: note the last name is not hyphenated and is two words
- `JACKSON LEE, SHEILA`: note that the last name is not Lee, so we use this instead of "LEE, SHEILA JACKSON"


Note that these names are *different* from other official names (1) on the ballot, (2) on the Clerk of the House report, or the (3) FEC. Any of these sources can disagree on the formatting of the names or whether to abbreviate a middle name. 

The Snyder formalization solves some shortcomings in the official data above. Candidates may report different style names in the ballot vs. the FEC (e.g. ____) or they may have multiple FEC IDs at the same time (e.g. _____). More commonly, a House representative who then runs for higher office like Senate will often get a separate FEC ID, even though they are the same person (e.g. ____). In theses cases, the Snyder formalization of ID'ing people by their full name and state is the most reliable. 

Therefore, it is important in our formalizatioon to spell out nicknames and distinguish between hyphenated last names to the extent that it uniquely identifies a person within a state. The same person's name should be formatted exactly the same way, and conversely, two different people with near-identical last names should somehow be given **different** names. For example, if a John Smith ran for Congress in 1980  in Ohio and then a *separate, unrelated* John Smith ran again in Ohio in 2020. Then to distinguish the two different people, we would need to find _something_ like a middle name or suffix to distinguish the name in characters.

One shortcoming of the Snyder formalization is that it may be __too__ rigid. Whether or not something is abbreviated can be determined on a coding rule decided early on. If a person's name changes, e.g. through marriage or divorce, the old name must be kept. For example:


* `BIDEN, JOSEPH R., JR.` has his middle name abbreviated, even though it is known (Robinette).
* `MACK, MARY BONO` (R-CA, 1998-2012) married to Connie Mack IV (R-FL, 2001-2003) during 2007-2013. They separated in 2013 and now goes by Mary Bono, but in the data she will be coded by the above name. 

### Incumbency (`inc`)

Determine incumbency based on prior election results for the same office including all special elections. District numberings do not matter; Conor Lamb who won a special election to PA-18 in March 2018 is still an incumbent when he ran in November 2018 for the re-drawn PA-17. The codes are

|Code | Description|
|-----|------------|
| 0 | not an incumbent for that office|
| 1 | regular incumbent|
| 2 | incumbent who won in special election|
| 3 | incumbent who was appointed (US senate)|


### Party affiliation

Democrats are coded as `"D"`, Republicans as `"D"`. Libertarians coded as `"Lbt"`, Green party as `"Grn"`.

There are several regional and idiosyncratic party names. 

- The Minnesota DFL (Democratic–Farmer–Labor Party) are coded as `"D"`
- The North Dakota NPL (Nonpartisan League Party) are coded as `"D"`
- The Working Families Parties endorses candidates in New York, Connecticut, South Carolina, and .... that appear on the ballot. Determine the primary party affiliation and code D-WFP cross-listed or fusion candidates as `"D"`.

Write-in votes, when officially reported, are coded ____.


### Election outcome (`won`)

1 if the candidate won that race, 0 otherwise. For President, 1 if the candidate won the electoral college votes in that _state_, rather than the office. 

If the election was effectively a primary or a race where no one candidate won outright (and a runoff was held later), then the winner of that first stage election gets a value of ___.


### Vote count (`candidatevotes`)

The official number of votes (instead of the voteshare). An integer.

For candidates running on multiple party tickets, this will be the _sum_ of all of their votes.  For example, in 2016, Rep. Rosa L. DeLauro (CT-03) ran as a Democrat and also ran as a Working Families Party candidate. She won 192,274 votes in the former and 21,298 votes in the latter, so her `candidatevotes` is the total, 213,572.


In some states, notably Florida, if a congressional district is uncontested by one of the major parties, the winner's vote count is __not reported__ by the Secretary of State. Votes here should be listed as blank.

##  Related Datasets and Data Sources

- The Clerk of the House [Official Election Returns](https://history.house.gov/Institution/Election-Statistics/) is the authoritative source for vote counts and party affiliations for `P`, `S`, `H`.  It does not include `inc` or the standardized name.
- The MIT Election Data Science Lab [Dataverse](https://dataverse.harvard.edu/dataverse/medsl_election_returns) compiles this Clerk information in csv [`P`](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/PEJ5QU), [`S`](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/PEJ5QU), [`H`](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/IG0UN2) (only till 2018 as of June 2021). It has information on special elections but not `inc`. 
- State executive offices (`G`, Secretary of State, AG, etc..) are taken from official statements of the vote of the Secretary of State. I have collected the list of URLs for each state at [`sec-state_statement-of-votes.csv`](links/sec-state_statement-of-votes.csv)
