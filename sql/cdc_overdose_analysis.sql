-- ============================================================
-- CDC Drug-Induced Mortality Analysis (2018–2024)
-- Source: CDC WONDER Multiple Cause of Death Database
-- Author: Corey Reynolds
-- Description: Analytical SQL queries mirroring Excel analysis
--              of drug-induced overdose mortality trends across
--              U.S. states and age groups (working-age adults
--              15–64). Data covers 50 states + DC.
-- ============================================================


-- ============================================================
-- TABLE SCHEMA
-- ============================================================

CREATE TABLE cdc_overdose (
    record_id       INTEGER PRIMARY KEY,
    year            INTEGER NOT NULL,
    state           VARCHAR(50) NOT NULL,
    state_code      INTEGER NOT NULL,
    age_group       VARCHAR(20) NOT NULL,
    deaths          INTEGER,
    population      INTEGER,
    crude_rate      DECIMAL(6,1),
    rate_lower_ci   DECIMAL(6,1),
    rate_upper_ci   DECIMAL(6,1)
);


-- ============================================================
-- QUERY 1: National Totals by Year
-- Purpose: Track year-over-year trend in drug-induced deaths
--          at the national level among working-age adults.
-- ============================================================

SELECT
    year,
    SUM(deaths)                                         AS total_deaths,
    SUM(population)                                     AS total_population,
    ROUND(
        SUM(deaths) * 100000.0 / SUM(population), 1
    )                                                   AS national_crude_rate,
    SUM(deaths) - LAG(SUM(deaths)) OVER (ORDER BY year) AS yoy_change,
    ROUND(
        (SUM(deaths) - LAG(SUM(deaths)) OVER (ORDER BY year)) * 100.0
        / NULLIF(LAG(SUM(deaths)) OVER (ORDER BY year), 0), 1
    )                                                   AS yoy_pct_change
FROM cdc_overdose
WHERE age_group IN (
    '15-24 years', '25-34 years', '35-44 years',
    '45-54 years', '55-64 years'
)
GROUP BY year
ORDER BY year;


-- ============================================================
-- QUERY 2: Deaths by Age Group — National Annual Breakdown
-- Purpose: Identify which age groups carry the highest burden
--          and how that has shifted over time.
-- ============================================================

SELECT
    year,
    age_group,
    SUM(deaths)                                             AS deaths,
    SUM(population)                                         AS population,
    ROUND(SUM(deaths) * 100000.0 / SUM(population), 1)     AS crude_rate,
    ROUND(
        SUM(deaths) * 100.0
        / SUM(SUM(deaths)) OVER (PARTITION BY year), 1
    )                                                       AS pct_of_annual_deaths
FROM cdc_overdose
WHERE age_group IN (
    '15-24 years', '25-34 years', '35-44 years',
    '45-54 years', '55-64 years'
)
GROUP BY year, age_group
ORDER BY year, age_group;


-- ============================================================
-- QUERY 3: State Rankings — Cumulative 2018–2024
-- Purpose: Rank all states by total burden and classify by
--          mortality tier for geographic risk stratification.
-- ============================================================

SELECT
    RANK() OVER (ORDER BY SUM(deaths) DESC)             AS death_rank,
    state,
    SUM(deaths)                                         AS total_deaths,
    SUM(population)                                     AS total_population,
    ROUND(SUM(deaths) * 100000.0 / SUM(population), 1) AS avg_crude_rate,
    CASE
        WHEN ROUND(SUM(deaths) * 100000.0 / SUM(population), 1) >= 40
            THEN 'CRITICAL'
        WHEN ROUND(SUM(deaths) * 100000.0 / SUM(population), 1) >= 25
            THEN 'HIGH'
        WHEN ROUND(SUM(deaths) * 100000.0 / SUM(population), 1) >= 15
            THEN 'MODERATE'
        ELSE 'LOW'
    END                                                 AS burden_tier
