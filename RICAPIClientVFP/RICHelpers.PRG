PROCEDURE RIC_AddOrganization
LPARAMETERS tcCustomerName, tcCustomerPassword, tcOrganizationName, tcSubdomainName, tcAdminUserName, tcAdminUserPassword
LOCAL loCustomerAPI, loretval, loReturnStructure
*
* set up the API client object
*
loCustomerAPI = goBridge.CreateInstance("RICAPIClientLib.API.CustomerAPIClient", tcCustomerName, tcCustomerPassword)

IF !EMPTY(goBridge.cErrorMsg)
	RETURN StructuredError(goBridge.cErrorMsg)
ENDIF

loretval = loCustomerAPI.AddOrganization(tcOrganizationName, tcSubdomainName, tcAdminUserName, tcAdminUserPassword)
IF !EMPTY(goBridge.cErrorMsg)
	RETURN StructuredError(goBridge.cErrorMsg)
ENDIF

RETURN loretval
ENDPROC 
	
PROCEDURE RIC_UploadReport
*
* uploads the XML file into the repository for the given organization, using the secret token for authentication
*
LPARAMETERS tcXmlFileName, tcRemoteLocation, tcOrganization, tcSecret

LOCAL loUserAPI, retval

loUserAPI = goBridge.CreateInstance("RICAPIClientLib.API.UserAPIClient", tcOrganization, tcSecret)
IF !EMPTY(goBridge.cErrorMsg)
	return StructuredError(goBridge.cErrorMsg)
ENDIF
retval = loUserAPI.UploadReport(tcXmlFileName, tcRemoteLocation)

RETURN retval
ENDPROC

PROCEDURE RIC_UploadExportedFile
*
* uploads the XML file into the repository for the given organization, using the secret token for authentication
*
LPARAMETERS tcXmlFileName, tcType, tcRemoteLocation, tcOrganization, tcSecret

LOCAL loUserAPI, retval

loUserAPI = goBridge.CreateInstance("RICAPIClientLib.API.UserAPIClient", tcOrganization, tcSecret)
IF !EMPTY(goBridge.cErrorMsg)
	return StructuredError(goBridge.cErrorMsg)
ENDIF
*loUserAPI.BaseURL = "http://localhost"
retval = loUserAPI.UploadExportedFile(tcXmlFileName, tcType, tcRemoteLocation)

RETURN retval
ENDPROC


PROCEDURE RIC_SetupWWDotNetBridge
*
* defines the public variable goBridge and set's up the env. returns the error message if something gets wrong
*
do wwDotNetBridge
PUBLIC goBridge as wwDotNetBridge
goBridge = CreateObject("wwDotNetBridge","V4")

goBridge.LoadAssembly("RICAPIClientLib.dll")
IF !EMPTY(goBridge.cErrorMsg)
	return goBridge.cErrorMsg
endif
goBridge.LoadAssembly("System.Net.Http.Formatting")
IF !EMPTY(goBridge.cErrorMsg)
	return goBridge.cErrorMsg
endif
goBridge.LoadAssembly("Newtonsoft.Json")
IF !EMPTY(goBridge.cErrorMsg)
	return goBridge.cErrorMsg
ENDIF
RETURN ""
ENDPROC

DEFINE CLASS RIC_StructuredErrorValue AS Custom
	IsOK = .T.
	ErrorMessage = ""
ENDDEFINE

PROCEDURE StructuredError
LPARAMETERS lcErrorMessage
	loReturnStructure = CREATEOBJECT("RIC_StructuredErrorValue")
	loReturnStructure.IsOK = .F.
	loReturnStructure.ErrorMessage = lcErrorMessage
	RETURN loReturnStructure
ENDPROC