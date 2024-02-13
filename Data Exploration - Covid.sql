select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


select *
from PortfolioProject..CovidDeaths
where continent is not null

exec sp_help 'dbo.CovidDeaths'

alter table dbo.CovidDeaths
alter column total_cases float


--Case percentage based on population 
--Specific data : Indonesia

select location, date, population, total_cases, (total_cases/population)*100 as case_percentage_id
from PortfolioProject.dbo.CovidDeaths
where location = 'Indonesia'
order by 1,2


--Covid-19 death risk
--Specific data : Indonesia

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage_id
from PortfolioProject.dbo.CovidDeaths
where location = 'Indonesia'
order by 1,2


--Death by covid-19 percentage based on population
--Specific data : Indonesia

select location, date, population, total_cases, (total_deaths/population)*100 as death_count_id
from PortfolioProject.dbo.CovidDeaths
where location = 'Indonesia'
order by 1,2


--Data breakdown in countries


--Countries with highest covid-19 case

select location, population, max(total_cases) as highest_infection_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by highest_infection_count desc


--Countries with highest covid-19 deaths count, based on population

select location, population, max(total_deaths) as highest_deaths_count 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by highest_deaths_count desc


--Countries with highest case percentage, based on population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as highest_case_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by highest_case_percentage desc


--Countries with highest covid-19 death percentage, based on population

select location, population, max(total_deaths) as highest_deaths_count, max((total_deaths/population))*100 as highest_deaths_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by highest_deaths_percentage desc


--Data breakdown in Continent


--Continents with highest covid-19 case

select continent, sum(total_cases) as highest_infection_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by highest_infection_count desc


--Continents with highest case percentage, based on population

select continent, sum(population) as population_count, sum(total_cases) as highest_infection_count,  max((total_cases/population)*100) as highest_case_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by highest_case_percentage desc


--Continents with highest covid-19 death percentage, based on population

select continent, sum(population) as population_count, sum(total_deaths) as highest_deaths_count, max((total_deaths/population)*100) as highest_deaths_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by highest_deaths_percentage desc


--Data breakdown in Global

select date, sum (new_cases) as global_cases, sum (new_deaths) as global_deaths, (sum (total_deaths)/sum (total_cases)*100) as death_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


--Vaccinations Data

select*
from PortfolioProject.dbo.CovidVaccs


select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations,
from PortfolioProject.dbo.CovidDeaths as ded
join PortfolioProject.dbo.CovidVaccs as vac
on ded.location = vac.location
and ded.date = vac.date
where ded.continent is not null
order by 2,3


select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by ded.location order by ded.location, ded.date) as vaccination_count

from PortfolioProject.dbo.CovidDeaths as ded
join PortfolioProject.dbo.CovidVaccs as vac
on ded.location = vac.location
and ded.date = vac.date

where ded.continent is not null
order by 2,3


-- Population vaccination percentage : CTE

with pop_vac (continent, location, date, population, new_vaccinations, vaccination_count)
as
(
select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by ded.location order by ded.location, ded.date) as vaccination_count

from PortfolioProject.dbo.CovidDeaths as ded
join PortfolioProject.dbo.CovidVaccs as vac
on ded.location = vac.location
and ded.date = vac.date

where ded.continent is not null
--order by 2,3
)
select location, max(vaccination_count/population)*100 as vacc_percentage
from pop_vac
group by location
order by 2 desc

--Population vaccination percentage : Temp table

drop table if exists #CovidVaccPercentage
create table #CovidVaccPercentage
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population float,
new_vaccination float,
vaccination_count float
)

insert into #CovidVaccPercentage
select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by ded.location order by ded.location, ded.date) as vaccination_count

from PortfolioProject.dbo.CovidDeaths as ded
join PortfolioProject.dbo.CovidVaccs as vac
on ded.location = vac.location
and ded.date = vac.date

where ded.continent is not null
--order by 2,3

select *, (vaccination_count/population)*100 as vacc_percentage
from #CovidVaccPercentage


--Creating view for later presentation

create view CovidVaccPercentage as
select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations,
sum (vac.new_vaccinations) over (partition by ded.location order by ded.location, ded.date) as vaccination_count

from PortfolioProject.dbo.CovidDeaths as ded
join PortfolioProject.dbo.CovidVaccs as vac
on ded.location = vac.location
and ded.date = vac.date

where ded.continent is not null
--order by 2,3

select*
from CovidVaccPercentage