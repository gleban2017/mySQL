/*
Student: Gleb Chemborisov
Assignment 3
*/


/*
1. Write a query to list how many stations are found in each location. Output should list the location name and the station count, and the columns should have the headers 'Location' and '# Stations'. Only report locations with 100 or more stations, and list locations with the most stations first.
*/

select l.name as 'Location', count(s.stationid) as '# Stations' from location as l inner join stationbylocation as sl
on l.locationid=sl.locid
inner join station as s
on sl.staid=s.stationid
group by l.name
having count(s.stationid)>=100
order by  2 desc;



/*
2. Write a query to list location name, the minimum elevation of its stations, the maximum elevation of its stations, and the average elevation of its stations. Include only those locations with 100 or more stations, and round the average elevation to just 1 decimal place. Locations with the highest average elevation should be listed first.
*/



select l.name as 'Location', min(s.elevation) as 'Minimum Elevation', max(s.elevation) as 'Maximum Elevation', round(avg(s.elevation),1) as 'Average Elevation' from location as l inner join stationbylocation as sl
on l.locationid=sl.locid
inner join station as s
on sl.staid=s.stationid
group by l.name
having count(s.stationid)>=100
order by  3  desc;









/*
3.Write a query to list the location category name, the location name, the station name, and elevation of the locations that include the one station in the entire database that has the highest elevation. Your column headers should be “Category”, “Location”, “Station”, and “Elevation”. HINT: the station and elevation will be the same for all five rows of your output.
*/


select lc.name as 'Category',l.name as 'Location', s.name as 'Station', s.elevation as 'Elevation' from locationcategory as lc inner join locationbycategory as lbc 
on lc.lcid=lbc.catid
inner join location as l
on lbc.locid=l.locationid
inner join stationbylocation as sbl
on l.locationid=sbl.locid
inner join station as s
on sbl.staid=s.stationid
where s.elevation=(select max(elevation) from station);





/*
4.A. Write a query to report station elevation, absolute value of the latitude, and average of the mean daily temperature measured at the station. Restrict you query to the year 2008 and later. Order by elevation, and limit the query to just 50 results. NOTE: The “mean daily temperature” at a station should be calculated as (tmin + tmax)/2. Do not use TObs, as it is reported only by a small subset of the stations.
*/


select elevation as 'Elevation',abs(latitude) as 'Absolute Latitude',(tmin+tmax)/2  as 'Mean Daily Temperature' 
from station as s inner join tminmax as t
on s.stationid=t.stationid
where t.year>=2008 
order by elevation
limit 50;




/*
B. Write a query to report the average of each of the fields in the previous query. Write this query in 4 different ways:


1) Average over the 50 highest elevations
*/

select avg(elevation) as 'Average Elevation',avg(abs(latitude)) as 'Average Absolute Latitude',avg((tmin+tmax)/2)  as 'Average Mean Daily Temperature' from station as s inner join tminmax as t
on s.stationid=t.stationid
where elevation in(

      select * from (  select distinct(elevation) from station where stationid in (
					      select stationid from tminmax where year>=2008)

                       order by elevation desc
               limit 50) 
      as t1);






/*
2) Average over the 50 lowest elevations
*/


select avg(elevation) as 'Average Elevation',avg(abs(latitude)) as 'Average Absolute Latitude',avg((tmin+tmax)/2)  as 'Average Mean Daily Temperature' from station as s inner join tminmax as t
on s.stationid=t.stationid
where elevation in(

   select * from (  select  distinct(elevation) from station where stationid in (
                             select stationid from tminmax where year>=2008)

                    order by elevation asc
            limit 50
) as t1);




/*
3) Average over the 50 lowest latitudes
*/


select avg(elevation) as 'Average Elevation',avg(abs(latitude)) as 'Average Absolute Latitude',avg((tmin+tmax)/2)  as 'Average Mean Daily Temperature' from station as s inner join tminmax as t
on s.stationid=t.stationid
where abs(latitude) in(

   select * from (  select  distinct(abs(latitude)) from station where stationid in (
                             select stationid from tminmax where year>=2008)

                    order by abs(latitude) asc
            limit 50
) as t1);





/*
4) Average over the 50 highest latitudes
*/


select avg(elevation) as 'Average Elevation',avg(abs(latitude)) as 'Average Absolute Latitude',avg((tmin+tmax)/2)  as 'Average Mean Daily Temperature' from station as s inner join tminmax as t
on s.stationid=t.stationid
where abs(latitude) in(

   select * from (  select  distinct(abs(latitude)) from station where stationid in (
                             select stationid from tminmax where year>=2008)

                    order by abs(latitude) desc
            limit 50
) as t1);




/*
###################################################################################################################

Station Category	Average Elevation	Average Latitude	Average Temperature
High Elevation	 		4003					36.09			2.82
Low Elevation			1.56					36.57			16.5
Low Latitutes			306.98					3.46			25.75
High Latitudes			60.89					71.75			-6.69


###################################################################################################################
*/


/*
C. Do the results suggest that the hypothesis has merit? Suggest how you might be able to quantify the variation in temperature with latitude.


Results sugggest that temperature increases in both cases:
	1. The closer to the equator (the lower the latitude) - the higher the temperature
    2. The lower the elevation (height above the sea level) - the higher the temperature

Tghe latitude is counted in degrees 0-90 from the point of Equator (0) to the North (90) or to the South (-90)
Each step above or below the equator line is measured in degrees number which can be used in calculation of the respective termpearature ranges
*/




/*
5. This database is not fully normalized. The station fields mindate and maxdate ideally should reflect the minimum and maximum dates for which temperature data is available in tminmax. Similarly, the location fields mindate and maxdate should reflect the minimum and maximum dates for which temperature data is available in tminmax taken over all of the stations in each location.


A. Write a query to return the number of stations for which the station's maxdate's year is less than the maximum year in tminmax for that station.  Use only those entries in tminmax where year >= 2000
*/


select count(*) as '# of Stations' from station s1 where DATE_FORMAT(maxdate,'%Y')< (select max(year) from tminmax where stationid=s1.stationid and year>=2000);




/*

B. Write a query to return the count of locations for which the location's maxdate's year is less than the maximum year for any station in that location.  Again, use only those entries in tminmax where year >= 2000.
*/


select count(*) from location as loc where date_format(maxdate,'%Y')<(select max(tminmax.year) from  station inner join tminmax on station.stationid=tminmax.stationid 
inner join stationbylocation on station.stationid=stationbylocation.staid
inner join location on stationbylocation.locid=location.locationid
where loc.locationid=location.locationid  and tminmax.year>=2000);




/*
6. If you plot daily temperature for any particular station measured over several years, you will find that it is perfectly periodic due to earth’s unwavering orbit around the sun. This periodicity can be modeled with a function:
*/

/*
For the station data shown above (stationid=1115), write the following queries:
A. Write a query to estimate both Tmeanand A.
*/


select t1.year,  sum(t1.meantemp)/count(year) as 'Yearly Mean Temperature', sum(t1.amp)/count(year) as 'Amplitude of the seasonal fluctuation' from 
(select year, (tmin+tmax)/2 meantemp, (tmax-tmin) amp from tminmax where stationid=1115) t1
group by t1.year;



/*
For the station data shown above (stationid=1115), write the following queries:
B. Estimating φ requires two steps:
*/

select * from tminmax where (tmin+tmax)/2=(
select min((tmin+tmax)/2) from tminmax where stationid=1115 and year>=2008)
and stationid=1115 and year>=2008


