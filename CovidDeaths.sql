Select * From MyportfolioDatabase..CovidDeaths$


Select location,population,MAX((total_cases)) as HighInfectionCases , Max(total_cases/population)*100 as PercentPopulationInfected
From MyportfolioDatabase..CovidDeaths$
Group by location, population
order by 4 desc




Select location,MAX(cast(total_deaths as int)) as DeathCount 
From MyportfolioDatabase..CovidDeaths$
where continent is not null
Group by location
order by DeathCount desc


-- Select Continent


Select continent,MAX(cast(total_deaths as int)) as DeathCount 
From MyportfolioDatabase..CovidDeaths$
where continent is not null
Group by continent
order by DeathCount desc


-- Done by Location


Select location,MAX(cast(total_deaths as int)) as DeathCount 
From MyportfolioDatabase..CovidDeaths$
where continent is null
Group by location
order by DeathCount desc


-- Global Numbers New updates


Select date,SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM MyportfolioDatabase..CovidDeaths$
where continent is not null 
group by date
order by 1,2 asc

-- INNEER JOIN and SUM Calculations.
-- USE OF OVER rather than Group By


-- CREATING CTE for further calculations
with dtvc(continent, location,date,population,total_deaths,TotalDeaths)
as
(
Select dea.continent, dea.location,dea.date, dea.population,dea.total_deaths,
sum(cast(dea.total_deaths as int)) over (partition by dea.location order by dea.location,dea.date) AS TotalDeaths
From  MyportfolioDatabase..Covid_vaccination$ vac
join MyportfolioDatabase..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.total_deaths is not null
--order by 2,3
)
Select* ,(total_deaths/population)*100 as DeathPercentage
From dtvc



--- Creating temporaray table for Calculations.
Drop table if exists #Death_by_Corona
Create Table #Death_by_Corona
(continent varchar(255), location varchar(255),date datetime,population numeric, total_deaths numeric,Total_Deaths_sum numeric)



Insert into #Death_by_Corona 
Select dea.continent, dea.location,dea.date, dea.population,dea.total_deaths,
sum(cast(dea.total_deaths as int)) over (partition by dea.location order by dea.location,dea.date) AS TotalDeaths
From  MyportfolioDatabase..Covid_vaccination$ vac
join MyportfolioDatabase..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.total_deaths is not null
--order by 2,3

-- Creating View
Create View Death_by_corona as
Select dea.continent, dea.location,dea.date, dea.population,dea.total_deaths,
sum(cast(dea.total_deaths as int)) over (partition by dea.location order by dea.location,dea.date) AS TotalDeaths
From  MyportfolioDatabase..Covid_vaccination$ vac
join MyportfolioDatabase..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 