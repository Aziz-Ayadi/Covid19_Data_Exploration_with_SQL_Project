-- A first look at our data of Covid Deaths
Select *
From CovidDeaths$
Where continent is not null
Order by 2, 3

-- Select data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null
Order by 1, 2

-- Total Cases vs Total Deaths (Shows likelihood of dying if you contract covid in your country)
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
From CovidDeaths$
Where continent is not null
and location like '%unisia'
Order by 1, 2

-- Total Cases vs Population (Shows what percentage of population infected with Covid)
Select location, date, total_cases, population, (total_cases / population) * 100 as PercentagePopulationInfected
From CovidDeaths$
Where continent is not null
and location like '%unisia'
Order by 1, 2

-- Countries with highest infection rate compared to population
Select location, MAX(total_cases) as MaximumInfectedPeople, population, MAX((total_cases / population) * 100) as PercentagePopulationInfected
From CovidDeaths$
Where continent is not null
Group by location, population
Order by 4 desc

-- Countries with highest death Count per Population
Select location, population, MAX(cast(total_deaths as int)) as MaximumDeadPeople
From CovidDeaths$
Where continent is not null
Group by location, population
Order by 3 desc

-- Breaking things down by Continent (Showing continents with the highest death count per population)
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths$
Where continent is not null
Group by continent
Order by 2 desc

-- Global numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
From CovidDeaths$
Where continent is not null

-- Total Population vs Vaccinations (Shows percentage of people that have received at least one Covid Vaccine)
Select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
SUM(Convert(int, new_vaccinations)) over (Partition by det.location order by det.location, det.date) as VaccinationPercentage
From CovidVaccinations$ as vac Inner Join CovidDeaths$ as det
On det.location = vac.location
and det.date = vac.date
where det.continent is not null
order by 2, 3

-- Using CTE in performing the previous query
With Vaccination_CTE as (
Select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
SUM(Convert(int, new_vaccinations)) over (Partition by det.location order by det.location, det.date) as TotalVaccinations
From CovidVaccinations$ as vac Inner Join CovidDeaths$ as det
On det.location = vac.location
and det.date = vac.date
where det.continent is not null
)
Select location, (TotalVaccinations / population) * 100 as VaccinationPercentage
From Vaccination_CTE
where location = 'United States'

-- Using Temp Table in performing the previous query
Drop Table if exists #VaccinationPercentage
Create Table #VaccinationPercentage(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)

Insert Into #VaccinationPercentage
Select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
SUM(Convert(int, new_vaccinations)) over (Partition by det.location order by det.location, det.date) as TotalVaccinations
From CovidVaccinations$ as vac Inner Join CovidDeaths$ as det
On det.location = vac.location
and det.date = vac.date
where det.continent is not null

Select location, (total_vaccinations / population) * 100 as VaccinationPercentage
From #VaccinationPercentage
where location = 'United States'