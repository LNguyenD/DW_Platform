IF OBJECT_ID('udfs.get_workingdays_udf') IS NOT NULL
	DROP FUNCTION udfs.get_workingdays_udf
GO
CREATE function udfs.get_workingdays_udf(@startdate DATETIME, @enddate DATETIME)  
	RETURNS int
AS  
BEGIN
	DECLARE @tempdate DATETIME, @tempdays int, @workingdays int

	IF @startdate > @enddate
	BEGIN  
		-- swap dates around if @startdate > @enddate
		SELECT @tempdate = @enddate
		SELECT @enddate = @startdate
		SELECT @startdate = @tempdate
	END

	SELECT @workingdays = 0, @tempdate = @startdate
	
	-- calculates the remainding days
	SELECT @tempdays = (7 - (DATEPART(dw, @startdate) - DATEPART(dw, @enddate))) 
			- ((7 - (DATEPART(dw, @startdate) - DATEPART(dw, @enddate))) / 7 * 7)

	WHILE @startdate <= DATEADD(d, @tempdays, @tempdate)
	BEGIN  
		-- determines if remainding days are weekdays
		IF DATEPART(dw,@startdate) > 1 AND DATEPART(dw,@startdate) < 7
		BEGIN
			SELECT @workingdays = @workingdays + 1  
		END
		
		SELECT @startdate = DATEADD(dd, 1, @startdate)
	END
	
	-- calculates all other weekdays minues Public Hols
	SELECT	@workingdays = (DATEDIFF ( d, @tempdate, @enddate) / 7 * 5)
			- (SELECT COUNT(*) FROM ref.public_hols_reference WHERE date BETWEEN @tempdate AND @enddate AND DATEPART(dw, date) BETWEEN 2 AND 6)
			+ @workingdays
			
	IF @workingdays > 0
	BEGIN
		SELECT @WorkingDays = @WorkingDays - 1
	END
	
	RETURN @WorkingDays
END
GO