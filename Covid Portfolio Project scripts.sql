select *
from PortfolioProject..CovidDeath
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

--select Data that we are going to be using
SELECT location,date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

--looking at total cases vs total deaths
--shows likehood of dying if you infected in your country
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
where location like '%China%'
ORDER BY 1,2

----looking at total cases vs population
--Shows what percentage of population got covid
SELECT location,date, total_cases, population, (total_deaths/population)*100 as InfectPercentage
FROM PortfolioProject..CovidDeath
where location like '%China%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to Population
SELECT location,population, MAX(total_cases) as highestInfectionCount, MAX(total_cases)/population*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeath
--where location like '%China%'
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count
SELECT location,population, MAX(cast(total_deaths as int)) as highestDeathsCount, MAX(cast(total_deaths as int))/population*100 as PercentPopulationDead
FROM PortfolioProject..CovidDeath
where continent is not null
GROUP BY location, Population
ORDER BY highestDeathsCount desc

--breaking things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as highestDeathsCount
FROM PortfolioProject..CovidDeath
where continent is not null
GROUP BY continent
ORDER BY highestDeathsCount desc

--Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as highestDeathsCount, MAX(cast(total_deaths as int))/population as highestDeathspercent 
FROM PortfolioProject..CovidDeath
where continent is not null
GROUP BY continent, population
ORDER BY highestDeathspercent desc

--Global numbers
select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as Deathpercentage
FROM PortfolioProject..CovidDeath
where continent is not null
ORDER BY 1,2

--Join covidDeath and CovidVaccination
SELECT *
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.date=vac.date
	and dea.location=vac.location
where dea.continent is not null
ORDER BY 2,3

--looking at total population vs vaccinations

--USE CTE
with popvsvac(Continent, location, date, population, new_vaccinated,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
and dea.location like '%china%'
--ORDER BY 2,3
)

select *, RollingPeopleVaccinated/population*100
From popvsvac

--creating view to store data for later visualizations

create view Rollingpeoplevaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
and dea.location like '%china%'
--ORDER BY 2,3

select *
from Rollingpeoplevaccinated