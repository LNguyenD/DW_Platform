IF OBJECT_ID('udfs.emi_rtw_gettargetandbase') IS NOT NULL
	DROP FUNCTION udfs.emi_rtw_gettargetandbase
GO
CREATE FUNCTION udfs.emi_rtw_gettargetandbase(@rem_end datetime, @item varchar(20), @type varchar(20), @value varchar(20), @sub_value varchar(20), @measure int)
	returns FLOAT
AS
BEGIN
	DECLARE @target float,@base float, @count int
	
	SELECT  @target = min(isnull(tb.[Target], 0)),@base = min(isnull(tb.[base], 0)),@count = count(*)
	FROM views.[emi_rtw_addtargetandbase] tb 
	WHERE 
	(([Type] = @type AND [Value] = @value)
	OR ([Value] = @value AND @value = 'emi'))
	AND ISNULL([Sub_Value], '') = ISNULL(@sub_value, '')
	AND [Measure] = @measure and Remuneration= (cast(year(@rem_end) AS varchar) 
                      + 'M' + CASE WHEN MONTH(@rem_end) <= 9 THEN '0' ELSE '' END 
                      + cast(month(@rem_end) AS varchar))	
	
	IF @COUNT = 0 OR @target = 0 OR @base = 0
	BEGIN		
		SELECT @target = min(tb.[Target]), @base = min(tb.[base])
		FROM views.[emi_rtw_addtargetandbase] tb 
		WHERE [Value] = 'emi'		
		AND [Measure] = @measure and Remuneration= (cast(year(@rem_end) AS varchar) 
                      + 'M' + CASE WHEN MONTH(@rem_end) <= 9 THEN '0' ELSE '' END 
                      + cast(month(@rem_end) AS varchar))						
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