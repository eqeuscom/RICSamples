clear
do wwDotNetBridge
LOCAL loBridge as wwDotNetBridge
loBridge = CreateObject("wwDotNetBridge","V4")

? loBridge.LoadAssembly("RICAPIClientLib.dll")
? loBridge.cErRORMSG
? loBridge.LoadAssembly("System.Net.Http.Formatting")
? loBridge.cErRORMSG
? loBridge.LoadAssembly("Newtonsoft.Json")
? loBridge.cErRORMSG

*
* customer API
*
LOCAL loCustomerAPI, retval, lcOrgID, loOrg, lcSecret

loCustomerAPI = loBridge.CreateInstance("RICAPIClientLib.API.CustomerAPIClient","martinsu","aaa")
? loBridge.cErRORMSG
ListOrganizations(loCustomerAPI, loBridge)
*
* add a new organization/domain
*
? "adding a new organization ..."
retval = loCustomerAPI.AddOrganization("mtest -b9", "mtestb9", "admin", "admin123")
? loBridge.cErRORMSG
IF retval.IsOK
	lcOrgID = retval.Data.ID
	? retval.Data.ID
	? retval.Data.AdminUserSecret
	lcSecret = retval.Data.AdminUserSecret
ELSE
	_cliptext = retval.ErrorMessage
	? "error:", retval.ErrorMessage
	return
ENDIF
ListOrganizations(loCustomerAPI, loBridge)
*
* user API - get current organization
*
? "getting organization as a user"
LOCAL loUserAPI
loUserAPI = loBridge.CreateInstance("RICAPIClientLib.API.UserAPIClient", "mtestb9", lcSecret)
retval = loUserAPI.GetOrganization()
IF retval.IsOK
	loOrg = retval.Data
	? loOrg.ID, loOrg.Name
ELSE
	? "get organization as a user failed. error:", retval.ErrorMessage
ENDIF
*
* user API - add a user
*
retval = loUserAPI.AddUser("testuser", "testpassword", "John Tester", .F., "")
IF retval.IsOK
	? "user successfully added"
ELSE
	? "user add failed. error:", retval.ErrorMessage
	_cliptext = retval.ErrorMessage
ENDIF
*
* user API - get a list of users
*
*retval = loUserAPI.GetUsers()
*IF retval.IsOK
*ELSE
*	? "get user list failed. error:", retval.ErrorMessage
*	_cliptext = retval.ErrorMessage
*ENDIF

*
* get a single org
*
? "getting organization: "+lcOrgID
retval = loCustomerAPI.GetOrganization(lcOrgID)
IF retval.IsOK
	loOrg = retval.Data
	? loOrg.ID, loOrg.Name
	loOrg.Name = "mtest renamed"
	loOrg.SubDomainName = "mtestrenamedb7"
	retval = loCustomerAPI.UpdateOrganization(loOrg)
	IF retval.IsOk
		? "update successful"
	ELSE
		? "update failed. error:", retval.ErrorMessage
	ENDIF
ELSE
	? "get organization failed. error:", retval.ErrorMessage
ENDIF
ListOrganizations(loCustomerAPI, loBridge)

*
* delete organization
*
retval = loCustomerAPI.DeleteOrganization(lcOrgID)
IF retval.IsOK
	? "organization deleted"	
ELSE
	? "error:", retval.ErrorMessage
endif
ListOrganizations(loCustomerAPI, loBridge)

*
* send a report out
*

PROCEDURE ListOrganizations
LPARAMETERS oCustomerAPI, oBridge
*
* list of organizations/domains
*
? "getting organizations ..."
retval = oCustomerAPI.GetOrganizations()
IF retval.IsOK
	loOrgs = oBridge.CreateArray()
	loOrgs.FromEnumerable(retval.Data)
	FOR lnX = 0 TO loOrgs.Count-1
		loOrg = loOrgs.Item(lnX)
		? loOrg.ID, ALLTRIM(STR(lnX))+":",loOrg.Name+" ("+loOrg.SubDomainName+".reportsincloud.com)"
	ENDFOR
ELSE
	_cliptext = retval.ErrorMessage
	? "error:", retval.ErrorMessage
ENDIF
