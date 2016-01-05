IF OBJECT_ID('views.claim_portfolio_view') IS NOT NULL
	DROP VIEW views.claim_portfolio_view
GO
CREATE VIEW views.claim_portfolio_view
AS
	/* Get data from DART for testing */
	
	--/* TMF */
	--SELECT TOP 10000 *
	--FROM [Dart].[dbo].[uv_PORT]
	--WHERE [System] = 'TMF'
	
	--UNION ALL
	
	--/* EML */
	--SELECT TOP 10000 *
	--FROM [Dart].[dbo].[uv_PORT]
	--WHERE [System] = 'EML'
	
	--UNION ALL
	
	--/* HEM */
	--SELECT TOP 10000 *
	--FROM [Dart].[dbo].[uv_PORT]
	--WHERE [System] = 'HEM'
	
	/* Get data from data warehouse: IN PROGRESS */
		
	SELECT
		'' [Reporting_Date],
		cdr.source_system_code [System],
		RTRIM(ISNULL('','Miscellaneous')) [Agency_Name],
		'' [Sub_Category],
		'' [Group],
		'' [Team],
		'' [Claims_Officer_Name],
		'' [EMPL_SIZE],
		'' [Account_Manager],
		'' [Portfolio],
		'' [Broker_Name],
		'' [Grouping],
		cdr.claim_number [Claim_No],
		'' [Policy_No],
		'' [WIC_Code],
		'' [Company_Name],
		wd.given_names + ', ' + wd.surname [Worker_Name],
		'' [Employee_Number],
		'' [Worker_Phone_Number],
		wd.date_of_birth [Date_Of_Birth],
		cd.date_of_injury [Date_Of_Injury],
		'' [Date_Of_Notification],
		'' [Notification_Lag],
		'' [Entered_Lag],
		sd.liability_status_code_description [Claim_Liability_Indicator_Group],
		'' [Is_Time_Lost],
		sd.claim_closed_flag [Claim_Closed_Flag],
		cd.date_claim_entered [Date_Claim_Entered],
		'' [Date_Claim_Closed],
		'' [Date_Claim_Received],
		'' [Date_Claim_Reopened],
		itd.result_of_injury_code [Result_Of_Injury_Code],
		cd.final_wpi_percentage [WPI],
		'' [Common_Law],
		'' [Is_Working],
		'' [Total_Recoveries],
		COALESCE(incurred.incurred_amount, 0) [Investigation_Incurred],
		COALESCE(payments.net_amount, 0) [Total_Paid],
		'' [Physio_Paid],
		'' [Chiro_Paid],
		'' [Massage_Paid],
		'' [Osteopathy_Paid],
		'' [Acupuncture_Paid],
		'' [Rehab_Paid],
		'' [Is_Stress],
		'' [Is_Inactive_Claims],
		'' [Is_Medically_Discharged],
		'' [Is_Exempt],
		'' [Is_Reactive],
		'' [Is_Medical_Only],
		'' [Is_D_D],
		'' [HoursPerWeek],
		'' [Is_Industrial_Deafness],
		'' [Action_Required],
		'' [RTW_Impacting],
		'' [Hindsight],
		'' [Active_Weekly],
		'' [Active_Medical],
		'' [Cost_Code],
		'' [Cost_Code2],
		'' [CC_Injury],
		'' [CC_Current],
		'' [Weeks_In],
		'' [Weeks_Band],
		'' [NCMM_Complete_Action_Due],
		'' [NCMM_Complete_Action_Due_2],
		'' [NCMM_Complete_Remaining_Days],
		'' [NCMM_Complete_Remaining_Days_2],
		'' [NCMM_Prepare_Action_Due],
		'' [NCMM_Prepare_Action_Due_2],
		'' [NCMM_Prepare_Remaining_Days],
		'' [NCMM_Prepare_Remaining_Days_2],
		'' [NCMM_Actions_This_Week],
		'' [NCMM_Actions_Next_Week],
		'' [NCMM_Actions_Next_Week_2],
		'' [Med_Cert_Status_Prev_1_Week],
		'' [Med_Cert_Status_Prev_2_Week],
		'' [Med_Cert_Status_Prev_3_Week],
		'' [Med_Cert_Status_Prev_4_Week],
		'' [Med_Cert_Status],
		'' [Capacity],
		'' [Entitlement_Weeks]
	FROM fact.clm_claim_fact cf
		INNER JOIN fact.clm_current_status_fact csf
			ON csf.claim_key = cf.claim_key
		INNER JOIN dim.clm_worker_dimension wd
			ON wd.worker_key = cf.worker_key
		INNER JOIN dim.clm_claim_dimension cd
			ON cd.claim_key = cf.claim_key
		INNER JOIN dim.clm_claim_dimension_reference cdr
			ON cdr.claim_key = cd.claim_key
		INNER JOIN dim.clm_status_dimension sd
			ON sd.status_key = csf.status_key
		INNER JOIN dim.clm_injury_type_dimension itd
			ON itd.injury_type_key = cf.injury_type_key

		-- Payment transaction view
		LEFT OUTER JOIN (
			SELECT
			  cdr.source_system_code,
			  cdr.claim_number,
			  SUM(pf.net_amount) net_amount,
			  SUM(pf.gross_amount) gross_amount,
			  MAX(pf.transaction_date_key) last_paid_date_key
			FROM fact.clm_payment_fact pf
			INNER JOIN dim.clm_claim_dimension_reference cdr
			  ON cdr.claim_key = pf.claim_key
			GROUP BY
			  cdr.source_system_code,
			  cdr.claim_number
		) payments
			ON payments.source_system_code = cd.source_system_code
				AND payments.claim_number = cd.claim_number

		-- Incurred
		LEFT OUTER JOIN (
			SELECT
			  cd.source_system_code,
			  cd.claim_number,
			  SUM(cif.incurred_amount) incurred_amount
			FROM fact.clm_incurred_fact cif
			INNER JOIN dim.clm_claim_dimension cd
			  ON cd.claim_key = cif.claim_key
			GROUP BY
			  cd.source_system_code,
			  cd.claim_number
		) incurred
			ON incurred.source_system_code = cd.source_system_code
				AND incurred.claim_number = cd.claim_number
GO