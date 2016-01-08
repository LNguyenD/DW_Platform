IF OBJECT_ID('ref.public_hols_reference') IS NOT NULL
	EXEC etl.drop_table 'ref', 'public_hols_reference'

CREATE TABLE ref.public_hols_reference(
  [date] datetime
)

BULK INSERT ref.public_hols_reference
FROM 'c:\dw_data\public_hols_reference.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  TABLOCK
)