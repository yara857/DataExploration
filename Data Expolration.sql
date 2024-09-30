SELECT Location, date, total_cases, new_cases, total_deaths, population
from protfolioProject.dbo.covidDeath 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from protfolioProject.dbo.covidDeath 
where total_cases != 0 and location like '%state%'
order by 1,2

-- Total Cases vs Population
SELECT Location, date, total_cases, population , (total_cases/population)*100 as populationsPercentage
from protfolioProject.dbo.covidDeath 
where total_cases != 0 and  location like '%gypt%'
order by 1,2

SELECT Location, population , MAX(total_cases) as HighestInfectionCount , Max((total_cases/population)*100) as PerscentPoplationInfected
from protfolioProject.dbo.covidDeath 
where total_cases != 0
group by location , population
order by PerscentPoplationInfected desc

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount 
from protfolioProject.dbo.covidDeath 
where total_cases != 0 and continent is not null 
group by continent
order by TotalDeathCount desc



SELECT Location,  MAX(cast(total_deaths as int)) as TotalDeathCount 
from protfolioProject.dbo.covidDeath 
where total_cases != 0 and continent is not null 
group by location
order by TotalDeathCount desc

SELECT date, SUM(new_cases) as SumNewCases , SUM(Cast(new_deaths as int)) as SumDeaths , 
 SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
from protfolioProject.dbo.covidDeath 
where new_cases != 0 and continent is not null
group by date
order by 1,2

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER 
(Partition by d.Location order by d.location ,
d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100 
--, (RollingPeopleVaccinated/population)*100
From  protfolioProject.dbo.covidDeath as d
Join protfolioProject.dbo.covidVaccination as v
	On d.location = d.location
	and d.date = v.date
where d.continent is not null 
order by 2,3

--CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations,
        SUM(CONVERT(BIGINT, ISNULL(v.new_vaccinations, 0))) OVER 
        (PARTITION BY d.Location ORDER BY d.date) AS RollingPeopleVaccinated
    FROM  
        protfolioProject.dbo.covidDeath AS d
    JOIN 
        protfolioProject.dbo.covidVaccination AS v
    ON 
        d.location = v.location
    AND 
        d.date = v.date
    WHERE 
        d.continent IS NOT NULL
)
SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM 
    PopvsVac;

--TEMP table 
create table #VaccinatedPeaple
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime , 
Population numeric , 
new_vaccination numeric , 
RollingPeopleVaccinated numeric
)


insert into #VaccinatedPeaple
SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations,
        SUM(CONVERT(BIGINT, ISNULL(v.new_vaccinations, 0))) OVER 
        (PARTITION BY d.Location ORDER BY d.date) AS RollingPeopleVaccinated
    FROM  
        protfolioProject.dbo.covidDeath AS d
    JOIN 
        protfolioProject.dbo.covidVaccination AS v
    ON 
        d.location = v.location
    AND 
        d.date = v.date
    WHERE 
        d.continent IS NOT NULL


SELECT 
    *
FROM 
    #VaccinatedPeaple;


Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM  
        protfolioProject.dbo.covidDeath AS d
    JOIN 
        protfolioProject.dbo.covidVaccination AS v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 


select * from PercentPopulationVaccinated