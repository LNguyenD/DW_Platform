IF OBJECT_ID('views.tmf_rtw_agency_group_compares_to_same_time_last_year_current') IS NOT NULL
	DROP VIEW views.tmf_rtw_agency_group_compares_to_same_time_last_year_current
GO
CREATE VIEW views.tmf_rtw_agency_group_compares_to_same_time_last_year_current
AS
	--Agency---	
	select Month_period=case when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 0
							then 1
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 2
							then 3
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 5
							then 6
						 when DATEDIFF(MM, Remuneration_Start, Remuneration_End) = 11
							then 12
					end
			,[type]='agency'
			,'TMF' as Agency_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.tmf_rtw_gettargetandbase(Remuneration_End,'target','agency','TMF',NULL,Measure),0)	
	from views.RTW_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by Measure,Remuneration_Start, Remuneration_End
	
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
			,[type]='agency'
			,rtrim(isnull(sub.agency_name,'Miscellaneous')) as Agency_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.tmf_rtw_gettargetandbase(Remuneration_End,'target','agency',rtrim(isnull(sub.agency_name,'Miscellaneous')),NULL,Measure),0)
	from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
		   
	group by rtrim(isnull(sub.agency_name,'Miscellaneous')),Measure, Remuneration_Start, Remuneration_End
	
	--Agency Police & Fire & RFS
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
			,[type]='agency'
			,'POLICE & EMERGENCY SERVICES' as Agency_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.tmf_rtw_gettargetandbase(Remuneration_End,'target','agency','POLICE & EMERGENCY SERVICES',NULL,Measure),0)
	from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
		   and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Police','Fire', 'RFS')

	group by Measure, Remuneration_Start, Remuneration_End
	
	--Agency Health & Other
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
			,[type]='agency'
			,'HEALTH & OTHER' as Agency_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.tmf_rtw_gettargetandbase(Remuneration_End,'target','agency','Health & Other',NULL,Measure),0)
	from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
		   and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Health','Other')

	group by Measure, Remuneration_Start, Remuneration_End
	
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
			,[type]='group'
			,'TMF' as Agency_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.tmf_rtw_gettargetandbase(Remuneration_End,'target','group','TMF',NULL,Measure),0)
	from views.RTW_view uv
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by Measure,Remuneration_Start, Remuneration_End
	
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
			,[type]='group'
			,rtrim(isnull(sub.[Group],'Miscellaneous')) as Agency_Group
			,Measure as Measure_months
			,sum(LT) as LT,sum(WGT) as WGT
			,sum(LT)/nullif(sum(WGT),0) as AVGDURN 
			,[Target] = sum(LT)/nullif(sum(WGT),0)*100/nullif(udfs.tmf_rtw_gettargetandbase(Remuneration_End,'target','group',rtrim(isnull(sub.[group],'Miscellaneous')),NULL,Measure),0)
	from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
		   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)

	group by rtrim(isnull(sub.[Group],'Miscellaneous')),Measure,Remuneration_Start, Remuneration_End	
	
	union all 
	select  Month_period
			,[type]
			,Agency_Group
			,Measure_months
			,LT
			,WGT
			,AVGDURN
			,[Target]
	from udfs.tmf_rtw_agency_group_compares_to_same_time_last_year_current_add_missing_group()
	where Measure_months not in (select distinct Measure from views.RTW_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
							where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.RTW_view)
							and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) = case when month_period = 1 then 0
																						   when month_period = 3 then 2
																						   when month_period = 6 then 5
																						   when month_period = 12 then 11
																					  end
							and CHARINDEX(case when RTRIM(Agency_Group) = 'TMF' then 'TMF' else RTRIM(sub.agency_name) end, RTRIM(Agency_Group),0) > 0
							)
GO