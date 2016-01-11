IF OBJECT_ID('views.claim_portfolio_detail_portfolio_view') IS NOT NULL
	DROP VIEW views.claim_portfolio_detail_portfolio_view
GO
CREATE VIEW views.claim_portfolio_detail_portfolio_view
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
			CAST('' AS VARCHAR(256)) COLLATE Latin1_General_CI_AS AS [SubSubValue],
			CAST('portfolio' AS VARCHAR(20)) AS [Type], [Start_Date], [End_Date], [System],
			Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type,
			[Sum] = COUNT(distinct Claim_No)
	FROM	(
				/* PORTFOLIO -> EMPLOYER_SIZE */
	
				/* BEGIN SECTION: NEW CLAIMS */
				
				/* All new claims */
	
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'ffsd_at_work_15_less'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'ffsd_at_work_15_more'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'ffsd_not_at_work'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'pid'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'totally_unfit'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'therapy_treat'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'd_d'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'med_only'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'lum_sum_in' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'ncmm_this_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_all', [Type] = 'ncmm_next_week'
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date]
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Time lost claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'ffsd_at_work_15_less' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'ffsd_at_work_15_more' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'ffsd_not_at_work' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'pid' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'totally_unfit' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'therapy_treat' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'd_d' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'med_only' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'lum_sum_in' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'ncmm_this_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_lt', [Type] = 'ncmm_next_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 1
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Non time lost claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'ffsd_at_work_15_less' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'ffsd_at_work_15_more' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'ffsd_not_at_work' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'pid' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'totally_unfit' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'therapy_treat' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'd_d' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'med_only' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'lum_sum_in' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'ncmm_this_week' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_new_nlt', [Type] = 'ncmm_next_week' 
				from views.claim_portfolio_view 
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and [End_Date] and is_Time_Lost = 0
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* END SECTION: NEW CLAIMS */
				
				/* BEGIN SECTION: OPEN CLAIMS */
				
				/* All open claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'ffsd_at_work_15_less' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'ffsd_at_work_15_more' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'ffsd_not_at_work' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'pid' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'totally_unfit' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'therapy_treat' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'd_d' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'med_only' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'lum_sum_in' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'ncmm_this_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Claim_Closed_Flag <> 'Y'
					and (Date_Claim_Closed is null or Date_Claim_Closed < [End_Date])
					and (Date_Claim_Reopened is null or Date_Claim_Reopened < [End_Date])
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_all', [Type] = 'ncmm_next_week' 
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
				
				/* RTW 0 - 13 weeks */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_13', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* RTW 13 - 26 weeks */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_13_26', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* RTW 26 - 52 weeks */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_26_52', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* RTW 52 - 78 weeks */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'ncmm_this_week'
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_52_78', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* RTW SubTotal 0-78 */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_0_78', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* RTW 78 - 130 weeks */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'ffsd_at_work_15_more'
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_78_130', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* RTW > 130 weeks */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_gt_130', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Non time lost claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_nlt', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* NCMM actions for this week */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'ncmm_this_week' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_this_week', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* NCMM actions for next week */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'pid'
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ncmm_next_week', [Type] = 'ncmm_next_week' 
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
				
				/* BEGIN SECTION: OPEN CLAIMS - THERAPY TREATMENT */
				
				/* Acupuncture */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'ffsd_at_work_15_less'
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'therapy_treat' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_acupuncture', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Chiro > $1.000 */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'therapy_treat' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_chiro', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Massage */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'therapy_treat' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_massage', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Osteopathy */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'therapy_treat' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_osteo', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Physio > $2.000 */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'therapy_treat' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_physio', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Rehab */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'ffsd_at_work_15_more'
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'therapy_treat' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'med_only'
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_rehab', [Type] = 'ncmm_next_week'
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* END SECTION: OPEN CLAIMS - THERAPY TREATMENT */
				
				/* BEGIN SECTION: OPEN CLAIMS - LUMP SUM INTIMATIONS */
				
				/* Death claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_death', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Industrial deafness claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_industrial_deafness', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Permanent partial disablement claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_ppd', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Recoveries claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'ffsd_not_at_work'
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_recovery', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* WPI All */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_all', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* WPI 0 - 10% */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_0_10', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* WPI 11 - 14% */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'lum_sum_in'
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_11_14', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* WPI 15 - 20% */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_15_20', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* WPI 21 - 30% */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_21_30', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* WPI >= 31% */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wpi_31_more', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* Common law */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,	
					Claim_Type = 'claim_open_wid', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'lum_sum_in' 
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
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_open_wid', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* END SECTION: OPEN CLAIMS - LUMP SUM INTIMATIONS */
				
				/* END SECTION: OPEN CLAIMS */
				
				/* BEGIN SECTION: CLAIM CLOSURES */
				
				/* Claim closures */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'ffsd_at_work_15_less' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'ffsd_at_work_15_more' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'ffsd_not_at_work' 
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
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'pid' 
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
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'totally_unfit' 
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
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'therapy_treat' 
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
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'd_d' 
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
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'med_only' 
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
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'lum_sum_in' 
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
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'ncmm_this_week' 
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
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_closure', [Type] = 'ncmm_next_week' 
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
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* END SECTION: CLAIM CLOSURES */
				
				/* BEGIN SECTION: REOPENED CLAIMS */
				
				/* Reopened claims */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'ffsd_at_work_15_less' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'ffsd_at_work_15_more' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'ffsd_not_at_work' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'pid' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'totally_unfit' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'therapy_treat' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'd_d' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'med_only' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'lum_sum_in' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'ncmm_this_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_re_open', [Type] = 'ncmm_next_week' 
				from views.claim_portfolio_view
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				union all
				
				/* END SECTION: REOPENED CLAIMS */
				
				/* BEGIN SECTION: REOPENED CLAIMS: STILL OPEN */
				
				/* Reopened claims: Still open */
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'ffsd_at_work_15_less'
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek <= 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'ffsd_at_work_15_more' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Med_Cert_Status = 'SID' and Is_Working = 1 and HoursPerWeek > 15
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'ffsd_not_at_work' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Med_Cert_Status = 'SID' and Is_Working = 0
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'pid' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Med_Cert_Status = 'PID'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'totally_unfit' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Med_Cert_Status = 'TU'
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'therapy_treat'
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'd_d' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Is_D_D = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'med_only' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and Is_Medical_Only = 1
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'lum_sum_in' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'ncmm_this_week' 
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and NCMM_Actions_This_Week <> '' and NCMM_Complete_Action_Due > [End_Date]
				union all
				
				select Value = Portfolio, SubValue = EMPL_SIZE, [Start_Date], [End_Date], Claim_No, [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive,
					Claim_Type = 'claim_still_open', [Type] = 'ncmm_next_week'
				from views.claim_portfolio_view cpr
				CROSS JOIN (
					SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
					CROSS JOIN dte_range dte2
					WHERE dte1.[Date] <= dte2.[Date]
				) dte_range
				where Reporting_Date <= [End_Date] and Date_Claim_Reopened between [Start_Date] and [End_Date]
					and exists (select [Claim_No] from views.claim_portfolio_view cpr_prior
									where Reporting_Date <= DATEADD(DAY, -1, [Start_Date]) + '23:59' and cpr_prior.Claim_No = cpr.Claim_No and cpr_prior.Claim_Closed_Flag = 'Y')
					and NCMM_Actions_Next_Week <> ''
					and NCMM_Prepare_Action_Due between DATEADD(week, 1, [End_Date]) and DATEADD(week, 3, [End_Date])
				
				/* END SECTION: REOPENED CLAIMS: STILL OPEN */
				
			) as tmp_claim_all
	GROUP BY Value, SubValue, [Start_Date], [End_Date], [System], Claim_Liability_Indicator_Group, Is_Stress, Is_Inactive_Claims, Is_Medically_Discharged, Is_Exempt, Is_Reactive, Claim_Type
GO