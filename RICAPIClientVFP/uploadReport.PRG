close all
*
* PARAMETERS
*
LOCAL remoteReportName, organizationSubdomain
remoteReportName = "invoices/invoices4"
organizationSubdomain = "XXXXX" && put your organization subdomain here

*
* set up the reports in cloud helpers
*
SET PROCEDURE TO RICHelpers ADDITIVE 
LOCAL lcSetupError
lcSetupError = RIC_SetupWWDotNetBridge()
IF !EMPTY(lcSetupError)
	? "error: "+lcSetupError
	RETURN
ENDIF

*
* set up XFRX
*
SET PATH TO xfrxdemo
SET PROCEDURE TO utilityreportlistener ADDITIVE 

use xfrxdemo\demoreps\invoices order customer
LOCAL loObj
loObj = XFRX("XFRX#LISTENER")
lnRetVal = loObj.SetParams("invoices.xml",,,,,,"XML")
*
* run the report
*
IF lnRetVal = 0
	REPORT FORM xfrxdemo\demoreps\splash object loObj NOPAGEEJECT
	REPORT FORM xfrxdemo\demoreps\invhead object loObj NOPAGEEJECT
	REPORT FORM xfrxdemo\demoreps\invoices object loObj		
ENDIF

*
* now upload the report to RIC
*

UploadReport("invoices.xml", remoteReportName, organizationSubdomain)
RETURN


PROCEDURE UploadReport
LPARAMETERS tcXmlFileName, tcRemoteLocation, tcOrganization
*
* use the secrets table to get the secret for the given organization
* and upload the report to the server
*
IF NOT USED("secrets")
	USE secrets IN 0
ENDIF

SELECT secrets
LOCATE ALL FOR subDomain = tcOrganization
IF NOT FOUND()
	? "organization not found in the secrets table"
	RETURN
endif

LOCAL lcretval
lcretval = RIC_UploadReport(tcXmlFileName, tcRemoteLocation, tcOrganization, secrets.secret)

IF lcretval.IsOK
	? "report uploaded successfully"
ELSE
	_cliptext = ErrorMessage.lcretval
	? "error:", ErrorMessage.lcretval
ENDIF