FROM cdc_overdose
WHERE age_group IN (
    '15-24 years', '25-34 years', '35-44 years',
    '45-54 years', '55-64 years'
)
GROUP BY state
ORDER BY total_deaths DESC;


-- ============================================================
-- QUERY 4: Top 10 States by Total Deaths
-- Purpose: Surface the ten highest-burden states for focused
--          policy and resource allocation analysis.
-- ============================================================

SELECT
    RANK() OVER (ORDER BY SUM(deaths) DESC)             AS rank,
    state,
    SUM(deaths)                                         AS total_deaths,
    ROUND(SUM(deaths) * 100000.0 / SUM(population), 1) AS avg_crude_rate
FROM cdc_overdose
WHERE age_group IN (
    '15-24 years', '25-34 years', '35-44 years',
    '45-54 years', '55-64 years'
)
GROUP BY state
ORDER BY total_deaths DESC
LIMIT 10;


-- ============================================================
-- QUERY 5: COVID-19 Impact — Pre vs. During vs. Post Pandemic
-- Purpose: Quantify the pandemic's effect on drug mortality
--          by comparing three distinct time periods.
-- ============================================================

SELECT
    CASE
        WHEN year IN (2018, 2019)       THEN 'Pre-Pandemic (2018–2019)'
        WHEN year IN (2020, 2021, 2022) THEN 'Pandemic Era (2020–2022)'
        WHEN year IN (2023, 2024)       THEN 'Post-Peak (2023–2024)'
    END                                                 AS period,
    SUM(deaths)                                         AS total_deaths,
    ROUND(AVG(
        CAST(deaths AS FLOAT) * 100000.0 / population
    ), 1)                                               AS avg_crude_rate,
    COUNT(DISTINCT year)                                AS years_in_period
FROM cdc_overdose
WHERE age_group IN (
    '15-24 years', '25-34 years', '35-44 years',
    '45-54 years', '55-64 years'
)
GROUP BY period
ORDER BY MIN(year);


-- ============================================================
-- QUERY 6: Hardest-Hit Age Group per State (2018–2024)
-- Purpose: Identify which age group drives mortality in each
--          state — useful for targeted intervention analysis.
-- ============================================================

WITH state_age_totals AS (
    SELECT
        state,
        age_group,
        SUM(deaths)                                         AS total_deaths,
        RANK() OVER (
            PARTITION BY state
            ORDER BY SUM(deaths) DESC
        )                                                   AS age_rank
    FROM cdc_overdose
    WHERE age_group IN (
        '15-24 years', '25-34 years', '35-44 years',
        '45-54 years', '55-64 years'
    )
    GROUP BY state, age_group
)
SELECT
    state,
    age_group                   AS highest_burden_age_group,
    total_deaths
FROM state_age_totals
WHERE age_rank = 1
ORDER BY state;


-- ============================================================
-- QUERY 7: Year-Over-Year Change by State
-- Purpose: Identify states where mortality is accelerating or
--          improving between 2023 and 2024.
-- ============================================================

WITH yearly_state AS (
    SELECT
        state,
        year,
        SUM(deaths) AS deaths
    FROM cdc_overdose
    WHERE age_group IN (
        '15-24 years', '25-34 years', '35-44 years',
        '45-54 years', '55-64 years'
    )
    GROUP BY state, year
)
SELECT
    a.state,
    a.deaths                                            AS deaths_2023,
    b.deaths                                            AS deaths_2024,
    b.deaths - a.deaths                                 AS yoy_change,
    ROUND(
        (b.deaths - a.deaths) * 100.0
        / NULLIF(a.deaths, 0), 1
    )                                                   AS yoy_pct_change,
    CASE
        WHEN b.deaths < a.deaths THEN 'Improving'
        WHEN b.deaths > a.deaths THEN 'Worsening'
        ELSE 'Stable'
    END                                                 AS trend_direction
FROM yearly_state a
JOIN yearly_state b
    ON a.state = b.state
    AND a.year = 2023
    AND b.year = 2024
ORDER BY yoy_pct_change DESC;
