IF OBJECT_ID('udfs.rtw_gettargetandbase') IS NOT NULL
	DROP FUNCTION udfs.rtw_gettargetandbase
GO
CREATE FUNCTION udfs.rtw_gettargetandbase(@system varchar(20), @rem_end datetime, @item varchar(20), @type varchar(20),
	@value varchar(20), @sub_value varchar(20), @measure int)
	returns FLOAT
AS
BEGIN
	DECLARE @target float, @base float, @count int
	
	SELECT	@target = MIN(COALESCE(tb.[Target], 0)), @base = MIN(COALESCE(tb.[base], 0)), @count = COUNT(*)
	FROM	views.rtw_addtargetandbase tb
	WHERE	(([Type] = @type AND [Value] = @value)
			OR ([Value] = @value AND UPPER(@value) = UPPER(@system)))
			AND COALESCE([Sub_Value], '') = COALESCE(@sub_value, '')
			AND [Measure] = @measure 
			AND Remuneration = (CAST(YEAR(@rem_end) AS varchar)
								+ 'M' + CASE WHEN MONTH(@rem_end) <= 9 THEN '0' ELSE '' END
								+ CAST(MONTH(@rem_end) AS varchar))
			AND tb.[System] = UPPER(@system)
	
	IF @COUNT = 0 OR @target = 0 OR @base = 0
	BEGIN		
		SELECT	@target = MIN(tb.[Target]), @base = MIN(tb.[base])
		FROM	views.rtw_addtargetandbase tb
		WHERE	[Value] = UPPER(@system)
				AND [Measure] = @measure
				AND Remuneration= (CAST(YEAR(@rem_end) AS varchar)
									+ 'M' + CASE WHEN MONTH(@rem_end) <= 9 THEN '0' ELSE '' END 
									+ CAST(MONTH(@rem_end) AS varchar))
				AND tb.[System] = UPPER(@system)
	END
	
	IF @item = 'target' 
	BEGIN
		RETURN @target
	END 

	IF @item = 'base' 
	BEGIN
		RETURN @base
	END
	RETURN 0
END
GO