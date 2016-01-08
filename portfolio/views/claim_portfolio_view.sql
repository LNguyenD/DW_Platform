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
		
	SELECT  TOP 3000
			--ad_date.date [Reporting_Date],
			'2014-12-31 23:59' [Reporting_Date],
			cdr.source_system_code [System],
			
			/* Agents */
			COALESCE(asm.agency_name,'Miscellaneous') [Agency_Name],
			COALESCE(asm.sub_category,'Miscellaneous') [Sub_Category],
			
			--COALESCE(std.team,'Miscellaneous') [Team],
			--case when cdr.source_system_code = 'EMI'
			--		then udfs.emi_getgroup_byteam_udf(COALESCE(std.team,'Miscellaneous'))
			--	when cdr.source_system_code = 'TMF'
			--		then udfs.tmf_getgroup_byteam_udf(COALESCE(std.team,'Miscellaneous'))
			--	when cdr.source_system_code = 'HEM'
			--		then udfs.hem_getgroup_byteam_udf(COALESCE(std.team,'Miscellaneous'))
			--end [Group],
			--std.given_names + ', ' + std.surname [Claims_Officer_Name],
			--'' [EMPL_SIZE],
			--'' [Account_Manager],
			--'' [Portfolio],
			--'' [Broker_Name],
			
			'WCNSW6B' [Team],
			'WCNSW6' [Group],
			'Erin Bartley' [Claims_Officer_Name],
			'C - Medium' [EMPL_SIZE],
			'Lauren Christiansen' [Account_Manager],
			'Other' [Portfolio],
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
			--sd.liability_status_code_description [Claim_Liability_Indicator_Group],
			'Notification of work related injury' [Claim_Liability_Indicator_Group],
			case when cd.is_time_lost = 'Yes' then 1 else 0 end [Is_Time_Lost],
			sd.claim_closed_flag [Claim_Closed_Flag],
			--cd.date_claim_entered [Date_Claim_Entered],
			--cc_date.date [Date_Claim_Closed],
			--cd.date_notification_received [Date_Claim_Received],
			--co_date.date [Date_Claim_Reopened],
			'2014-12-31' [Date_Claim_Entered],
			'2014-12-31' [Date_Claim_Closed],
			'2014-12-31' [Date_Claim_Received],
			'2014-12-31' [Date_Claim_Reopened],
			itd.result_of_injury_code [Result_Of_Injury_Code],
			cd.final_wpi_percentage [WPI],
			case when COALESCE(common_law.amount, 0) > 0 then 1 else 0 end [Common_Law],
			case when sd.work_status_code in (1,2,3,4,14) then 1
				 when sd.work_status_code in (5,6,7,8,9) then 0
			end [Is_Working],
			
			/* Payments */
			COALESCE(total_recoveries.amount,0) [Total_Recoveries],
			COALESCE(incurred.incurred_amount, 0) [Investigation_Incurred],
			COALESCE(payments.net_amount, 0) [Total_Paid],
			COALESCE(physio_paid.amount,0) [Physio_Paid],
			COALESCE(chiro_paid.amount,0) [Chiro_Paid],
			COALESCE(massage_paid.amount,0) [Massage_Paid],
			COALESCE(osteopathy_paid.amount,0) [Osteopathy_Paid],
			COALESCE(acupuncture_paid.amount,0) [Acupuncture_Paid],
			COALESCE(rehab_Paid.amount,0) [Rehab_Paid],
			
			case when imd.mechanism_of_incident_code in (81,82,84,85,86,87,88)
					OR itd.nature_of_injury_code in (910,702,703,704,705,706,707,718,719)
					then 1
				else 0
			end [Is_Stress],
			case when COALESCE(inactive_claims_paid.amount,0) = 0 then 1 else 0 end [Is_Inactive_Claims],
			'' [Is_Medically_Discharged],
			'' [Is_Exempt],
			'' [Is_Reactive],
			cd.is_medical_only [Is_Medical_Only],
			'' [Is_D_D],
			'' [HoursPerWeek],
			case when itd.nature_of_injury_code in (152,250,312,389,771)
					then 1
				else 0
			end [Is_Industrial_Deafness],
			case when udfs.ncmm_get_actionthisweek_udf(udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered),ad_date.date)) <> ''
					or udfs.ncmm_get_actionnextweek_udf(udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered),ad_date.date)) <> ''
					then 'Y'
				else 'N'
			end [Action_Required],
			'' [RTW_Impacting],
			case when cd.date_of_injury > DATEADD(day, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH,-36,ad_date.financial_year)) + 1, 0))
					 and cd.date_of_injury <= DATEADD(day, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH,-24,ad_date.financial_year)) + 1, 0)) 
					 then '3 years'
				  when cd.date_of_injury > DATEADD(day, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH,-60,ad_date.financial_year)) + 1, 0))
					 and cd.date_of_injury <= DATEADD(day, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH,-48,ad_date.financial_year)) + 1, 0)) 
					 then '5 years'
				else ''
			end [Hindsight],
			case when COALESCE(active_weekly.amount,0) <> 0
					then 'Y'
				else 'N'
			end [Active_Weekly],
			case when COALESCE(active_medical.amount,0) <> 0
					then 'Y'
				else 'N'
			end [Active_Medical],
			'' [Cost_Code],
			'' [Cost_Code2],
			'' [CC_Injury],
			'' [CC_Current],
			udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received, cd.date_claim_entered), ad_date.date) [Weeks_In],
			case when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 0 and 12 then 'A.0-12 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 13 and 18 then 'B.13-18 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 19 and 22 then 'C.19-22 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 23 and 26 then 'D.23-26 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 27 and 34 then 'E.27-34 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 35 and 48 then 'F.35-48 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 49 and 52 then 'G.48-52 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 53 and 60 then 'H.53-60 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 61 and 76 then 'I.61-76 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 77 and 90 then 'J.77-90 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 91 and 100 then 'K.91-100 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 101 and 117 then 'L.101-117 WK'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) between 118 and 130 then 'M.117 - 130 WKS'
				when udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date) > 130 then 'N.130+ WKS'
			end [Weeks_Band],
			
			/* NCMM */
			DATEADD(week, udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date),
				COALESCE(cd.date_notification_received,cd.date_claim_entered)) [NCMM_Complete_Action_Due],
			udfs.get_workingdays_udf(ad_date.date, DATEADD(week,
				udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered),ad_date.date),
				COALESCE(cd.date_notification_received,cd.date_claim_entered))) [NCMM_Complete_Remaining_Days],
			udfs.ncmm_get_prepareactionduedate_udf(udfs.ncmm_get_weeks_udf(
				COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date),
				COALESCE(cd.date_notification_received,cd.date_claim_entered)) [NCMM_Prepare_Action_Due],
			udfs.get_workingdays_udf(ad_date.date, udfs.ncmm_get_prepareactionduedate_udf(
				udfs.ncmm_get_weeks_udf(COALESCE(cd.date_notification_received,cd.date_claim_entered),ad_date.date),
				COALESCE(cd.date_notification_received,cd.date_claim_entered))) [NCMM_Prepare_Remaining_Days],
			udfs.ncmm_get_actionthisweek_udf(udfs.ncmm_get_weeks_udf(
				COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date)) [NCMM_Actions_This_Week],
			udfs.ncmm_get_actionnextweek_udf(udfs.ncmm_get_weeks_udf(
				COALESCE(cd.date_notification_received,cd.date_claim_entered), ad_date.date)) [NCMM_Actions_Next_Week],
			
			/* Medical Certs */
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
			LEFT JOIN fact.clm_activity_fact caf
				ON cf.claim_key = caf.claim_key
			LEFT JOIN dim.clm_worker_dimension wd
				ON wd.worker_key = cf.worker_key
			LEFT JOIN dim.clm_status_dimension sd
				ON sd.status_key = caf.status_key
			INNER JOIN dim.clm_injury_type_dimension itd
				ON itd.injury_type_key = cf.injury_type_key
			INNER JOIN dim.clm_injury_mechanism_dimension imd
				ON imd.injury_mechanism_key = cf.injury_mechanism_key
			LEFT JOIN dim.gen_staff_dimension std
				ON std.staff_key = caf.case_manager_key
			LEFT JOIN dim.pol_policy_dimension pd
				ON pd.policy_number = cd.policy_number
				
			/* Agency, Sub category mapping */
			LEFT JOIN ref.pol_agency_sub_category_mapping_reference asm
				ON asm.policy_number = cd.policy_number
			
			/* Dates */
			LEFT JOIN dim.gen_date_dimension co_date
				ON co_date.date_key = caf.date_claim_reopened_key
			LEFT JOIN dim.gen_date_dimension cc_date
				ON cc_date.date_key = caf.date_claim_closed_key
			LEFT JOIN dim.gen_date_dimension ad_date
				ON ad_date.date_key = caf.activity_date_key
		
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
					
			/* Physio Paid */
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
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
				WHERE (ptd.payment_type_code = '05' OR ptd.payment_type_code like 'pta%' OR ptd.payment_type_code like 'ptx%')
					AND etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) physio_paid
				ON physio_paid.source_system_code = cd.source_system_code
					AND physio_paid.claim_number = cd.claim_number
					
			/* Chiro Paid */
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
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
				WHERE (ptd.payment_type_code = '06' OR ptd.payment_type_code like 'cha%' OR ptd.payment_type_code like 'chx%')
					AND etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) chiro_paid
				ON chiro_paid.source_system_code = cd.source_system_code
					AND chiro_paid.claim_number = cd.claim_number
					
			/* Massage Paid */
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
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
				WHERE (ptd.payment_type_code like 'rma%' OR ptd.payment_type_code like 'rmx%')
					AND etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) massage_paid
				ON massage_paid.source_system_code = cd.source_system_code
					AND massage_paid.claim_number = cd.claim_number
					
			/* Osteopathy Paid */
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
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
				WHERE (ptd.payment_type_code like 'osa%' OR ptd.payment_type_code like 'osx%')
					AND etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) osteopathy_paid
				ON osteopathy_paid.source_system_code = cd.source_system_code
					AND osteopathy_paid.claim_number = cd.claim_number
					
			/* Acupuncture Paid */
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
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
				WHERE ptd.payment_type_code like 'ott001'
					AND etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) acupuncture_paid
				ON acupuncture_paid.source_system_code = cd.source_system_code
					AND acupuncture_paid.claim_number = cd.claim_number
					
			/* Rehab Paid */
			LEFT OUTER JOIN (
				SELECT
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date transaction_date,
				  SUM(pf.transaction_amount) amount
				FROM fact.clm_payment_fact pf
					INNER JOIN dim.clm_claim_dimension_reference cdr
						ON cdr.claim_key = pf.claim_key
					INNER JOIN dim.clm_estimate_type_dimension etd
						ON etd.estimate_type_key = pf.estimate_type_key
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
					INNER JOIN dim.gen_date_dimension gdd
						ON pf.transaction_date_key = gdd.date_key
				WHERE (ptd.payment_type_code = '04' OR ptd.payment_type_code like 'or%')
					AND etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date
			) rehab_paid
				ON rehab_paid.source_system_code = cd.source_system_code
					AND rehab_paid.claim_number = cd.claim_number
					AND rehab_paid.transaction_date >= DATEADD(MM, -3, ad_date.date)
					
			/* Total Recoveries */
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
				WHERE etd.estimate_type_code in ('70','71','72','73','74','75','76','77')
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number
			) total_recoveries
				ON total_recoveries.source_system_code = cd.source_system_code
					AND total_recoveries.claim_number = cd.claim_number
					
			/* Inactive Claims */
			LEFT OUTER JOIN (
				SELECT
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date transaction_date,
				  SUM(pf.transaction_amount) amount
				FROM fact.clm_payment_fact pf
					INNER JOIN dim.clm_claim_dimension_reference cdr
						ON cdr.claim_key = pf.claim_key					
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
					INNER JOIN dim.gen_date_dimension gdd
						ON pf.transaction_date_key = gdd.date_key
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date
			) inactive_claims_paid
				ON inactive_claims_paid.source_system_code = cd.source_system_code
					AND inactive_claims_paid.claim_number = cd.claim_number
					AND inactive_claims_paid.transaction_date >= DATEADD(MM, -3, ad_date.date)
					
			/* Active Weekly */
			LEFT OUTER JOIN (
				SELECT
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date transaction_date,
				  SUM(pf.transaction_amount) amount
				FROM fact.clm_payment_fact pf
					INNER JOIN dim.clm_claim_dimension_reference cdr
						ON cdr.claim_key = pf.claim_key				
					INNER JOIN dim.clm_estimate_type_dimension etd
						ON etd.estimate_type_key = pf.estimate_type_key	
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
					INNER JOIN dim.gen_date_dimension gdd
						ON pf.transaction_date_key = gdd.date_key
				WHERE etd.estimate_type_code = '50'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date
			) active_weekly
				ON Active_Weekly.source_system_code = cd.source_system_code
					AND active_weekly.claim_number = cd.claim_number
					AND active_weekly.transaction_date >= DATEADD(MM, -3, ad_date.date)
					
			/* Active Medical */
			LEFT OUTER JOIN (
				SELECT
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date transaction_date,
				  SUM(pf.transaction_amount) amount
				FROM fact.clm_payment_fact pf
					INNER JOIN dim.clm_claim_dimension_reference cdr
						ON cdr.claim_key = pf.claim_key				
					INNER JOIN dim.clm_estimate_type_dimension etd
						ON etd.estimate_type_key = pf.estimate_type_key	
					INNER JOIN dim.clm_payment_type_dimension ptd
						ON pf.payment_type_key = ptd.payment_type_key
					INNER JOIN dim.gen_date_dimension gdd
						ON pf.transaction_date_key = gdd.date_key
				WHERE etd.estimate_type_code = '55'
				GROUP BY
				  cdr.source_system_code,
				  cdr.claim_number,
				  gdd.date
			) active_medical
				ON active_medical.source_system_code = cd.source_system_code
					AND active_medical.claim_number = cd.claim_number
					AND active_medical.transaction_date >= DATEADD(MM, -3, ad_date.date)
GO