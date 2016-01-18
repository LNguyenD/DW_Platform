IF OBJECT_ID('views.emi_rtw_agency_group_rolling_month_12') IS NOT NULL
	DROP VIEW views.emi_rtw_agency_group_rolling_month_12
GO
CREATE VIEW views.emi_rtw_agency_group_rolling_month_12
AS
	SELECT    EmployerSize_Group = udfs.emi_getgroup_byteam_udf(Team)
			  ,[Type] = 'group'
			  ,uv.Remuneration_Start 
			  ,uv.Remuneration_End
			  ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar) 
	          
			  ,Measure_months = Measure 
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.emi_rtw_gettargetandbase(uv.Remuneration_End,'target','group',udfs.emi_getgroup_byteam_udf(Team),NULL,uv.Measure)									
			  ,Base = udfs.emi_rtw_gettargetandbase(uv.Remuneration_End,'base','group',udfs.emi_getgroup_byteam_udf(Team),NULL,uv.Measure)
							
	FROM      views.rtw_view uv 

	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
			  and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.rtw_view)

	GROUP BY  udfs.emi_getgroup_byteam_udf(Team), uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL

	SELECT     EmployerSize_Group = rtrim(uv.EMPL_SIZE)
			   ,[Type] = 'employer_size' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.emi_rtw_gettargetandbase(uv.Remuneration_End,'target','employer_size',uv.EMPL_SIZE,NULL,uv.Measure)									
			  ,Base = udfs.emi_rtw_gettargetandbase(uv.Remuneration_End,'base','employer_size',uv.EMPL_SIZE,NULL,uv.Measure)					 
	FROM         views.rtw_view uv 
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.rtw_view)
	GROUP BY  uv.EMPL_SIZE, uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

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
			  ,[Target] = udfs.emi_rtw_gettargetandbase(uv.Remuneration_End,'target','account_manager',uv.Account_Manager,NULL,uv.Measure)									
			  ,Base = udfs.emi_rtw_gettargetandbase(uv.Remuneration_End,'base','account_manager',uv.Account_Manager,NULL,uv.Measure)					 
	FROM         views.rtw_view uv 
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and rtrim(uv.Account_Manager) is not null
	GROUP BY  uv.Account_Manager, uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL
	SELECT     EmployerSize_Group ='WCNSW'
				,[Type] = 'group'
				,t.Remuneration_Start
				,t.Remuneration_End
				, Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months = Measure
				,LT= SUM(t.LT)
				,WGT= SUM(t.WGT)
				,AVGDURN= SUM(LT) / nullif(SUM(WGT),0)			
				,[Target] = udfs.emi_rtw_gettargetandbase(t.Remuneration_End,'target','group','EMI',NULL,t.Measure)
				,Base = udfs.emi_rtw_gettargetandbase(t.Remuneration_End,'base','group','EMI',NULL,t.Measure)

	FROM         views.rtw_view t 
	inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.rtw_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end

	UNION ALL

	SELECT     EmployerSize_Group= 'WCNSW'
				,[Type] = 'employer_size'
				,t.Remuneration_Start
				,t.Remuneration_End
				,Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months= Measure
				,LT = SUM(t.LT)  
				,WGT =SUM(t.WGT)  
				,AVGDURN =SUM(LT) / nullif(SUM(WGT),0) 			
				,[Target] = udfs.emi_rtw_gettargetandbase(t.Remuneration_End,'target','employer_size','EMI',NULL,t.Measure)
				,Base = udfs.emi_rtw_gettargetandbase(t.Remuneration_End,'base','employer_size','EMI',NULL,t.Measure)

	FROM         views.rtw_view t inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.rtw_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end

	UNION ALL

	SELECT     EmployerSize_Group= 'WCNSW'
				,[Type] = 'account_manager'
				,t.Remuneration_Start
				,t.Remuneration_End
				,Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months= Measure
				,LT = SUM(t.LT)  
				,WGT =SUM(t.WGT)  
				,AVGDURN =SUM(LT) / nullif(SUM(WGT),0) 			
				,[Target] = udfs.emi_rtw_gettargetandbase(t.Remuneration_End,'target','account_manager','EMI',NULL,t.Measure)
				,Base = udfs.emi_rtw_gettargetandbase(t.Remuneration_End,'base','account_manager','EMI',NULL,t.Measure)

	FROM         views.rtw_view t inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.rtw_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.rtw_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end
GO