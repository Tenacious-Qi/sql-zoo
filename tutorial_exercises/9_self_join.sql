-- How many stops are in the database. 

SELECT COUNT(id) AS stops
FROM stops;

-- Find the id value for the stop 'Craiglockhart' 

SELECT id
FROM stops
WHERE name = 'Craiglockhart';

-- Give the id and the name for the stops on the '4' 'LRT' service. 

SELECT id, name
FROM stops JOIN route ON stops.id = route.stop
WHERE route.num = '4' AND route.company = 'LRT';

-- The query shown gives the number of routes that 
-- visit either London Road (149) or Craiglockhart (53). 
-- Run the query and notice the two services 
-- that link these stops have a count of 2. 
-- Add a HAVING clause to restrict the output to these two routes. 

SELECT company, num, COUNT(*)
FROM route WHERE stop = 149 OR stop = 53
GROUP BY company, num
HAVING COUNT(*) = 2;

-- Execute the self join shown and observe that b.stop gives 
-- all the places you can get to from Craiglockhart, without changing routes. 
-- Change the query so that it shows 
-- the services from Craiglockhart to London Road.

SELECT a.company, a.num, a.stop, b.stop
FROM route a JOIN route b ON
a.company = b.company AND a.num = b.num
WHERE a.stop=53 AND b.stop = 149

-- The query shown is similar to the previous one, 
-- however by joining two copies of the stops table we can
-- refer to stops by name rather than by number.
--  Change the query so that the services between 
-- 'Fairmilehead' and 'Tollcross' are shown.

SELECT a.company, a.num, stopa.name, stopb.name
FROM route a JOIN route b ON
a.company = b.company AND a.num = b.num
JOIN stops AS stopa ON a.stop=stopa.id
JOIN stops AS stopb ON b.stop=stopb.id
WHERE stopa.name = 'Fairmilehead' AND stopb.name = 'Tollcross';

-- Give a list of all the services 
-- which connect stops 115 and 137 ('Haymarket' and 'Leith')

SELECT DISTINCT a.company, a.num
FROM route a JOIN route b ON
a.company = b.company AND a.num = b.num
WHERE a.stop = 115 AND b.stop = 137;

-- Give a list of the services 
-- which connect the stops 'Craiglockhart' and 'Tollcross' 

SELECT a.company, a.num
FROM route a JOIN route b ON
a.company = b.company AND a.num = b.num
JOIN stops AS stopa ON a.stop = stopa.id
JOIN stops AS stopb ON b.stop = stopb.id
WHERE stopa.name = 'Craiglockhart' AND stopb.name = 'Tollcross';

-- Give a distinct list of the stops which may be reached 
-- from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself,
-- offered by the LRT company
-- Include the company and bus no. of the relevant services. 

SELECT stops_table2.name, route_table2.company, route_table2.num
FROM route AS route_table1 JOIN route AS route_table2 ON
route_table1.company = route_table2.company AND route_table1.num = route_table2.num
JOIN stops AS stops_table1 ON route_table1.stop = stops_table1.id
JOIN stops AS stops_table2 ON route_table2.stop = stops_table2.id
WHERE stops_table1.name = 'Craiglockhart';

---------------------------------------------------------------------------------
-- I took the following solution from most upvoted solution at
-- https://stackoverflow.com/questions/24834948/self-join-tutorial-10-on-sqlzoo
-- comments are my own, reformatted, and added the ORDER BY clause

-- Find the routes involving two buses that can go from Craiglockhart to Lochend.
-- Show the bus no. and company for the first bus, the name of the stop for the transfer,
-- and the bus no. and company for the second bus. 
-- Hint
-- Self-join twice to find buses that visit Craiglockhart and Lochend, 
-- then join those on matching stops.

SELECT DISTINCT 1st.num AS first_bus, 1st.company AS first_company, 
                stops.name AS transfer, 
                2nd.num AS second_bus, 2nd.company AS second_company
FROM (
    SELECT a.company, a.num, b.stop
    -- first self-join
    FROM route a JOIN route b ON a.company = b.company AND a.num = b.num
    WHERE a.stop = (SELECT id FROM stops WHERE name = 'Craiglockhart')
) AS 1st
JOIN (
    SELECT a.company, a.num, b.stop
    -- second self-join
    FROM route a JOIN route b ON a.company = b.company AND a.num = b.num
    WHERE a.stop = (SELECT id FROM stops WHERE name = 'Lochend')
) AS 2nd
-- join the above two tables on their matching stops
ON 1st.stop = 2nd.stop
JOIN stops ON stops.id = 1st.stop
ORDER BY first_bus, transfer, second_bus;
