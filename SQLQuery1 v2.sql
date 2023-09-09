Select *
 From [Portfoilio Project]..['Covid Death$']
 Where continent is not null
 order by 3,4

 --Select *
 --From [Portfoilio Project]..['Covid Vaccinations$']
 --order by 3,4
 
 --Select Data that we are going to be using


 
 Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfoilio Project]..['Covid Death$']
 Where continent is not null
 order by 1,2

 --Looking at Total Cases vs Total Deaths
 --shows likelihood of dying if you contract covid in your country
 SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
 From [Portfoilio Project]..['Covid Death$']
 Where location like '%india%'
 order by 1,2

 --Looking at Total Cases vs Population
 --Shows what percentage of population got covid
 SELECT
    Location,
    date,
    total_cases,
    population,
    (CAST(population AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
 From [Portfoilio Project]..['Covid Death$']
 Where location like '%Africa%'
 order by 1,2

 --Looking at countries with highest infection Rate compaared to population

SELECT
    Location,
    MAX(CAST(population AS FLOAT)) AS Population,
    MAX(CAST(total_cases AS FLOAT)) AS HighestiInfectionCount,
    (MAX(CAST(total_deaths AS FLOAT)) / MAX(CAST(total_cases AS FLOAT))) * 100 AS PercentPopulationInfected

    From [Portfoilio Project]..['Covid Death$']
	Where location like '%States%'
GROUP BY
    Location, Population
	order by PercentPopulationInfected ASC;
	
	
	-- Showing countries with highest Death Count per Population;

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From [Portfoilio Project]..['Covid Death$']
--Where location like '%India%'
 Where continent is not null
Group by location
ORDER BY TotalDeathCount DESC;

Select *
 From [Portfoilio Project]..['Covid Death$']
 Where continent is not null
 order by 3,4

 --Let's Break Things Down By Continents

 SELECT Continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From [Portfoilio Project]..['Covid Death$']
--Where location like '%India%'
 Where continent is Not null
Group by Continent
ORDER BY TotalDeathCount DESC;

--Let's Break Things Down By Continents

 SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From [Portfoilio Project]..['Covid Death$']
--Where location like '%India%'
 Where continent is not null
Group by location
ORDER BY TotalDeathCount DESC;


--Let's Break Things Down By Continents
--Showing continents with the highest death count per population

SELECT Continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From [Portfoilio Project]..['Covid Death$']
--Where location like '%India%'
 Where continent is Not null
Group by Continent
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT
       SUM(new_cases) AS new_cases,
       SUM(CAST(total_deaths AS DECIMAL(18, 2))) AS total_deaths,
       CASE 
           WHEN SUM(new_cases) = 0 THEN 0
           WHEN SUM(CAST(total_deaths AS DECIMAL(18, 2))) = 0 THEN 0
           ELSE (SUM(CAST(total_deaths AS DECIMAL(18, 2))) / SUM(new_cases)) * 100
       END AS DeathPercentage
FROM [Portfoilio Project]..['Covid Death$']
--Where location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2;


--USE CTE

with popvsVac(continent, Location, Date, Population, New_vaccination, Rollingpeoplevaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations,
       SUM(CONVERT(BIGINT, vac.New_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rollingpeoplevaccinated
	--,(Rollingpeoplevaccinated/population)*100
FROM [Portfoilio Project]..['Covid Death$'] dea
JOIN [Portfoilio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
select *,(Rollingpeoplevaccinated/population)*100 
FROM popvsVac


--TEMP TABLE

DROP Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations,
       SUM(CONVERT(BIGINT, vac.New_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rollingpeoplevaccinated
	--,(Rollingpeoplevaccinated/population)*100
FROM [Portfoilio Project]..['Covid Death$'] dea
JOIN [Portfoilio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
select *,(Rollingpeoplevaccinated/population)*100 
FROM #percentpopulationvaccinated


--creating view to store data for later visualisation

Create View  PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations,
       SUM(CONVERT(BIGINT, vac.New_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rollingpeoplevaccinated
	--,(Rollingpeoplevaccinated/population)*100
FROM [Portfoilio Project]..['Covid Death$'] dea
JOIN [Portfoilio Project]..['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
