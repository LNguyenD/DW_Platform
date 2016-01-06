IF OBJECT_ID('udfs.ncmm_get_prepareactionduedate_udf') IS NOT NULL
	DROP FUNCTION udfs.ncmm_get_prepareactionduedate_udf
GO
CREATE function udfs.ncmm_get_prepareactionduedate_udf(@WeeksIn int, @Date_Claim_Received datetime)
	RETURNS DATETIME
AS
BEGIN
	RETURN (case when @WeeksIn <= 2 then DATEADD(week, 3, @Date_Claim_Received)
				when @WeeksIn <= 5 and @WeeksIn > 2 then DATEADD(week, 6, @Date_Claim_Received)
				when @WeeksIn <= 9 and @WeeksIn > 5 then DATEADD(week, 10, @Date_Claim_Received)
				when @WeeksIn <= 14 and @WeeksIn > 9 then DATEADD(week, 16, @Date_Claim_Received)
				when @WeeksIn = 15 then DATEADD(week, 16, @Date_Claim_Received)
				when @WeeksIn <= 18 and @WeeksIn > 15 then DATEADD(week, 20, @Date_Claim_Received)
				when @WeeksIn = 19 then DATEADD(week, 20, @Date_Claim_Received)
				when @WeeksIn <= 24 and @WeeksIn > 19 then DATEADD(week, 26, @Date_Claim_Received)
				when @WeeksIn = 25 then DATEADD(week, 26, @Date_Claim_Received)
				when @WeeksIn <= 38 and @WeeksIn > 25 then DATEADD(week, 40, @Date_Claim_Received)
				when @WeeksIn = 39 then DATEADD(week, 40, @Date_Claim_Received)
				when @WeeksIn <= 50 and @WeeksIn > 39 then DATEADD(week, 52, @Date_Claim_Received)
				when @WeeksIn = 51 then DATEADD(week, 52, @Date_Claim_Received)
				when @WeeksIn <= 63 and @WeeksIn > 51 then DATEADD(week, 65, @Date_Claim_Received)
				when @WeeksIn = 64 then DATEADD(week, 65, @Date_Claim_Received)
				when @WeeksIn <= 75 and @WeeksIn > 64 then DATEADD(week, 78, @Date_Claim_Received)
				when @WeeksIn <= 77 and @WeeksIn > 75 then DATEADD(week, 78, @Date_Claim_Received)
				when @WeeksIn <= 88 and @WeeksIn > 77 then DATEADD(week, 90, @Date_Claim_Received)
				when @WeeksIn = 89 then DATEADD(week, 90, @Date_Claim_Received)
				when @WeeksIn <= 98 and @WeeksIn > 89 then DATEADD(week, 100, @Date_Claim_Received)
				when @WeeksIn = 99 then DATEADD(week, 100, @Date_Claim_Received)
				when @WeeksIn <= 112 and @WeeksIn > 99 then DATEADD(week, 114, @Date_Claim_Received)
				when @WeeksIn = 113 then DATEADD(week, 114, @Date_Claim_Received)
				when @WeeksIn <= 130 and @WeeksIn > 113 then DATEADD(week, 132, @Date_Claim_Received)
				when @WeeksIn = 131 then DATEADD(week, 132, @Date_Claim_Received)
				when @WeeksIn = 132 then DATEADD(week, 132, @Date_Claim_Received)
				when @WeeksIn > 132 and (@WeeksIn - 132) % 13 = 11 then DATEADD(week, @WeeksIn + 2, @Date_Claim_Received)
				when @WeeksIn > 132 and (@WeeksIn - 132) % 13 = 12 then DATEADD(week, @WeeksIn + 1, @Date_Claim_Received)
				else null
			end)
END 
GO