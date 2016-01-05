IF OBJECT_ID('udfs.hem_getgroup_byteam_udf') IS NOT NULL
	DROP FUNCTION udfs.hem_getgroup_byteam_udf
GO
CREATE function udfs.hem_getgroup_byteam_udf(@Team varchar(20))
	returns varchar(20)
AS
	BEGIN
		RETURN CASE WHEN (RTRIM(ISNULL(@Team,''))='') OR @Team NOT LIKE 'hosp%'
						THEN 'Miscellaneous'
				WHEN PATINDEX('HEM%', @Team) = 0 
					THEN Left(UPPER(RTRIM(@Team)), 1) + Right(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team))-1)
				ELSE SUBSTRING(Left(UPPER(RTRIM(@Team)), 1) + Right(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team))-1), 1, 
						CASE WHEN PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 4, LEN(RTRIM(@Team)) - 3)) > 0 
								THEN (PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 4, LEN(RTRIM(@Team)) - 3)) + 2) 
							ELSE LEN(RTRIM(@Team))
						END)
				END
	END 
GO