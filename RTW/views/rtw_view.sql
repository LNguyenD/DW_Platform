IF OBJECT_ID('views.rtw_view') IS NOT NULL
	DROP VIEW views.rtw_view
GO
CREATE VIEW views.rtw_view
AS
	WITH
	rollings_fake AS
	(
		--select 1 as R
		--union select 3 as R
		--union select 6 as R
		--union 
		select 12 as R
	),
	end_dates_fake AS
	(
		select	DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) AS End_Date
		union all
		select DATEADD(m, -1, End_Date)
		from end_dates_fake 
		where End_Date > DATEADD(m, -12, CONVERT(datetime, CONVERT(char, GETDATE(), 106)))
	),
	measures_fake AS
	(
		select M_months = 3, M_weeks = 13
		union select M_months = 6, M_weeks = 26
		union select M_months = 12, M_weeks = 52
		union select M_months = 18, M_weeks = 78
		union select M_months = 24, M_weeks = 104
	),
	rems_fake AS
	(
		select	DATEADD(mm,-R, End_Date) AS Rem_Start,
				DATEADD(dd, -1, End_Date) + '23:59' AS Rem_End,
				M_months, M_weeks
		from	end_dates_fake
		cross join rollings_fake
		cross join measures_fake
	)
	
	SELECT
		rf.Rem_Start [Remuneration_Start],
		rf.Rem_End [Remuneration_End],
		rf.M_months [Measure_months],
		rf.M_weeks [Measure], *
	FROM
	(	
		SELECT TOP 3000
			cdr.source_system_code [System],
			COALESCE(asm.agency_name,'Miscellaneous') [Agency_Name],
			COALESCE(asm.sub_category,'Miscellaneous') [Sub_Category],
			udfs.getgroup_byteam_udf(cdr.source_system_code, COALESCE(std.team,'Miscellaneous')) [Group],
			COALESCE(std.team,'Miscellaneous') [Team],
			'C - Medium' [EMPL_SIZE],
			'Lauren Christiansen' [Account_Manager],
			'Accommodation' [Portfolio],
			[Agency_Grouping] = case when COALESCE(asm.agency_name,'Miscellaneous') in ('Health', 'Other')
										then 'Health & Other'
									when COALESCE(asm.agency_name,'Miscellaneous') in ('Police', 'Fire', 'RFS')
										then 'Police & Emergency Services'
									else ''
								end,
			[Portfolio_Grouping] = case when 'Accommodation' in ('Accommodation', 'Pubs, Taverns and Bars')
											then 'Hotel'
										else ''
									end,
			cdr.claim_number [Claim_no],
			cd.date_of_injury [DTE_OF_INJURY],
			cd.policy_number [POLICY_NO],
			'SARA HORNBY-HOWELL' [Case_manager],
			
			/* Fake numbers */
			ABS(CHECKSUM(NEWID())) % 14 [LT],
			RAND(CHECKSUM(NEWID())) [WGT],
			ABS(CHECKSUM(NewId())) % 14 [Weeks_paid],
			
			wf.fitness_code_description [Cert_Type],
			sd_date.date [Med_cert_From],
			ed_date.date [Med_cert_To],
			'' [Cell_no],
			Stress = case when imd.mechanism_of_incident_code in (81,82,84,85,86,87,88)
							or itd.nature_of_injury_code in (910,702,703,704,705,706,707,718,719) then 'Y'
						else 'N'
					end,
			sd.liability_status_code_description [Liability_Status],
			'' [cost_code],
			'' [cost_code2],
			sd.claim_closed_flag [Claim_Closed_flag]
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
			LEFT JOIN dim.clm_work_fitness_dimension wf
				ON mc.work_fitness_key = wf.work_fitness_key
				
			/* Agency, Sub category mapping */
			LEFT JOIN ref.pol_agency_sub_category_mapping_reference asm
				ON asm.policy_number = cd.policy_number
	) rtw
	CROSS JOIN rems_fake rf
GO