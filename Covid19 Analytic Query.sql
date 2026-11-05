-- 1. Initial Data Inspection
SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


-- 2. Total Cases vs Total Deaths (Example: United States)
-- Shows the likelihood of dying if you contract COVID-19 in your country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths::numeric / NULLIF(total_cases, 0)::numeric) * 100 AS death_percentage
FROM covid_deaths
WHERE location = 'United States'
  AND continent IS NOT NULL
ORDER BY location, date;


-- 3. Total Cases vs Population
-- Shows what percentage of the population has been infected with COVID-19
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases::numeric / population::numeric) * 100 AS percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- 4. Countries with Highest Infection Rate compared to Population
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases::numeric / population::numeric)) * 100 AS percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- 5. Countries with Highest Death Count per Population
SELECT 
    location,
    MAX(total_deaths::integer) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- 6. Breaking Things Down by Continent
-- Showing continents with the highest death count
SELECT 
    continent,
    MAX(total_deaths::integer) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- 7. Global Numbers
-- Total cases, deaths, and global death percentage per day
SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths::integer) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(new_deaths::integer)::numeric / SUM(new_cases)::numeric) * 100 
    END AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


-- 8. Joining Deaths and Vaccinations Tables
-- Looking at Total Population vs Vaccinations & Rolling People Vaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations::integer) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- 9. Using CTE (Common Table Expression) to perform calculation on Partition By from previous query
WITH pop_vs_vac AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations::integer) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.date
        ) AS rolling_people_vaccinated
    FROM covid_deaths dea
    JOIN covid_vaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       (rolling_people_vaccinated::numeric / population::numeric) * 100 AS percent_people_vaccinated
FROM pop_vs_vac;


-- 10. Using Temp Table to perform calculation on Partition By
DROP TABLE IF EXISTS percent_population_vaccinated;

CREATE TEMP TABLE percent_population_vaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date TIMESTAMP,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vaccinated NUMERIC
);

INSERT INTO percent_population_vaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations::numeric,
    SUM(vac.new_vaccinations::integer) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    )
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date;

SELECT *, 
       (rolling_people_vaccinated / population) * 100 AS percent_people_vaccinated
FROM percent_population_vaccinated;


-- 11. Creating View to store data for later visualizations
CREATE OR REPLACE VIEW v_percent_population_vaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations::integer) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- 4 table to import to Teblau

-- Table1_GlobalNumbers
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths::integer) AS total_deaths,
    (SUM(new_deaths::integer)::numeric / NULLIF(SUM(new_cases), 0)::numeric) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Table2_ContinentDeaths
SELECT 
    location, 
    SUM(new_deaths::integer) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL 
  AND location NOT IN ('World', 'European Union', 'International', 'Low income', 'Upper middle income', 'High income', 'Lower middle income')
GROUP BY location
ORDER BY total_death_count DESC;

-- Table3_CountryInfection
SELECT 
    location, 
    population, 
    MAX(total_cases) AS highest_infection_count, 
    MAX((total_cases::numeric / NULLIF(population, 0)::numeric)) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Table4_InfectionOverTime
SELECT 
    location, 
    population, 
    date, 
    MAX(total_cases) AS highest_infection_count, 
    MAX((total_cases::numeric / NULLIF(population, 0)::numeric)) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;