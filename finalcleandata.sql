
--total rows=541,909
--135,080 rows whithout coustomer id 
--406,829 with customer id


with online_retail as(   --give the query a name 
SELECT   [InvoiceNo]
      ,[StockCode]
      ,[Description]
      ,[Quantity]
      ,[InvoiceDate]
      ,[UnitPrice]
      ,[CustomerID]
      ,[Country]
  FROM [project].[dbo].[opp]
  where [CustomerID] !=0
  )
  
  , quantity_unit_price as(										 --«Ì÷« ‰‰ÿÌ ··ﬂÊÌ—Ì  «”„ Õ Ï ‰” œ⁄ÌÂ« ﬂ√‰„« ÃœÊ· 
  --397,884 rows with quantity and unit price 
  select *from 
  online_retail														 --Â‰« «” œ⁄Ì‰« «·ﬂÊÌ—Ì «·Ì ”ÊÌ‰Â« Ê«·Ì ÂÌ »«⁄ »«— ÃœÊ· 
  where Quantity > 0 and UnitPrice > 0    )								--„›· — «›÷· „„« «Ÿ· «÷Ì› ‘—Êÿ ⁄ 
																	 -- ‰›” «·ﬂÊÌ—Ì Ê «Œ– Êﬁ  Ê«·ﬂÊœ Ì’Ì— „« „„« „— »
  
  -- dublicate cheack
  ,dublicate_rows as
  (
	  select * ,row_number() over (partition by InvoiceNo,StockCode,Quantity order by InvoiceNo) dub_flag
	  from quantity_unit_price 
	  )
	   --5,215 dublicated rows
	   --392,669 rows without dublicate
	  select *
	  into #online_retail_main			--Â‰« ‰„——«·ﬂÊÌ—Ì ﬂ ÃœÊ· Ì”„Ï 
		from dublicate_rows			 -- temp table 
		  where dub_flag =1			--Õ Ï „« «÷ÿ— «‰›– ﬂ· «·ﬂÊÌ—Ì Ê«‰„« »” «„——«·«”„ „«· «·ÃœÊ· «·„ƒﬁ  ÊÂÊ ÕÌ‰›– ﬂ·‘Ì 
	  
	  --clean data 
	  -- begin chohort anlysis
	  select * from  #online_retail_main

--unique identifire customer id
--initial startdate (first invoice date)
--revenue data

	select 
	CustomerID,min(InvoiceDate) first_purches, 
	DATEFROMPARTS(year(min(InvoiceDate)),month(min(InvoiceDate)),1) cohort_date --‰„—— »„ﬂ«‰ «·ÌÊ„ 1 ·«‰ «Õ‰… „« ‰Â „ ··ÌÊ„ 
		into #cohort															--„Ê „Â„ ›—ﬁ «·«Ì«„ Ê«‰„« ›ﬁÿ ‰—Ìœ ›—ﬁ «·«‘Â— ›‰€Ì— »«· «—ÌŒ
	from #online_retail_main
	group by CustomerID			 --‰”ÊÌ ﬂ—Ê» »«Ì ·√‰ «” ⁄„·‰… «ﬂ—ÌﬂÌ  ›«‰ﬂ‘‰ 


	select * 
	from #cohort

--create cohort index
	select mmm.* ,
	cohort_index = year_diff*12 + month_diff +1
	into #cohort_retention
		from (select  mm.*,
				year_diff = invoice_year - cohort_year,
				month_diff = invoice_month - cohort_month
from (
	select m.*,c.cohort_date,
		YEAR(m.InvoiceDate) invoice_year
		,month(m.InvoiceDate) invoice_month
		,year(c.cohort_date) cohort_year
		,month(c.cohort_date) cohort_month
	from #online_retail_main m
left join #cohort c  on c.CustomerID =m.CustomerID
	)mm
) mmm

--povit data to see cohort table
select * 
into #pivot_cohort
from 
(
	SELECT  distinct
	CustomerID,cohort_date,cohort_index

	from #cohort_retention
  
	)tbl  

--pivot table

PIVOT(
 Count(CustomerID)
for cohort_index in
		( 
		    [1],
		  [2],
		  [3],
		  [4], 
		  [5],
		  [6],
		  [7],
		  [8],
		  [9],
		 [10],
		 [11],
		 [12],
		 [13]	 )

) as pivot_table
  --order by cohort_date
   
   select  * from #pivot_cohort
   order by cohort_date


   select cohort_date ,
   (1.0 *[1]/[1] *100) as[1]
   ,(1.0 *[2]/[1] *100) as[2]
   ,(1.0 *[3]/[1] *100) as[3]
   ,(1.0 *[4]/[1] *100) as[4]
   ,(1.0 *[5]/[1] *100) as[5]
   ,(1.0 *[6]/[1] *100) as[6]
   ,(1.0 *[7]/[1] *100) as[7]
   ,(1.0 *[8]/[1] *100) as[8]
   ,(1.0 *[9]/[1] *100) as[9]
   ,(1.0 *[10]/[1] *100) as[10]
   ,(1.0 *[11]/[1] *100) as[11]
   ,(1.0 *[12]/[1] *100) as[12]
   ,(1.0 *[13]/[1] *100) as[13]
   from #pivot_cohort
   order by cohort_date