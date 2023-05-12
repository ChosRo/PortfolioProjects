SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Order BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentaje
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Peru'
Order BY 1,2

--Total Cases vs Population
--Shos what percentaje of population got Covid in Peru

SELECT location, date, population, total_cases, (total_cases / population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Peru'
Order BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX (total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
Order BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population

SELECT location, population, MAX (CAST (total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
Order BY TotalDeathCount DESC

--Let's break things down by Continent

SELECT location,  MAX (CAST (total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
Order BY TotalDeathCount DESC

-- Showing the Continents with the Highest death count per population

SELECT continent,  MAX (CAST (total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
Order BY TotalDeathCount DESC

--Global numbers

SELECT date, SUM (new_cases) AS TotalCases,SUM (CAST (new_deaths AS int)) AS TotalDeaths, SUM (CAST(new_deaths AS int)) / SUM (new_cases)*100 AS DeathPercentaje
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is NOT NULL
GROUP BY date
Order BY 1,2

SELECT SUM (new_cases) AS TotalCases,SUM (CAST (new_deaths AS int)) AS TotalDeaths, SUM (CAST(new_deaths AS int)) / SUM (new_cases)*100 AS DeathPercentaje
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is NOT NULL
Order BY 1,2


--Joining both tables
SELECT * 
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp Tables
DROP TABLE IF Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
