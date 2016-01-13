IF OBJECT_ID('usps.claim_portfolio_summary_usp') IS NOT NULL
	DROP PROCEDURE usps.claim_portfolio_summary_usp
GO
CREATE PROCEDURE usps.claim_portfolio_summary_usp
(
	@system VARCHAR(10)
	,@type VARCHAR(20)
	,@value NVARCHAR(256)
	,@subvalue NVARCHAR(256)
	,@start_date DATETIME
	,@end_date DATETIME
	,@claim_liability_indicator NVARCHAR(256)
	,@psychological_claims VARCHAR(10)
	,@inactive_claims VARCHAR(10)
	,@medically_discharged VARCHAR(10)
	,@exempt_from_reform VARCHAR(10)
	,@reactivation VARCHAR(10)
)
AS
BEGIN
	IF OBJECT_ID('tempdb..#total') IS NOT NULL DROP TABLE #total
	IF OBJECT_ID('tempdb..#claim_all') IS NOT NULL DROP TABLE #claim_all
	IF OBJECT_ID('tempdb..#claim_new_all') IS NOT NULL DROP TABLE #claim_new_all
	IF OBJECT_ID('tempdb..#claim_open_all') IS NOT NULL DROP TABLE #claim_open_all
	IF OBJECT_ID('tempdb..#claim_closure') IS NOT NULL DROP TABLE #claim_closure
	IF OBJECT_ID('tempdb..#claim_re_open') IS NOT NULL DROP TABLE #claim_re_open
	IF OBJECT_ID('tempdb..#claim_re_open_still_open') IS NOT NULL DROP TABLE #claim_re_open_still_open
	IF OBJECT_ID('tempdb..#claim_list') IS NOT NULL DROP TABLE #claim_list
	IF OBJECT_ID('tempdb..#prior_claim_list') IS NOT NULL DROP TABLE #prior_claim_list
	
	/* Append time to @end_date */
	SET @end_date = DATEADD(dd, DATEDIFF(dd, 0, @end_date), 0) + '23:59'
	
	/* Prepare data before querying */
	
	DECLARE @SQL varchar(MAX)
	
	CREATE TABLE #claim_list
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL
	)
	
	SET @SQL = 'SELECT Value = ' + case when UPPER(@system) = 'TMF'
										then
											case when @type = 'agency'
													then + 'rtrim(isnull(sub.agency_name,''Miscellaneous''))'
												when @type = 'group'
													then 'dbo.claim_portfolio_getgroup_byteam_tmf_udf(Team)'
												else ''''''
											end
									when UPPER(@system) = 'EML'
										then
											case when @type = 'employer_size' 
													then '[EMPL_SIZE]' 
												when @type = 'group' 
													then 'dbo.claim_portfolio_getgroup_byteam_eml_udf(Team)'
												when @type = 'account_manager'
													then '[Account_Manager]' 
												when @type = 'broker'
													then 'ltrim([Broker_Name])'
												else ''''''
											end
									when UPPER(@system) = 'HEM'
										then
											case when @type = 'account_manager' 
													then '[Account_Manager]'
												when @type = 'portfolio'
													then '[portfolio]' 
												when @type = 'group'
													then 'dbo.claim_portfolio_getgroup_byteam_hem_udf(Team)'
												when @type = 'broker'
													then 'ltrim([Broker_Name])'
												else ''''''
											end
								end	+
				',SubValue = ' + case when UPPER(@system) = 'TMF'
										then
											case when @type = 'agency'
													then 'rtrim(isnull(sub.Sub_Category,''Miscellaneous''))'
												when @type = 'group'
													then '[Team]'
												else ''''''
											end
									when UPPER(@system) = 'EML'
										then
											case when @type = 'group'
													then '[Team]'
												when @type = 'employer_size' or @type = 'account_manager'
													then '[EMPL_SIZE]'
												else ''''''
											end
									when UPPER(@system) = 'HEM'
										then
											case when @type = 'account_manager' or @type = 'portfolio' 
													then '[EMPL_SIZE]' 
												when @type = 'group' 
													then '[Team]'
												else ''''''
											end
								end	+
				',SubValue2 = [Claims_Officer_Name]
				,[Claim_No],[Date_Of_Injury],[Date_Of_Notification],[Claim_Liability_Indicator_Group],[Is_Time_Lost]
				,[Claim_Closed_Flag],[Date_Claim_Entered],[Date_Claim_Closed],[Date_Claim_Received]
				,[Date_Claim_Reopened],[Result_Of_Injury_Code],[WPI],[Common_Law],[Total_Recoveries]
				,[Physio_Paid],[Chiro_Paid],[Massage_Paid],[Osteopathy_Paid],[Acupuncture_Paid],[Rehab_Paid]
				,[Is_Industrial_Deafness],[Is_Stress],[Is_Inactive_Claims],[Is_Medically_Discharged],[Is_Exempt]
				,[Is_Reactive],[NCMM_Actions_This_Week],[NCMM_Actions_Next_Week],[NCMM_Complete_Action_Due],[NCMM_Prepare_Action_Due]'
				+ case when @type = 'agency'
								then ' FROM views.claim_portfolio_view uv left join ref.pol_agency_sub_category_mapping_reference sub on sub.policy_number = uv.Policy_No'
							else ' FROM views.claim_portfolio_view'
				end +
				' WHERE [System] = ''' + UPPER(@system) + ''' AND Reporting_Date <= ''' + CONVERT(VARCHAR, @end_date, 120) + ''''
					
	/* Apply the user input filters */
	SET @SQL = @SQL + case when @claim_liability_indicator <> 'all'
								then ' and dbo.claim_portfolio_getliabilitycode_bydesc_udf(''' + UPPER(@system) + '''
									,[Claim_Liability_Indicator_Group]) in (''' + REPLACE(@claim_liability_indicator,'|',''',''') + ''')'
							else ''
						end
	SET @SQL = @SQL + case when @psychological_claims <> 'all' then ' and [Is_Stress] = ''' + @psychological_claims + '''' else '' end
	SET @SQL = @SQL + case when @inactive_claims <> 'all' then ' and [Is_Inactive_Claims] = ''' + @inactive_claims + '''' else '' end
	SET @SQL = @SQL + case when @medically_discharged <> 'all' then ' and [Is_Medically_Discharged] = ''' + @medically_discharged + '''' else '' end
	SET @SQL = @SQL + case when @exempt_from_reform <> 'all' then ' and [Is_Exempt] = ''' + @exempt_from_reform + '''' else '' end
	SET @SQL = @SQL + case when @reactivation <> 'all' then ' and [Is_Reactive] = ''' + @reactivation + '''' else '' end
		
	INSERT INTO #claim_list
	EXEC(@SQL)
	
	CREATE TABLE #prior_claim_list
	(
		[Claim_No] [varchar](19) NULL,
		[Claim_Closed_Flag] [nchar](1) NULL
	)
	
	SET @SQL = 'SELECT Claim_No, Claim_Closed_Flag
				FROM views.claim_portfolio_view
				WHERE [System] = ''' + UPPER(@system) + ''' AND Reporting_Date <= ''' + CONVERT(VARCHAR, @start_date, 120) + ''''
					
	INSERT INTO #prior_claim_list
	EXEC(@SQL)
	
	/* NEW CLAIMS */
	
	CREATE TABLE #claim_new_all
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[Age_of_claim] [float] NULL
	)
	
	SET @SQL = 'SELECT *, Age_of_claim = 0
					FROM #claim_list
					WHERE ISNULL(Date_Claim_Entered,Date_Claim_Received)
						between ''' + CONVERT(VARCHAR, @start_date, 120) + ''' and ''' + CONVERT(VARCHAR, @end_date, 120) + ''''
						
	INSERT INTO	#claim_new_all
	EXEC(@SQL)
	
	/* OPEN CLAIMS */
	
	CREATE TABLE #claim_open_all
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[Age_of_claim] [float] NULL
	)
	
	SET @SQL = 'SELECT *, Age_of_claim = DATEDIFF(DAY, Date_of_Injury, DATEADD(DAY, -1, ''' + CONVERT(VARCHAR, @end_date, 120) + ''')) / 7.0
					FROM #claim_list
					WHERE Claim_Closed_Flag <> ''Y''
						and (Date_Claim_Closed is null or Date_Claim_Closed < ''' + CONVERT(VARCHAR, @end_date, 120) + ''')
						and (Date_Claim_Reopened is null or Date_Claim_Reopened < ''' + CONVERT(VARCHAR, @end_date, 120) + ''')'
	
	INSERT INTO	#claim_open_all
	EXEC(@SQL)
	
	/* CLAIM CLOSURES */
	
	CREATE TABLE #claim_closure
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[Age_of_claim] [float] NULL
	)
	
	SET @SQL = 'SELECT *, Age_of_claim = 0
					FROM #claim_list cpr
					WHERE Claim_Closed_Flag = ''Y''
						and Date_Claim_Closed between ''' + CONVERT(VARCHAR, @start_date, 120) + ''' and ''' + CONVERT(VARCHAR, @end_date, 120) + '''
						and (exists (SELECT [Claim_No] FROM #prior_claim_list cpr_pre
										WHERE cpr_pre.Claim_No = cpr.Claim_No AND cpr_pre.Claim_Closed_Flag = ''N'')
											or ISNULL(cpr.Date_Claim_Entered, cpr.date_claim_received) >= ''' + CONVERT(VARCHAR, @start_date, 120) + ''')'
	
	INSERT INTO	#claim_closure
	EXEC(@SQL)
	
	/* REOPEN CLAIMS */
	
	CREATE TABLE #claim_re_open
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[Age_of_claim] [float] NULL
	)
	
	SET @SQL = 'SELECT *, Age_of_claim = 0
					FROM #claim_list
					WHERE Date_Claim_Reopened between ''' + CONVERT(VARCHAR, @start_date, 120) + ''' and ''' + CONVERT(VARCHAR, @end_date, 120) + ''''
	
	INSERT INTO	#claim_re_open
	EXEC(@SQL)
	
	/* REOPEN CLAIMS: STILL OPEN */
	
	CREATE TABLE #claim_re_open_still_open
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[Age_of_claim] [float] NULL
	)
	
	SET @SQL = 'SELECT *, Age_of_claim = 0
					FROM #claim_list cpr
					WHERE Claim_Closed_Flag <> ''Y''
						and Date_Claim_Reopened between ''' + CONVERT(VARCHAR, @start_date, 120) + ''' and ''' + CONVERT(VARCHAR, @end_date, 120) + '''
						and exists (SELECT [Claim_No] FROM #prior_claim_list cpr_pre
										WHERE cpr_pre.Claim_No = cpr.Claim_No AND cpr_pre.Claim_Closed_Flag = ''Y'')'
	
	INSERT INTO	#claim_re_open_still_open
	EXEC(@SQL)
									
	/* Drop temp table */
	IF OBJECT_ID('tempdb..#prior_claim_list') IS NOT NULL DROP TABLE #prior_claim_list
	
	/* CLAIM ALL */	
	
	CREATE TABLE #claim_all
	(
		[Value] [varchar](256) NULL,
		[SubValue] [varchar](256) NULL,
		[SubValue2] [varchar](256) NULL,
		[Claim_No] [varchar](19) NULL,
		[Date_Of_Injury] [datetime] NULL,
		[Date_Of_Notification] [datetime] NULL,
		[Claim_Liability_Indicator_Group] [varchar](256) NULL,
		[Is_Time_Lost] [bit] NULL,
		[Claim_Closed_Flag] [nchar](1) NULL,
		[Date_Claim_Entered] [datetime] NULL,
		[Date_Claim_Closed] [datetime] NULL,
		[Date_Claim_Received] [datetime] NULL,
		[Date_Claim_Reopened] [datetime] NULL,
		[Result_Of_Injury_Code] [int] NULL,
		[WPI] [float] NULL,
		[Common_Law] [bit] NULL,
		[Total_Recoveries] [float] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[Age_of_claim] [float] NULL,
		[claim_type] [varchar](30) NULL
	)
	
	SET @SQL = 'SELECT *
				FROM (select *,claim_type=''claim_new_all'' from #claim_new_all
							union all select *,claim_type=''claim_new_lt'' from #claim_new_all where is_Time_Lost = 1
							union all select *,claim_type=''claim_new_nlt'' from #claim_new_all where is_Time_Lost = 0
							union all select *,claim_type=''claim_open_all'' from #claim_open_all
							union all select *,claim_type=''claim_open_0_13'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 0 and Age_of_claim <= 13
							union all select *,claim_type=''claim_open_13_26'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 13 and Age_of_claim <= 26
							union all select *,claim_type=''claim_open_26_52'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 26 and Age_of_claim <= 52
							union all select *,claim_type=''claim_open_52_78'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 52 and Age_of_claim <= 78
							union all select *,claim_type=''claim_open_0_78'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 0 and Age_of_claim <= 78
							union all select *,claim_type=''claim_open_78_130'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 78 and Age_of_claim <= 130
							union all select *,claim_type=''claim_open_gt_130'' from #claim_open_all where Is_Time_Lost = 1 and Age_of_claim > 130
							union all select *,claim_type=''claim_open_nlt'' from #claim_open_all where is_Time_Lost = 0
							union all select *,claim_type=''claim_open_ncmm_this_week'' from #claim_open_all where NCMM_Actions_This_Week <> '''' AND NCMM_Complete_Action_Due > ''' + CONVERT(VARCHAR, @end_date, 120) + '''
							union all select *,claim_type=''claim_open_ncmm_next_week'' from #claim_open_all where NCMM_Actions_Next_Week <> ''''
								AND NCMM_Prepare_Action_Due BETWEEN DATEADD(week, 1, ''' + CONVERT(VARCHAR, @end_date, 120) + ''') AND DATEADD(week, 3, ''' + CONVERT(VARCHAR, @end_date, 120) + ''')
							union all select *,claim_type=''claim_open_acupuncture'' from #claim_open_all where Acupuncture_Paid > 0
							union all select *,claim_type=''claim_open_chiro'' from #claim_open_all where Chiro_Paid > 1000
							union all select *,claim_type=''claim_open_massage'' from #claim_open_all where Massage_Paid > 0
							union all select *,claim_type=''claim_open_osteo'' from #claim_open_all where Osteopathy_Paid > 0
							union all select *,claim_type=''claim_open_physio'' from #claim_open_all where Physio_Paid > 2000
							union all select *,claim_type=''claim_open_rehab'' from #claim_open_all where Rehab_Paid > 0
							union all select *,claim_type=''claim_open_death'' from #claim_open_all where Result_Of_Injury_Code = 1
							union all select *,claim_type=''claim_open_industrial_deafness'' from #claim_open_all where Is_Industrial_Deafness = 1
							union all select *,claim_type=''claim_open_ppd'' from #claim_open_all where Result_Of_Injury_Code = 3
							union all select *,claim_type=''claim_open_recovery'' from #claim_open_all where Total_Recoveries <> 0
							union all select *,claim_type=''claim_open_wpi_all'' from #claim_open_all where WPI > 0
							union all select *,claim_type=''claim_open_wpi_0_10'' from #claim_open_all where WPI > 0 AND WPI <= 10
							union all select *,claim_type=''claim_open_wpi_11_14'' from #claim_open_all where WPI >= 11 AND WPI <= 14
							union all select *,claim_type=''claim_open_wpi_15_20'' from #claim_open_all where WPI >= 15 AND WPI <= 20
							union all select *,claim_type=''claim_open_wpi_21_30'' from #claim_open_all where WPI >= 21 AND WPI <= 30
							union all select *,claim_type=''claim_open_wpi_31_more'' from #claim_open_all where WPI >= 31
							union all select *,claim_type=''claim_open_wid'' from #claim_open_all where Common_Law = 1
							union all select *,claim_type=''claim_closure'' from #claim_closure
							union all select *,claim_type=''claim_re_open'' from #claim_re_open
							union all select *,claim_type=''claim_still_open'' from #claim_re_open_still_open
						   ) as tmp'
			   
	INSERT INTO	#claim_all
	EXEC(@SQL)
			
	/* Drop temp tables */
	IF OBJECT_ID('tempdb..#claim_new_all') IS NOT NULL DROP TABLE #claim_new_all
	IF OBJECT_ID('tempdb..#claim_open_all') IS NOT NULL DROP TABLE #claim_open_all
	IF OBJECT_ID('tempdb..#claim_closure') IS NOT NULL DROP TABLE #claim_closure
	IF OBJECT_ID('tempdb..#claim_re_open') IS NOT NULL DROP TABLE #claim_re_open
	IF OBJECT_ID('tempdb..#claim_re_open_still_open') IS NOT NULL DROP TABLE #claim_re_open_still_open
	
	CREATE TABLE #total
	(
		[Value] [varchar](256) NULL,
		[Claim_type] [varchar](30) NULL,
		[iClaim_Type] [int] NULL,
		[overall] [int] NULL
	)
	
	SET @SQL = 'SELECT  tmp.Value, Claim_type, tmp.iClaim_Type
					,overall = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type' +
					case when @value = 'all'
							then ' and [Value] = tmp.Value)'
						else (case when @subvalue = 'all'
									then ' and [Value] = ''' + @value + ''' and [SubValue] = tmp.Value)'
								else ' and [Value] = ''' + @value + ''' and [SubValue] = ''' + @subvalue + ''' and [SubValue2] = tmp.Value)'
							end)
					end + '
				FROM
				(
					select * from views.claim_getall_claimtype_view
					cross join (select distinct' +
									case when @value = 'all' 
											then ' Value'
										else (case when @subvalue = 'all'
													then ' SubValue as Value'
												else ' SubValue2 as Value'
											end)
									end + '
									from #claim_list
									where' +
									case when @value = 'all' 
											then ' Value <> '''''
										else (case when @subvalue = 'all'
													then ' Value = ''' + @value + ''' and SubValue <> '''''
												else ' Value = ''' + @value + ''' and SubValue = ''' + @subvalue + ''' and SubValue2 <> '''''
											end)
									end + '
									group by' + case when @value = 'all' 
														then ' Value'
													else (case when @subvalue = 'all'
																then ' SubValue'
															else ' SubValue2'
														end)
												end + '
									having COUNT(*) > 0
									union
									select ''Miscellaneous'') as tmp_value
				) as tmp'
	
	INSERT INTO #total
	EXEC(@SQL)
	
	/* Clean data with zero value for all claim types */
	DELETE FROM #total WHERE Value NOT IN (SELECT Value FROM #total
												GROUP BY Value
												HAVING SUM(overall) > 0)
												
	/* Filter Top 10 brokers with largest Open claims */
	IF @type = 'broker' AND @value = 'all'
	BEGIN
		DELETE FROM #total WHERE Value NOT IN (SELECT TOP 10 Value FROM #total
													WHERE Claim_type = 'claim_open_all'
													ORDER BY overall DESC)
	END
	
	/* Drop temp tables */
	IF OBJECT_ID('tempdb..#claim_all') IS NOT NULL DROP TABLE #claim_all
	IF OBJECT_ID('tempdb..#claim_list') IS NOT NULL DROP TABLE #claim_list
	
	IF @value = 'all'
	BEGIN
		/* Append Total & Grouping values */
	
		IF UPPER(@system) = 'TMF'
		BEGIN
			/* TMF */
			INSERT INTO #total
			SELECT Value = 'TMF_total', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			GROUP BY Claim_Type, iClaim_Type
			
			/* Grouping Value: Health & Other */
			INSERT INTO #total
			SELECT Value = 'HEALTH & OTHER', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			WHERE Value = 'Health' or Value = 'Other'
			GROUP BY Claim_Type, iClaim_Type
			
			/* Grouping Value: Police & Emergency Services */
			INSERT INTO #total
			SELECT Value = 'POLICE & EMERGENCY SERVICES', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			WHERE Value = 'Police' or Value = 'Fire' or Value = 'RFS'
			GROUP BY Claim_Type, iClaim_Type
		END
		ELSE IF UPPER(@system) = 'EML'
		BEGIN
			/* WCNSW */
			INSERT INTO #total
			SELECT Value = 'WCNSW_total', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			GROUP BY Claim_Type, iClaim_Type
		END
		ELSE IF UPPER(@system) = 'HEM'
		BEGIN
			/* Hospitality */
			INSERT INTO #total
			SELECT Value = 'Hospitality_total', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			GROUP BY Claim_Type, iClaim_Type
			
			/* Grouping Value: Hotel */
			INSERT INTO #total
			SELECT Value = 'Hotel', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			WHERE Value = 'Accommodation' or Value = 'Pubs, Taverns and Bars'
			GROUP BY Claim_Type, iClaim_Type
		END
	END
	ELSE
	BEGIN
		IF @subvalue = 'all'
		BEGIN
			/* Total */
			INSERT INTO #total
			SELECT Value = @value + '_total', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			GROUP BY Claim_Type, iClaim_Type
		END
		ELSE
		BEGIN
			/* Total */
			INSERT INTO #total
			SELECT Value = @subvalue + '_total', Claim_Type, iClaim_Type, SUM(overall) as overall
			FROM #total
			GROUP BY Claim_Type, iClaim_Type
		END
	END
	
	/* Transform returning table structure and get results */
	IF (UPPER(@system) = 'HEM' OR UPPER(@system) = 'TMF')
	BEGIN
		SET @SQL = 'SELECT	Value,
							Claim_Type,
							[Sum] = (select tmp_total_2.overall
										from #total tmp_total_2
										where tmp_total_2.[Value] = tmp_total.[Value]
											and tmp_total_2.Claim_Type = tmp_total.Claim_Type)
					FROM #total tmp_total
					ORDER BY
					CASE
						/* BEGIN HEM */
						WHEN Value = ''Clubs (Hospitality)'' THEN 31
						WHEN Value = ''Accommodation'' THEN 32
						WHEN Value = ''Pubs, Taverns and Bars'' THEN 33
						WHEN Value = ''Hotel'' THEN 34
						WHEN Value = ''HEALTH'' THEN 50		-- TMF
						WHEN Value = ''Other'' THEN 51		-- TMF and HEM
						/* END HEM */
						
						/* BEGIN TMF */
						WHEN Value = ''HEALTH & OTHER'' THEN 52
						WHEN Value = ''POLICE'' THEN 53
						WHEN Value = ''FIRE'' THEN 54
						WHEN Value = ''RFS'' THEN 55
						WHEN Value like ''%POLICE & EMERGENCY SERVICES'' THEN 56
						/* END TMF */
						
						WHEN Value = ''Miscellaneous'' THEN 998
						WHEN Value like ''%total'' THEN 999
					END, Value, iClaim_Type'
	END
	ELSE
	BEGIN
		SET @SQL = 'SELECT	Value,
							Claim_Type,
							[Sum] = (select tmp_total_2.overall
										from #total tmp_total_2
										where tmp_total_2.[Value] = tmp_total.[Value]
											and tmp_total_2.Claim_Type = tmp_total.Claim_Type)
					FROM #total tmp_total
					ORDER BY
					CASE 
						 WHEN Value = ''Miscellaneous'' THEN 998
						 WHEN Value like ''%total'' THEN 999
					END, Value, iClaim_Type'
	END
	
	/* Get final results */
	EXEC(@SQL)
	
	/* Drop temp table */
	IF OBJECT_ID('tempdb..#total') IS NOT NULL DROP TABLE #total
END
GO