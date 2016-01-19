-- Enable SQLCMD mode (Query -> SQLCMD Mode)

SET NOCOUNT ON

:setvar path "E:\d.vo\Work\Repos\DW_Platform\RTW"

-- staging\system.sql must be executed first
:r $(path)\staging\system.sql

:r $(path)\views\rtw_view.sql
:r $(path)\views\rtw_target_base.sql

:r $(path)\udfs\rtw_get_target_base.sql

:r $(path)\views\rtw_compares_to_same_time_last_year_current.sql
:r $(path)\views\rtw_rolling_month_12.sql