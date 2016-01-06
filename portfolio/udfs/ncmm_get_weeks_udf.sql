IF OBJECT_ID('udfs.ncmm_get_weeks_udf') IS NOT NULL
	DROP FUNCTION udfs.ncmm_get_weeks_udf
GO
CREATE FUNCTION udfs.ncmm_get_weeks_udf(@DON DATETIME, @AsAt DATETIME)
	RETURNS INT
AS
BEGIN
	RETURN CEILING(DATEDIFF(D, @DON, DATEADD(D, 1, @AsAt)) / 7.0)
END
GO