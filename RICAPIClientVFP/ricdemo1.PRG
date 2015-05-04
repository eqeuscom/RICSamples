CLEAR
CD JUSTPATH(SYS(16))
SET PROCEDURE TO RICHelpers ADDITIVE
LOCAL lcCustomerName, lcCustomerPassword, lcOrganization, lcOrganizationSubdomain, lcAdminUserName, lcAdminUserPassword, lcSecret, loUserAPI, loOrganizationAPI, lcLogFile, loObj 

* 1. parameters 
lcCustomerName = "YourXFRXLogin" 		&& Put your XFRX login name here
lcCustomerPassword = "YourXFRXPassword" && Put your XFRX password here
lcOrganization = "org"+STRTRAN(sys(2015),'_','-') 		&& This is the name of the organization we are going to create. Leave this to generate a random name
lcOrganizationSubdomain = lcOrganization && The subdomain is the same as the organization name
lcAdminUserName = "admin"  				&& Login for new organization administrator
lcAdminUserPassword = "test123" 		&& Password for new organization Administrator

* 2. Create new organization in ReportInCloud service 
loOrganizationAPI = RIC_GetOrganizationAPIClient(lcCustomerName, lcCustomerPassword)
loRetval = loOrganizationAPI.AddOrganization(lcOrganization, lcOrganizationSubdomain, lcAdminUserName, lcAdminUserPassword, 5)
IF loRetval.IsOK
	lcSecret = loretval.Data[1].RIC_AdminUserSecret
	? "Organization "+lcOrganization+" created successfully."
ELSE
	? "could not add a new organization"
	? "error:", loretval.ErrorMessage
	return
ENDIF

SET PATH TO xfrxdemo
SET PROCEDURE TO utilityreportlistener ADDITIVE 
use xfrxdemo\demoreps\invoices order customer

* 3. Create report via XFRX
* we are going to generate the report using the pre-vfp9 syntax to support VFP 6.0 - VFP 9.0
loObj = XFRX("XFRX#INIT")
lnRetVal = loObj.SetParams("invoices.xml",,,,,,"XML")
IF lnRetVal = 0
	loObj.ProcessReport("xfrxdemo\demoreps\splash")
	loObj.ProcessReport("xfrxdemo\demoreps\invhead")
	loObj.ProcessReport("xfrxdemo\demoreps\invoices")
	loObj.Finalize()
ENDIF

* 4. Upload the report to ReportsInCloud service
*lcLogFile = "ric.log"
loUserAPI = RIC_GetUserAPIClient(lcOrganizationSubdomain, lcSecret)
loUserAPI.LogFile = lcLogFile
loRetval = loUserApi.UploadReport("invoices.xml", "invoices/Invoices demo 1")
IF loRetval.IsOK
	? "Report Invoices demo 1 created and uploaded successfully."
	?
	? "Log in to "+lcOrganization+".reportsincloud.com to see your demo report in the web browser (URL copied in cliboard)" +CHR(13)+CHR(10)+"Login: "+lcAdminUserName+CHR(13)+CHR(10)+"Password: "+lcAdminUserPassword
	_cliptext = "https://"+lcOrganizationSubdomain+".reportsincloud.com"
ELSE
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

