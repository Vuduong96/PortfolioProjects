
Select * 
From PortfolioProject..CovidDeaths
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Casses vs Total Deaths
-- Show likelihood of dying if you contract the covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%vietnam%'
order by 1,2 

-- Looking at Total Cases vs Population
-- Show what percentgae of population got Covid
Select Location, date, total_cases,Population, (total_cases/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%vietnam%'
order by 1,2 


-- Which country has the highest replaction rate

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/Population)*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing the country with the highest death counts per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths 
where continent is not null
Group by Location
order by TotalDeaths desc

-- Handle the continents (Asia, Europe,..) 
Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- LET's BREAK THINGS DOWN BY CONTINENT
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths 
where continent is null and Location !='World' and Location !='Upper middle income' and Location !='High income'
and Location != 'Low income' and Location != 'International' and Location != 'Lower middle income'
Group by Location
order by TotalDeaths desc

-- Showing the continent with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, 
SUM(cast(new_deaths as int))/sum(new_cases)*1000 as DeathPercentageGlobally
From PortfolioProject..CovidDeaths
where continent is not null
Group by Date
order by 1,2


-- Looking at Total Population vs Vaccinations
------ How many people in vietnam is vaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null and dea.location ='Vietnam'
order by date, location


-- USE CTE 
------ How many people in vietnam is vaccinated for EACH COUNTRY

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
) 

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null 

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null 


Select *
From PercentPopulationVaccinated