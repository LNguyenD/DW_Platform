IF OBJECT_ID('views.claim_portfolio_detail_lastmonth_group_view') IS NOT NULL
	DROP VIEW views.claim_portfolio_detail_lastmonth_group_view
GO
CREATE VIEW views.claim_portfolio_detail_lastmonth_group_view
AS
	WITH
	claim_new_all AS
	(
		SELECT Agency_Name, Sub_Category, [System], Claim_No, Date_Of_Injury, Is_Time_Lost, Claim_Closed_Flag,
				Date_Claim_Entered, Date_Claim_Closed, Date_Claim_Received, Date_Claim_Reopened,
				Result_Of_Injury_Code, WPI, Common_Law, Total_Recoveries, Med_Cert_Status, Is_Working, Physio_Paid,
				Chiro_Paid, Massage_Paid, Osteopathy_Paid, Acupuncture_Paid, Rehab_Paid, Is_Medical_Only, Is_D_D,
				NCMM_Actions_This_Week, NCMM_Actions_Next_Week, NCMM_Complete_Action_Due, NCMM_Prepare_Action_Due,
				HoursPerWeek, Is_Industrial_Deafness, Age_of_claim = 0
		FROM views.claim_portfolio_view
		WHERE Reporting_Date <= '2016-01-11 23:59' 
			and ISNULL(Date_Claim_Entered, Date_Claim_Received) between '2013-01-11' and '2016-01-11 23:59'
	),
	claim_open_all AS
	(
		SELECT Agency_Name, Sub_Category, [System], Claim_No, Date_Of_Injury, Is_Time_Lost, Claim_Closed_Flag,
				Date_Claim_Entered, Date_Claim_Closed, Date_Claim_Received, Date_Claim_Reopened,
				Result_Of_Injury_Code, WPI, Common_Law, Total_Recoveries, Med_Cert_Status, Is_Working, Physio_Paid,
				Chiro_Paid, Massage_Paid, Osteopathy_Paid, Acupuncture_Paid, Rehab_Paid, Is_Medical_Only, Is_D_D,
				NCMM_Actions_This_Week, NCMM_Actions_Next_Week, NCMM_Complete_Action_Due, NCMM_Prepare_Action_Due,
				HoursPerWeek, Is_Industrial_Deafness, Age_of_claim = DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2016-01-11 23:59')) / 7.0
		FROM views.claim_portfolio_view
		WHERE Reporting_Date <= '2016-01-11 23:59'
			and Claim_Closed_Flag <> 'Y'
			and (Date_Claim_Closed is null or Date_Claim_Closed < '2016-01-11 23:59')
			and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2016-01-11 23:59')
	),
	claim_closure AS
	(
		SELECT Agency_Name, Sub_Category, [System], Claim_No, Date_Of_Injury, Is_Time_Lost, Claim_Closed_Flag,
				Date_Claim_Entered, Date_Claim_Closed, Date_Claim_Received, Date_Claim_Reopened,
				Result_Of_Injury_Code, WPI, Common_Law, Total_Recoveries, Med_Cert_Status, Is_Working, Physio_Paid,
				Chiro_Paid, Massage_Paid, Osteopathy_Paid, Acupuncture_Paid, Rehab_Paid, Is_Medical_Only, Is_D_D,
				NCMM_Actions_This_Week, NCMM_Actions_Next_Week, NCMM_Complete_Action_Due, NCMM_Prepare_Action_Due,
				HoursPerWeek, Is_Industrial_Deafness, Age_of_claim = 0
		FROM views.claim_portfolio_view cpr
		WHERE Reporting_Date <= '2016-01-11 23:59' 
			and Date_Claim_Closed between '2013-01-11' and '2016-01-11 23:59'
			and (exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
						where Reporting_Date <= DATEADD(DAY, -1, '2013-01-11') + '23:59' 
							and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'N')
							or ISNULL(cpr.Date_Claim_Entered, cpr.date_claim_received) >= '2013-01-11')
	),
	claim_re_open AS
	(
		SELECT Agency_Name, Sub_Category, [System], Claim_No, Date_Of_Injury, Is_Time_Lost, Claim_Closed_Flag,
				Date_Claim_Entered, Date_Claim_Closed, Date_Claim_Received, Date_Claim_Reopened,
				Result_Of_Injury_Code, WPI, Common_Law, Total_Recoveries, Med_Cert_Status, Is_Working, Physio_Paid,
				Chiro_Paid, Massage_Paid, Osteopathy_Paid, Acupuncture_Paid, Rehab_Paid, Is_Medical_Only, Is_D_D,
				NCMM_Actions_This_Week, NCMM_Actions_Next_Week, NCMM_Complete_Action_Due, NCMM_Prepare_Action_Due,
				HoursPerWeek, Is_Industrial_Deafness, Age_of_claim = 0
		FROM views.claim_portfolio_view
		WHERE Reporting_Date <= '2016-01-11 23:59' 
			and Date_Claim_Reopened between '2013-01-11' and '2016-01-11 23:59'
	),
	claim_re_open_still_open AS
	(
		SELECT Agency_Name, Sub_Category, [System], Claim_No, Date_Of_Injury, Is_Time_Lost, Claim_Closed_Flag,
				Date_Claim_Entered, Date_Claim_Closed, Date_Claim_Received, Date_Claim_Reopened,
				Result_Of_Injury_Code, WPI, Common_Law, Total_Recoveries, Med_Cert_Status, Is_Working, Physio_Paid,
				Chiro_Paid, Massage_Paid, Osteopathy_Paid, Acupuncture_Paid, Rehab_Paid, Is_Medical_Only, Is_D_D,
				NCMM_Actions_This_Week, NCMM_Actions_Next_Week, NCMM_Complete_Action_Due, NCMM_Prepare_Action_Due,
				HoursPerWeek, Is_Industrial_Deafness, Age_of_claim = 0
		FROM views.claim_portfolio_view cpr
		WHERE Reporting_Date <= '2016-01-11 23:59'
			and Date_Claim_Reopened between '2013-01-11' and '2016-01-11 23:59'
			and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
						where Reporting_Date <= DATEADD(DAY, -1, '2013-01-11') + '23:59'
							and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
	),
	claim_all AS
	(
		SELECT *
		FROM 
		(
			select *, claim_type = 'claim_new_all' from claim_new_all
			union all select *, claim_type = 'claim_new_lt' from claim_new_all where is_Time_Lost = 1
			union all select *, claim_type = 'claim_new_nlt' from claim_new_all where is_Time_Lost = 0
			union all select *, claim_type = 'claim_open_all' from claim_open_all
			union all select *, claim_type = 'claim_open_0_13' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 0 and Age_of_claim <= 13
			union all select *, claim_type = 'claim_open_13_26' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 13 and Age_of_claim <= 26
			union all select *, claim_type = 'claim_open_26_52' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 26 and Age_of_claim <= 52
			union all select *, claim_type = 'claim_open_52_78' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 52 and Age_of_claim <= 78
			union all select *, claim_type = 'claim_open_0_78' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 0 and Age_of_claim <= 78
			union all select *, claim_type = 'claim_open_78_130' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 78 and Age_of_claim <= 130
			union all select *, claim_type = 'claim_open_gt_130' from claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 130
			union all select *, claim_type = 'claim_open_nlt' from claim_open_all where is_Time_Lost = 0
			union all select *, claim_type = 'claim_open_ncmm_this_week' from claim_open_all where NCMM_Actions_This_Week <> '' 
				AND NCMM_Complete_Action_Due > '2016-01-11 23:59'
			union all select *, claim_type = 'claim_open_ncmm_next_week' from claim_open_all where NCMM_Actions_Next_Week <> ''
				AND NCMM_Prepare_Action_Due BETWEEN DATEADD(week, 1, '2016-01-11 23:59') AND DATEADD(week, 3, '2016-01-11 23:59')
			union all select *, claim_type = 'claim_open_acupuncture' from claim_open_all where Acupuncture_Paid > 0
			union all select *, claim_type = 'claim_open_chiro' from claim_open_all where Chiro_Paid > 1000
			union all select *, claim_type = 'claim_open_massage' from claim_open_all where Massage_Paid > 0
			union all select *, claim_type = 'claim_open_osteo' from claim_open_all where Osteopathy_Paid > 0
			union all select *, claim_type = 'claim_open_physio' from claim_open_all where Physio_Paid > 2000
			union all select *, claim_type = 'claim_open_rehab' from claim_open_all where Rehab_Paid > 0
			union all select *, claim_type = 'claim_open_death' from claim_open_all where Result_Of_Injury_Code = 1
			union all select *, claim_type = 'claim_open_industrial_deafness' from claim_open_all where Is_Industrial_Deafness = 1
			union all select *, claim_type = 'claim_open_ppd' from claim_open_all where Result_Of_Injury_Code = 3
			union all select *, claim_type = 'claim_open_recovery' from claim_open_all where Total_Recoveries <> 0
			union all select *, claim_type = 'claim_open_wpi_all' from claim_open_all where WPI > 0
			union all select *, claim_type = 'claim_open_wpi_0_10' from claim_open_all where WPI > 0 AND WPI <= 10
			union all select *, claim_type = 'claim_open_wpi_11_14' from claim_open_all where WPI >= 11 AND WPI <= 14
			union all select *, claim_type = 'claim_open_wpi_15_20' from claim_open_all where WPI >= 15 AND WPI <= 20
			union all select *, claim_type = 'claim_open_wpi_21_30' from claim_open_all where WPI >= 21 AND WPI <= 30
			union all select *, claim_type = 'claim_open_wpi_31_more' from claim_open_all where WPI >= 31
			union all select *, claim_type = 'claim_open_wid' from claim_open_all where Common_Law = 1
			union all select *, claim_type = 'claim_closure' from claim_closure
			union all select *, claim_type = 'claim_re_open' from claim_re_open
			union all select *, claim_type = 'claim_still_open' from claim_re_open_still_open
		) as tmp
	),
	claim_total_summary AS
	(
		SELECT	CAST(tmp.Agency_Name AS VARCHAR(256)) AS [Value]
				,CAST(tmp.Sub_Category AS VARCHAR(256)) AS [SubValue]
				,CAST('' AS VARCHAR(256)) AS [SubSubValue]
				,CAST('agency' AS VARCHAR(20)) AS [Type]
				,tmp.[System], tmp.Claim_Type, tmp.iClaim_Type
				,COALESCE(tmp1.ffsd_at_work_15_less, 0) as ffsd_at_work_15_less
				,COALESCE(tmp2.ffsd_at_work_15_more, 0) as ffsd_at_work_15_more
				,COALESCE(tmp3.ffsd_not_at_work, 0) as ffsd_not_at_work
				,COALESCE(tmp4.pid, 0) as pid
				,COALESCE(tmp5.totally_unfit, 0) as totally_unfit
				,COALESCE(tmp6.therapy_treat, 0) as therapy_treat
				,COALESCE(tmp7.d_d, 0) as d_d
				,COALESCE(tmp8.med_only, 0) as med_only
				,COALESCE(tmp9.lum_sum_in, 0) as lum_sum_in
				,COALESCE(tmp10.ncmm_this_week, 0) as ncmm_this_week
				,COALESCE(tmp11.ncmm_next_week, 0) as ncmm_next_week
				,COALESCE(tmp12.overall, 0) as overall
		FROM	
		(
			/* AGENCY -> SUB_CATEGORY */
			
			select * from views.claim_getall_claimtype_view
			cross join (select distinct Agency_Name, Sub_Category, [System]
						from views.claim_portfolio_view
						where Agency_Name <> '' and Sub_Category <> '') as tmp_value
		) as tmp
		LEFT OUTER JOIN
		(
			select COUNT(distinct Claim_No) as ffsd_at_work_15_less, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp1 ON tmp1.[System] = tmp.[System] and tmp1.Agency_Name = tmp.Agency_Name 
			and tmp1.Sub_Category = tmp.Sub_Category and tmp1.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as ffsd_at_work_15_more, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp2 ON tmp2.[System] = tmp.[System] and tmp2.Agency_Name = tmp.Agency_Name 
			and tmp2.Sub_Category = tmp.Sub_Category and tmp2.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as ffsd_not_at_work, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Med_Cert_Status = 'SID' and Is_Working = 0
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp3 ON tmp3.[System] = tmp.[System] and tmp3.Agency_Name = tmp.Agency_Name 
			and tmp3.Sub_Category = tmp.Sub_Category and tmp3.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as pid, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Med_Cert_Status = 'PID'
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp4 ON tmp4.[System] = tmp.[System] and tmp4.Agency_Name = tmp.Agency_Name 
			and tmp4.Sub_Category = tmp.Sub_Category and tmp4.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN
		(
			select COUNT(distinct Claim_No) as totally_unfit, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Med_Cert_Status = 'TU'
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp5 ON tmp5.[System] = tmp.[System] and tmp5.Agency_Name = tmp.Agency_Name 
			and tmp5.Sub_Category = tmp.Sub_Category and tmp5.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN
		(
			select COUNT(distinct Claim_No) as therapy_treat, [System], Agency_Name, Sub_Category, claim_type
			from claim_all
			where Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp6 ON tmp6.[System] = tmp.[System] and tmp6.Agency_Name = tmp.Agency_Name
			and tmp6.Sub_Category = tmp.Sub_Category and tmp6.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as d_d, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Is_D_D = 1
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp7 ON tmp7.[System] = tmp.[System] and tmp7.Agency_Name = tmp.Agency_Name 
			and tmp7.Sub_Category = tmp.Sub_Category and tmp7.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as med_only, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Is_Medical_Only = 1
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp8 ON tmp8.[System] = tmp.[System] and tmp8.Agency_Name = tmp.Agency_Name 
			and tmp8.Sub_Category = tmp.Sub_Category and tmp8.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as lum_sum_in, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0
				or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp9 ON tmp9.[System] = tmp.[System] and tmp9.Agency_Name = tmp.Agency_Name 
			and tmp9.Sub_Category = tmp.Sub_Category and tmp9.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN 
		(
			select COUNT(distinct Claim_No) as ncmm_this_week, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > '2016-01-11 23:59'
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp10 ON tmp10.[System] = tmp.[System] and tmp10.Agency_Name = tmp.Agency_Name 
			and tmp10.Sub_Category = tmp.Sub_Category and tmp10.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN
		(
			select COUNT(distinct Claim_No) as ncmm_next_week, [System], Agency_Name, Sub_Category, claim_type
			from claim_all 
			where NCMM_Actions_Next_Week <> ''
				and NCMM_Prepare_Action_Due BETWEEN DATEADD(week, 1, '2016-01-11 23:59') AND DATEADD(week, 3, '2016-01-11 23:59')
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp11 ON tmp11.[System] = tmp.[System] and tmp11.Agency_Name = tmp.Agency_Name 
			and tmp11.Sub_Category = tmp.Sub_Category and tmp11.claim_type = tmp.Claim_Type
			
		LEFT OUTER JOIN
		(
			select COUNT(distinct Claim_No) as overall, [System], Agency_Name, Sub_Category, claim_type
			from claim_all
			group by [System], Agency_Name, Sub_Category, claim_type
		) tmp12 ON tmp11.[System] = tmp.[System] and tmp12.Agency_Name = tmp.Agency_Name 
			and tmp12.Sub_Category = tmp.Sub_Category and tmp12.claim_type = tmp.Claim_Type
	)
		
	SELECT	Value,
			Claim_Type,
			[Type] = tmp_port_type.PORT_Type,
			[Sum] = (select (case when tmp_port_type.PORT_Type = 'ffsd_at_work_15_less'
									then tmp_total_2.ffsd_at_work_15_less
								when tmp_port_type.PORT_Type = 'ffsd_at_work_15_more'
									then tmp_total_2.ffsd_at_work_15_more
								when tmp_port_type.PORT_Type = 'ffsd_not_at_work'
									then tmp_total_2.ffsd_not_at_work
								when tmp_port_type.PORT_Type = 'pid'
									then tmp_total_2.pid
								when tmp_port_type.PORT_Type = 'totally_unfit'
									then tmp_total_2.totally_unfit
								when tmp_port_type.PORT_Type = 'therapy_treat'
									then tmp_total_2.therapy_treat
								when tmp_port_type.PORT_Type = 'd_d'
									then tmp_total_2.d_d
								when tmp_port_type.PORT_Type = 'med_only'
									then tmp_total_2.med_only
								when tmp_port_type.PORT_Type = 'lum_sum_in'
									then tmp_total_2.lum_sum_in
								when tmp_port_type.PORT_Type = 'ncmm_this_week'
									then tmp_total_2.ncmm_this_week
								when tmp_port_type.PORT_Type = 'ncmm_next_week'
									then tmp_total_2.ncmm_next_week
								when tmp_port_type.PORT_Type = 'overall'
									then tmp_total_2.overall
							end)
					from claim_total_summary tmp_total_2
					where tmp_total_2.[Value] = tmp_total.[Value]
						and tmp_total_2.Claim_Type = tmp_total.Claim_Type)
	FROM claim_total_summary tmp_total
	CROSS JOIN (SELECT * from views.claim_getall_porttype_view) tmp_port_type
GO