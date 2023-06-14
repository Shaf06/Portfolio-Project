
Select * 
From Portfolio..CovidDeaths
Where continent is not null
Order by 3,4

-- Selecting data that will be used 

Select Location, date, total_cases, new_cases, total_deaths, Population 
From Portfolio..CovidDeaths
Where continent is not null
Order by 1,2

-- Total Cases vs Total Deaths
-- Shows probability of dying if you come in contact with covid in your country  


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like '%india%'
And continent is not null
Order by 1,2


 --Total Cases vs Population 
 --Shows percentage of population infected with covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--Where location like '%india%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases)as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected 
From Portfolio..CovidDeaths
--Where location like '%india%'
Group by Location, Population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--Where location like '%india%'
Where continent is not null 
Group by continent 
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
--Where location like '%india%'
Where continent is not null 
--Group by date 
Order by 1,2


-- Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
   On dea.location = vac.location
   and dea.date =vac.date
Where dea.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinatons, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
   On dea.location = vac.location
   and dea.date =vac.date
Where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
   On dea.location = vac.location
   and dea.date =vac.date
--Where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data fo later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
   On dea.location = vac.location
   and dea.date =vac.date
Where dea.continent is not null 
--order by 2,3
