
select * 
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4


--select * 
--from dbo.CovidVaccinations 
--order by 3,4

-- select data that we are going to be using 
select location , date , total_cases , new_cases , total_deaths , population
from PortfolioProject..CovidDeath
order by 1,2

-- total cases vs total death  
select location , date , total_cases , total_deaths ,
Round((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 , 2) AS DeathPercentage 
from PortfolioProject..CovidDeath
where location like '%states%'
and continent is not null
order by 1,2

-- total cases vs population 
select location , date , total_cases , total_deaths, population , 
(Cast(total_deaths as float) / total_cases ) * 100  as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

-- percentage of population got covid
select location , date ,population , total_cases,
(total_cases/population) * 100 as CovidPercentage
from PortfolioProject..CovidDeath
where location like '%state%'
order by 1,2

-- countries with highest infection rate compared to population
select location , population, Max(total_cases) as "Highest_infection_Country" 
, MAX((total_cases/population)) *100 as percentpopulationInfected
from PortfolioProject..CovidDeath
group by location , population
order by percentpopulationInfected desc

-- country with highest death count per population
select location , MAX(cast(total_deaths as int)) "Total Death"
from PortfolioProject..CovidDeath
where continent is not null
group by location 
order by "Total Death" desc

-- break things down by continent
select continent , MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeaths desc

--showing continents with highest deathcount per population
select continent ,  Max(cast(total_deaths as int)) AS TotalDeath
from PortfolioProject..CovidDeath
where continent is not null and total_deaths is not null
group by continent 
order by 2 desc

-- global numbers 
select Sum(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_death , 
sum(cast(new_deaths as int)) / Sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null and new_cases !=0
order by 1,2

-- looking at total population vs vaccination
-- create CTE
with PopvsVac(continent , location , date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) *100
from PortfolioProject..CovidVaccinations vac 
join PortfolioProject..CovidDeath dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Create Temp Table
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) *100
from PortfolioProject..CovidVaccinations vac 
join PortfolioProject..CovidDeath dea
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- vreating view to show data later for visualizations 
create view PercentPopulationVaccinated as 
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) *100
from PortfolioProject..CovidVaccinations vac 
join PortfolioProject..CovidDeath dea
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVaccinated
