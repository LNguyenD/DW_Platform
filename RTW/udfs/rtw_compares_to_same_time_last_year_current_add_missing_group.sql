IF OBJECT_ID('udfs.rtw_compares_to_same_time_last_year_current_add_missing_group') IS NOT NULL
	DROP FUNCTION udfs.rtw_compares_to_same_time_last_year_current_add_missing_group
GO
CREATE function udfs.rtw_compares_to_same_time_last_year_current_add_missing_group()
	RETURNS TABLE
AS
RETURN 
(	
    select * from 
	(
	select Month_period =1
	union select Month_period =3
	union select Month_period =6
	union select Month_period =12
	) as tmp1
	cross join
	(

	select Measure_months =13
	union select Measure_months =26
	union select Measure_months =52
	union select Measure_months =78
	union select Measure_months =104) as tmp2

	cross join
	(
	select [type]='group'  ,Agency_Group  ='4' ,LT=0,WGT  =0   ,AVGDURN   =0   ,[Target] = 0
	union select [type]='group'  ,Agency_Group  ='6' ,LT=0,WGT  =0   ,AVGDURN   =0   ,[Target] = 0
	union select [type]='group'  ,Agency_Group  ='9' ,LT=0,WGT  =0   ,AVGDURN   =0   ,[Target] = 0
	
	union 
	select distinct [type]='agency' 
		   ,rtrim(isnull(sub.agency_name,'Miscellaneous')) as Agency_Group
		   ,LT = 0
		   ,WGT = 0
		   ,AVGDURN = 0
		   ,[Target] = 0
	from views.rtw_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
	   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)
	   
	union 
	select distinct [type]='agency' 
		   ,'POLICE & EMERGENCY SERVICES' as Agency_Group
		   ,LT = 0
		   ,WGT = 0
		   ,AVGDURN = 0
		   ,[Target] = 0
	from views.rtw_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
	   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11) 
	   and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Police','Fire','RFS')
	   
	union 
	select distinct [type]='agency' 
		   ,'HEALTH & OTHER' as Agency_Group
		   ,LT = 0
		   ,WGT = 0
		   ,AVGDURN = 0
		   ,[Target] = 0
	from views.rtw_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
	   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)  
	   and rtrim(isnull(sub.agency_name,'Miscellaneous')) in ('Health','Other')   
	   
	union 
	select distinct [type]='agency' 
		   ,'TMF' as Agency_Group
		   ,LT = 0
		   ,WGT = 0
		   ,AVGDURN = 0
		   ,[Target] = 0
	from views.rtw_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number 
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
	   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)     
	
	union   
	select distinct [type]='group' 
		   ,'TMF' as Agency_Group
		   ,LT = 0
		   ,WGT = 0
		   ,AVGDURN = 0
		   ,[Target] = 0
	from views.rtw_view uv left join ref.pol_agency_sub_category_mapping_reference sub on uv.POLICY_NO = sub.policy_number 
	where  uv.Remuneration_End = (SELECT max(Remuneration_End) FROM  views.rtw_view)
	   and  DATEDIFF(MM, Remuneration_Start, Remuneration_End) in (0,2,5,11)    
	) as tmp3
)
GO