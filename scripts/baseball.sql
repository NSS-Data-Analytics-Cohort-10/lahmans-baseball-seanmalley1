-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year),MAX(year)
FROM homegames
--Answer: 1871 - 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT playerid,height, namefirst, namelast, appearances.teamid, bats, throws, g_all, birthyear,deathyear,debut,finalgame, teams.name
FROM people
LEFT JOIN appearances
USING(playerid)
LEFT JOIN teams
USING(teamid)
ORDER BY height ASC
LIMIT 1




--Answer: Eddie Gaedel, 43. No team that I can find, One game.
-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each playerâ€™s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT namefirst, namelast, schoolid, SUM(salaries.salary) as sumsal, salaries.yearid,salary
FROM people
LEFT JOIN collegeplaying
USING (playerid)
LEFT JOIN schools
USING(schoolid)
LEFT JOIN salaries
USING(playerid)
WHERE schoolid = 'vandy' AND salary IS NOT NULL
GROUP BY namefirst, namelast, schoolid, salaries.yearid, salary
ORDER BY sumsal DESC
--Answer: David Price, but don't know why its not summing his salaries


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT
	CASE 
		WHEN pos = 'OF' THEN 'Outfield' 
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		END AS position,
		SUM(po) AS Putouts
FROM fielding		
INNER JOIN people
USING (playerid)
WHERE fielding.yearid = '2016'
GROUP BY  pos
ORDER BY Putouts DESC;
   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	

-- 7.  From 1970 â€“ 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion â€“ determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 â€“ 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
