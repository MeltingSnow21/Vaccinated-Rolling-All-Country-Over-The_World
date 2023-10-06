
--SELECTS ALL DATA IN THE COVIDDEATHS TABLE
SELECT * FROM PortoSQL .. CovidDeaths
ORDER BY 3,4

----SELECTS ALL DATA IN THE COVIDVACINATION TABLE
--SELECT * FROM PortoSQL .. CovidVacination
--ORDER BY 3,4


-- Selecting the data to be used
SELECT location, date, total_cases, new_cases, CONVERT(float,total_deaths), population From PortoSQL .. CovidDeaths
order by 1,2


-- finding total cases vs total deaths (Indonesia)
SELECT location, date, total_cases, total_deaths, 
(convert(float,total_deaths) /  convert(float,total_cases))*100 as DeathPercentage
From PortoSQL .. CovidDeaths
where location like '%Indonesia%'
order by 1, 2

-- finding total cases vs population (Indonesia)
SELECT location, date, total_cases, population, 
(total_cases / population)*100 as PercentPopulatioanInfected
From PortoSQL .. CovidDeaths
where location like '%Indonesia%'
order by 1, 2

-- Highest Infection Rate by Population
SELECT location, MAX(total_cases) as HighestInfection, population, 
(MAX(total_cases)/ population)*100 as PercentPopulatioanInfected
From PortoSQL .. CovidDeaths
group by location, population
order by PercentPopulatioanInfected Desc

-- Showing the country with the highest death per population
SELECT location, MAX(total_deaths) as TotalDeaths
From PortoSQL .. CovidDeaths where continent is not null
group by location 
Order by TotalDeaths desc

--- By continent
SELECT location, MAX(total_deaths) as TotalDeaths
From PortoSQL .. CovidDeaths where continent is not null
group by location 
Order by TotalDeaths desc

-- Highest countinent with deaths precentage
SELECT continent, MAX(total_deaths) as TotalDeathsContinent
From PortoSQL .. CovidDeaths where continent is not null
group by continent 
Order by TotalDeathsContinent desc


---- GLOBAL NUMBER

-- total daily case
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int)) / ISNULL(1, SUM (New_cases))*100 as DeathsPercentage
From PortoSQL .. CovidDeaths
where continent is not null
group by date
order by 1, 2

-- total entier world
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int)) / ISNULL(1, SUM (New_cases))*100 as DeathsPercentage
From PortoSQL .. CovidDeaths
where continent is not null
order by 1, 2


-- Population dan Vacination
Select * 
From PortoSQL .. CovidDeaths dea
Join PortoSQL .. CovidVacination Vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Total Population dan Vacination
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM (convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.date)	as rollingpeoplevaccinated
From PortoSQL .. CovidDeaths dea
Join PortoSQL .. CovidVacination Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE (new table)
with PopvsVac ( continent, locatioan, date, population, new_vacination, rollingpeoplevaccinated)
as(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.date)	as rollingpeoplevaccinated
From PortoSQL .. CovidDeaths dea
Join PortoSQL .. CovidVacination Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

-- temporary table
drop table if exists #percentpupulationvacinated
Create Table #percentpupulationvacinated
(
lontinent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpupulationvacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.date)	as rollingpeoplevaccinated
From PortoSQL .. CovidDeaths dea
Join PortoSQL .. CovidVacination Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from #percentpupulationvacinated

-- Creating View for final viz
create view percentpopulationvaccinated 
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(float, vac.new_vaccinations)) Over (partition by dea.location order by dea.date)	as rollingpeoplevaccinated
From PortoSQL .. CovidDeaths dea
Join PortoSQL .. CovidVacination Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)


select * from percentpopulationvaccinated
order by rollingpeoplevaccinated desc
