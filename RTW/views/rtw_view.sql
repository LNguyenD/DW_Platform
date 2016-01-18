IF OBJECT_ID('views.rtw_view') IS NOT NULL
	DROP VIEW views.rtw_view
GO
CREATE VIEW views.rtw_view
AS
	SELECT TOP 3000
	'2014-12-01' [Remuneration_Start],
	'2014-12-31 23:59' [Remuneration_End],
	3 [Measure_months],
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
	'SARA HORNBY-HOWELL' [Case_manager],
	cdr.claim_number [Claim_no],
	cd.date_of_injury [DTE_OF_INJURY],
	cd.policy_number [POLICY_NO],
	11.25 [LT],
	0.9852941176 [WGT],
	'C - Medium' [EMPL_SIZE],
	2 [Weeks_paid],
	cd_date.date [create_date],
	13 [Measure],
	wf.fitness_code_description [Cert_Type],
	sd_date.date [Med_cert_From],
	sd_date.date [Med_cert_To],
	'Lauren Christiansen' [Account_Manager],
	'' [Cell_no],
	'Other' [Portfolio],
	Stress = case when imd.mechanism_of_incident_code in (81,82,84,85,86,87,88)
					or itd.nature_of_injury_code in (910,702,703,704,705,706,707,718,719) then 'Y'
				else 'N'
			end,
	sd.liability_status_code_description [Liability_Status],
	'' [cost_code],
	'' [cost_code2],
	sd.claim_closed_flag [Claim_Closed_flag],
	cdr.source_system_code [System]
	FROM fact.clm_claim_fact cf
		INNER JOIN dim.clm_claim_dimension cd
			ON cd.claim_key = cf.claim_key
		INNER JOIN dim.clm_claim_dimension_reference cdr
			ON cdr.claim_key = cd.claim_key
		LEFT JOIN fact.clm_activity_fact caf
			ON cf.claim_key = caf.claim_key						
		LEFT JOIN dim.clm_status_dimension sd
			ON sd.status_key = caf.status_key
		INNER JOIN dim.clm_injury_type_dimension itd
			ON itd.injury_type_key = cf.injury_type_key
		INNER JOIN dim.clm_injury_mechanism_dimension imd
			ON imd.injury_mechanism_key = cf.injury_mechanism_key
		LEFT JOIN dim.gen_staff_dimension std
			ON std.staff_key = caf.case_manager_key					
		LEFT JOIN fact.clm_medical_certificate_fact mc
			ON cf.claim_key = mc.claim_key
		LEFT JOIN dim.gen_date_dimension sd_date
			ON mc.start_date_key = sd_date.date_key
		LEFT JOIN dim.gen_date_dimension ed_date
			ON mc.end_date_key = ed_date.date_key
		LEFT JOIN dim.gen_date_dimension cd_date
			ON mc.creation_date_key = cd_date.date_key
		LEFT JOIN dim.clm_work_fitness_dimension wf
			ON mc.work_fitness_key = wf.work_fitness_key
			
		/* Agency, Sub category mapping */
		LEFT JOIN ref.pol_agency_sub_category_mapping_reference asm
			ON asm.policy_number = cd.policy_number
GO