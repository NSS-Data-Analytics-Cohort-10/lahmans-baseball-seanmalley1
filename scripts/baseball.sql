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
SELECT namefirst, namelast, schoolname, SUM(salaries.salary) as sumsal
FROM people
INNER JOIN collegeplaying
USING (playerid)
INNER JOIN schools
USING(schoolid)
INNER JOIN salaries
USING(playerid)
WHERE schoolid = 'vandy' AND salary IS NOT NULL
GROUP BY namefirst, namelast, schoolname
ORDER BY sumsal DESC
--Answer: David Price


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT 
	CASE 
		WHEN pos = 'OF' THEN 'Outfield' 
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		END AS position,
		SUM(po) AS Putouts
FROM fielding		
WHERE fielding.yearid = '2016'
GROUP BY position 
ORDER BY Putouts DESC;
-- Answer: infield = 58934, Battery = 41424, outfield = 29560
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT ROUND(AVG(so),2) AS avg_strikeouts, ROUND(AVG(hr),2) AS avg_homeruns, yearid
FROM batting
WHERE yearid >= '1920'
GROUP BY yearid
ORDER BY yearid
--Answer: In general both are increasing 


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT batting.playerid, people.namefirst, people.namelast, batting.sb, batting.cs, ROUND((batting.sb::decimal/(batting.sb::decimal + batting.cs::decimal)),2) as success_stealing
FROM batting
LEFT JOIN PEOPLE 
USING (playerid)
WHERE batting.yearid >= '2016' AND batting.sb + batting.cs >= 20
ORDER BY success_stealing DESC
--ANSWER Chris Owings, 91 success rate%
	

-- 7.  From 1970 - 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? 
--Answer: Seattle Mariners 116, 
-- Doing this will probably result in an unusually small number of wins for a world series champion â€“ determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 - 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT name, wswin, w, l, yearid
FROM teams
WHERE wswin IS NOT NULL
	AND yearid BETWEEN 1970 AND 2016 AND wswin = 'N'
ORDER BY w DESC
--- For smallest number of wins --Answer: Seattle Mariners 116, 
SELECT name, wswin, w, l, yearid
FROM teams
WHERE wswin IS NOT NULL AND yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' 
GROUP BY name, wswin, w, l, yearid
ORDER BY w ASC
-- Answer: dodgers @ 47 wins in 1981

SELECT COUNT(name), name, wswin, w, l, yearid
FROM teams
WHERE wswin IS NOT NULL AND yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' AND yearid <> 1981
GROUP BY name, wswin, w, l, yearid
ORDER BY w ASC
--Answer Cardinals @ 78 wins in 2006

SELECT
    COUNT(DISTINCT t.yearid) AS Most_Wins_and_WS_winner, Most_Wins_and_WS_winner
FROM 
    teams t
INNER JOIN 
    seriespost s ON t.yearid = s.yearid AND t.teamid = s.teamidwinner AND s.round = 'WS'
WHERE 
    t.w = (SELECT MAX(w) FROM teams WHERE yearid = t.yearid) AND s.yearid != '1981' AND t.yearid BETWEEN 1970 AND 2016
--12 times where most wins AND ws winner 

SELECT yearid
FROM seriespost
WHERE yearid BETWEEN 1970 AND 2016 AND yearid != 1981
GROUP BY yearid
--45 seaons

-- ANSWER -- So 12/45 = .26 = 27% of the time.
--- SECOND PART OF 7 WHERE I USE TWO CTEs TO SOLVE IT ALL IN ONE GO
WITH winwin AS (
    SELECT COUNT(DISTINCT t.yearid) AS Most_Wins_and_WS_winner
    FROM teams t
    INNER JOIN seriespost s ON t.yearid = s.yearid AND t.teamid = s.teamidwinner AND s.round = 'WS'
    WHERE t.w = (SELECT MAX(w) FROM teams WHERE yearid = t.yearid) AND t.yearid != 1981 AND t.yearid BETWEEN 1970 AND 2016
), 
seasons AS (
    SELECT COUNT(DISTINCT yearid) as total_seasons
    FROM seriespost
    WHERE yearid BETWEEN 1970 AND 2016 AND yearid != 1981
)
SELECT (winwin.Most_Wins_and_WS_winner::float / seasons.total_seasons::float)*100 as percent_wins
FROM winwin, seasons;


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- SELECT * from homegames where games >= 10

