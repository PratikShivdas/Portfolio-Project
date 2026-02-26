CREATE DATABASE PortfolioProject;
USE PortfolioProject;

SELECT * 
FROM Portfolioproject.coviddeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4;

SELECT * 
FROM Portfolioproject.coviddeaths
ORDER BY 3,4;

-- SELECT * FROM Portfolioproject.covidvaccinations ORDER BY 3, 4;

-- Select the Data that we are going to be using :
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths 
WHERE Continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at the Total Cases vs Total Deaths :
-- Shows the likelihood of dying if you contract covid in your country.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolioproject.coviddeaths 
WHERE Location like '%Bangla%'
and Continent IS NOT NULL
ORDER BY 1, 2;	

-- Looking at the Total Cases vs Population :
-- shows what percentageof population got covid.
SELECT Location, date, Population, total_cases, (total_cases/Population) *100 as PercentPopulationInfected
FROM portfolioproject.coviddeaths 
-- WHERE Location like '%Afg%'
WHERE Continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at the Countries with Highest Infection rate compared to population 
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)) *100 as PercentPopulationInfected
FROM portfolioproject.coviddeaths 
-- WHERE Location like '%Afg%'
WHERE Continent IS NOT NULL
GROUP BY Location, Population

ORDER BY PercentPopulationInfected desc;

-- Showing the Counties with Highest Death Count per population :
SELECT Location, Max(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM portfolioproject.coviddeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- LET' S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population :
SELECT Continent, Max(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM portfolioproject.coviddeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount desc;

-- Global Numbers :
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths, SUM(cast(new_deaths as SIGNED))/ SUM(new_cases) * 100 as DeathPercentage	 -- , total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolioproject.coviddeaths 
-- WHERE Location like '%Bangla%'
WHERE Continent IS NOT NULL 
-- GROUP BY date
ORDER BY 1, 2;	

-- Looking at the Total Population vs Vaccinations :

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100 - this will give an error. So, we need to create CTEs or Temp Table for this.
FROM portfolioproject.coviddeaths as dea
JOIN portfolioproject.covidvaccinations as vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE  dea.Continent IS NOT NULL
ORDER BY 2, 3;

-- Use CTE :
WITH PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated) -- the no. of columns in the CTE and and the no. of columns in the other table has to be equal otherwise it'll give an error.
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100 - this will give an error. So, we need to create CTEs or Temp Table for this.
FROM portfolioproject.coviddeaths as dea
JOIN portfolioproject.covidvaccinations as vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE  dea.Continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeoplpeVaccinated/Population) * 100 FROM PopvsVac;

-- Temp Table :-

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent varchar(105),
Location varchar(105),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;
-- WHERE dea.continent is not null 
-- ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100 - this will give an error. So, we need to create CTEs or Temp Table for this.
FROM portfolioproject.coviddeaths as dea
JOIN portfolioproject.covidvaccinations as vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE  dea.Continent IS NOT NULL;
-- ORDER BY 2, 3

SELECT * FROM PercentPopulationVaccinated;
