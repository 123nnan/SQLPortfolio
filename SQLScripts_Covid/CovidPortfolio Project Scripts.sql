/*Select * From PortfolioProject..CovidDeaths
order by 3,4
Select * From PortfolioProject..CovidVaccines
order by 3,4*/

-- Selecting Data that is going to be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at Total Cases vs Total Deaths 
	--Converting total_deaths & total_cases as float for better pectentage value
	--Shows likelihood of dying if contracted covid for different countries (Philippines)
Select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%pines%'
Order by 1, 2

-- Looking at Total Cases vs Population
	--Shows what percentage of population have Covid
Select location, date, population, total_cases, (cast(total_cases as float) / population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
--where location like '%pines%'
Order by 1, 2


-- Looking at Countries with highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount, (Max(cast(total_cases as float)) / population)*100 as MaxInfectedPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
Order by MaxInfectedPercentage desc


-- Looknig at Countries with highest deathcount per population
	--looking at continent,and location, by settnig continent is not null, it would select only the continent value
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Breaking down by continent & country
	--looking at continent,and location, by settnig continent is not null, it would select only the continent value
Select continent, location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent, location
Order by continent, TotalDeathCount desc


-- Global Numbers
Select  SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, (SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_deaths != 0
Order by 1, 2


-- Joining CovidDeaths & CovidVaccines
Select * from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
 /* Creating CTE --PopVsVac-- */
With PopVsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
 as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

/* Creating Temp Table */
Drop Table if exists #PercentPopulationVaccinated --if ever there is need an alteration to a table
Create Table #PercentPopulationVaccinated (
	Continent varchar(255),
	Location varchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated bigint
	)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


/* Creating Views for storing data for later visualizations
 Global Number, Breaking down by continent & country, #PercentPopulationVaccinated
*/

Create View GlobalNumbers as
Select  SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, (SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_deaths != 0

Create View TotalDeathCounts as
Select continent, location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent, location

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

Create Table PortfolioProject..PopulationVaccinated (
	Continent varchar(255),
	Location varchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated bigint
	)

insert into PortfolioProject..PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

Create View PercentPopulationVaccinated as
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From PortfolioProject..PopulationVaccinated