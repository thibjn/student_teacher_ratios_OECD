# =========================================================
# Student Teacher Ratios OECD Countries
# =========================================================

# Load packages
library(tidyverse)

# -------------------------
# Download data from the OECD API
# -------------------------
# The query extracts student-teacher ratios for:
# - OECD countries and aggregates
# - primary and lower secondary education
# - all, public and private educational institutions
# - years 2015 to 2023
url <- paste0(
  "https://sdmx.oecd.org/public/rest/data/",
  "OECD.EDU.IMEP,DSD_EAG_UOE_NON_FIN_PERS@DF_UOE_NF_PERS_STR,1.0/",
  "AUS+AUT+BEL+CAN+CHL+CRI+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LVA+LTU+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+G20+EU25+OECD.",
  "ISCED11_1+ISCED11_2......A...INST_EDU+INST_EDU_PUB+INST_EDU_PRIV..._T.",
  "?startPeriod=2015&endPeriod=2023",
  "&dimensionAtObservation=AllDimensions",
  "&format=csvfilewithlabels"
)

# Import the data directly from the OECD API
df <- read_csv(url)

# -------------------------
# Keep only the variables needed for the analysis
# -------------------------
# The raw OECD file contains many dimensions that are not used here.
# We keep only:
# - country and country code
# - year
# - education level
# - type of institution
# - observed student-teacher ratio
df <- df %>% 
  select(
    country = `Reference area`,
    country_code = REF_AREA,
    year = TIME_PERIOD,
    level = `Education level`,
    institution = `Type of educational institution`,
    ratio = OBS_VALUE
  ) %>% 
  # Remove observations with missing ratio values
  filter(!is.na(ratio))

# Quick check of the cleaned structure
glimpse(df)


# -------------------------
# Check data coverage by country
# -------------------------
# The table below reports, for each country, the number of available
# observations (out of a maximum of 54 = 9 years x 2 education levels x
# 3 institution types).
df %>% 
  count(country, year, level, institution) %>% 
  group_by(country) %>% 
  summarise(obs = n()) %>% 
  arrange(obs)

# We keep countries with at least 48 observations.
# This allows for a small number of missing values while excluding
# countries with substantially incomplete series.
valid_countries <- df %>% 
  count(country) %>% 
  filter(n >= 48) %>% 
  pull(country)

# Restrict the dataset to countries with sufficient coverage
df <- df %>% 
  filter(country %in% valid_countries)

# -------------------------
# Build the chart dataset
# -------------------------
# The chart focuses on the OECD aggregate only in order to show
# a clear trend over time without overcrowding the figure.
chart_df <- df %>%
  filter(country_code == "OECD") %>% 
  mutate(
    # Reorder education levels for display in the chart
    level = factor(level, levels = c("Primary education", "Lower secondary education")),
    
    # Simplify institution labels to make the legend shorter and clearer
    institution = factor(
      institution,
      levels = c(
        "All educational institutions",
        "Public educational institutions",
        "Private educational institutions"
      ),
      labels = c("All institutions", "Public", "Private")
    )
  )

# Create the chart
# The chart shows the evolution of student-teacher ratios from 2015 to 2023,
# distinguishing institution type and education level.
chart <- ggplot(chart_df, aes(x = year, y = ratio, color = institution, linetype = institution)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  facet_wrap(~ level, ncol = 1) +
  scale_x_continuous(breaks = 2015:2023) +
  scale_y_continuous(breaks = seq(11, 15, 1)) +
  scale_color_manual(values = c(
    "All institutions" = "#666666",
    "Public" = "#1b9e77",
    "Private" = "#d95f02"
  )) +
  scale_linetype_manual(values = c(
    "All institutions" = "solid",
    "Public" = "dashed",
    "Private" = "dashed"
  )) +
  labs(
    title = "Student-teacher ratios in the OECD, by institution type",
    subtitle = "Primary and lower secondary education, 2015–2023",
    x = NULL,
    y = "Students per teacher",
    color = "Institution type",
    caption = "Source: OECD Data Explorer"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  ) +
  # Keep only the color legend to avoid duplication
  guides(linetype = "none")

# Save the chart
ggsave("student_teacher_ratios_oecd_chart.png", chart, width = 8, height = 6, dpi = 300)

# -------------------------
# Build the 2023 cross-country comparison table
# -------------------------
# The table focuses on the latest year available (2023)
# and compares countries across:
# - education level
# - type of institution
df_table <- df %>%
  filter(year == 2023) %>% 
  select(-country_code, -year)

# Reshape the table so that each row is a country and each column
# corresponds to one level-institution combination
df_table_wide <- df_table %>% 
  pivot_wider(
    names_from = c(level, institution),
    values_from = ratio
  ) %>%
  select(
    country,
    `Primary education_All educational institutions`,
    `Primary education_Public educational institutions`,
    `Primary education_Private educational institutions`,
    `Lower secondary education_All educational institutions`,
    `Lower secondary education_Public educational institutions`,
    `Lower secondary education_Private educational institutions`
  )

# To show the dynamics in the table we compute changes between 2015 and 2023.  
# To keep the table readable, the change is computed only for
# "All educational institutions", separately for each education level.
df_change <- df %>%
  filter(
    year %in% c(2015, 2023),
    institution == "All educational institutions"
  ) %>%
  select(country, level, year, ratio) %>%
  pivot_wider(
    names_from = year,
    values_from = ratio
  ) %>%
  # Difference between the latest and the initial year
  mutate(change = `2023` - `2015`) %>%
  select(country, level, change) %>%
  pivot_wider(
    names_from = level,
    values_from = change,
    names_prefix = "Change 2015_2023_"
  )

# We merge the 2023 table with the change variables
# The final table presents:
# - 2023 ratios by country, level and institution type
# - change between 2015 and 2023 for all institutions
final_table <- df_table_wide %>%
  left_join(df_change, by = "country") %>%
  # Round all numeric values to one decimal place
  mutate(across(-country, ~ round(.x, 1))) %>% 
  # Rename columns to shorter and more readable labels
  select(
    `Country` = country,
    `Primary - All` = `Primary education_All educational institutions`,
    `Primary - Public` = `Primary education_Public educational institutions`,
    `Primary - Private` = `Primary education_Private educational institutions`,
    `Change 2015-2023 (Primary)` = `Change 2015_2023_Primary education`,
    `Lower secondary - All` = `Lower secondary education_All educational institutions`,
    `Lower secondary - Public` = `Lower secondary education_Public educational institutions`,
    `Lower secondary - Private` = `Lower secondary education_Private educational institutions`,
    `Change 2015-2023 (Lower secondary)` = `Change 2015_2023_Lower secondary education`
  ) %>% 
  # Sort countries by the 2023 primary ratio for all institutions
  arrange(`Primary - All`)

# Display the final numeric table in R
final_table

# We create a version of the table for export
# Missing values are replaced by "n.a." for presentation purposes.
# This is done only in the export version of the table.
final_table_word <- final_table %>% 
  mutate(across(everything(), ~ ifelse(is.na(.), "n.a.", as.character(.))))

# Export the table as a CSV file
write.csv(final_table_word, "student_teacher_ratios_oecd_table.csv", row.names = FALSE)