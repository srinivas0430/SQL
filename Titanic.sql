-- To find overall death percentage
select 
	sum(total_cases) Total_Cases,
    sum(total_deaths) Total_Deaths,
    (sum(total_deaths)/ sum(total_cases)) *100 Death_Per
from covidasiad

-- To find out maximum deaths in particular Continent (Asia)
select 
	continent,
    location,
	MAX(total_deaths) as Total_Deaths
from covidasiad
where continent = 'Asia'
group by location
order by total_deaths desc
limit 10


-- To find death percentage {Remove groupby we'll get overall per}
select 
	location,
    SUM(new_cases) Total_Cases,
    SUM(new_deaths) Total_Deaths,
    SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
from covidasiad
where location <> 'north korea'
group by location
order by Total_Deaths desc


-- To find overall population in a Continent

select 
	cd.continent Continent,
    cd.location Location,
    cv.population Population,
    SUM(cv.population) over (partition by cd.continent) as Total_Population

from covidasiad cd
join covidasiav cv
	on cd.location = cv.location
    and cd.date = cv.date

group by cd.location

order by cv.population desc

-- To compare between population and vaccination
-- NOTE : We cannot use calculation for another calculation
-- Using CTE method for temp table

with popvac (continent, location, date, new_vaccinations, population, Total_Vac)
as 
(
select 
	cd.continent,
    cd.location,
    cd.date,
    cv.new_vaccinations,
    cv.population,
    SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as Total_Vac
    
from coviddeathsasia cd
join covidvaccinationasia cv
	on cd.location = cv.location
    and cd.date = cv.date

where cv.new_vaccinations <> 0
-- group by cd.location (If you group here result will be changed. Hence if you are creating a temp table fix the values before sorting it out)
order by cd.location, Total_Vac desc
)

select location, population, Total_Vac, (Total_Vac/population *100) POP
from popvac
group by location
-- order by location, Total_Vac desc
