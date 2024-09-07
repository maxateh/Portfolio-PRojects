-- COVID DEATHS

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1, 2;


-- Total cases vs Total deaths
-- Shows he likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) AS death_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%Cameroon%'
WHERE continent is not null
order by 2 Desc;

-- Total Cases ve Population
-- Percentage of population that got covid

SELECT Location, date, population, total_cases, Round((total_cases/population)*100, 2) as case_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%Cameroon%'
WHERE continent is not null
order by 3 Desc;

-- Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as highest_infection_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 DESC;

-- Countries with highest death  count per population
SELECT Location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC;

-- Breaking it down by continent
-- Showing continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC;

-- GLOBAL NUMBERS

-- Global number of cases vs deaths per day
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 2) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1, 2 Desc;

-- Global total number of cases vs deaths
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 2) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null;



-- COVID VACCINATIONS
SELECT *
FROM PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations as vac
	ON deaths.location = vac.location
	and deaths.date = vac.date


-- Total population vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, deaths.new_vaccinations
FROM PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations as vac
	ON deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null
ORDER BY 1, 2, 3;

-- Total number of Rolling People Vaccinated

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations as vac
	ON deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null
ORDER BY 5 DESC;

-- Total population vs Vaccinations
-- Making use of a CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations as vac
	ON deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null
)

SELECT *
FROM PopvsVac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations as vac
	ON deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATER VIZ

CREATE VIEW PercentPopulationVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations as vac
	ON deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null

SELECT *
FROM PercentPopulationVaccinated