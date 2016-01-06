IF OBJECT_ID('udfs.emi_getgroup_byteam_udf') IS NOT NULL
	DROP FUNCTION udfs.emi_getgroup_byteam_udf
GO
CREATE function udfs.emi_getgroup_byteam_udf(@Team varchar(20))
	returns varchar(20)
AS
	BEGIN
		RETURN CASE WHEN (RTRIM(ISNULL(@Team,''))='') OR (@Team NOT LIKE 'wcnsw%' or PATINDEX('WCNSW', RTRIM(@Team))>0)
						THEN 'Miscellaneous'
					WHEN PATINDEX('WCNSW%', @Team) = 0 
						THEN Left(UPPER(RTRIM(@Team)), 1) + Right(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team))-1)
					WHEN RTRIM(@Team) = 'WCNSW'
						THEN 'WCNSW(Group)'
					ELSE SUBSTRING(Left(UPPER(RTRIM(@Team)), 1) + Right(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team))-1), 1, 
							CASE WHEN PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 6, LEN(RTRIM(@Team)) - 5)) > 0 
									THEN (PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 6, LEN(RTRIM(@Team)) - 5)) + 4) 
								ELSE LEN(RTRIM(@Team))
							END)
				END
	END 
GO