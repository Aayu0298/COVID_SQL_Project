-- Selecting data which is going to be used 
select * from SQL_portfolio..Covid_deaths_data$
where continent is not null
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population 
from SQL_portfolio..Covid_deaths_data$
where continent is not null
order by 1,2

-- Total cases vs total deaths
-- Probabilty of dying if contracted with covid
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from SQL_portfolio..Covid_deaths_data$
where location like '%India%'
and continent is not null
order by 1,2

-- Total cases vs population in India
-- Percentage of population got infected with covid
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulation_Percentage
from SQL_portfolio..Covid_deaths_data$
where location like '%India%'
order by 1,2

-- Countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulation_Percentage
from SQL_portfolio..Covid_deaths_data$
group by location, population
order by InfectedPopulation_Percentage desc

-- Countries with the highest death count 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQL_portfolio..Covid_deaths_data$
where continent is not null
group by location
order by TotalDeathCount desc

-- Highest death count by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQL_portfolio..Covid_deaths_data$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Total cases vs population by continent
-- Percentage of population got infected with covid
select distinct continent, population, total_cases, (total_cases/population)*100 as InfectedPopulation_Percentage
from SQL_portfolio..Covid_deaths_data$
where continent is not null
order by InfectedPopulation_Percentage desc

---Global numbers------
select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(new_cases)*100 as DeathPercentage
from SQL_portfolio..Covid_deaths_data$
where continent is not null
group by date
order by 1,2


--Total population vs vaccination-------
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date)
from SQL_portfolio..Covid_deaths_data$ dea
join SQL_portfolio..Covid_vacc_data$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--common table expression (CTE)----------

with popvsvacc (Continent, Location, Date, Population, New_vaccinations, RollingCount_Vacc)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingCount_Vacc
from SQL_portfolio..Covid_deaths_data$ dea
join SQL_portfolio..Covid_vacc_data$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingCount_Vacc/Population)*100 as RollingVacc_Percent
from popvsvacc


--Temp table------
drop table if exists Percent_VaccinatedPopulation
Create table Percent_VaccinatedPopulation
(
Continent nvarchar(255),
Locateion nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCount_Vacc numeric
)


Insert into Percent_VaccinatedPopulation
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingCount_Vacc
from SQL_portfolio..Covid_deaths_data$ dea
join SQL_portfolio..Covid_vacc_data$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select * , (RollingCount_Vacc/Population)*100 as RollingVacc_Percent
from Percent_VaccinatedPopulation


--For visualisation--------

Create view PercentVaccinatedPopulation as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingCount_Vacc
from SQL_portfolio..Covid_deaths_data$ dea
join SQL_portfolio..Covid_vacc_data$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select *
from PercentVaccinatedPopulation