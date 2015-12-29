IF OBJECT_ID('views.claim_portfolio_summary_last2weeks_view') IS NOT NULL
	DROP VIEW views.claim_portfolio_summary_last2weeks_view
GO
CREATE VIEW views.claim_portfolio_summary_last2weeks_view
AS
	/* agency */
	SELECT	Value = Agency_Name, [Type] = 'agency', [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type,
			[Sum] = COUNT(distinct Claim_No)
	FROM  (select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_new_all' 
			from views.claim_portfolio_view
			where ISNULL(Date_Claim_Entered, Date_Claim_Received) between '2015-12-13' and '2015-12-28 23:59'
			union all
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_new_lt' 
			from views.claim_portfolio_view where ISNULL(Date_Claim_Entered, Date_Claim_Received) between '2015-12-13' and '2015-12-28 23:59' and is_Time_Lost = 1
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_new_nlt' 
			from views.claim_portfolio_view where ISNULL(Date_Claim_Entered, Date_Claim_Received) between '2015-12-13' and '2015-12-28 23:59' and is_Time_Lost = 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_all' 
			from views.claim_portfolio_view
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59')
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_0_13' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 0
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 <= 13
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_13_26' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 13 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 <= 26
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_26_52' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 26 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 <= 52
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_52_78' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 52 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 <= 78
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_0_78' 
			from views.claim_portfolio_view
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 0 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 <= 78
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_78_130' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 78 
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 <= 130
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_gt_130' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 1
				and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, '2015-12-28 23:59')) / 7.0 > 130
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_nlt' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Time_Lost = 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_ncmm_this_week' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and NCMM_Actions_This_Week <> '' 
				and NCMM_Complete_Action_Due > '2015-12-28 23:59'
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_ncmm_next_week' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and NCMM_Actions_Next_Week <> ''
				and NCMM_Prepare_Action_Due between DATEADD(week, 1, '2015-12-28 23:59') and DATEADD(week, 3, '2015-12-28 23:59')
			union all
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_acupuncture' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Acupuncture_Paid > 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_chiro' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Chiro_Paid > 1000
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_massage' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Massage_Paid > 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_osteo' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Osteopathy_Paid > 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_physio' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Physio_Paid > 2000
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_rehab' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Rehab_Paid > 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_death' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Result_Of_Injury_Code = 1
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_industrial_deafness' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Is_Industrial_Deafness = 1
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_ppd' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Result_Of_Injury_Code = 3
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_recovery' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Total_Recoveries <> 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_all' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and WPI > 0
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_0_10' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and WPI > 0 and WPI <= 10
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_11_14' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and WPI >= 11 and WPI <= 14
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_15_20' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and WPI >= 15 and WPI <= 20
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_21_30' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and WPI >= 21 and WPI <= 30
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_31_more' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and WPI >= 31
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wid' 
			from views.claim_portfolio_view 
			where Claim_Closed_Flag <> 'Y'
				and (Date_Claim_Closed is null or Date_Claim_Closed < '2015-12-28 23:59')
				and (Date_Claim_Reopened is null or Date_Claim_Reopened < '2015-12-28 23:59') 
				and Common_Law = 1
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_closure' 
			from views.claim_portfolio_view
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_re_open' 
			from views.claim_portfolio_view
			union all 
			select Agency_Name, Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_still_open' 
			from views.claim_portfolio_view) as tmp_claim_all
		GROUP BY Agency_Name, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type
GO