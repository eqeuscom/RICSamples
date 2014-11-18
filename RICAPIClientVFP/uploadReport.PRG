close all

SET PATH TO xfrxdemo
SET PROCEDURE TO utilityreportlistener

use xfrxdemo\demoreps\invoices order customer
LOCAL loObj
*
* get the xfrxlistener object reference
*
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

UploadReport("invoices.xml", "invoices/invoices4", "demo")
return


PROCEDURE UploadReport
LPARAMETERS tcXmlFileName, tcRemoteLocation, tcOrganization


do wwDotNetBridge
LOCAL loBridge as wwDotNetBridge
loBridge = CreateObject("wwDotNetBridge","V4")

loBridge.LoadAssembly("RICAPIClientLib.dll")
IF !EMPTY(loBridge.cErrorMsg)
	? loBridge.cErrorMsg
endif
loBridge.LoadAssembly("System.Net.Http.Formatting")
IF !EMPTY(loBridge.cErrorMsg)
	? loBridge.cErrorMsg
endif
loBridge.LoadAssembly("Newtonsoft.Json")
IF !EMPTY(loBridge.cErrorMsg)
	? loBridge.cErrorMsg
endif

LOCAL loUserAPI, retval

IF NOT USED("secrets")
	USE secrets IN 0
ENDIF

SELECT secrets
LOCATE ALL FOR subDomain = tcOrganization
IF NOT FOUND()
	? "organization not found in the secrets table"
	RETURN
endif

loUserAPI = loBridge.CreateInstance("RICAPIClientLib.API.UserAPIClient", tcOrganization, secrets.secret)
IF !EMPTY(loBridge.cErrorMsg)
	? loBridge.cErrorMsg
endif

retval = loUserAPI.UploadReport(tcXmlFileName, tcRemoteLocation)

IF retval.IsOK
	? "report uploaded successfully"
ELSE
	_cliptext = retval.ErrorMessage
	? "error:", retval.ErrorMessage
ENDIF
