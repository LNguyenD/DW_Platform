IF OBJECT_ID('views.rtw_compares_to_same_time_last_year_current') IS NOT NULL
	DROP VIEW views.rtw_compares_to_same_time_last_year_current
GO
CREATE VIEW views.rtw_compares_to_same_time_last_year_current
AS	
	WITH values_by_type AS 
	(
		select * 
		from
			(select 0 as month_period
			union all
			select 2 as month_period
			union all
			select 5 as month_period
			union all
			select 11 as month_period) as month_period
			cross join
			(select 13 as Measure_months
			union all
			select 26 as Measure_months
			union all
			select 52 as Measure_months
			union all
			select 78 as Measure_months
			union all
			select 104 as Measure_months) as measure_months		
			cross join
			(
				select distinct Agency_Name as Value, [Type]='agency', [System]
				from views.rtw_view uv 
				where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
				union
				
				select distinct rtrim(EMPL_SIZE) as Value, [Type]='employer_size', [System]
				from views.rtw_view uv 
				where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
				union
				select distinct rtrim([Account_Manager]) as Value, [Type]='account_manager', [System]
				from views.rtw_view uv 
				where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
				union
				select distinct rtrim(Portfolio) as Value, [Type]='portfolio', [System]
				from views.rtw_view uv 
				where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)		
					
				union
				select distinct [Group] as Value, [Type]='portfolio', [System]
				from views.rtw_view uv 
				where uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)				   				
				
				union all
								
				select distinct [Grouping] as Value, [Type] = 'grouping', [System]
				from views.rtw_view uv
				where uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11) and [Grouping] <> ''
					
				union all
				
				select distinct [System] as Value, [Type] = '', [System]
				from views.rtw_view uv
				where uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
			) as temp_value )
			
			
			
			select  Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end,
					[Type], rtw.[System], Measure_months = Measure, Value,					
					SUM(LT) as LT,
					SUM(WGT) as WGT,
					AVGDURN = SUM(LT) / NULLIF(SUM(WGT),0)		
				    ,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.rtw_get_target_base(rtw.[System], Remuneration_End, 'target', [Type], Value, NULL, Measure),0)
				    
			from    views.rtw_view rtw
					inner join values_by_type val
						on val.Value = case when val.[Type] = 'agency'
												then rtw.Agency_Name
											when val.[Type] = 'group'
												then rtw.[Group]
											when val.[Type] = 'portfolio'
												then rtw.Portfolio
											when val.[Type] = 'employer_size'
												then rtw.EMPL_SIZE
											when val.[Type] = 'account_manager'
												then rtw.Account_Manager
											when val.[Type] = 'grouping'
												then rtw.[Grouping]
											else rtw.[System]
										end AND val.[System] = rtw.[System]
			where	rtw.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
					and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
			group by [Type], rtw.[System], Measure, Value, Remuneration_Start, Remuneration_End

GO


