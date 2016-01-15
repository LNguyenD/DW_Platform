IF OBJECT_ID('views.hem_rtw_agency_group_rolling_month_12_view') IS NOT NULL
	DROP VIEW views.hem_rtw_agency_group_rolling_month_12_view
GO
CREATE VIEW views.hem_rtw_agency_group_rolling_month_12_view
AS
	SELECT    EmployerSize_Group = udfs.tmf_getgroup_byteam_udf(Team)
			  ,[Type] = 'group'
			  ,uv.Remuneration_Start 
			  ,uv.Remuneration_End
			  ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar) 
	          
			  ,Measure_months = Measure 
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'target','group',udfs.tmf_getgroup_byteam_udf(Team),NULL,uv.Measure)									
			  ,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'base','group',udfs.tmf_getgroup_byteam_udf(Team),NULL,uv.Measure)
							
	FROM      views.RTW_view uv 

	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
			  and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)

	GROUP BY  udfs.tmf_getgroup_byteam_udf(Team), uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL

	SELECT     EmployerSize_Group = rtrim(uv.Portfolio)
			   ,[Type] = 'portfolio' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'target','portfolio',uv.Portfolio,NULL,uv.Measure)									
			  ,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'base','portfolio',uv.Portfolio,NULL,uv.Measure)					 
	FROM         views.RTW_view uv 
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)
				and uv.Portfolio is not null
	GROUP BY  uv.Portfolio, uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	--Hotel summary--
	UNION ALL

	SELECT     EmployerSize_Group = 'Hotel'
			   ,[Type] = 'portfolio' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'target','portfolio','Hotel',NULL,uv.Measure)									
			  ,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'base','portfolio', 'Hotel',NULL,uv.Measure)					 
	FROM         views.RTW_view uv 
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)
				and uv.Portfolio is not null
				and uv.Portfolio in ('Accommodation','Pubs, Taverns and Bars')
	GROUP BY  uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL

	SELECT     EmployerSize_Group = rtrim(uv.Account_Manager)
			   ,[Type] = 'account_manager' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'target','account_manager',uv.Account_Manager,NULL,uv.Measure)									
			  ,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(uv.Remuneration_End,'base','account_manager',uv.Account_Manager,NULL,uv.Measure)					 
	FROM         views.RTW_view uv 
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)
				and rtrim(uv.Account_Manager) is not null
	GROUP BY  uv.Account_Manager, uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL
	SELECT     EmployerSize_Group ='Hospitality'
				,[Type] = 'group'
				,t.Remuneration_Start
				,t.Remuneration_End
				, Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months = Measure
				,LT= SUM(t.LT)
				,WGT= SUM(t.WGT)
				,AVGDURN= SUM(LT) / nullif(SUM(WGT),0)			
				,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(t.Remuneration_End,'target','group','Hospitality',NULL,t.Measure)
				,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(t.Remuneration_End,'base','group','Hospitality',NULL,t.Measure)

	FROM         views.RTW_view t
	inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.RTW_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end

	UNION ALL

	SELECT     EmployerSize_Group= 'Hospitality'
				,[Type] = 'portfolio'
				,t.Remuneration_Start
				,t.Remuneration_End
				,Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months= Measure
				,LT = SUM(t.LT)  
				,WGT =SUM(t.WGT)  
				,AVGDURN =SUM(LT) / nullif(SUM(WGT),0)  			
				,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(t.Remuneration_End,'target','portfolio','Hospitality',NULL,t.Measure)
				,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(t.Remuneration_End,'base','portfolio','Hospitality',NULL,t.Measure)
	            
	            
	FROM         views.RTW_view t inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.RTW_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end

	UNION ALL

	SELECT     EmployerSize_Group= 'Hospitality'
				,[Type] = 'account_manager'
				,t.Remuneration_Start
				,t.Remuneration_End
				,Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months= Measure
				,LT = SUM(t.LT)  
				,WGT =SUM(t.WGT)  
				,AVGDURN =SUM(LT) / nullif(SUM(WGT),0)  			
				,[Target] = udfs.dashboard_tmf_rtw_gettargetandbase_udf(t.Remuneration_End,'target','account_manager','Hospitality',NULL,t.Measure)
				,Base = udfs.dashboard_tmf_rtw_gettargetandbase_udf(t.Remuneration_End,'base','account_manager','Hospitality',NULL,t.Measure)
	            
	            
	FROM         views.RTW_view t inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.RTW_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end
GO