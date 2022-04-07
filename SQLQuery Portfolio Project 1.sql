select * from CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccinations
--order by 3,4

select location, date, total_cases,new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like '%nigeria%'
order by 1,2

select location,date, population, total_cases, (total_cases/population)*100 as percentage_of_infected_population
from CovidDeaths
Where location like '%nigeria%' 
order by 1,2

select
	location, 
	population, 
	MAX(total_cases)as highestInfectionCount, 
	Max((total_cases/population))*100 as percentage_of_infected_population
from CovidDeaths
--where location like '%nigeria%'
group by location, population
order by percentage_of_infected_population desc

select
	location, 
	max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by total_death_count desc

select
	continent, 
	max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by total_death_count desc

--global numbers
	select 
		--date, 
		sum(new_cases) as total_cases_global,
		sum(cast (new_deaths as int)) as total_deaths_global, 
		(sum(cast (new_deaths as int))/sum(new_cases) )*100 as Global_DeathPercentage
	from CovidDeaths
	--Where location like '%nigeria%'
	where continent is not null
	--group by date
	order by 1,2

		select *
		from CovidDeaths CD
		join 
	CovidVaccinations CV ON CD.location=CV.location
	and CD.date=CV.date


	--use CTE
	with PopvsVac (continent,location, date, population, new_vaccinations,RollingPeopleVaccinated)
	as
	(
	select CD.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	sum(convert(bigint, new_vaccinations)) OVER(partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated--, (rollingpeoplevaccinated/population)*100
	from CovidDeaths CD
		join 
	CovidVaccinations CV ON CD.location=CV.location
	and CD.date=CV.date
	where cd.continent is not null and cd.location like'%alb%'
	--order by 2,3
	)
	select* ,(RollingPeopleVaccinated/population)*100
	from PopvsVac



-- using TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #percentpopulationvaccinated
select CD.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	sum(convert(bigint, new_vaccinations)) OVER(partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated--, (rollingpeoplevaccinated/population)*100
	from CovidDeaths CD
		join 
	CovidVaccinations CV ON CD.location=CV.location
	and CD.date=CV.date
	--where cd.continent is not null and cd.location like'%alb%'
	--order by 2,3

	select *,(rollingpeoplevaccinated/population)*100
	from  #percentpopulationvaccinated

	---creating view to stare data for later visualisation

	create view PercentPopulationVaccinated as 
	select CD.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	sum(convert(bigint, new_vaccinations)) OVER(partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated--, (rollingpeoplevaccinated/population)*100
	from CovidDeaths CD
		join 
	CovidVaccinations CV ON CD.location=CV.location
	and CD.date=CV.date
	where cd.continent is not null and cd.location like'%alb%'
	--order by 2,3

	select * 
	from PercentPopulationVaccinated

	create view PercentDeathNigeria as
	select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	from CovidDeaths
	Where location like '%nigeria%'
	--order by 1,2

	
	create view PercentofNigeriansInfected as
	select location,date, population, total_cases, (total_cases/population)*100 as percentage_of_infected_population
	from CovidDeaths
	Where location like '%nigeria%' 
	--order by 1,2

	select * from PercentofNigeriansInfected 
	
	--DATA FOR WORKING WITH TABLEU

--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income', 'High income','lower middle income','low income')
Group by location
order by TotalDeathCount desc


--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
	
	
