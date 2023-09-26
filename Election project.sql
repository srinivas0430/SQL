-- to find total votes per party excluding independent and NOTA

with cte as
(select distinct(Party), sum(votes) over (partition by party) as Total_votes from election)

select * from cte 
where party not in ('None of the Above','independent')
order by Total_votes desc;

-- to find winner and runner along with margin

with cte as 
(select *, rank() over (partition by constituency order by votes desc) as ran,
lead (votes) over (partition by constituency) leads
from election) 

select ran as 'Rank', upper(candidate) Candidate, Party,Constituency , District, Votes, (votes-leads) Margin
from cte
where ran in ('1','2');

-- to find where contestant won with less margin

with cte as 
(select *,rank() over (partition by constituency order by votes desc) as ran, (lead (votes) over (partition by constituency)) as leads
from election) 

select upper(Candidate) Candidate, Party,Constituency, District, Votes, (votes-leads) Margin
from cte
where ran in ('1') 
having margin <1000
order by margin asc;

-- to find where BJP came in 2nd place along with margin

with cte as 
(select *,rank() over (partition by constituency order by votes desc) as ran, (lag (votes) over (partition by constituency)) as leads
from election) 

select upper(candidate) Candidate, Party,Constituency, District, Votes, (votes-leads) Margin
from cte
where party in ('Bharatiya Janata Party') and ran in ('2')
order by margin desc;










