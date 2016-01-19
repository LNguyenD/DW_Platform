IF OBJECT_ID('udfs.getgroup_byteam_udf') IS NOT NULL
	DROP FUNCTION udfs.getgroup_byteam_udf
GO
CREATE function udfs.getgroup_byteam_udf(@System varchar(20), @Team varchar(20))
	returns varchar(20)
AS
BEGIN
	DECLARE @group varchar(20) = ''

	IF UPPER(@System) = 'EMI'
	BEGIN
		SET @group = CASE WHEN (RTRIM(ISNULL(@Team,'')) = '') OR (@Team NOT LIKE 'wcnsw%' or PATINDEX('WCNSW', RTRIM(@Team)) > 0)
							THEN 'Miscellaneous'
						WHEN PATINDEX('WCNSW%', @Team) = 0 
							THEN LEFT(UPPER(RTRIM(@Team)), 1) + RIGHT(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team)) - 1)
						WHEN RTRIM(@Team) = 'WCNSW'
							THEN 'WCNSW(Group)'
						ELSE SUBSTRING(LEFT(UPPER(RTRIM(@Team)), 1) + RIGHT(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team))-1), 1,
								CASE WHEN PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 6, LEN(RTRIM(@Team)) - 5)) > 0 
										THEN (PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 6, LEN(RTRIM(@Team)) - 5)) + 4) 
									ELSE LEN(RTRIM(@Team))
								END)
					END
	END
	ELSE IF UPPER(@System) = 'TMF'
	BEGIN
		DECLARE @strReturn varchar(20)
		
		IF RTRIM(ISNULL(@Team, '')) = ''
		BEGIN
			SET @strReturn = 'Miscellaneous'
		END
		ELSE
		BEGIN
			SET @strReturn= REPLACE(@Team,'tmf','')
		END
			
		SELECT @strReturn = CASE WHEN PATINDEX('%[A-Z]%',@strReturn) >= 2
									THEN SUBSTRING(@strReturn,1,PATINDEX('%[A-Z]%',@strReturn)-1)
								ELSE @strReturn
							END
		
		SET @group = CASE WHEN PATINDEX('%[A-Z]%',@strReturn) < 1
							THEN RTRIM(@strReturn) 
						ELSE 'Miscellaneous'
					END
	END
	ELSE IF UPPER(@System) = 'HEM'
	BEGIN
		SET @group = CASE WHEN (RTRIM(ISNULL(@Team,'')) = '') OR @Team NOT LIKE 'hosp%'
							THEN 'Miscellaneous'
						WHEN PATINDEX('HEM%', @Team) = 0 
							THEN LEFT(UPPER(RTRIM(@Team)), 1) + RIGHT(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team)) - 1)
						ELSE SUBSTRING(LEFT(UPPER(RTRIM(@Team)), 1) + RIGHT(LOWER(RTRIM(@Team)), LEN(RTRIM(@Team))-1), 1, 
								CASE WHEN PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 4, LEN(RTRIM(@Team)) - 3)) > 0 
										THEN (PATINDEX('%[A-Z]%', SUBSTRING(RTRIM(@Team), 4, LEN(RTRIM(@Team)) - 3)) + 2) 
									ELSE LEN(RTRIM(@Team))
								END)
					END
	END
	
	RETURN @group
END
GO