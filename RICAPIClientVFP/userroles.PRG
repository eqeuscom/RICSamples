close all
*
* PARAMETERS
*
LOCAL organizationSubdomain
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

LOCAL secret
secret = GetSecret(organizationSubdomain)
IF EMPTY(secret)
	? "organization not found in the secrets table"
	RETURN
ENDIF

LOCAL lcretval, lnCount, lcRoleName
lcretval = RIC_GetRoles(organizationSubdomain, secret)

IF lcretval.IsOK
	ListRoles(lcRetval.data)
	lnCount = lcRetval.data.Count
	*
	* now add a new random role
	*
	lcRoleName = "role"+sys(2015)
	lcretval = RIC_AddRole(organizationSubdomain, secret, lcRoleName, "user1,user2")
	if lcretval.isOK
		? "role added:"+lcRoleName
	ELSE
		_cliptext = lcretval.ErrorMessage
		? "error:", lcretval.ErrorMessage
	ENDIF	
ELSE
	_cliptext = lcretval.ErrorMessage
	? "error:", lcretval.ErrorMessage
	return
ENDIF

PROCEDURE ListRoles
LPARAMETERS toRoles
	if toRoles.Count == 0
		? "there are no roles stored in RIC"
	else
		FOR lnX = 0 TO toRoles.Count-1
			loRole = toRoles.Item(lnX)
			? loRole.ID, ALLTRIM(STR(lnX))+":",loRole.Name+" ("+loRole.UserList+")"
		ENDFOR
	ENDIF
ENDPROC

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
RETURN allt(secrets.secret)

