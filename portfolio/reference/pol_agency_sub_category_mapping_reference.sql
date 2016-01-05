/* Agency, Sub category mapping */

IF OBJECT_ID('ref.pol_agency_sub_category_mapping_reference') IS NOT NULL
  EXEC etl.drop_table 'ref', 'pol_agency_sub_category_mapping_reference'

CREATE TABLE ref.pol_agency_sub_category_mapping_reference(
  source_system_code NVARCHAR(3),
  policy_number NVARCHAR(19),
  agency_id NVARCHAR(19),
  agency_name NVARCHAR(255),
  sub_category NVARCHAR(255),
  [group] NVARCHAR(255)
  CONSTRAINT pk_pol_agency_sub_category_mapping_ref PRIMARY KEY CLUSTERED (source_system_code, policy_number)
)

BULK INSERT ref.pol_agency_sub_category_mapping_reference
FROM 'c:\dw_data\pol_agency_sub_category_mapping_reference.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  TABLOCK
)