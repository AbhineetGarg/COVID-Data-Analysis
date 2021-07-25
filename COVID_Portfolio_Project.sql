SELECT *
FROM PortfolioProject..[Covid Deaths]
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..[CovidVaccinations]
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid Deaths]
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
FROM PortfolioProject..[Covid Deaths]
WHERE location = 'India'
ORDER BY 1,2

-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPerc
FROM PortfolioProject..[Covid Deaths]
--WHERE location = 'India'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases), MAX(total_cases/population)*100 as InfectionPerc
FROM PortfolioProject..[Covid Deaths]
GROUP BY location, population
ORDER BY InfectionPerc DESC

-- Countries with their Highest Death Rate
SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with their respective Highest Death Rate
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS tot_cases, SUM(CAST(new_deaths AS INT)) AS tot_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPerc
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS tot_cases, SUM(CAST(new_deaths AS INT)) AS tot_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPerc
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Cum_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (Cum_Vaccinations/Population)*100
FROM PopvsVac

-- Population vs Vaccinations using Temp Table
IF OBJECT_ID('tempdb.dbo.#VaccinationPerc', 'U') IS NOT NULL  -- this syntax upto SQL Server 2014
	DROP TABLE #VaccinationPerc
-- " DROP TABLE IF EXISTS dbo.#VaccinationPerc " for SQL Server 2016 & up
CREATE TABLE #VaccinationPerc
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
Cum_Vaccinations numeric
)

INSERT INTO #VaccinationPerc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (Cum_Vaccinations/Population)*100 AS VaccinatedPopulationPerc
FROM #VaccinationPerc
ORDER BY 2, 3


-- Creating View for later visualizations
IF OBJECT_ID('VaccinationPerc', 'V') IS NOT NULL
	DROP VIEW VaccinationPerc
GO

CREATE VIEW VaccinationPerc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM VaccinationPerc