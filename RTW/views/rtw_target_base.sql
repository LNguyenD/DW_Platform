IF OBJECT_ID('views.rtw_target_base') IS NOT NULL
	DROP VIEW views.rtw_target_base
GO
CREATE VIEW views.rtw_target_base
AS
	WITH
	values_by_type AS
	(
		select distinct Agency_Name as Value, '' as Sub_Value, [Type] = 'agency', [System]
		from views.rtw_view
		union all
		select distinct [Group] as Value, '' as Sub_Value, [Type] = 'group', [System]
		from views.rtw_view
		union all
		select distinct Portfolio as Value, '' as Sub_Value, [Type] = 'portfolio', [System]
		from views.rtw_view
		union all
		select distinct EMPL_SIZE as Value, '' as Sub_Value, [Type] = 'employer_size', [System]
		from views.rtw_view
		union all
		select distinct Account_Manager as Value, '' as Sub_Value, [Type] = 'account_manager', [System]
		from views.rtw_view
		union all
		select distinct Agency_Grouping as Value, '' as Sub_Value, [Type] = 'agency_grouping', [System]
		from views.rtw_view
		where Agency_Grouping <> '' and UPPER([System]) = 'TMF'
		union all
		select distinct Portfolio_Grouping as Value, '' as Sub_Value, [Type] = 'portfolio_grouping', [System]
		from views.rtw_view
		where Portfolio_Grouping <> '' and UPPER([System]) = 'HEM'
		union all
		select distinct [System] as Value, '' as Sub_Value, [Type] = 'total', [System]
		from views.rtw_view
	),
	measure_types AS
	(
		select 13 as Measure
		union select 26 as Measure
		union select 52 as Measure
		union select 78 as Measure
		union select 104 as Measure
	),
	remunerations AS
	(
		select * 
		from (select Remuneration = DATEADD(dd, - 1, DATEADD(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
				from master.dbo.spt_values tmp
				where 'P' = type
					and DATEADD(dd, - 1, DATEADD(m, number, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 23, 0))) + '23:59'
								<= cast(year(getdate()) as  varchar(10)) + '-12-31 ' + '23:59') as tmp
	)
	
	select	[Type], [System], Measure, Value, Sub_Value,
			[Target] = (select ISNULL(SUM(LT) / NULLIF(SUM(WGT),0),0)
		 						* POWER(CAST(0.9 as float),
		 							(CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,rem.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,rem.Remuneration))) as float)/18))
		 					from views.rtw_view rtw
							where rtw.Measure = m.Measure
								AND Remuneration_End = cast(year(DATEADD(mm,-3,rem.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
								AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11 
								AND rtw.[System] = val.[System]
								AND val.Value = case when val.[Type] = 'agency'
														then rtw.Agency_Name
													when val.[Type] = 'group'
														then rtw.[Group]
													when val.[Type] = 'portfolio'
														then rtw.Portfolio
													when val.[Type] = 'employer_size'
														then rtw.EMPL_SIZE
													when val.[Type] = 'account_manager'
														then rtw.Account_Manager
													when val.[Type] = 'agency_grouping'
														then rtw.Agency_Grouping
													when val.[Type] = 'portfolio_grouping'
														then rtw.Portfolio_Grouping
													else rtw.[System]
												end),
			[Base] = (select ISNULL(SUM(LT) / NULLIF(SUM(WGT),0),0)
								* POWER(CAST(0.9 as float),
									(CAST((DATEDIFF(mm,cast(year(DATEADD(mm,-3,rem.Remuneration)) -1 as varchar(10)) +'/06/30',DATEADD(mm,-3,rem.Remuneration))) as float)/18))*1.15
						from views.rtw_view rtw
						where rtw.Measure = m.Measure
							AND Remuneration_End = cast(year(DATEADD(mm,-3,rem.Remuneration)) -1 as varchar(10)) +'/09/30 23:59:00.000'
							AND DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							AND rtw.[System] = val.[System]
							AND val.Value = case when val.[Type] = 'agency'
														then rtw.Agency_Name
													when val.[Type] = 'group'
														then rtw.[Group]
													when val.[Type] = 'portfolio'
														then rtw.Portfolio
													when val.[Type] = 'employer_size'
														then rtw.EMPL_SIZE
													when val.[Type] = 'account_manager'
														then rtw.Account_Manager
													when val.[Type] = 'agency_grouping'
														then rtw.Agency_Grouping
													when val.[Type] = 'portfolio_grouping'
														then rtw.Portfolio_Grouping
													else rtw.[System]
												end),
			Remuneration = CAST(YEAR(rem.Remuneration) AS varchar) + 'M'
							+ case when MONTH(rem.Remuneration) <= 9 then '0' else '' end
							+ CAST(MONTH(rem.Remuneration) AS varchar)
	from values_by_type val
	cross join measure_types m
	cross join remunerations rem
GO