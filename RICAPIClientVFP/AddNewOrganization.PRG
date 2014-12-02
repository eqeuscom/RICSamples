CLOSE ALL
*
* PARAMETERS
*
LOCAL lcCustomerName, lcCustomerPassword
*
* the following are the "customer" level user name and password, the same you use to log in to www.eqeus.net/xfrx to download new XFRX versions
*
lcCustomerName = "CUSTOMER_USER_NAME"
lcCustomerPassword = "CUSTOMER_PASSWORD"

LOCAL lcOrganizationName, lcSubdomainName, lcAdminUserName, lcAdminUserPassword
lcOrganizationName = "ORGANIZATION_NAME" && Enter the organization name here
lcSubdomainName = "YOUR_DOMAIN" && enter your domain here (no spaces)
lcAdminUserName = "admin" && user name, no spaces
lcAdminUserPassword = "USER_PASSWORD" && the new admin user password goes here

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
* add a new organization/domain
*
retval = RIC_AddOrganization(lcCustomerName, lcCustomerPassword, lcOrganizationName, lcSubdomainName, lcAdminUserName, lcAdminUserPassword)
? "adding a new organization ..."
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
