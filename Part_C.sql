/* Delete the tables if they already exist */
drop table  Restaurant;
drop table  Reviewer;
drop table  Rating;

/* Create the schema for our tables */
create table Restaurant(rID int, name varchar2(100), address varchar2(100), cuisine varchar2(100));
create table Reviewer(vID int, name varchar2(100));
create table Rating(rID int, vID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Restaurant values(101, 'India House Restaurant', '59 W Grand Ave Chicago, IL 60654', 'Indian');
insert into Restaurant values(102, 'Bombay Wraps', '122 N Wells St Chicago, IL 60606', 'Indian');
insert into Restaurant values(103, 'Rangoli', '2421 W North Ave Chicago, IL 60647', 'Indian');
insert into Restaurant values(104, 'Cumin', '1414 N Milwaukee Ave Chicago, IL 60622', 'Indian');
insert into Restaurant values(105, 'Shanghai Inn', '4723 N Damen Ave Chicago, IL 60625', 'Chinese');
insert into Restaurant values(106, 'MingHin Cuisine', '333 E Benton Pl Chicago, IL 60601', 'Chinese');
insert into Restaurant values(107, 'Shanghai Terrace', '108 E Superior St Chicago, IL 60611', 'Chinese');
insert into Restaurant values(108, 'Jade Court', '626 S Racine Ave Chicago, IL 60607', 'Chinese');

insert into Reviewer values(2001, 'Sarah M.');
insert into Reviewer values(2002, 'Daniel L.');
insert into Reviewer values(2003, 'B. Harris');
insert into Reviewer values(2004, 'P. Suman');
insert into Reviewer values(2005, 'Suikey S.');
insert into Reviewer values(2006, 'Elizabeth T.');
insert into Reviewer values(2007, 'Cameron J.');
insert into Reviewer values(2008, 'Vivek T.');

insert into Rating values( 101, 2001,2, DATE '2011-01-22');
insert into Rating values( 101, 2001,4, DATE '2011-01-27');
insert into Rating values( 106, 2002,4, null);
insert into Rating values( 103, 2003,2, DATE '2011-01-20');
insert into Rating values( 108, 2003,4, DATE '2011-01-12');
insert into Rating values( 108, 2003,2, DATE '2011-01-30');
insert into Rating values( 101, 2004,3, DATE '2011-01-09');
insert into Rating values( 103, 2005,3, DATE '2011-01-27');
insert into Rating values( 104, 2005,2, DATE '2011-01-22');
insert into Rating values( 108, 2005,4, null);
insert into Rating values( 107, 2006,3, DATE '2011-01-15');
insert into Rating values( 106, 2006,5, DATE '2011-01-19');
insert into Rating values( 107, 2007,5, DATE '2011-01-20');
insert into Rating values( 104, 2008,3, DATE '2011-01-02');

--1. Find the name of all restaurants offering Indian cuisine
Select name
from restaurant 
where cuisine = 'Indian';

--2. Find restaurant names that received a rating of 4 or 5, sort them in increasing order. 
Select  R.name, G.stars
from restaurant R, rating G
where G.stars>= 4 and R.rid = G.rid
Order by G.stars;

--3. Find the names of all restaurants that have no rating.
Select name 
from restaurant
where rid not in (select rid from rating);
--another solution
select R.name
from restaurant R left outer join rating G on R.rid = G.rid 
where G.stars is NULL;

--4. Some reviewers didn't provide a date with their rating. Find the names of 
--all reviewers who have ratings with a NULL value for the date. 
select G.name
from rating R left outer join reviewer G on R.vid = G.vid 
where R.ratingdate is NULL;

--5. For all cases where the same reviewer rated the same restaurant twice and 
--gave it a higher rating the second time, return the reviewer's name and the 
--name of the restaurant.
Select G.name, W.name
from (select r2.rid, r2.vid
from rating R1, rating R2
Where r1.rid = r2.rid and r1.vid = r2.vid and r1.ratingdate < r2.ratingdate and r1.stars < r2.stars) R,
reviewer G, restaurant W
where R.vid = G.vid and R.rid = W.rid;

--6. For each restaurant that has at least one rating, find the highest number 
--of stars that a restaurant received. Return the restaurant name and number of 
--stars. Sort by restaurant name. 
Select name, max(stars)
from (select W.name, G.stars
from restaurant W left outer join rating G on W.rid = G.rid
where G.stars IS NOT NULL)
Group by name
Order by name;

--7. For each restaurant, return the name and the 'rating spread', that is, the
--difference between highest and lowest ratings given to that restaurant. Sort 
--by rating spread from highest to lowest, then by restaurant name. 
Select name, R2.spread
from restaurant R, (select G.rid, (max(stars) - min(stars))as spread
from restaurant W left outer join rating G on W.rid = G.rid
where G.stars IS NOT NULL
Group by G.rid) R2
where R.rid = R2.rid
Order BY R2.spread DESC, R.name;

--8. Find the difference between the average rating of Indian restaurants and 
--the average rating of Chinese restaurants. (Make sure to calculate the average 
--rating for each restaurant, then the average of those averages for Indian and 
--Chinese restaurants. Don't just calculate the overall average rating for Indian 
--and Chinese restaurants.) Note: The difference can be negative. 
--select *
--from (Select Cuisine, avg(stars) as stars
--from (Select R.rid, W.cuisine, avg(stars) as stars
--from rating R, (Select * from restaurant 
--where cuisine = 'Indian' or cuisine = 'Chinese') W
--Where R.rid = W.rid
--Group by R.rid, W.cuisine) 
--Group by Cuisine);
select  avg(stars) - avg(stars1) as difference
from (Select R.rid, W.cuisine, avg(stars) as stars
from rating R, (Select * from restaurant 
where cuisine = 'Indian') W
Where R.rid = W.rid
Group by R.rid, W.cuisine), (Select R.rid, W.cuisine, avg(stars) as stars1
from rating R, (Select * from restaurant 
where cuisine = 'Chinese') W
Where R.rid = W.rid
Group by R.rid, W.cuisine);