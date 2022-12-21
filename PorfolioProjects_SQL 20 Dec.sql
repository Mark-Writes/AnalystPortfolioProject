Select *
From PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProjects..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases,new_cases, total_deaths,population
From PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows probablbity of dying if you contract Covid in your Country

Select Location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where Location like '%States%'
Where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows percentage of population with Covid
Select Location,date,Population,total_cases,(total_cases/population)*100 as PercentPopluationInfected
From PortfolioProjects..CovidDeaths
--Where Location like '%States%'
Where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopluationInfected
From PortfolioProjects..CovidDeaths
--Where Location like '%States%'
Group by Location, population
Where continent is not null
order by PercentPopluationInfected desc

-- Showing Countries with Highest Death Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Broken Down By Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where Location like '%States%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store date for later visualations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3