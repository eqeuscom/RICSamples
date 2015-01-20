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
* get the secret for the current organization
*
LOCAL secret
secret = GetSecret(organizationSubdomain)
IF EMPTY(secret)
	? "organization not found in the secrets table"
	RETURN
ENDIF
*
* now upload the report to RIC
*
_UploadReport("invoices.xml", remoteReportName, organizationSubdomain, secret)

*
* convert the report to PDF
*
LOCAL loSession, loXFF 
loXFF = EVALUATE([xfrx("XFRX#XML")])
loXFF.OpenDocument("invoices.xml")

loSession=EVALUATE([xfrx("XFRX#INIT")])
lnRetVal = m.loSession.SetParams("invoices.pdf",,.T.,,,,"PDF")
loSession.transformReport(m.loXFF)

*
* upload the PDF to RIC
*
_UploadExportedFile("invoices.pdf", "PDF", remoteReportName, organizationSubdomain, secret)

RETURN

PROCEDURE _UploadReport
LPARAMETERS tcXmlFileName, tcRemoteLocation, tcOrganization, tcSecret
*
* upload the report to the server
*
LOCAL lcretval
lcretval = RIC_UploadReport(tcXmlFileName, tcRemoteLocation, tcOrganization, tcSecret)

IF lcretval.IsOK
	? "report uploaded successfully"
ELSE
	_cliptext = lcretval.ErrorMessage
	? "error:", lcretval.ErrorMessage
ENDIF

PROCEDURE _UploadExportedFile
LPARAMETERS tcXmlFileName, tcType, tcRemoteLocation, tcOrganization, tcSecret
*
* upload the report to the server
*
LOCAL lcretval
lcretval = RIC_UploadExportedFile(tcXmlFileName, tcType, tcRemoteLocation, tcOrganization, tcSecret)

IF lcretval.IsOK
	? "file uploaded successfully"
ELSE
	_cliptext = lcretval.ErrorMessage
	? "error:", lcretval.ErrorMessage
ENDIF


PROCEDURE GetSecret
LPARAMETERS tcOrganization
*
* use the secrets table to get the secret for the given organization
*
IF NOT USED("secrets")
	USE secrets IN 0
ENDIF

SELECT secrets
LOCATE ALL FOR subDomain = tcOrganization
IF NOT FOUND()
	RETURN ""
ENDIF
RETURN secrets.secret

