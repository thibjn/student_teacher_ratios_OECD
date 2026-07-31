# Student-Teacher Ratios in the OECD

An empirical analysis of how student-teacher ratios differ between public and private institutions in primary and lower secondary education across OECD countries, and how they evolved between 2015 and 2023.

## Research question

> How do student-teacher ratios differ between public and private institutions in primary and lower secondary education, and how have these ratios evolved between 2015 and 2023?

## Data

Source: [OECD Data Explorer — Non-financial personnel statistics](https://data-explorer.oecd.org/vis?pg=0&isAvailabilityDisabled=false&fs[0]=Topic,1%7CEducation%20and%20skills%23EDU%23%7CTeachers%23EDU_TEA%23&fc=Topic&bp=true&snb=45&vw=tb&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_EAG_UOE_NON_FIN_PERS%40DF_UOE_NF_PERS_STR&df[ag]=OECD.EDU.IMEP&df[vs]=1.0&dq=AUS%2BAUT%2BBEL%2BCAN%2BCHL%2BCRI%2BCZE%2BDNK%2BEST%2BFIN%2BFRA%2BDEU%2BGRC%2BHUN%2BISL%2BIRL%2BISR%2BITA%2BJPN%2BKOR%2BLVA%2BLTU%2BLUX%2BMEX%2BNLD%2BNZL%2BNOR%2BPOL%2BPRT%2BSVK%2BSVN%2BESP%2BSWE%2BCHE%2BTUR%2BGBR%2BUSA%2BG20%2BEU25%2BOECD.ISCED11_1%2BISCED11_2......A...INST_EDU%2BINST_EDU_PUB%2BINST_EDU_PRIV..._T.&pd=2015,2023&to[TIME_PERIOD]=false), dataset `DSD_EAG_UOE_NON_FIN_PERS`.

- **Pulled:** 17 April 2026, directly from the OECD SDMX API.
- **Coverage:** primary and lower secondary education, 2015–2023.
- **Institution types:** all institutions, public, private.
- **Countries:** all OECD members plus G20/EU25/OECD aggregates.

The pipeline queries the OECD API directly rather than working from a static downloaded file. This means re-running the script pulls the latest data OECD has published for this series, so the analysis can be refreshed as new years become available.

**Missing data rule.** Each country should have 54 observations (9 years × 2 education levels × 3 institution types). Countries with fewer than 48 observations (i.e. more than ~10% missing) were dropped from the analysis; countries above that threshold were kept as-is.

## Repository contents

| File | Description |
|---|---|
| `student_teacher_ratios_oecd.R` | Full analysis pipeline: data pull, cleaning, filtering, chart, and summary table |
| `student_teacher_ratios_oecd_chart.png` | OECD-level student-teacher ratio trend, 2015–2023, by institution type and education level |
| `student_teacher_ratios_oecd_table.csv` | Country-level summary table: 2023 ratios by institution type and level, plus change since 2015 |

## Method

1. Pull raw data from the OECD SDMX endpoint (`read_csv` on the API URL, no manual download).
2. Select and rename the relevant fields (country, year, education level, institution type, ratio).
3. Keep individual countries alongside the `G20`, `EU25`, and `OECD` group aggregates throughout, so the comparison table reflects both country-level and aggregate-level positions.
4. Drop countries with fewer than 48 of 54 possible observations (year × education level × institution type), as the missing-data share is too high to treat the series as reliable.
5. Build a faceted line chart (OECD aggregate only) showing ratio trends by institution type, split by education level.
6. Build a country-level wide table for 2023, with year-on-year change since 2015, sorted by change in lower secondary ratios.

Built with `tidyverse` in R.

## Key findings

- Student-teacher ratios are consistently higher in primary education than in lower secondary education throughout the period.
- Primary education ratios declined steadily, from just above 15 in 2015 to around 13.5 in 2023. Lower secondary shows no clear trend — it hovers around 12–13 with more short-term fluctuation.
- Public institutions have somewhat higher ratios than private institutions at both levels; the gap is modest and narrows slightly over time, especially in primary education.
- Cross-country variation is large: primary ratios range from under 10 (e.g. Luxembourg, Iceland) to over 20 (Mexico); lower secondary ranges from under 10 (e.g. Portugal, Norway) to over 30 (Mexico). These differences suggest that education systems allocate teaching resources very differently across countries.
- Country-level trends are not uniform: some countries improved substantially, others (e.g. United Kingdom, Latvia) saw ratios rise, and a few (e.g. Lithuania) moved sharply in both education levels. This heterogeneity suggests that adjustments in teaching resources have not been uniform across countries.

## Conclusion

- Overall, the results point to a gradual reduction in student-teacher ratios in primary education at the OECD level, alongside more stable patterns in lower secondary education.
- At the same time, substantial cross-country differences persist, both in levels and in trends, reflecting diverse institutional settings and policy choices in the allocation of educational resources.

## Excluded countries

Countries with fewer than 48 of 54 possible observations (year × education level × institution type) are dropped before analysis, as the missing-data share is too high to treat the series as reliable. Based on the 17 April 2026 data pull, the excluded countries are:

**Switzerland, Ireland, Australia, Canada, Greece, Slovenia.**

All other OECD countries, plus the G20/EU25/OECD aggregates, are retained.

## Requirements

- R (≥ 4.0)
- `tidyverse`

```r
install.packages("tidyverse")
```

## Running the analysis

Open `student_teacher_ratios_oecd.R` in RStudio and run it top to bottom, or from the command line:

```r
source("student_teacher_ratios_oecd.R")
```

This will re-pull the latest data from the OECD API and regenerate the chart and table outputs — note results may differ slightly from those in this repo if OECD has revised the series since 17 April 2026.

## Author

Thibault Jannin
