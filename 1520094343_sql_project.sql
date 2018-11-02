/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * FROM Facilities
WHERE membercost = 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost < monthlymaintenance * 0.2
AND membercost > 0


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN  'expensive'
ELSE  'cheap'
END AS  "Cheap or Expensive?"
FROM  `Facilities` 
ORDER BY 2 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (

SELECT MAX( joindate ) 
FROM  `Members`
)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT name, CONCAT(surname, ',', firstname) AS "Tennis Users"
FROM
(SELECT DISTINCT
M.surname ,M.firstname, 
F.name
FROM `Bookings` B
JOIN Members M
ON B.memid = M.memid
JOIN
(SELECT * 
FROM  `Facilities` 
WHERE name LIKE  "Tennis court%") F
ON B.facid = F.facid
ORDER BY M.surname, M.firstname, F.name) sub



/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

(SELECT F.name as Facility,
M.surname as Name, 
B.slots*guestcost  AS Cost
FROM 
(SELECT *
FROM Bookings 
WHERE LEFT(starttime, 10) = '2012-09-14') B
JOIN Facilities F
ON B.facid = F.facid
JOIN Members M
ON B.memid = M.memid
WHERE B.memid = 0
ORDER BY Cost DESC)


UNION ALL

(SELECT  f.name, 
		concat(m.firstname, ' ', m.surname) AS member,
		SUM(f.membercost*b.slots) AS cost
		
		FROM country_club.Bookings b
		JOIN country_club.Facilities f
			ON b.facid = f.facid
		JOIN country_club.Members m
			ON m.memid = b.memid
		WHERE left(starttime, 10) = '2012-09-14'
		AND m.memid != 0
		GROUP BY m.memid
		HAVING cost > 30
		ORDER BY cost DESC)



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

(SELECT F.name as Facility,
M.surname as Name, 
B.slots*guestcost  AS Cost
FROM 
(SELECT *
FROM Bookings 
WHERE LEFT(starttime, 10) = '2012-09-14') B
JOIN Facilities F
ON B.facid = F.facid
JOIN Members M
ON B.memid = M.memid
WHERE B.memid = 0
ORDER BY Cost DESC)

UNION ALL

(SELECT F.name as Facility, 
CONCAT(M.firstname, ' ', M.surname) as Name,
sub3.slots*F.membercost AS Cost
FROM
(SELECT facid, memid, slots
FROM Bookings B
WHERE memid IN
(SELECT memid
FROM
(SELECT M.memid, 
SUM(B.slots*membercost)  AS Member_Cost
FROM 
(SELECT *
FROM Bookings 
WHERE LEFT(starttime, 10) = '2012-09-14') B
JOIN Facilities F
ON B.facid = F.facid
JOIN Members M
ON B.memid = M.memid
WHERE B.memid != 0
GROUP BY M.memid
ORDER BY Member_Cost DESC) sub
WHERE Member_Cost > 30)
AND LEFT(starttime, 10) = '2012-09-14'
ORDER BY B.memid) sub3
JOIN Facilities F
ON sub3.facid = F.facid
JOIN Members M
ON sub3.memid = M.memid)


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name, Revenue
FROM
(SELECT B.facid, F.name,
SUM(CASE WHEN B.memid = 0 THEN B.slots*F.guestcost
ELSE B.slots*F.membercost END) AS Revenue
FROM Bookings B
JOIN Facilities F
ON B.facid = F.facid
GROUP BY 1,2) sub
WHERE Revenue < 1000
ORDER BY Revenue DESC























