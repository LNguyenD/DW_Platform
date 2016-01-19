IF OBJECT_ID('views.rtw_rolling_month_12') IS NOT NULL
	DROP VIEW views.rtw_rolling_month_12
GO
CREATE VIEW views.rtw_rolling_month_12
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
		where [Agency_Grouping] <> '' and UPPER([System]) = 'TMF'
		union all
		select distinct [Portfolio_Grouping] as Value, [Type] = 'portfolio_grouping', [System]
		from views.rtw_view
		where [Portfolio_Grouping] <> '' and UPPER([System]) = 'HEM'
		union all
		select distinct [System] as Value, [Type] = 'total', [System]
		from views.rtw_view
	)

	select  [Type], rtw.[System], Measure_months = Measure, Value,
			Remuneration_Start,
			Remuneration_End,
			Remuneration = CAST(YEAR(Remuneration_End) AS varchar)
							+ 'M' + CASE WHEN MONTH(Remuneration_End) <= 9 THEN '0' ELSE '' END 
							+ CAST(month(Remuneration_End) AS varchar),
			LT = SUM(LT),
			WGT = SUM(WGT),
			AVGDURN = SUM(LT) / NULLIF(SUM(WGT),0),
			[Target] = udfs.rtw_get_target_base(rtw.[System], Remuneration_End, 'target', [Type], Value, NULL, Measure),
			Base = udfs.rtw_get_target_base(rtw.[System], Remuneration_End, 'base', [Type], Value, NULL, Measure)
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
	where	DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
			AND rtw.Remuneration_End BETWEEN DATEADD(DAY, -1, DATEADD(M, -23 + DATEDIFF(M, 0, (SELECT MAX(Remuneration_End) FROM views.rtw_view WHERE [System] = rtw.[System])), 0)) + '23:59'
				AND (SELECT MAX(Remuneration_End) FROM views.rtw_view WHERE [System] = rtw.[System])
	group by [Type], rtw.[System], Measure, Value, Remuneration_Start, Remuneration_End
GO