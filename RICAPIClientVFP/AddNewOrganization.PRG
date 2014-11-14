CLEAR
*
* set up wwDotNetBridge
*
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

*
* customer API setup
*
LOCAL loCustomerAPI, retval, lcOrgID, loOrg, lcSecret

LOCAL lcCustomerName, lcCustomerPassword
*
* the following are the "customer" level user name and password, the same you use to log in to www.eqeus.net/xfrx to download new XFRX versions
*
lcCustomerName = "martinsu"
lcCustomerPassword = "aaa"
*
* set up the API client object
*
loCustomerAPI = loBridge.CreateInstance("RICAPIClientLib.API.CustomerAPIClient", lcCustomerName, lcCustomerPassword)
IF !EMPTY(loBridge.cErrorMsg)
	? loBridge.cErrorMsg
endif

LOCAL lcOrganizationName, lcSubdomainName, lcAdminUserName, lcAdminUserPassword

lcOrganizationName = "Eqeus.com demo" && Enter the organization name here
lcSubdomainName = "demo" && enter your domain here (no spaces)
lcAdminUserName = "admin" && user name, no spaces
lcAdminUserPassword = "" && yourpasswordhere

*
* add a new organization/domain
*
? "adding a new organization ..."
retval = loCustomerAPI.AddOrganization(lcOrganizationName, lcSubdomainName, lcAdminUserName, lcAdminUserPassword)
IF !EMPTY(loBridge.cErrorMsg)
	? loBridge.cErrorMsg
endif
IF retval.IsOK
	? "organization added successfully"
	? "admin user secret: "+retval.Data.AdminUserSecret
	CreateOrOpenSecretsTable()
	INSERT INTO secrets VALUES (retval.Data.id, lcOrganizationName, lcSubdomainName, retval.data.AdminUserSecret)
	_cliptext = retval.Data.AdminUserSecret
ELSE
	_cliptext = retval.ErrorMessage
	? "error:", retval.ErrorMessage
ENDIF


PROCEDURE CreateOrOpenSecretsTable()
IF FILE("secrets.dbf")
	IF !USED("secrets")
		USE secrets IN 0
	ENDIF
ELSE
	SELECT 0
	CREATE TABLE secrets (orgID C(100), orgName C(100), subdomain C(100), secret C(100))
ENDIF
