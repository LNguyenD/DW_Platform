IF OBJECT_ID('usps.claim_portfolio_detail_usp') IS NOT NULL
	DROP PROCEDURE usps.claim_portfolio_detail_usp
GO
CREATE PROCEDURE usps.claim_portfolio_detail_usp
(
	@system VARCHAR(10)
	,@type VARCHAR(20)
	,@value NVARCHAR(256)
	,@subvalue NVARCHAR(256)
	,@subsubvalue NVARCHAR(256)
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
	IF OBJECT_ID('tempdb..#brokers10') IS NOT NULL DROP TABLE #brokers10
	
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL
	)
	
	DECLARE @WHERE_CONS VARCHAR(MAX) = 
		/* Append the filter condition based on @value */
		case when @value <> 'all'
				then 
					case when UPPER(@system) = 'TMF'
							then
								case when @type = 'agency' 
										then
											case when @value = 'health@@@other' 
													then ' and rtrim(isnull(sub.agency_name,''Miscellaneous'')) in (''health'',''other'')'
												when @value = 'police@@@emergency services'
													then ' and rtrim(isnull(sub.agency_name,''Miscellaneous'')) in (''police'',''fire'',''rfs'')'
												when @value like '%_total' 
													then ' '
												else ' and rtrim(isnull(sub.agency_name,''Miscellaneous'')) = ''' + @value + ''' '
											end														
									when @type = 'group'
										then
											case when @value like '%_total'
													then ' '
												else ' and dbo.claim_portfolio_getgroup_byteam_tmf_udf(Team) = ''' + @value + ''''
											end
									else ''
								end
						when UPPER(@system) = 'EML'
							then
								case when @type = 'employer_size' 
										then
											case when @value like '%_total'
													then ' '
												else ' and [EMPL_SIZE] = ''' + @value + ''''
											end
									when @type = 'group'
										then
											case when @value like '%_total' 
													then ' '
												else ' and dbo.claim_portfolio_getgroup_byteam_eml_udf(Team) = ''' + @value + ''''
											end
									when @type = 'account_manager'
										then 
											case when @value like '%_total'
													then ' '
												else ' and [Account_Manager] = ''' + @value + ''''
											end
									when @type = 'broker'
										then 
											case when @value like '%_total'
													then ' '
												else ' and [Broker_Name] = ''' + @value + ''''
											end
									else ''
								end
						when UPPER(@system) = 'HEM'
							then
								case when @type = 'account_manager'
										then
											case when @value like '%_total'
													then ' '
												else ' and [Account_Manager] = ''' + @value + ''''
											end
									when @type = 'portfolio' 
										then
											case when @value = 'hotel'
													then ' and ([portfolio] = ''Accommodation'' or [portfolio] = ''Pubs, Taverns and Bars'')'
												when @value like '%_total'
													then ' '
												else ' and [Portfolio] = ''' + @value + ''''
											end
									when @type = 'group' 
										then
											case when @value like '%_total'
													then ' '
												else ' and dbo.claim_portfolio_getgroup_byteam_hem_udf(Team) = ''' + @value + ''''
											end
									when @type = 'broker'
										then
											case when @value like '%_total'
													then ' '
												else ' and [Broker_Name] = ''' + @value + ''''
											end
									else ''
								end
					end
		end +
		
		/* Append the filter condition based on @subvalue */
		case when @subvalue <> 'all' 
				then
					case when @subvalue like '%_total' 
							then
								case when UPPER(@system) = 'TMF'
									then
										case when @type = 'agency'
												then ' and rtrim(isnull(sub.agency_name,''Miscellaneous'')) = ''' + @value + ''''
											when @type = 'group' 
												then ' and dbo.claim_portfolio_getgroup_byteam_tmf_udf(Team) = ''' + @value + ''''
											else ''
										end
									when UPPER(@system) = 'EML'
										then
											case when @type = 'group' 
													then ' and dbo.claim_portfolio_getgroup_byteam_eml_udf(Team) = ''' + @value + ''''
												when @type = 'employer_size'
													then ' and [EMPL_SIZE] = ''' + @value + ''''
												when @type = 'account_manager'
													then ' and [Account_Manager] = ''' + @value + ''''
												when @type = 'broker'
													then ' and [Broker_Name] = ''' + @value + ''''
												else ''
											end
									when UPPER(@system) = 'HEM'
										then
											case when @type = 'account_manager'
													then ' and [Account_Manager] = ''' + @value + ''''
												when @type = 'portfolio' 
													then ' and [Portfolio] = ''' + @value + ''''
												when @type = 'group'
													then ' and dbo.claim_portfolio_getgroup_byteam_hem_udf(Team) = ''' + @value + ''''
												when @type = 'broker'
													then ' and [Broker_Name] = ''' + @value + ''''
												else ''
											end
								end
						else
							case when UPPER(@system) = 'TMF'
									then
										case when @type = 'agency' 
												then ' and rtrim(isnull(sub.Sub_Category,''Miscellaneous'')) = ''' + @subvalue + ''''
											when @type = 'group' 
												then ' and [Team] = ''' + @subvalue + ''''
											else ''
										end
								when UPPER(@system) = 'EML'
									then
										case when @type = 'group'
												then ' and [Team] = ''' + @subvalue + ''''
											when @type = 'employer_size' or @type = 'account_manager'
												then ' and [EMPL_SIZE] = ''' + @subvalue + ''''
											else ''
										end
								when UPPER(@system) = 'HEM'
									then
										case when @type = 'account_manager' or @type = 'portfolio'
												then ' and [EMPL_SIZE] = ''' + @subvalue + ''''
											when @type = 'group'
												then ' and [Team] = ''' + @subvalue + ''''
											else ''
										end
							end
					end
			else ''
		end +
		
		/* Append the filter condition based on @subsubvalue */
		case when @subsubvalue <> 'all' 
				then
					case when @subsubvalue like '%_total' 
							then
								case when UPPER(@system) = 'TMF'
									then
										case when @type = 'agency' 
												then ' and rtrim(isnull(sub.Sub_Category,''Miscellaneous'')) = ''' + @subvalue + ''''
											when @type = 'group' 
												then ' and [Team] = ''' + @subvalue + ''''
											else ''
										end
									when UPPER(@system) = 'EML'
										then
											case when @type = 'group' 
													then ' and [Team] = ''' + @subvalue + ''''
												when @type = 'employer_size' or @type = 'account_manager'
													then ' and [EMPL_SIZE] = ''' + @subvalue + ''''
												else ''
											end
									when UPPER(@system) = 'HEM'
										then
											case when @type = 'account_manager' or @type = 'portfolio' 
													then ' and [EMPL_SIZE] = ''' + @subvalue + '''' 
												when @type = 'group' 
													then ' and [Team] = ''' + @subvalue + ''''
												else ''
											end
								end
						else ' and [Claims_Officer_Name] = ''' + @subsubvalue + ''''
					end
			else ''
		end
	
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
													then '[Broker_Name]'
												else ''''''
											end
									when UPPER(@system) = 'HEM'
										then
											case when @type = 'account_manager' 
													then '[Account_Manager]' 
												when @type = 'portfolio'
													then '[Portfolio]'
												when @type = 'group'
													then 'dbo.claim_portfolio_getgroup_byteam_hem_udf(Team)'
												when @type = 'broker'
													then '[Broker_Name]'
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
				,[Med_Cert_Status],[Is_Working],[Physio_Paid],[Chiro_Paid],[Massage_Paid],[Osteopathy_Paid]
				,[Acupuncture_Paid],[Rehab_Paid],[Is_Stress],[Is_Inactive_Claims],[Is_Medically_Discharged],[Is_Exempt]
				,[Is_Reactive],[Is_Medical_Only],[Is_D_D],[NCMM_Actions_This_Week],[NCMM_Actions_Next_Week],[NCMM_Complete_Action_Due],[NCMM_Prepare_Action_Due]
				,[HoursPerWeek],[Is_Industrial_Deafness]'
				+ case when @type = 'agency'
						then ' FROM views.claim_portfolio_view uv left join ref.pol_agency_sub_category_mapping_reference sub on sub.policy_number = uv.Policy_No'
					else ' FROM view.claim_portfolio_view'
				end +
				' WHERE [System] = ''' + UPPER(@system) + '''' + @WHERE_CONS +
					' AND Reporting_Date <= ''' + CONVERT(VARCHAR, @end_date, 120) + ''''
					
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
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
		[Med_Cert_Status] [varchar](20) NULL,
		[Is_Working] [bit] NULL,
		[Physio_Paid] [float] NULL,
		[Chiro_Paid] [float] NULL,
		[Massage_Paid] [float] NULL,
		[Osteopathy_Paid] [float] NULL,
		[Acupuncture_Paid] [float] NULL,
		[Rehab_Paid] [float] NULL,
		[Is_Stress] [bit] NULL,
		[Is_Inactive_Claims] [bit] NULL,
		[Is_Medically_Discharged] [bit] NULL,
		[Is_Exempt] [bit] NULL,
		[Is_Reactive] [bit] NULL,
		[Is_Medical_Only] [bit] NULL,
		[Is_D_D] [bit] NULL,
		[NCMM_Actions_This_Week] [varchar](256) NULL,
		[NCMM_Actions_Next_Week] [varchar](256) NULL,
		[NCMM_Complete_Action_Due] [datetime] NULL,
		[NCMM_Prepare_Action_Due] [datetime] NULL,
		[HoursPerWeek] [float] NULL,
		[Is_Industrial_Deafness] [bit] NULL,
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
	
	/* Create #brokers10 table to store Top 10 brokers by largest Open claims (ONLY FOR EML/HEM) */
	CREATE TABLE #brokers10
	(
		[Broker_Name] [varchar](256) NULL
	)
	
	IF UPPER(@system) IN ('EML', 'HEM') AND @type = 'broker' AND @value like '%_total'
	BEGIN
		/* Retrieve Top 10 brokers by largest Open claims */
		INSERT INTO #brokers10
		SELECT TOP 10 Value
			FROM #claim_open_all
			GROUP BY [Value]
			HAVING [Value] <> ''
			ORDER BY COUNT(DISTINCT Claim_No) DESC
			
		/* Clean data that not belong to Top 10 brokers by largest Open claims */
		DELETE FROM #claim_all WHERE Value NOT IN (SELECT [Broker_Name] FROM #brokers10) OR Value IS NULL
	END
			
	/* Drop temp tables */
	IF OBJECT_ID('tempdb..#claim_new_all') IS NOT NULL DROP TABLE #claim_new_all
	IF OBJECT_ID('tempdb..#claim_open_all') IS NOT NULL DROP TABLE #claim_open_all
	IF OBJECT_ID('tempdb..#claim_closure') IS NOT NULL DROP TABLE #claim_closure
	IF OBJECT_ID('tempdb..#claim_re_open') IS NOT NULL DROP TABLE #claim_re_open
	IF OBJECT_ID('tempdb..#claim_re_open_still_open') IS NOT NULL DROP TABLE #claim_re_open_still_open
	IF OBJECT_ID('tempdb..#brokers10') IS NOT NULL DROP TABLE #brokers10
		
	CREATE TABLE #total
	(
		Value nvarchar(150) NULL				
		,Claim_type nvarchar(150) NULL
		,iClaim_Type [float] NULL		
		,ffsd_at_work_15_less [float] NULL
		,ffsd_at_work_15_more [float] NULL
		,ffsd_not_at_work [float] NULL
		,pid [float] NULL
		,totally_unfit [float] NULL
		,therapy_treat [float] NULL
		,d_d [float] NULL
		,med_only [float] NULL
		,lum_sum_in [float] NULL
		,ncmm_this_week [float] NULL
		,ncmm_next_week [float] NULL
		,overall [float] NULL
	)				

	SET @SQL = 'SELECT tmp.Value, Claim_type, tmp.iClaim_Type
					,ffsd_at_work_15_less = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and  Med_Cert_Status = ''SID'' and Is_Working = 1 and HoursPerWeek <= 15)
						
					,ffsd_at_work_15_more = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and  Med_Cert_Status = ''SID'' and Is_Working = 1 and HoursPerWeek > 15)
						
					,ffsd_not_at_work = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and  Med_Cert_Status = ''SID'' and Is_Working = 0)
						
					,pid = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and  Med_Cert_Status = ''PID'')
						
					,totally_unfit = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and  Med_Cert_Status = ''TU'')
						
					,therapy_treat=(select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and (Physio_Paid > 2000 or Chiro_Paid > 1000 or Massage_Paid > 0 or Osteopathy_Paid > 0 or Acupuncture_Paid > 0 or Rehab_Paid > 0)) 
					
					,d_d = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and Is_D_D = 1) 
					
					,med_only = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and Is_Medical_Only = 1) 
					
					,lum_sum_in = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and (Total_Recoveries <> 0 or Common_Law = 1 or WPI >= 0 or Result_Of_Injury_Code = 3 or Result_Of_Injury_Code = 1 or Is_Industrial_Deafness = 1)) 
					
					,ncmm_this_week = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and NCMM_Actions_This_Week <> '''' and NCMM_Complete_Action_Due > ''' + CONVERT(VARCHAR, @end_date, 120) + ''')
					
					,ncmm_next_week = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type
						and NCMM_Actions_Next_Week <> ''''
						and NCMM_Prepare_Action_Due BETWEEN ''' + CONVERT(VARCHAR, DATEADD(week, 1, @end_date), 120) + ''' AND ''' + CONVERT(VARCHAR, DATEADD(week, 3, @end_date), 120) + ''')
					
					,overall = (select COUNT(distinct Claim_No) from #claim_all where claim_type COLLATE Latin1_General_CI_AS = tmp.Claim_Type)
					FROM
					(
						select * from views.claim_getall_claimtype_view
						cross join (select ''' +
										case when @subsubvalue <> 'all' 
												then @subsubvalue
											else 
												case when @subvalue <> 'all'
														then @subvalue
													else @value
												end
										end + ''' as Value) as tmp_value
					) as tmp'
	
	INSERT INTO #total
	EXEC(@SQL)	

	/* Drop temp tables */
	IF OBJECT_ID('tempdb..#claim_all') IS NOT NULL DROP TABLE #claim_all
	IF OBJECT_ID('tempdb..#claim_list') IS NOT NULL DROP TABLE #claim_list
	
	/* Transform returning table structure and get results */
	SET @SQL = 'SELECT Value,
						Claim_Type,
						iClaim_Type,
						[Type] = tmp_port_type.PORT_Type,
						iType = tmp_port_type.iPORT_Type,
						[Sum] = (select (case when tmp_port_type.PORT_Type = ''ffsd_at_work_15_less''
												then tmp_total_2.ffsd_at_work_15_less
											when tmp_port_type.PORT_Type = ''ffsd_at_work_15_more''
												then tmp_total_2.ffsd_at_work_15_more
											when tmp_port_type.PORT_Type = ''ffsd_not_at_work''
												then tmp_total_2.ffsd_not_at_work
											when tmp_port_type.PORT_Type = ''pid''
												then tmp_total_2.pid
											when tmp_port_type.PORT_Type = ''totally_unfit''
												then tmp_total_2.totally_unfit
											when tmp_port_type.PORT_Type = ''therapy_treat''
												then tmp_total_2.therapy_treat
											when tmp_port_type.PORT_Type = ''d_d''
												then tmp_total_2.d_d
											when tmp_port_type.PORT_Type = ''med_only''
												then tmp_total_2.med_only
											when tmp_port_type.PORT_Type = ''lum_sum_in''
												then tmp_total_2.lum_sum_in
											when tmp_port_type.PORT_Type = ''ncmm_this_week''
												then tmp_total_2.ncmm_this_week
											when tmp_port_type.PORT_Type = ''ncmm_next_week''
												then tmp_total_2.ncmm_next_week
											when tmp_port_type.PORT_Type = ''overall''
												then tmp_total_2.overall
										end)
								from #total tmp_total_2
								where tmp_total_2.[Value] = tmp_total.[Value]
									and tmp_total_2.Claim_Type = tmp_total.Claim_Type)
				FROM #total tmp_total
				CROSS JOIN (SELECT * from views.claim_getall_porttype_view) tmp_port_type
				UNION
				SELECT '''' AS Value, ''New claims'' AS Claim_Type, -1 AS iClaim_Type, '''' AS [Type], -1 AS iType, 0 AS [Sum]
				UNION
				SELECT '''' AS Value, ''Open claims'' AS Claim_Type, -1 AS iClaim_Type, '''' AS [Type], -1 AS iType, 0 AS [Sum]
				UNION
				SELECT '''' AS Value, ''Therapy treatment'' AS Claim_Type, -1 AS iClaim_Type, '''' AS [Type], -1 AS iType, 0 AS [Sum]
				UNION
				SELECT '''' AS Value, ''Lump sum intimations'' AS Claim_Type, -1 AS iClaim_Type, '''' AS [Type], -1 AS iType, 0 AS [Sum]
				UNION
				SELECT '''' AS Value, ''Claim closures'' AS Claim_Type, -1 AS iClaim_Type, '''' AS [Type], -1 AS iType, 0 AS [Sum]
				ORDER BY Value, iClaim_Type, tmp_port_type.iPORT_Type'
				
	/* Get final results */
	EXEC(@SQL)
	
	/* Drop temp table */
	IF OBJECT_ID('tempdb..#total') IS NOT NULL DROP TABLE #total
END
GO