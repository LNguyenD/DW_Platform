IF OBJECT_ID('udfs.tmf_getgroup_byteam_udf') IS NOT NULL
	DROP FUNCTION udfs.tmf_getgroup_byteam_udf
GO
CREATE function udfs.tmf_getgroup_byteam_udf(@Team varchar(20))
	returns varchar(20)	 
AS
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
			
		SELECT @strReturn =(case when PATINDEX('%[A-Z]%',@strReturn) >=2 
									then SUBSTRING(@strReturn,1,PATINDEX('%[A-Z]%',@strReturn)-1)
		ELSE @strReturn end)
		
		RETURN (case when PATINDEX('%[A-Z]%',@strReturn) <1
					then RTRIM(@strReturn) else 'Miscellaneous' 
				end)
	END 
GO