select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3, 4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3, 4

--select data that we are going to using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

--looking at the total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%anada'
and continent is not null
order by 1, 2

--Looking ar total cases vs population
--Shows waht percentage of population got Covid
select location, date, population, total_cases, (total_cases/population) * 100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%anada'
order by 1, 2

--Looking at Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population)) * 100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

--Showing the countries with the highest death count per population
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's break things down by contiennt
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing the contintents with the highest death count per population
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global number
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
sum(cast(new_deaths as int))/sum(New_Cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1, 2


-- Looking at Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from PortfolioProject.dbo.CovidDeaths as dea
inner join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from PortfolioProject.dbo.CovidDeaths as dea
inner join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac

--- Ues Temp table
Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from PortfolioProject.dbo.CovidDeaths as dea
inner join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


---Creating View to Store data for later visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from PortfolioProject.dbo.CovidDeaths as dea
inner join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated