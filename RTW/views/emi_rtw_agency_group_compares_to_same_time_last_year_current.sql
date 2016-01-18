IF OBJECT_ID('views.emi_rtw_agency_group_compares_to_same_time_last_year_current') IS NOT NULL
	DROP VIEW views.emi_rtw_agency_group_compares_to_same_time_last_year_current
GO
CREATE VIEW views.emi_rtw_agency_group_compares_to_same_time_last_year_current
AS
	WITH temp AS 
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
			select distinct 'WCNSW' as EmployerSize_Group,[Type]='employer_size'
			from views.rtw_view uv 
			where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
			   
			union
			select distinct rtrim(EMPL_SIZE) as EmployerSize_Group, [Type]='employer_size'
			from views.rtw_view uv 
			where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
			union
			select distinct 'WCNSW' as EmployerSize_Group, [Type]='group'
			from views.rtw_view uv 
			where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
			union
			select distinct udfs.emi_getgroup_byteam_udf(Team) as EmployerSize_Group, [Type]='group'
			from views.rtw_view uv 
			where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
			union
			select distinct 'WCNSW' as EmployerSize_Group, [Type]='account_manager'
			from views.rtw_view uv 
			where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
			union
			select distinct rtrim([Account_Manager]) as EmployerSize_Group, [Type]='account_manager'
			from views.rtw_view uv 
			where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
				and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
				
			) as temp_value
	)
	
	--Employer size---	
	select Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[Type]='employer_size'
			,'WCNSW' as EmployerSize_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.emi_rtw_gettargetandbase(Remuneration_End,'target','','EMI',NULL,Measure),0)
	from views.rtw_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by Measure,Remuneration_Start, Remuneration_End
	
	union all
	select top 100000000 Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[Type]='employer_size'
			,rtrim(EMPL_SIZE) as EmployerSize_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.emi_rtw_gettargetandbase(Remuneration_End,'target','employer_size',rtrim(EMPL_SIZE),NULL,Measure),0)
	from views.rtw_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by EMPL_SIZE,Measure,Remuneration_Start, Remuneration_End
	order by EMPL_SIZE
	---Group---
	union all
	
	select Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[Type]='group'
			,'WCNSW' as EmployerSize_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.emi_rtw_gettargetandbase(Remuneration_End,'target','','EMI',NULL,Measure),0)
	from views.rtw_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by Measure,Remuneration_Start, Remuneration_End
	
	union all
	select top 100000000 Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[Type]='group'
			,udfs.emi_getgroup_byteam_udf(Team) as EmployerSize_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.emi_rtw_gettargetandbase(Remuneration_End,'target','group',udfs.emi_getgroup_byteam_udf(Team),NULL,Measure),0)
	from views.rtw_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by udfs.emi_getgroup_byteam_udf(Team),Measure,Remuneration_Start, Remuneration_End	
	order by udfs.emi_getgroup_byteam_udf(Team)
	---Account manager---
	union all
	
	select Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[Type]='account_manager'
			,'WCNSW' as EmployerSize_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.emi_rtw_gettargetandbase(Remuneration_End,'target','','EMI',NULL,Measure),0)
	from views.rtw_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by Measure,Remuneration_Start, Remuneration_End
	
	union all
	select top 100000000 Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[Type]='account_manager'
			,rtrim([Account_Manager]) as EmployerSize_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.emi_rtw_gettargetandbase(Remuneration_End,'target','account_manager',rtrim([Account_Manager]),NULL,Measure),0)
	from views.rtw_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
		   and rtrim([Account_Manager]) is not null

	group by [Account_Manager],Measure,Remuneration_Start, Remuneration_End
	order by [Account_Manager]
	
	--add missing measure months
	union all
	select Month_period=case when month_period = 0
							then 1
						 when month_period = 2
							then 3
						 when month_period = 5
							then 6
						 when month_period = 11
							then 12
					end
		  ,[Type]
		  ,EmployerSize_Group
		  ,Measure_months
		  ,LT = 0
		  ,WGT = 0
		  ,AVGDURN = 0
		  ,[Target] = 0
	from temp as tmp
	where Measure_months not in (select distinct Measure from views.rtw_view uv
							where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
							and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) = tmp.month_period
							and case when [Type] = 'group' then (case when EmployerSize_Group <> 'WCNSW' then udfs.emi_getgroup_byteam_udf(rtrim(uv.Team)) else 'WCNSW' end)
									 when [Type] = 'employer_size' then (case when EmployerSize_Group <> 'WCNSW' then rtrim(uv.EMPL_SIZE) else 'WCNSW' end)
									 when [Type] = 'account_manager' then (case when EmployerSize_Group <> 'WCNSW' then rtrim(uv.Account_Manager) else 'WCNSW' end)
								end
									 = EmployerSize_Group)
GO