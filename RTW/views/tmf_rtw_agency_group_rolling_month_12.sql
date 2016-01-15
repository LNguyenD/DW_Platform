IF OBJECT_ID('views.tmf_rtw_agency_group_rolling_month_12') IS NOT NULL
	DROP VIEW views.tmf_rtw_agency_group_rolling_month_12
GO
CREATE VIEW views.tmf_rtw_agency_group_rolling_month_12
AS
	SELECT    Agency_Group = rtrim(isnull(sub.[Group],'Miscellaneous'))
			  ,[Type] = 'group'
			  ,uv.Remuneration_Start 
			  ,uv.Remuneration_End
			  ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar) 
	          
			  ,Measure_months = Measure 
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'target','group',rtrim(isnull(sub.[Group],'Miscellaneous')),NULL,uv.Measure)									
			  ,Base = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'base','group',rtrim(isnull(sub.[Group],'Miscellaneous')),NULL,uv.Measure)
							
	FROM      views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number

	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
			  and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)

	GROUP BY  rtrim(isnull(sub.[Group],'Miscellaneous')), uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL

	SELECT     Agency_Group = rtrim(isnull(sub.agency_name,'Miscellaneous'))
			   ,[Type] = 'agency' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'target','agency',rtrim(isnull(sub.agency_name,'Miscellaneous')),NULL,uv.Measure)									
			  ,Base = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'base','agency',rtrim(isnull(sub.agency_name,'Miscellaneous')),NULL,uv.Measure)					 
	FROM         views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)
	GROUP BY  rtrim(isnull(sub.agency_name,'Miscellaneous')), uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	--Agency Police & Fire & RFS--
	UNION ALL

	SELECT     Agency_Group = 'POLICE & EMERGENCY SERVICES'
			   ,[Type] = 'agency' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'target','agency','POLICE & EMERGENCY SERVICES',NULL,uv.Measure)
			  ,Base = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'base','agency','POLICE & EMERGENCY SERVICES',NULL,uv.Measure)
	FROM         views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)
				and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Police','Fire','RFS')
	GROUP BY  uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	--Agency Health & Other--
	UNION ALL

	SELECT     Agency_Group = 'HEALTH & OTHER'
			   ,[Type] = 'agency' 
			   ,uv.Remuneration_Start
			   ,uv.Remuneration_End
			   ,Remuneration = cast(year(uv.Remuneration_End) AS varchar) 
						  + 'M' + CASE WHEN MONTH(uv.Remuneration_End) <= 9 THEN '0' ELSE '' END + cast(month(uv.Remuneration_End) AS varchar)
	          
			  ,Measure_months = Measure
			  ,LT = SUM(uv.LT)
			  ,WGT = SUM(uv.WGT)
			  ,AVGDURN = SUM(uv.LT) / nullif(SUM(uv.WGT),0)
			  ,[Target] = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'target','agency','Health & Other',NULL,uv.Measure)									
			  ,Base = udfs.tmf_rtw_gettargetandbase(uv.Remuneration_End,'base','agency','Health & Other',NULL,uv.Measure)					 
	FROM         views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	WHERE	  DATEDIFF(MM, uv.Remuneration_Start, uv.Remuneration_End) =11 
				and uv.Remuneration_End between DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)), 0)) + '23:59' and (SELECT max(Remuneration_End) FROM  views.RTW_view)
				and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Health','Other')
	GROUP BY  uv.Remuneration_Start, uv.Remuneration_End, uv.Measure

	UNION ALL
	SELECT     Agency_Group ='TMF'
				,[Type] = 'group'
				,t.Remuneration_Start
				,t.Remuneration_End
				, Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months = Measure
				,LT= SUM(t.LT)
				,WGT= SUM(t.WGT)
				,AVGDURN= SUM(LT) / nullif(SUM(WGT),0)
				,[Target] = udfs.tmf_rtw_gettargetandbase(t.Remuneration_End,'target','group','TMF',NULL,t.Measure)
				,Base = udfs.tmf_rtw_gettargetandbase(t.Remuneration_End,'base','group','TMF',NULL,t.Measure)

	FROM         views.RTW_view t 
	inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.RTW_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end

	UNION ALL

	SELECT     Agency_Group= 'TMF'
				,[Type] = 'agency'
				,t.Remuneration_Start
				,t.Remuneration_End
				,Remuneration = cast(year(t .Remuneration_End) AS varchar) + 'M' + CASE WHEN MONTH(t .Remuneration_End) 
						  <= 9 THEN '0' ELSE '' END + cast(month(t .Remuneration_End) AS varchar)                      
				,Measure_months= Measure
				,LT = SUM(t.LT)  
				,WGT =SUM(t.WGT)  
				,AVGDURN =SUM(LT) / nullif(SUM(WGT),0) 			
				,[Target] = udfs.tmf_rtw_gettargetandbase(t.Remuneration_End, 'target','agency','TMF',NULL,t.Measure)
				,Base = udfs.tmf_rtw_gettargetandbase(t.Remuneration_End,'base','agency','TMF',NULL,t.Measure)

	FROM         views.RTW_view t inner join (SELECT     dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' AS Remuneration_End
						   FROM          master.dbo.spt_values
						   WHERE      'P' = type AND dateadd(dd, - 1, DateAdd(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT max(Remuneration_End) FROM  views.RTW_view)) - 23, 0))) + '23:59' <= (SELECT max(Remuneration_End) FROM  views.RTW_view)) u on t.Remuneration_End = u.Remuneration_End
	AND     DATEDIFF(MM, t .remuneration_start, t .remuneration_end) = 11
	GROUP BY  t .Measure, t .remuneration_start, t .remuneration_end
GO