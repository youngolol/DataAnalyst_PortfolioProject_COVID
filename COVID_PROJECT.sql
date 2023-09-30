SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs total deaths
--likelihood of death in the US once infected
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- total cases vs population (percentage of US population that got covid)
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- viewing highest infection rate vs population (Glboal)
SELECT Location, population, MAX(total_cases) AS GreatestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- global highest death count by population
-- total_deaths cast to appropriate data type to clear NULL
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- total deaths by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- previous query resulted in inaccuries in reporting where NA only encompasses deaths from US
-- compare to the following for more accurate total death counts
-- SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
-- FROM PortfolioProject..CovidDeaths
-- WHERE continent is null
-- GROUP BY Location
-- ORDER BY TotalDeathCount DESC

-- global total death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Global # of people vaccinated (gather rolling sums via OVER())
-- develop CTE to generate percentage of vaccinations over population
WITH PopVac (continent, location, date, population, new_vaccinations, ProgressiveVaccinations)
AS 
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
  , SUM(CAST(vax.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY 
  death.location, death.date) AS ProgressiveVaccinations
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent is not null
)
SELECT *, (ProgressiveVaccinations/population)*100 AS PercentVaccinated
FROM PopVac



-- store for viz
USE PortfolioProject
GO
CREATE VIEW PercentVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
  , SUM(CAST(vax.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY 
  death.location, death.date) AS ProgressiveVaccinations
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent is not null