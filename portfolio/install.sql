-- Enable SQLCMD mode (Query -> SQLCMD Mode)

SET NOCOUNT ON

:setvar path "E:\d.vo\Work\Repos\DW_Platform\portfolio"

-- staging\system.sql must be executed first
:r $(path)\staging\system.sql

:r $(path)\udfs\emi_getgroup_byteam_udf.sql
:r $(path)\udfs\tmf_getgroup_byteam_udf.sql
:r $(path)\udfs\hem_getgroup_byteam_udf.sql
:r $(path)\udfs\ncmm_get_weeks_udf.sql
:r $(path)\udfs\ncmm_get_actionthisweek_udf.sql
:r $(path)\udfs\ncmm_get_actionnextweek_udf.sql
:r $(path)\udfs\ncmm_get_prepareactionduedate_udf.sql
:r $(path)\udfs\get_workingdays_udf.sql

:r $(path)\reference\pol_agency_sub_category_mapping_reference.sql
:r $(path)\reference\public_hols_reference.sql

:r $(path)\views\claim_getall_claimtype_view.sql
:r $(path)\views\claim_getall_porttype_view.sql
:r $(path)\views\claim_portfolio_view.sql
:r $(path)\views\claim_portfolio_summary_bymode_agency_view.sql
:r $(path)\views\claim_portfolio_summary_bymode_group_view.sql
:r $(path)\views\claim_portfolio_summary_bymode_portfolio_view.sql
:r $(path)\views\claim_portfolio_summary_bymode_employer_size_view.sql
:r $(path)\views\claim_portfolio_summary_bymode_account_manager_view.sql
:r $(path)\views\claim_portfolio_summary_bymode_broker_view.sql
:r $(path)\views\claim_portfolio_summary_agency_view.sql
:r $(path)\views\claim_portfolio_summary_group_view.sql
:r $(path)\views\claim_portfolio_summary_portfolio_view.sql
:r $(path)\views\claim_portfolio_summary_employer_size_view.sql
:r $(path)\views\claim_portfolio_summary_account_manager_view.sql
:r $(path)\views\claim_portfolio_summary_broker_view.sql

:r $(path)\views\claim_portfolio_detail_lastmonth_agency_view.sql
:r $(path)\views\claim_portfolio_detail_lastmonth_group_view.sql
:r $(path)\views\claim_portfolio_detail_lastmonth_portfolio_view.sql
:r $(path)\views\claim_portfolio_detail_lastmonth_employer_size_view.sql
:r $(path)\views\claim_portfolio_detail_lastmonth_account_manager_view.sql
:r $(path)\views\claim_portfolio_detail_lastmonth_broker_view.sql