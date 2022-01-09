/*
COVID-19 Data Exploration

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by location, date


-- Snapshot of data for preliminary analysis. (1, 2 in order by clause represent the first(location) and second(date) columns in select statement)

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Morbidity percentages
-- Can be further drilled down by using the where clause and specifying the country - abc

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%abc%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Percentage of population infected with COVID
-- Can be further drilled down by using the where clause and specifying the country - abc

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%abc%'
order by 1,2


-- Countries with Highest Infection Rate compared to total population
-- Can be further drilled down by using the where clause and specifying the country - abc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%abc%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
-- Can be further drilled down by using the where clause and specifying the country - abc

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%abc%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Analysis based on loacation - continents
-- Contintents with the highest death count per population
-- Can be further drilled down by using the where clause and specifying the country - abc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%abc%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- COVID Pandemic scenario - Global scope 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%abc%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By

-- Drop table if exists

DROP Table if exists #PercentPopulationVaccinated

--Create Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--Inset Data into Table

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
--where death.continent is not null 
--order by 2,3

--Select from Table

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creation of Views

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 



