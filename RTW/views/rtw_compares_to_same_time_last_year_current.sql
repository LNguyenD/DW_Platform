IF OBJECT_ID('views.rtw_compares_to_same_time_last_year_current') IS NOT NULL
	DROP VIEW views.rtw_compares_to_same_time_last_year_current
GO
CREATE VIEW views.rtw_compares_to_same_time_last_year_current
AS	
	WITH
	values_by_type AS
	(
		select distinct Agency_Name as Value, [Type] = 'agency', [System]
		from views.rtw_view
		union all
		select distinct [Group] as Value, [Type] = 'group', [System]
		from views.rtw_view
		union all
		select distinct Portfolio as Value, [Type] = 'portfolio', [System]
		from views.rtw_view
		union all
		select distinct EMPL_SIZE as Value, [Type] = 'employer_size', [System]
		from views.rtw_view
		union all
		select distinct Account_Manager as Value, [Type] = 'account_manager', [System]
		from views.rtw_view
		union all
		select distinct [Agency_Grouping] as Value, [Type] = 'agency_grouping', [System]
		from views.rtw_view
		where [Agency_Grouping] <> ''
		union all
		select distinct [Portfolio_Grouping] as Value, [Type] = 'portfolio_grouping', [System]
		from views.rtw_view
		where [Portfolio_Grouping] <> ''
		union all
		select distinct [System] as Value, [Type] = 'total', [System]
		from views.rtw_view
	)

	select  Month_period = case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
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
			AVGDURN = SUM(LT) / NULLIF(SUM(WGT),0),
			[Target] = SUM(LT) / NULLIF(SUM(WGT),0) * 100 / NULLIF(udfs.rtw_get_target_base(rtw.[System], Remuneration_End, 'target', [Type], Value, NULL, Measure),0)
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
									when val.[Type] = 'agency_grouping'
										then rtw.Agency_Grouping
									when val.[Type] = 'portfolio_grouping'
										then rtw.Portfolio_Grouping
									else rtw.[System]
								end AND val.[System] = rtw.[System]
	where	DATEDIFF(MM, Remuneration_Start, Remuneration_End) IN (0, 2, 5, 11)
			AND rtw.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view WHERE [System] = rtw.[System])
	group by [Type], rtw.[System], Measure, Value, Remuneration_Start, Remuneration_End
GO