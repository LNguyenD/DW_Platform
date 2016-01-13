IF OBJECT_ID('views.claim_portfolio_raw_data_view') IS NOT NULL
	DROP VIEW views.claim_portfolio_raw_data_view
GO
CREATE VIEW views.claim_portfolio_raw_data_view
AS	
	WITH dte_range AS
	(
		/* For 3 years from yesterday */
		SELECT DATEADD(d, -1, CONVERT(datetime, CONVERT(char, GETDATE(), 106))) AS [Date]
		UNION ALL
		SELECT DATEADD(d, -1, [Date])
		FROM dte_range 
		WHERE [Date] > DATEADD(yy, -3, DATEADD(d, -1, CONVERT(datetime, CONVERT(char, GETDATE(), 106))))
	)
	
	select * 
	from views.claim_portfolio_view
	CROSS JOIN (
		SELECT dte1.[Date] as [Start_Date], dte2.[Date] + '23:59' as [End_Date] FROM dte_range dte1
		CROSS JOIN dte_range dte2
		WHERE dte1.[Date] <= dte2.[Date]
	) dte_range
	where Reporting_Date <= [End_Date] and ISNULL(Date_Claim_Entered, Date_Claim_Received) between [Start_Date] and	[End_Date]
GO	