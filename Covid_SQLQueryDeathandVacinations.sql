--Showing all data in Covid Deaths
select *
from SQLCovid19..CovidDeaths
where continent != ''
order by 3,4

--Showing all data in Vaccinations
select *
from SQLCovid19..CovidVaccinations
order by 3,4


-- Select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from SQLCovid19..CovidDeaths
order by 1, 2

-- Looking at total cases vs total deaths
 Likelihood of dying if you contract covif in your contry
select Location, date, total_cases, total_deaths, total_deaths * (1/ NULLIF(total_cases, 0))*100 as DeathPercentage
from SQLCovid19..CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at total cases vs population
select Location, date, total_cases, population, total_cases * (1/ NULLIF(population, 0))*100 as CasesPopulationPercentage
from SQLCovid19..CovidDeaths
where location like '%states%'
order by 1, 2


-- Looking at countries with high infection rate cmpared to population
select Location, population, max(total_cases) as HighestinfectionCount, max(total_cases * (1/ NULLIF(population, 0)))*100 as CasesPopulationPercentage
from SQLCovid19..CovidDeaths
group by Location, population
order by 4 desc

-- Showing  countries with high death cont per population
select Location, population, max(total_deaths) as TotalDeathCount, max(total_deaths * (1/ NULLIF(population, 0)))*100 as DeathPopulationPercentage
from SQLCovid19..CovidDeaths
where continent != ''
group by Location, population
order by 3 desc

-- Breakdown per continent
--Showing  countries with high death cont on one day
select continent, max(total_deaths) as TotalDeathCount
from SQLCovid19..CovidDeaths
where continent != ''
group by continent
order by 2 desc


-- Global Numbers
 Likelihood of dying if you contract covif in your contry
select date, 
	sum(new_cases) as SumNewCases, 
	sum(new_deaths) as SumNewCases,
	sum(new_deaths) / NULLIF(sum(new_cases), 0)*100  as NewDeathCasesPercentage
from SQLCovid19..CovidDeaths
where continent != ''
group by date
order by 1, 2

select *
from SQLCovid19..CovidDeaths
where continent != ''
order by 3,4;

-- Total population vs vaccinations
select dea.continent, 
	dea.location , 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from SQLCovid19..CovidVaccinations vac 
join SQLCovid19..CovidDeaths dea
	on dea.location = vac.location and dea.date = vac.date
order by 2, 3


-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations , RollingPeopleVaccinated)
as (
	select dea.continent, 
		dea.location , 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from SQLCovid19..CovidVaccinations vac 
	join SQLCovid19..CovidDeaths dea
		on dea.location = vac.location and dea.date = vac.date
	where dea.continent != ''
	--order by 2, 3
	)
select * , (RollingPeopleVaccinated/NULLIF(population, 0))*100 as VaccShotOverPopulation
from PopvsVac;


-- Temp Table 
drop table if exists #VaccShotOverPopulation
create table #VaccShotOverPopulation
(
	continent nvarchar(255),
	location nvarchar(255),
	date date,
	population float,
	new_vaccinations float,
	RollingPeopleVaccinated float
)

insert into #VaccShotOverPopulation
select dea.continent, 
		dea.location , 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from SQLCovid19..CovidVaccinations vac 
	join SQLCovid19..CovidDeaths dea
		on dea.location = vac.location and dea.date = vac.date
	where dea.continent != ''
	--order by 2, 3

select * , (RollingPeopleVaccinated/NULLIF(population, 0))*100 as VaccShotOverPopulation
from #VaccShotOverPopulation;


-- Creating View to store data for later visuatilations 
create view VaccShotOverPopulation5 as 
select dea.continent, 
		dea.location , 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from SQLCovid19..CovidVaccinations vac 
	join SQLCovid19..CovidDeaths dea
		on dea.location = vac.location and dea.date = vac.date
	where dea.continent != ''
	;

