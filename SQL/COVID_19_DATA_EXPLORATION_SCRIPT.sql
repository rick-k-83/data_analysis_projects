SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


--chances of deaths from covid 19 total deaths vs total cases
SELECT date, location, total_deaths, total_cases, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS chances_of_death
FROM PortfolioProject..covid_deaths
WHERE location like '%Honduras%'
ORDER BY 1 ASC

-- total cases vs population
SELECT date, location, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS chances_of_contagion
FROM PortfolioProject..covid_deaths
WHERE 
	location like '%Honduras%'
ORDER BY 
	2, 1 ASC

-- highest infection rate compared to population 
SELECT location, population, MAX(CAST(total_cases AS int)) AS highest_infection_count, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS rate_of_infection
FROM PortfolioProject..covid_deaths
GROUP BY 
	location, population
ORDER BY 
	rate_of_infection DESC



-- DEATHS BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	total_deaths_count DESC


-- GLOBAL NUMBERS 
SELECT 
	--date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	CASE
        WHEN SUM(new_cases) = 0 THEN NULL  -- Handle zero cases as NULL
        ELSE SUM(new_deaths) * 100.0 / SUM(new_cases)
    END AS death_percentage
FROM PortfolioProject..covid_deaths
--WHERE location like '%Honduras%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2 

-- total population vs vaccionations
SELECT 
	dea.continent, 
	dea.location, dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_count
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using cte for population vs vaccination

WITH PopvsVac(
	continent, 
	location, 
	date, 
	population, 
	new_vaccinations,
	vaccination_count
	) AS
(
SELECT 
	dea.continent, 
	dea.location, dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_count
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (vaccination_count/population)*100 AS vaccination_rate
FROM PopvsVac




-- Temp table
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccination_count numeric
)

INSERT INTO #percent_population_vaccinated
SELECT 
	dea.continent, 
	dea.location, dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_count
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (vaccination_count/population)*100 AS vaccination_rate
FROM #percent_population_vaccinated



-- Creating a View
CREATE VIEW population_vaccinated_view AS
SELECT 
	dea.continent, 
	dea.location, dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_count
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
