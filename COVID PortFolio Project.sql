SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

SElECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2   

--looking at total Cases Vs Total Death
--Show the likelihood of dying if you contract covid from your country

SElECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Cameroon' and continent is not null
Order by 1,2   

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

SElECT location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location like 'Cameroon'
Order by 1,2   

-- Looking at Countries With Highest Infection Rate Compared to Population

SElECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location like 'Cameroon'
Group by location, population
Order by PercentPopulationInfected DESC

-- Showing Highest Death Count per Population

SElECT location , MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location like 'Cameroon'
Group by location
Order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SElECT continent , MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location like 'Cameroon'
Group by continent
Order by TotalDeathCount DESC

-- Showing Continents with the Highest death count per population

SElECT continent , MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location like 'Cameroon'
Group by continent
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS

SElECT  SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Cameroon' 
WHERE continent is not null 
AND new_cases > 0
--Group by date
Order by 1,2   


-- Looking at total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER by 2,3


-- USE CTE

WITH Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM Popvsvac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER by 2,3


SElECT *
FROM PercentPopulationVaccinated
