SET TALK OFF
close all
clear
CD JUSTPATH(SYS(16))
SET PROCEDURE TO RICHelpers ADDITIVE

LOCAL lcCustomerName, lcCustomerPassword, lcOrganization, lcOrganizationSubdomain, lcAdminUserName, lcAdminUserPassword
*
* the following are the "customer" level user name and password, the same you use to log in to www.eqeus.net/xfrx to download new XFRX versions
*
lcCustomerName = "USERNAME" && put your customer name here
lcCustomerPassword = "PASSWORD" && your password goes here
lcOrganization = "org"+sys(2015) && this is a name of the newly created organization
lcOrganizationSubdomain = lcOrganization
*
* use the user name and password to sign in into the web application. To call the API you need to use the "secret" string returned when adding
* the new organization
*
lcAdminUserName = "admin"
lcAdminUserPassword = "test123"

LOCAL lcSecret, lcretval, lnCount, lcRoleName, loUserAPI, loOrganizationAPI, lcLogFile, lcOrgID

*
* organization API demo
*
lcLogFile = "ric.log"
loOrganizationAPI = RIC_GetOrganizationAPIClient(lcCustomerName, lcCustomerPassword)
loOrganizationAPI.logFile = lcLogFile
*
* add a new organization/domain
*
? "adding a new organization, user quota set to 5"
loRetval = loOrganizationAPI.AddOrganization(lcOrganization, lcOrganizationSubdomain, lcAdminUserName, lcAdminUserPassword, 5)
IF loRetval.IsOK
	*
	* we got back a structure with details about the newly created organization
	*
	? "organization "+lcOrganization+" added successfully"
	? "URL: https://"+lcOrganizationSubdomain+".reportsincloud.com (copied to clipboard)"
	_cliptext = "https://"+lcOrganizationSubdomain+".reportsincloud.com"
	? "admin user lcSecret: "+loretval.Data[1].RIC_AdminUserSecret
	lcOrgID = loretval.Data[1].RIC_ID
	? "organization id: ", lcOrgID
	? ""
	CreateOrOpenSecretsTable()
	INSERT INTO secrets VALUES (lcOrgID, lcOrganization, lcOrganizationSubdomain, loretval.data[1].RIC_AdminUserSecret)
	lcSecret = loretval.Data[1].RIC_AdminUserSecret
	
	*
	* note: you need to store the secret to be able to authenticate when accessing the user api. In this demo we are storing the secret in a variable here, but also in the secrets dbf. 
	* You can call 
	*
	* lcSecret = GetSecret(lcOrganizationSubdomain)
	*
	* to retrieve the secret.
	*
	* The secret is also displayed in the organization detail in the administration console at https://admin.reportsincloud.com
	*
ELSE
	? "could not add a new organization"
	? "error:", loretval.ErrorMessage
	return
ENDIF

? "Get the organization structure"
loRetval = loOrganizationAPI.GetOrganization(lcOrgID)
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

local loOrgData
loOrgData = loRetval.Data[1]
DisplayOrganizationDetails(loOrgData)

? "update the login message for our organization"
loOrgData.RIC_LoginMessage = "hello, welcome to our reports area!"
loRetval = loOrganizationAPI.UpdateOrganization(loOrgData)
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

*
* User API demo
*
loUserAPI = RIC_GetUserAPIClient(lcOrganizationSubdomain, lcSecret)
loUserAPI.LogFile = lcLogFile

*
* 1. add new roles
*
? "add new role 'area1'"
loRetval = loUserApi.AddRole("area1", "")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "add new role 'area2'"
loRetval = loUserApi.AddRole("area2", "")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF
*
* 2.1 add users
*
? "add user john and assign to role area1"
loRetval = loUserApi.AddUser("john", "john123", "John Smith", .f., "area1" )
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "add user paul and assign to role area2"
loRetval = loUserApi.AddUser("paul", "paul123", "Paul Johnson", .f., "area2" )
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

*
* 2.2 add folders
*
* Note: you do not need to create folders explicitly. Folders are created automatically when you upload 
* reports into them
*
? "add a new folder: area1"
loRetval = loUserApi.AddFolder("area1")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "set access rights to folder 'area1' for role 'area1'"
loRetval = loUserApi.AddFolderRights("area1", "", "area1")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "Now John can see the 'area1' folder, Paul can not. Admin can see everything"

* 
*
* 3. upload some reports to area1 and area2 folders
*
*
* set up XFRX
*
? "uploading a report to area1 as 'area1/Invoices report 1'"

SET PATH TO xfrxdemo
SET PROCEDURE TO utilityreportlistener ADDITIVE 

use xfrxdemo\demoreps\invoices order customer
LOCAL loObj

