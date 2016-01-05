IF OBJECT_ID('views.claim_portfolio_summary_group_view') IS NOT NULL
	DROP VIEW views.claim_portfolio_summary_group_view
GO
CREATE VIEW views.claim_portfolio_summary_group_view
AS
	WITH dte_range AS
	(
		/* For 3 years from yesterday */
		SELECT DATEADD(d, -1, CONVERT(datetime, CONVERT(char, GETDATE(), 106))) AS [Date]
		UNION ALL
		SELECT DATEADD(d, -1, [Date])
		FROM dte_range 
		WHERE [Date] > DATEADD(yy, -3, DATEADD(d, -1, CONVERT(datetime, CONVERT(char, GETDATE(), 106))))
	)
	
	SELECT	CAST([Value] AS VARCHAR(256)) AS [Value],
			CAST([SubValue] AS VARCHAR(256)) AS [SubValue],
			CAST([SubSubValue] AS VARCHAR(256)) AS [SubSubValue],
			CAST('group' AS VARCHAR(20)) AS [Type], [Start_Date], [End_Date], [System],
			Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type,
			[Sum] = COUNT(distinct Claim_No)
	FROM	(
				/* GROUP -> TEAM -> CLAIM_OFFICER */
	
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_new_all' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_new_lt' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_new_nlt' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_all' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_0_13' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 0
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 <= 13
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_13_26' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 13 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 <= 26
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_26_52' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 26 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 <= 52
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_52_78' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 52 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 <= 78
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_0_78' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 0 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 <= 78
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_78_130' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 78 
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 <= 130
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_gt_130' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 1
					and DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, [End_Date])) / 7.0 > 130
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_nlt' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Time_Lost = 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_ncmm_this_week' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and NCMM_Actions_This_Week <> '' 
					and NCMM_Complete_Action_Due > [End_Date]
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_ncmm_next_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_acupuncture' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Acupuncture_Paid > 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_chiro' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Chiro_Paid > 1000
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_massage' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Massage_Paid > 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_osteo' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Osteopathy_Paid > 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_physio' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Physio_Paid > 2000
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_rehab' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Rehab_Paid > 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_death' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Result_Of_Injury_Code = 1
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_industrial_deafness' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Is_Industrial_Deafness = 1
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_ppd' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Result_Of_Injury_Code = 3
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_recovery' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Total_Recoveries <> 0
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_all' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and WPI > 0
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_0_10' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and WPI > 0 and WPI <= 10
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_11_14' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and WPI >= 11 and WPI <= 14
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_15_20' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and WPI >= 15 and WPI <= 20
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_21_30' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and WPI >= 21 and WPI <= 30
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wpi_31_more' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and WPI >= 31
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_open_wid' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date]) 
					and Common_Law = 1
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_closure' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Closed between [Start_Date] and [End_Date]
					and (exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'N')
										or ISNULL(cpr.Date_Claim_Entered, cpr.date_claim_received) >= [Start_Date])
				union all
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_re_open' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
				union all 
				
				select Value = [Group], SubValue = Team, SubSubValue = Claims_Officer_Name, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type = 'claim_still_open' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
			) as tmp_claim_all
	GROUP BY Value, SubValue, SubSubValue, [Start_Date], [End_Date], [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type
GO