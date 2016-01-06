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
			caf.activity_date_key [Reporting_Date],
			cdr.source_system_code [System],
			COALESCE(asm.agency_name,'Miscellaneous') [Agency_Name],
			COALESCE(asm.sub_category,'Miscellaneous') [Sub_Category],
			COALESCE(std.team,'Miscellaneous') [Team],
			case when cdr.source_system_code = 'EMI'
					then udfs.emi_getgroup_byteam_udf(COALESCE(std.team,'Miscellaneous'))
				when cdr.source_system_code = 'TMF'
					then udfs.tmf_getgroup_byteam_udf(COALESCE(std.team,'Miscellaneous'))
				when cdr.source_system_code = 'HEM'
					then udfs.hem_getgroup_byteam_udf(COALESCE(std.team,'Miscellaneous'))
			end [Group],
			std.given_names + ', ' + std.surname [Claims_Officer_Name],
			'' [EMPL_SIZE],
			'' [Account_Manager],
			'' [Portfolio],
			'' [Broker_Name],
			cdr.claim_number [Claim_No],
			cd.policy_number [Policy_No],
			'' [WIC_Code],
			COALESCE(pd.company_legal_name, cd.policy_number) [Company_Name],
			wd.given_names + ', ' + wd.surname [Worker_Name],
			'' [Employee_Number],
			wd.home_phone [Worker_Phone_Number],
			wd.date_of_birth [Date_Of_Birth],
			cd.date_of_injury [Date_Of_Injury],
			COALESCE(cd.date_notification_received, cd.date_claim_entered) [Date_Of_Notification],
			'' [Notification_Lag],
			DATEDIFF(day, cd.date_notification_received, cd.date_claim_entered) [Entered_Lag],
			sd.liability_status_code_description [Claim_Liability_Indicator_Group],
			cd.is_time_lost [Is_Time_Lost],
			sd.claim_closed_flag [Claim_Closed_Flag],
			cd.date_claim_entered [Date_Claim_Entered],
			cc_date.date [Date_Claim_Closed],
			cd.date_notification_received [Date_Claim_Received],
			co_date.date [Date_Claim_Reopened],
			itd.result_of_injury_code [Result_Of_Injury_Code],
			cd.final_wpi_percentage [WPI],
			case when COALESCE(common_law.amount, 0) > 0 then 1 else 0 end [Common_Law],
			case when sd.work_status_code in (1,2,3,4,14) then 1
				 when sd.work_status_code in (5,6,7,8,9) then 0
			end [Is_Working],
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
	FROM	fact.clm_claim_fact cf
			INNER JOIN dim.clm_claim_dimension cd
				ON cd.claim_key = cf.claim_key
			INNER JOIN dim.clm_claim_dimension_reference cdr
				ON cdr.claim_key = cd.claim_key
			INNER JOIN fact.clm_activity_fact caf
				ON cf.claim_key = caf.claim_key
			INNER JOIN dim.clm_worker_dimension wd
				ON wd.worker_key = cf.worker_key
			INNER JOIN dim.clm_status_dimension sd
				ON sd.status_key = caf.status_key
			INNER JOIN dim.clm_injury_type_dimension itd
				ON itd.injury_type_key = cf.injury_type_key
			INNER JOIN dim.gen_staff_dimension std
				ON std.staff_key = caf.case_manager_key
			LEFT JOIN dim.pol_policy_dimension pd
				ON pd.policy_number = cd.policy_number
				
			/* Agency, Sub category mapping */
			LEFT JOIN ref.pol_agency_sub_category_mapping_reference asm
				ON asm.policy_number = cd.policy_number
			
			/* Dates */
			INNER JOIN dim.gen_date_dimension co_date
				ON co_date.date_key = caf.date_claim_reopened_key
			INNER JOIN dim.gen_date_dimension cc_date
				ON cc_date.date_key = caf.date_claim_closed_key
		
			/* Payment transaction view */
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

			/* Incurred */
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
					
			/* Common Law */
			LEFT OUTER JOIN (
				SELECT
				  cdr.source_system_code,
				  cdr.claim_number,
				  SUM(pf.transaction_amount) amount
				FROM fact.clm_payment_fact pf
					INNER JOIN dim.clm_claim_dimension_reference cdr
						ON cdr.claim_key = pf.claim_key
					INNER JOIN dim.clm_estimate_type_dimension etd
						ON etd.estimate_type_key = pf.estimate_type_key
				WHERE etd.estimate_type_code = '57'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) common_law
				ON common_law.source_system_code = cd.source_system_code
					AND common_law.claim_number = cd.claim_number
GO