*
* the code below is the VFP 9 syntax
*
*!*	loObj = XFRX("XFRX#LISTENER")
*!*	lnRetVal = loObj.SetParams("invoices.xml",,,,,,"XML")
*!*	*
*!*	* run the report
*!*	*
*!*	IF lnRetVal = 0
*!*		REPORT FORM xfrxdemo\demoreps\splash object loObj NOPAGEEJECT
*!*		REPORT FORM xfrxdemo\demoreps\invhead object loObj NOPAGEEJECT
*!*		REPORT FORM xfrxdemo\demoreps\invoices object loObj		
*!*	ENDIF

*
* we are going to generate the report using the pre-vfp9 syntax to support VFP 6.0 - VFP 9.0
*
loObj = XFRX("XFRX#INIT")
lnRetVal = loObj.SetParams("invoices.xml",,,,,,"XML")
*
* run the report
*
IF lnRetVal = 0
	loObj.ProcessReport("xfrxdemo\demoreps\splash")
	loObj.ProcessReport("xfrxdemo\demoreps\invhead")
	loObj.ProcessReport("xfrxdemo\demoreps\invoices")
	loObj.Finalize()
ENDIF

*
* now upload the report to RIC
*
loRetval = loUserApi.UploadReport("invoices.xml", "area1/invoices report 1")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

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
loRetval = loUserApi.UploadExportedFile("invoices.pdf", "PDF", "area1/invoices report 1")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "uploading a report to area2 as 'area2/Invoices report 2'"
*
* now upload the same report to area2 
*
loRetval = loUserApi.UploadReport("invoices.xml", "area2/invoices report 2")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF
*
* and the PDF
*
loRetval = loUserApi.UploadExportedFile("invoices.pdf", "PDF", "area2/invoices report 2")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "no access rights were set for the 'area2' folder, so only the admin can see it. "
? ""

? "add user jane"
loRetval = loUserApi.AddUser("jane", "jane123", "Jane Akins", .f., "" )
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "add jane access to report 'area2/invoices report 2'"
loRetval = loUserApi.AddReportRights("area2/invoices report 2", "jane", "")
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ENDIF

? "now jane can see 'area2' folder because it contains a report she can see"



? "Roles list"
loRetval = loUserApi.GetRoles()
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ELSE
	ListRoles(loRetval)
ENDIF

? "User list"
loRetval = loUserApi.GetUsers()
IF !loRetval.IsOK
	? "error:", loRetval.ErrorMessage	
	return
ELSE
	ListUsers(loRetval)
ENDIF

return


PROCEDURE ListRoles
LPARAMETERS toRoles
	if toRoles.dataCount == 0		
		? "there are no roles"
	ELSE
		? ALLTRIM(STR(toRoles.datacount))+" role(s)"
		FOR lnX = 1 TO toRoles.datacount
			loRole = toRoles.data(lnX)
			? ALLTRIM(STR(lnX))+":",loRole.RIC_ID, loRole.RIC_Name+" ("+loRole.RIC_UserList+")"
		ENDFOR		
	ENDIF
ENDPROC

PROCEDURE ListUsers
LPARAMETERS toUsers
	if toUsers.dataCount == 0		
		? "there are no users"
	ELSE
		? ALLTRIM(STR(toUsers.datacount))+" user(s)"
		FOR lnX = 1 TO toUsers.datacount
			loUser = toUsers.data(lnX)
			? ALLTRIM(STR(lnX))+":",loUser.RIC_ID, loUser.RIC_UserName+" ("+loUser.RIC_Roles+")"
		ENDFOR		
	ENDIF
ENDPROC

PROCEDURE DisplayOrganizationDetails
LPARAMETERS toOrg
? "Organization details"
? "ID:", toOrg.RIC_ID
? "Name:", toOrg.RIC_Name
? "SubDomainName:", toOrg.RIC_SubDomainName
? "BaseURL:", toOrg.RIC_BaseURL
? "TotalUsers:", toOrg.RIC_TotalUsers
? "LoginMessage:", toOrg.RIC_LoginMessage


PROCEDURE CreateOrOpenSecretsTable()
IF FILE("secrets.dbf")
	IF !USED("secrets")
		USE secrets IN 0
	ENDIF
ELSE
	SELECT 0
	CREATE TABLE secrets (orgID C(100), orgName C(100), subdomain C(100), lcSecret C(100))
ENDIF

PROCEDURE GetSecret
LPARAMETERS tcOrganization
*
* use the secrets table to get the lcSecret for the given organization
*
IF NOT USED("secrets")
	USE secrets IN 0
ENDIF

SELECT secrets
LOCATE ALL FOR subDomain = tcOrganization
IF NOT FOUND()
	RETURN ""
ENDIF
RETURN allt(secrets.secret)

