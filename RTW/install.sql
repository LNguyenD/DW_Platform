-- Enable SQLCMD mode (Query -> SQLCMD Mode)

SET NOCOUNT ON

:setvar path "E:\d.vo\Work\Repos\DW_Platform\RTW"

-- staging\system.sql must be executed first
:r $(path)\staging\system.sql

:r $(path)\views\rtw_view.sql
:r $(path)\views\emi_rtw_addtargetandbase.sql
:r $(path)\views\tmf_rtw_addtargetandbase.sql
:r $(path)\views\hem_rtw_addtargetandbase.sql

:r $(path)\udfs\emi_rtw_gettargetandbase.sql
:r $(path)\udfs\tmf_rtw_gettargetandbase.sql
:r $(path)\udfs\hem_rtw_gettargetandbase.sql
:r $(path)\udfs\tmf_rtw_agency_group_compares_to_same_time_last_year_current_add_missing_group.sql

:r $(path)\views\emi_rtw_agency_group_compares_to_same_time_last_year_current.sql
:r $(path)\views\tmf_rtw_agency_group_compares_to_same_time_last_year_current.sql
:r $(path)\views\hem_rtw_agency_group_compares_to_same_time_last_year_current.sql

:r $(path)\views\emi_rtw_agency_group_rolling_month_12.sql
:r $(path)\views\tmf_rtw_agency_group_rolling_month_12.sql
:r $(path)\views\hem_rtw_agency_group_rolling_month_12.sql