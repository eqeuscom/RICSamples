LPARAMETERS tcCustomerID
SELECT 0
IF NOT USED("custDet")
	USE customers AGAIN ALIAS custDet
ENDIF
SELECT custDet
LOCATE ALL FOR customerID = tcCustomerID
DO FORM custDet