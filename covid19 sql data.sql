SELECT * FROM [Portfolio Project]..[covidDeaths]
WHERE continent is not null
Order By 3,4;


--SELECT * FROM [Portfolio Project]..[covidvaccinations]
--Order By 3,4;

--select location,date,total_cases, new_cases, total_deaths , population_density
--FROM [Portfolio Project]..[covidDeaths]
--Order By 1,2;

-- Looking total cases vs total deaths:


select location,date,total_cases, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM [Portfolio Project]..[covidDeaths]

WHERE location LIKE '%india%'
AND continent is not null

Order By 1,2;

-- Looking total cases vs total deaths:

--- showws what percentage of population got covid 

select location,date,Population_density,total_cases,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population_density ), 0)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..[covidDeaths]
---WHERE location LIKE '%india%'
Order By 1,2;



--Looking at countries highest infection rate compare to population

select location,Population_density,MAX(total_cases) As HighestInfectionCount,MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population_density ), 0))  * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..[covidDeaths]
WHERE continent is not null

---WHERE location LIKE '%india%'
Group By location,Population_density
Order By PercentPopulationInfected desc;


-- BREAKING THINGS DOWN BY CONTINENT


-- The countries with the highest death count per population

select continent,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..[covidDeaths]
WHERE continent is not null

---WHERE location LIKE '%india%'
Group By continent
Order By TotalDeathCount desc;

-- Showing the continent with the highest death count per population

select continent,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..[covidDeaths]
WHERE continent is not null

---WHERE location LIKE '%india%'
Group By continent
Order By TotalDeathCount desc;

-- Global Numbers

select SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths ,SUM(new_deaths) / SUM(NULLIF(CONVERT(float, total_cases), 0)) *100 AS Deathpercentage
FROM [Portfolio Project]..[covidDeaths]

-- WHERE location LIKE '%india%'
WHERE continent is not null
--GROUP BY date
Order By 1,2;


-- Looking at total population vs vaccination
SELECT dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CAST(COALESCE(vac.new_vaccinations, 0) AS BIGINT)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population_density)*100
FROM [Portfolio Project]..[covidDeaths] as dea
JOIN [Portfolio Project]..[covidvaccinations] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;



-- USE CTE

with PopvsVac(Continent,Location,Date, Population_density,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CAST(COALESCE(vac.new_vaccinations,NULL) AS BIGINT)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population_density)*100
FROM [Portfolio Project]..[covidDeaths] as dea
JOIN [Portfolio Project]..[covidvaccinations] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
) 

SELECT * ,(RollingPeopleVaccinated/population_density)*100
FROM PopvsVac;



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population_density numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CAST(COALESCE(vac.new_vaccinations,NULL) AS BIGINT)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population_density)*100
FROM [Portfolio Project]..[covidDeaths] as dea
JOIN [Portfolio Project]..[covidvaccinations] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT * ,(RollingPeopleVaccinated/NULLIF(population_density,0))*100
FROM #PercentPopulationVaccinated;


-- creating the view for later visualizations

create view PercentPopulationVaccinated as
SELECT dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CAST(COALESCE(vac.new_vaccinations,NULL) AS BIGINT)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population_density)*100
FROM [Portfolio Project]..[covidDeaths] as dea
JOIN [Portfolio Project]..[covidvaccinations] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


SELECT * FROM PercentPopulationVaccinated;