SELECT park, (attendance/games) as avg_attendence
from homegames 
where games >= 10 AND year = 2016
ORDER BY park
--------------------
SELECT 'top_5' TYPE, *  FROM
(WITH top_5_attendance AS 
	(SELECT team, park,
		SUM(hg.attendance) AS attend_2016,
		SUM(hg.games) AS games,
-- 		ROUND((SUM(hg.attendance)/sum(hg.games)), 2) AS avg_attend
	 	(SUM(hg.attendance)/sum(hg.games)) AS avg_attend
		FROM homegames AS hg 
		WHERE hg.year = 2016
		GROUP BY team, park
		HAVING SUM(hg.games) >= 10
		ORDER BY avg_attend DESC
		LIMIT 5)
SELECT top_5_attendance.attend_2016, top_5_attendance.games, top_5_attendance.park, team_info.name
FROM top_5_attendance
INNER JOIN (SELECT * FROM teams ) as team_info ON top_5_attendance.team = team_info.teamid AND team_info.yearid = 2016
GROUP BY top_5_attendance.attend_2016, top_5_attendance.games, top_5_attendance.park, team_info.name
ORDER BY top_5_attendance.park)

UNION 
SELECT 'bottom_5' TYPE, * FROM 
(WITH bot AS 
	(SELECT team, park,
		SUM(hg.attendance) AS attend_2016,
		SUM(hg.games) AS games,
-- 		ROUND((SUM(hg.attendance)/sum(hg.games)), 2) AS avg_attend
	 	(SUM(hg.attendance)/sum(hg.games)) AS avg_attend
		FROM homegames AS hg 
		WHERE hg.year = 2016
		GROUP BY team, park
		HAVING SUM(hg.games) >= 10
		ORDER BY avg_attend ASC
		LIMIT 5)
SELECT bot.attend_2016, bot.games, bot.park, team_info.name
FROM bot
INNER JOIN (SELECT * FROM teams ) as team_info ON bot.team = team_info.teamid AND team_info.yearid = 2016
GROUP BY bot.attend_2016, bot.games, bot.park, team_info.name
ORDER BY bot.park)
ORDER BY 1 DESC, 2
-- ANSWER Top 5: Chicago Cubs, Sanfrancisco Giants, Toronto Blue Jays, St. Louis Cardinals, Los Angeles Dodgers
-- Bottom 5 Tampa Bay Rays, Oakland Atheletics, Cleveland Indians, Miami Marlins, Chicago White Sox.

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT *
FROM awardsmanagers

---------------------------------------------------------------------------------

SELECT 
    a.playerID,
    p.nameFirst,
    p.nameLast,
	t.teamid,
	tf.franchname
FROM 
    awardsmanagers a
JOIN 
    people p ON a.playerID = p.playerID
JOIN
	managers m ON p.playerID = m.playerID
JOIN 
	teams t USING(teamid)
JOIN 
	teamsfranchises tf USING(franchid)
WHERE 
    a.awardID = 'TSN Manager of the Year' AND (a.lgID = 'AL' OR a.lgID = 'NL')
GROUP BY 
    a.playerID, p.nameFirst, p.nameLast, t.teamid, tf.franchname
HAVING 
    COUNT(DISTINCT a.lgID) = 2;
-- ANSWER: Davey Johnson, managing Baltimore Orioles, Cincinnati Reds, LA Dodgers, New York Mets, Washington Nationals, Washington Senators, and Jim Leyland, managing Colorado Rockies, Detriot Tigers, Florida MArlins, Pittsburg Pirates

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- should be around 

SELECT 
    p.nameFirst,
    p.nameLast,
    b.HR
FROM 
    batting b
JOIN 
    people p USING(playerid)
WHERE 
    b.yearID = 2016 
    AND b.HR = (SELECT MAX(HR) FROM batting WHERE playerID = b.playerID)
    AND b.HR > 0 
    AND (SELECT COUNT(DISTINCT yearID) FROM batting WHERE playerID = b.playerID) >= 10
ORDER BY hr DESC
--Answer: Edwin Encarnacion 42, Robinson Cano 39, Mike Napoli 34, Justin Upton 31, Angel Pagan 12, Rajai Davis 12, Adam Wainwright 2, Francisco Liriano, 1, Bartolo Colon 1.


