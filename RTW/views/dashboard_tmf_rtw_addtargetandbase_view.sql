IF OBJECT_ID('views.dashboard_tmf_rtw_addtargetandbase_view') IS NOT NULL
	DROP VIEW views.dashboard_tmf_rtw_addtargetandbase_view
GO
CREATE VIEW views.dashboard_tmf_rtw_addtargetandbase_view
AS
	--TMF--
	SELECT [Type] = ''
		   ,[Value] = 'TMF'
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							)
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
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
		
	--Agency--
	UNION ALL
	SELECT [Type] = 'agency'
		   ,[Value] = tmp.agencyname 
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.agencyname) = rtrim(isnull(sub.agency_name,'Miscellaneous')))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.agencyname) = rtrim(isnull(sub.agency_name,'Miscellaneous')))					
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

	(select distinct rtrim(isnull(sub.agency_name,'Miscellaneous')) as agencyname from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number and uv.[System] = 'TMF') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
		
	--Agency Police & Fire & RFS
	UNION ALL
	SELECT [Type] = 'agency'
		   ,[Value] = 'POLICE & EMERGENCY SERVICES'
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Police','Fire','RFS'))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Police','Fire','RFS'))
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

	(select [agencyname] = 'POLICE & EMERGENCY SERVICES') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
		
	--Agency Health & Other
	UNION ALL
	SELECT [Type] = 'agency'
		   ,[Value] = 'Health & Other'
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Health','Other'))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Health','Other'))
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

	(select [agencyname] = 'Health & Other') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp

	--Group--
	UNION ALL
	SELECT [Type] = 'group'
		   ,[Value] = tmp.[group] 
		   ,[Sub_Value] = NULL
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.[group]) = rtrim(isnull(sub.[Group],'Miscellaneous')))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.[group]) = rtrim(isnull(sub.[Group],'Miscellaneous')))					
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

	(select distinct rtrim(isnull(sub.[Group],'Miscellaneous')) as [group] from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number and uv.[System] = 'TMF') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp

	--Team--
	UNION ALL
	SELECT [Type] = 'group'
		   ,[Value] = tmp.[group] 
		   ,[Sub_Value] = Team
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.[group]) = rtrim(isnull(sub.[Group],'Miscellaneous'))
							AND RTRIM(tmp.[Team]) =RTRIM([Team]))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.[group]) = rtrim(isnull(sub.[Group],'Miscellaneous'))
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

	(select distinct rtrim(isnull(sub.[Group],'Miscellaneous')) as [group],[Team] from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number and uv.[System] = 'TMF') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp

	--Sub cagetory--
	UNION ALL
	SELECT [Type] = 'agency'
		   ,[Value] = tmp.agencyname 
		   ,[Sub_Value] = tmp.Sub_Category
		   ,[Measure]= tmp.measure 	   
		   ,[Target] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
		 					 * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))
		 			   FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.agencyname) = rtrim(isnull(sub.agency_name,'Miscellaneous'))
							AND RTRIM(tmp.sub_category) = rtrim(isnull(sub.Sub_Category,'Miscellaneous')))
		   ,[Base] = (select ISNULL(SUM(LT) / nullif(SUM(WGT),0),0) 
					   * POWER(CAST(0.9 as float), (CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,tmp.Remuneration))) as float)/18))*1.15
						FROM views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
					   WHERE Measure=tmp.Measure								 
							AND Remuneration_End = cast(year(DATEADD(mm,-3,tmp.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) =11 and [System] = 'TMF'
							AND RTRIM(tmp.agencyname) = rtrim(isnull(sub.agency_name,'Miscellaneous'))
							AND RTRIM(tmp.sub_category) = rtrim(isnull(sub.Sub_Category,'Miscellaneous')))					
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

	(select distinct rtrim(isnull(sub.agency_name,'Miscellaneous')) as agencyname, rtrim(isnull(sub.Sub_Category,'Miscellaneous')) as sub_category from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number and uv.[System] = 'TMF') as t2

	CROSS JOIN

	(select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure	) as t3) as tmp
GO