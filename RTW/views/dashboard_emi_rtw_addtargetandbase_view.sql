IF OBJECT_ID('views.dashboard_emi_rtw_addtargetandbase_view') IS NOT NULL
	DROP VIEW views.dashboard_emi_rtw_addtargetandbase_view
GO
CREATE VIEW views.dashboard_emi_rtw_addtargetandbase_view
AS		
	-- EML --
	SELECT [Type] = ''
		   ,[Value] = 'EML'
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							)
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							)					
		   ,Create_Date = GETDATE()
		   ,Remuneration = cast(year(tmp.Remuneration) AS varchar) 
		  + 'M' + CASE WHEN MONTH(tmp.Remuneration) <= 9 THEN '0' ELSE '' END 
		  + cast(month(tmp.Remuneration) AS varchar)
	FROM 
	(select * from 
		(SELECT   Remuneration = dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
			FROM          master.dbo.spt_values t1
			WHERE      'P' = type 
			AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59' 
			<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as t1
	CROSS JOIN

	(select [Value]='') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
		
	-- Group --
	UNION ALL
	SELECT [Type] = 'group'
		   ,[Value] = tmp.[group] 
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.[group]) =RTRIM([group]))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.[group]) =RTRIM([group]))					
		   ,Create_Date = GETDATE()
		   ,Remuneration = cast(year(tmp.Remuneration) AS varchar) 
		  + 'M' + CASE WHEN MONTH(tmp.Remuneration) <= 9 THEN '0' ELSE '' END 
		  + cast(month(tmp.Remuneration) AS varchar)
	FROM 
	(select * from 
		(SELECT   Remuneration = dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
			FROM          master.dbo.spt_values t1
			WHERE      'P' = type 
			AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59' 
			<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as t1
	CROSS JOIN

	(select distinct udfs.emi_getgroup_byteam_udf(Team) as [group] from views.RTW_view where [System] = 'EMI') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
		
	-- Employer size --
	UNION ALL
	SELECT [Type] = 'employer_size'
		   ,[Value] = tmp.EMPL_SIZE
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.EMPL_SIZE) =RTRIM(EMPL_SIZE))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.EMPL_SIZE) =RTRIM(EMPL_SIZE))					
		   ,Create_Date = GETDATE()
		   ,Remuneration = cast(year(tmp.Remuneration) AS varchar) 
		  + 'M' + CASE WHEN MONTH(tmp.Remuneration) <= 9 THEN '0' ELSE '' END 
		  + cast(month(tmp.Remuneration) AS varchar)
	FROM 
	(select * from 
		(SELECT   Remuneration = dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
			FROM          master.dbo.spt_values t1
			WHERE      'P' = type 
			AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59' 
			<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as t1
	CROSS JOIN

	(select distinct  [EMPL_SIZE] from views.RTW_view where [System] = 'EMI') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
	
	-- Account manager --
	UNION ALL
	SELECT [Type] = 'account_manager'
		   ,[Value] = tmp.[Account_Manager] 
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.[Account_Manager]) =RTRIM([Account_Manager]))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.[Account_Manager]) =RTRIM([Account_Manager]))					
		   ,Create_Date = GETDATE()
		   ,Remuneration = cast(year(tmp.Remuneration) AS varchar) 
		  + 'M' + CASE WHEN MONTH(tmp.Remuneration) <= 9 THEN '0' ELSE '' END 
		  + cast(month(tmp.Remuneration) AS varchar)
	FROM 
	(select * from 
		(SELECT   Remuneration = dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
			FROM          master.dbo.spt_values t1
			WHERE      'P' = type 
			AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59' 
			<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as t1
	CROSS JOIN

	(select distinct  [Account_Manager] from views.RTW_view where [System] = 'EMI') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
		
	-- Group -> Team --
	UNION ALL
	SELECT [Type] = 'group'
		   ,[Value] = tmp.[group] 
		   ,[Sub_Value] = tmp.Team
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.[group]) =RTRIM([group])
							AND RTRIM(tmp.[Team]) =RTRIM([Team]))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.[group]) =RTRIM([group])
							AND RTRIM(tmp.[Team]) =RTRIM([Team]))					
		   ,Create_Date = GETDATE()
		   ,Remuneration = cast(year(tmp.Remuneration) AS varchar) 
		  + 'M' + CASE WHEN MONTH(tmp.Remuneration) <= 9 THEN '0' ELSE '' END 
		  + cast(month(tmp.Remuneration) AS varchar)
	FROM 
	(select * from 
		(SELECT   Remuneration = dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
			FROM          master.dbo.spt_values t1
			WHERE      'P' = type 
			AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59' 
			<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as t1
	CROSS JOIN

	(select distinct udfs.emi_getgroup_byteam_udf(Team) as [group],[Team] from views.RTW_view where [System] = 'EMI') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp

	-- Account manager -> Employer size --
	UNION ALL
	SELECT [Type] = 'account_manager'
		   ,[Value] = tmp.Account_Manager 
		   ,[Sub_Value] = tmp.EMPL_SIZE
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.Account_Manager) =RTRIM(Account_Manager)
							AND RTRIM(tmp.EMPL_SIZE) =RTRIM(EMPL_SIZE))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(tmp.Remuneration) -1 as varchar(10)) +'/06/30',tmp.Remuneration)) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(tmp.Remuneration) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'EMI'
							AND RTRIM(tmp.Account_Manager) =RTRIM(Account_Manager)
							AND RTRIM(tmp.EMPL_SIZE) =RTRIM(EMPL_SIZE))
		   ,Create_Date = GETDATE()
		   ,Remuneration = cast(year(tmp.Remuneration) AS varchar) 
		  + 'M' + CASE WHEN MONTH(tmp.Remuneration) <= 9 THEN '0' ELSE '' END 
		  + cast(month(tmp.Remuneration) AS varchar)
	FROM 
	(select * from 
		(SELECT   Remuneration = dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
			FROM          master.dbo.spt_values t1
			WHERE      'P' = type 
			AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59' 
			<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as t1
	CROSS JOIN

	(select distinct  [Account_Manager],[EMPL_SIZE] from views.RTW_view where [System] = 'EMI') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp

GO