SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'india' 
AND continent IS NOT NULL
ORDER BY 1,2

-- looking at total cases vs population
SELECT location, date, total_cases, population ,( total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'india'
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count ,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC

--- Countries with highest death rate compared to population
SELECT location, MAX(CAST(total_deaths AS int)) AS Highest_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--- trying with continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS Highest_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global numbers by day

SELECT date, SUM(new_cases) AS new_cases, SUM(CAST(new_deaths AS int)) AS new_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentasCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 4 DESC

-- global numbers in total
SELECT SUM(new_cases) AS new_cases, SUM(CAST(new_deaths AS int)) AS new_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentasCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- vaccination data

SELECT *
FROM PortfolioProject..CovidVaccinations

-- total vaccination done by date
SELECT dea.continent,dea.location,dea.date,population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int))
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS VaccinationsByDate -- PARTITION will sum the data by location and date, and won't merge data of two locations
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to get vaccination vs population
with PopvsVac (continent,location,date,population, new_vaccinations, VaccinationsByDate)
as
(
SELECT dea.continent,dea.location,dea.date,population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int))
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS VaccinationsByDate -- PARTITION will sum the data by location and date, and won't merge data of two locations
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (VaccinationsByDate / population)*100 as Vaccinationpercentage
FROM PopvsVac


-- doing so using temp table
DROP TABLE if exists #pecrentpopulationvaccinated -- this will keept the table from crashing if the query is midified and somehting is takes out of it
CREATE TABLE #pecrentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationsByDate numeric
)

INSERT into #pecrentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int))
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS VaccinationsByDate -- PARTITION will sum the data by location and date, and won't merge data of two locations
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (VaccinationsByDate / population)*100 as Vaccinationpercentage
FROM #pecrentpopulationvaccinated


-- creating view to store data for later viz
CREATE VIEW pecrentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int))
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS VaccinationsByDate -- PARTITION will sum the data by location and date, and won't merge data of two locations
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3