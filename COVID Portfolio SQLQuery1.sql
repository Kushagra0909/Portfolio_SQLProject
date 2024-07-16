select * 
from PortfolioProject..CovidDeaths
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases v/s total deaths
--shows likely hood of dying if covid hits your country
select Location,date,total_cases,total_deaths, (convert (float,total_deaths)/nullif (convert (float,total_cases),0)) 
as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%congo%'
order by 1,2

--looking at total_cases v/s population
-- shows what percentage of population got covid
select Location,date,population,total_cases, (convert (float,total_cases)/nullif (convert (float,population),0))
as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%congo%'
order by 1,2

--looking at countries having highest infection rates compared to population
select Location,population,MAX(total_cases) as HighestInfectionCount, MAX((convert (float,total_cases)/nullif (convert (float,population),0)))
as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%congo%'
group by Location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%congo%'
where continent is not null
group by Location
order by TotalDeathCount desc


--Lets break everything by Continent
--SHowing continents with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%congo%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select SUM(new_cases)as total_cases,SUM(new_deaths)as total_deaths, 
SUM((convert (float,new_deaths)))/SUM(nullif (convert (float,new_cases),0))*100 
as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%congo%'
where continent is not null
--group by date
order by 1,2



--Looking at total population vs Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3 



--Use CTE
With PopvsVac(continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Create view to store later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select*
from PercentPopulationVaccinated
