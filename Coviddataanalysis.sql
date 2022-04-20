/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views
*/

-- Table containing data about covid deaths
SELECT *
From coviddeathss
Order by 3,4;

-- Table containing data about covid vaccinations
SELECT *
From covac
Order by 3,4;


-- Selecting Data to work with
SELECT location,date,total_cases,new_cases,total_deaths,population
From coviddeathss
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths*1.0/total_cases)*100 AS DeathPercentage
From coviddeathss
Where location='India'
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location,date,population,total_cases, (total_deaths*1.0/population)*100 AS Percentpopulationinfected
From coviddeathss
order by 1,2;


-- Countries with Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) AS MAXInfectioncount, MAX((total_cases*1.0/population))*100 AS Percentpopulationinfected
From coviddeathss
group by location, population
order by Percentpopulationinfected desc;


-- Countries with Highest Death Count per Population
SELECT location,MAX(total_deaths) AS deathcount
From coviddeathss
Where continent is NOT NULL AND total_deaths is NOT NULL
group by location
order by deathcount desc;


-- Contintents with the highest death count per population
SELECT continent,MAX(total_deaths) AS deathcount
From coviddeathss
Where continent is NOT NULL AND total_deaths is NOT NULL
group by continent
order by deathcount desc;


-- GLOBAL NUMBERS
SELECT date,SUM(total_cases) AS totalcases,SUM(new_deaths) AS newdeaths, (SUM(new_deaths)*1.0/SUM(total_cases))*100 AS deathpercent
From coviddeathss
Where continent is not null
Group by date
order by 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(new_vaccinations) OVER(partition by dea.location Order by dea.location,dea.date ) AS rollingvaccinations
From coviddeathss AS dea
join covac AS vac
ON dea.location=vac.location
AND dea.date=vac.date
Where dea.continent is NOT null
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query and saving it into a new table
WITH popvsvac AS
(
	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(new_vaccinations) OVER(partition by dea.location Order by dea.location,dea.date ) AS rollingvaccinations
From coviddeathss AS dea
join covac AS vac
ON dea.location=vac.location
AND dea.date=vac.date
Where dea.continent is NOT null
order by 2,3
)

SELECT *, (rollingvaccinations*1.0/population)*100 AS percentpopvaccinated INTO vaccinationstable
FROM popvsvac;


-- Creating View to store data for later visualizations
Create view vaccinationsview as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(new_vaccinations) OVER(partition by dea.location Order by dea.location,dea.date ) AS rollingvaccinations
From coviddeathss AS dea
join covac AS vac
ON dea.location=vac.location
AND dea.date=vac.date
Where dea.continent is NOT null;