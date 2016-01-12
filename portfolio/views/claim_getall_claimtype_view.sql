IF OBJECT_ID('views.claim_getall_claimtype_view') IS NOT NULL
	DROP VIEW views.claim_getall_claimtype_view
GO
CREATE VIEW views.claim_getall_claimtype_view
AS
	-- NEW CLAIMS
	SELECT  Claim_Type = 'claim_new_all', iClaim_Type = 0
	union SELECT Claim_Type = 'claim_new_lt', iClaim_Type = 1
	union SELECT Claim_Type = 'claim_new_nlt', iClaim_Type = 2
	
	-- BEGIN: OPEN CLAIMS	
		
	union SELECT Claim_Type = 'claim_open_all', iClaim_Type = 3
	
	-- OPEN CLAIMS: RTW - EMICS
	union SELECT Claim_Type = 'claim_open_0_13', iClaim_Type = 4
	union SELECT Claim_Type = 'claim_open_13_26', iClaim_Type = 5
	union SELECT Claim_Type = 'claim_open_26_52', iClaim_Type = 6
	union SELECT Claim_Type = 'claim_open_52_78', iClaim_Type = 7
	union SELECT Claim_Type = 'claim_open_0_78', iClaim_Type = 8
	union SELECT Claim_Type = 'claim_open_78_130', iClaim_Type = 9
	union SELECT Claim_Type = 'claim_open_gt_130', iClaim_Type = 10
	
	-- OPEN CLAIMS: RTW - WOW
	union SELECT Claim_Type = 'claim_open_lt_05', iClaim_Type = 11
	union SELECT Claim_Type = 'claim_open_lt_013', iClaim_Type = 12
	union SELECT Claim_Type = 'claim_open_lt_26', iClaim_Type = 13
	union SELECT Claim_Type = 'claim_open_lt_52', iClaim_Type = 14
	union SELECT Claim_Type = 'claim_open_lt_78', iClaim_Type = 15
	union SELECT Claim_Type = 'claim_open_lt_104', iClaim_Type = 16
	union SELECT Claim_Type = 'claim_open_lt_130', iClaim_Type = 17
	union SELECT Claim_Type = 'claim_open_ge_130', iClaim_Type = 18
	
	union SELECT Claim_Type = 'claim_open_nlt', iClaim_Type = 19
	
	-- OPEN CLAIMS: NCMM
	union SELECT Claim_Type = 'claim_open_ncmm_this_week', iClaim_Type = 20
	union SELECT Claim_Type = 'claim_open_ncmm_next_week', iClaim_Type = 21
	
	-- OPEN CLAIMS: THERAPY TREATMENTS
	union SELECT Claim_Type = 'claim_open_acupuncture', iClaim_Type = 22
	union SELECT Claim_Type = 'claim_open_chiro', iClaim_Type = 23
	union SELECT Claim_Type = 'claim_open_massage', iClaim_Type = 24
	union SELECT Claim_Type = 'claim_open_osteo', iClaim_Type = 25
	union SELECT Claim_Type = 'claim_open_physio', iClaim_Type = 26
	union SELECT Claim_Type = 'claim_open_rehab', iClaim_Type = 27
	
	-- OPEN CLAIMS: LUMP SUM INTIMATIONS
	union SELECT Claim_Type = 'claim_open_death', iClaim_Type = 28
	union SELECT Claim_Type = 'claim_open_industrial_deafness', iClaim_Type = 29
	union SELECT Claim_Type = 'claim_open_ppd', iClaim_Type = 30
	union SELECT Claim_Type = 'claim_open_recovery', iClaim_Type = 31
	
	-- OPEN CLAIMS: LUMP SUM INTIMATIONS - WPI
	union SELECT Claim_Type = 'claim_open_wpi_all', iClaim_Type = 32
	union SELECT Claim_Type = 'claim_open_wpi_0_10', iClaim_Type = 33
	union SELECT Claim_Type = 'claim_open_wpi_11_14', iClaim_Type = 34
	union SELECT Claim_Type = 'claim_open_wpi_15_20', iClaim_Type = 35
	union SELECT Claim_Type = 'claim_open_wpi_21_30', iClaim_Type = 36
	union SELECT Claim_Type = 'claim_open_wpi_31_more', iClaim_Type = 37
	
	union SELECT Claim_Type = 'claim_open_wid', iClaim_Type = 38
	
	-- END: OPEN CLAIMS
	
	-- CLAIM CLOSURES
	union SELECT Claim_Type = 'claim_closure', iClaim_Type = 39
	union SELECT Claim_Type = 'claim_re_open', iClaim_Type = 40
	union SELECT Claim_Type = 'claim_still_open', iClaim_Type = 41
GO