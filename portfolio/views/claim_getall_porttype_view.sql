IF OBJECT_ID('views.claim_getall_porttype_view') IS NOT NULL
	DROP VIEW views.claim_getall_porttype_view
GO
CREATE VIEW views.claim_getall_porttype_view
AS
	SELECT PORT_Type = 'ffsd_at_work_15_less', iPORT_Type = 1
	union SELECT PORT_Type = 'ffsd_at_work_15_more', iPORT_Type = 2
	union SELECT PORT_Type = 'ffsd_not_at_work', iPORT_Type = 3
	union SELECT PORT_Type = 'pid', iPORT_Type = 4
	union SELECT PORT_Type = 'totally_unfit', iPORT_Type = 5
	union SELECT PORT_Type = 'therapy_treat', iPORT_Type = 6
	union SELECT PORT_Type = 'd_d', iPORT_Type = 7
	union SELECT PORT_Type = 'med_only', iPORT_Type = 8
	union SELECT PORT_Type = 'lum_sum_in', iPORT_Type = 9
	union SELECT PORT_Type = 'ncmm_this_week', iPORT_Type = 10
	union SELECT PORT_Type = 'ncmm_next_week', iPORT_Type = 11
	union SELECT PORT_Type = 'overall', iPORT_Type = 12
GO