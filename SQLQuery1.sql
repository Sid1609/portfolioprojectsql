
select *
from [portfolio project sql]..['COVID DEATHS$']
order by 3,4


--select *
--from [portfolio project sql]..['COVID VACCINATIONS$']
--order by 3,4

select location, date,population, total_cases, new_cases,total_deaths 
from [portfolio project sql]..['COVID DEATHS$']
order by 1,2

--looking at total cases vs total deaths
--likelihood of death in our country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [portfolio project sql]..['COVID DEATHS$']
where location like '%canada'
order by 1,2

--looking at total cases vs population
--shows  what percentage of people infected 
select location, date, total_cases,population, (total_cases/population)*100 as covid_percentage
from [portfolio project sql]..['COVID DEATHS$']
--where location like '%canada'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infectedcount, MAX((total_cases/population))*100 as max_covid_percentage
from [portfolio project sql]..['COVID DEATHS$']
group by location,population
--where location like '%canada'
order by max_covid_percentage desc

--countries with highest death count
select location, MAX( cast(total_deaths as int)) as highest_deathcount
from [portfolio project sql]..['COVID DEATHS$']
where continent is not null
group by location
--where location like '%canada'
order by highest_deathcount desc

--global scenario
select  SUM(cast(new_cases as int))as total_cases ,SUM(cast(new_deaths as int))as total_deaths,
 SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS Death_percentage
from [portfolio project sql]..['COVID DEATHS$']
where continent is not null
--group by date
--where location like '%canada'
order by 1,2






--looking at total population vs total vaccination



---USE CTE
With popvsvac (continent,location,date,population,rollingvaccinationcount,new_vaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationcount
from [portfolio project sql]..['COVID DEATHS$'] dea
Join [portfolio project sql]..['COVID VACCINATIONS$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.location like '%canada%'
--order by 2,3
)
select *,(rollingvaccinationcount/population)*100
from popvsvac

--TEMP TABLE
Drop Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinationcount numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationcount
from [portfolio project sql]..['COVID DEATHS$'] dea
Join [portfolio project sql]..['COVID VACCINATIONS$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *,(rollingvaccinationcount/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualizations
Create view percentpopulationvaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationcount
from [portfolio project sql]..['COVID DEATHS$'] dea
Join [portfolio project sql]..['COVID VACCINATIONS$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
from percentpopulationvaccinated

