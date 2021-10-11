select location, date, total_cases, new_cases, total_deaths, population from FirstProject_Covid..CovidDeaths order by 1,2


-- Total Cases / Total Deaths
select location, date, total_cases, total_deaths, population , ((total_deaths/total_cases)*100) as DeathPercentage
from FirstProject_Covid..CovidDeaths 
--where location = 'Poland'
order by 1,2

-- Total Cases / Population
select location, date, total_cases, population , ((total_cases/population)*100) as PopulationInfastation
from FirstProject_Covid..CovidDeaths 
--where location = 'Poland'
order by 1,2

-- Countries with highest infection rate
select location,population, MAX(total_cases) as HighestInfectionCount, ((MAX(total_cases)/population)*100) as PercentPopulationInfected
from FirstProject_Covid..CovidDeaths 
where total_cases IS NOT NULL
group by location, population
order by PercentPopulationInfected desc


-- Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from FirstProject_Covid..CovidDeaths 
--where location = 'Poland'
where total_deaths IS NOT NULL and continent is not null
group by location
order by TotalDeathCount desc

-- World and continents by total deaths
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from FirstProject_Covid..CovidDeaths 
where total_deaths IS NOT NULL and continent is null
group by location
order by TotalDeathCount desc

-- Global Numbers
select date, sum(new_cases) as TotalNewDeaths, 
sum(cast(new_deaths as int)) as TotalNewDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathsPercentage
from FirstProject_Covid..CovidDeaths 
where continent is not null
group by date
order by 1,2


-- Global Death Percentage
select sum(new_cases) as TotalNewDeaths, 
sum(cast(new_deaths as int)) as TotalNewDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathsPercentage
from FirstProject_Covid..CovidDeaths 
where continent is not null
order by 1,2

-- Looking at total population and vaccination

-- USE CTE
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by  dea.date) as RollingPeopleVaccinated
from FirstProject_Covid..CovidDeaths dea
join FirstProject_Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)select *, (RollingPeopleVaccinated/Population)*100 as WolrdVaccination from PopvsVac



-- TEMP TABLE
DROP TABLE if exists #PErcentPopulationVaccinated
Create Table #PErcentPopulationVaccinated(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PErcentPopulationVaccinated 
select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by  dea.date) as RollingPeopleVaccinated
from FirstProject_Covid..CovidDeaths dea
join FirstProject_Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as WolrdVaccination from #PErcentPopulationVaccinated



create view PercentPopulationVaccinated as
select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by  dea.date) as RollingPeopleVaccinated
from FirstProject_Covid..CovidDeaths dea
join FirstProject_Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null