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
PostUserAPISetup(loUserAPI)
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
PostUserAPISetup(loUserAPI)
retval = loUserAPI.UploadExportedFile(tcXmlFileName, tcType, tcRemoteLocation)

RETURN retval
ENDPROC


DEFINE CLASS RIC_StructuredErrorValue AS Custom
	IsOK = .T.
	ErrorMessage = ""
ENDDEFINE

DEFINE CLASS RIC_Data AS Custom
	IsOK = .T.
	dimension Data(1)
	dataCount = 0
	ErrorMessage = ""
ENDDEFINE

PROCEDURE StructuredError
LPARAMETERS lcErrorMessage
	loReturnStructure = CREATEOBJECT("RIC_StructuredErrorValue")
	loReturnStructure.IsOK = .F.
	loReturnStructure.ErrorMessage = lcErrorMessage
	RETURN loReturnStructure
ENDPROC

PROCEDURE RIC_GetUserAPIClient
LPARAMETERS tcOrg, tcSecret
local loobj
loobj = CREATEOBJECT("RIC_UserAPIClient")
loobj.Organization = tcOrg
loobj.Secret = tcSecret
return loobj

PROCEDURE RIC_GetOrganizationAPIClient
LPARAMETERS tcCustomerName, tcPassword
local loobj
loobj = CREATEOBJECT("RIC_OrganizationAPIClient")
loobj.CustomerName = tcCustomerName
loobj.Password = tcPassword
return loobj

PROCEDURE MergeParameters1
LPARAMETERS lParam1
RETURN ["]+ALLTRIM(lParam1)+[" ]
ENDPROC

PROCEDURE MergeParameters2
LPARAMETERS lParam1, lParam2
RETURN ["]+ALLTRIM(lParam1)+[" ]+["]+ALLTRIM(lParam2)+[" ]
ENDPROC

PROCEDURE MergeParameters3
LPARAMETERS lParam1, lParam2, lParam3
RETURN ["]+ALLTRIM(lParam1)+[" ]+["]+ALLTRIM(lParam2)+[" ]+["]+ALLTRIM(lParam3)+[" ]
ENDPROC

PROCEDURE MergeParameters4
LPARAMETERS lParam1, lParam2, lParam3, lParam4
RETURN ["]+ALLTRIM(lParam1)+[" ]+["]+ALLTRIM(lParam2)+[" ]+["]+ALLTRIM(lParam3)+[" ]+["]+ALLTRIM(lParam4)+[" ]
ENDPROC

PROCEDURE MergeParameters5
LPARAMETERS lParam1, lParam2, lParam3, lParam4, lParam5
RETURN ["]+ALLTRIM(lParam1)+[" ]+["]+ALLTRIM(lParam2)+[" ]+["]+ALLTRIM(lParam3)+[" ]+["]+ALLTRIM(lParam4)+[" ]+'"'+ALLTRIM(lParam5)+[" ]
ENDPROC

PROCEDURE AddS
LPARAMETERS tcPath
tcPath = allt(tcPath)
if EMPTY(tcPath)
	return tcPath+"/"
ENDIF
if RIGHT(tcPath,1) == "/"
	return tcPath
ELSE
	return tcPath+"/"
ENDIF

DEFINE CLASS APIClient as Custom
	
	LogFile = ""
	DeleteTempFile = .T.
	
	PROCEDURE CallAPI
	LPARAMETERS tcAction, tcParams
	
	local lcTempFile, execstring
	lcTempFile = ADDBS(sys(2023))+"_r"+sys(3)
	
	lcFileName = "RICAPIClient\RICAPIClient.exe" 
	lcParams = lcTempFile+" "+tcAction+" "+this.DefaultParameters()+" "+tcParams
		
	ExecAndWait(lcFileName,lcParams)

	IF !EMPTY(this.LogFile)
		STRTOFILE(lcFileName+" "+lcParams+CHR(13)+CHR(10),this.LogFile,.t. )		
	ENDIF
	
	return this.ReadReturnValues(lcTempFile)
	
	ENDPROC
		
	PROCEDURE ReadReturnValues
	LPARAMETERS tcFileName
	
	local lnh, loRetval, lcLine, lcStatus, llInsideList, llInsideObject, loNewObject
	
	loRetval = CREATEOBJECT("RIC_Data")
	
	lnh = fopen(tcFileName)
	if (lnh < 0)
		loRetval.IsOK = .f.
		loRetval.ErrorMessage = "Cannot read returned values"
		return loRetval
	ENDIF
	lcStatus = fgets(lnh)
	if (lcStatus) == "ok"
		DO while !FEOF(lnh)
			lcLine = FGETS(lnh)
			if lcLine == "["
				llInsideList = .t.
				loNewObject = CREATEOBJECT("custom")
			ELSE
				if llInsideList
					if (EMPTY(lcLine) or lcLine=="]")
						if llInsideObject
							loRetval.dataCount = loRetval.dataCount + 1
							dimension loRetval.data(loRetval.dataCount)
							loRetval.data(loRetval.dataCount) = loNewObject
							loNewObject = CREATEOBJECT("custom")
							llInsideObject = .F.
						ENDIF
					ELSE
						*
						* adding a new property
						*
						llInsideObject = .t.
						local lnPos, lcKey, lcValue
						lnPos = AT(" ", lcLine)
						lcKey = SUBSTR(lcLine, 1, lnPos-1)
						lcValue = SUBSTR(lcLine, lnPos+1)
						loNewObject.AddProperty(lcKey, lcValue)
					ENDIF					
				ENDIF				
			endif
		ENDDO 
	ELSE
		loRetval.IsOK = .f.
		DO while !FEOF(lnh)
			loRetval.ErrorMessage = loRetval.ErrorMessage + FGETS(lnh)
		ENDDO 		
	ENDIF	
	FCLOSE(lnh)
	if this.DeleteTempFile
		erase (tcFileName)
	ENDIF	
	return loRetval
	ENDPROC
	
	PROCEDURE SerializeOrganization
	LPARAMETERS toOrg
	local lcFile, lnh
	lcFile = ADDBS(sys(2023))+"_RU"+sys(3)
	lnh = fcreate(lcFile)
	FPUTS(lnh, "[")
	FPUTS(lnh, "ID "+toOrg.ID)	
	FPUTS(lnh, "Name "+toOrg.Name)	
	FPUTS(lnh, "SubDomainName "+toOrg.SubDomainName)	
	FPUTS(lnh, "LoginMessage "+toOrg.LoginMessage)	
	FPUTS(lnh, "]")
	FCLOSE(lnh)
	return lcFile
ENDDEFINE

DEFINE CLASS RIC_OrganizationAPIClient as APIClient
	CustomerName = ""
	Password = ""		
	
	PROCEDURE DefaultParameters
	return this.CustomerName+" "+this.Password
	ENDPROC

	PROCEDURE AddOrganization
	LPARAMETERS tcOrganizationName, tcSubdomainName, tcAdminUserName, tcAdminUserPassword, tnUserQuota
	return this.CallAPI("ADDORGANIZATION", MergeParameters5(tcOrganizationName, tcSubdomainName, tcAdminUserName, tcAdminUserPassword, TRANSFORM(tnUserQuota)))
	ENDPROC
	
	PROCEDURE GetOrganization
	LPARAMETERS tcID
	return this.CallAPI("GETORGANIZATION", MergeParameters1(tcID))
	ENDPROC

	PROCEDURE UpdateOrganization
	LPARAMETERS toOrg	
	local lcTempFile, loRetval
	lcTempFile = this.SerializeOrganization(toOrg)
	loRetval = this.CallAPI("UPDATEORGANIZATION", MergeParameters1(lcTempFile))
	if this.DeleteTempFile
		erase (tcFileName)
	ENDIF	
	return loRetval
	ENDPROC

ENDDEFINE

DEFINE CLASS RIC_UserAPIClient as APIClient
	Organization = ""
	Secret = ""
	
	PROCEDURE DefaultParameters
	return this.Organization+" "+ALLTRIM(this.Secret)
	ENDPROC
	
	PROCEDURE GetRoles
	return this.CallAPI("GETROLES","")		

	PROCEDURE AddRole
	LPARAMETERS tcRoleName, tcUserList
	return this.CallAPI("ADDROLE",MergeParameters2(tcRoleName,tcUserList))

	PROCEDURE UpdateRole
	LPARAMETERS tcRoleName, tcUserList
	return this.CallAPI("UPDATEROLE",MergeParameters2(tcRoleName,tcUserList))

	PROCEDURE DeleteRole
	LPARAMETERS tcRoleName
	return this.CallAPI("DELETEROLE",tcRoleName)

	PROCEDURE AddUser
	LPARAMETERS tcUserName, tcPassword, tcRealName, tlIsAdmin, tcRoleList
	return this.CallAPI("ADDUSER",MergeParameters5(tcUserName, tcPassword, tcRealName, IIF(tlIsAdmin,"true","false"), tcRoleList))		

	PROCEDURE UpdateUser
	LPARAMETERS tcUserName, tcPassword, tcRealName, tcIsAdmin, tcRoleList
	return this.CallAPI("UPDATEUSER",MergeParameters5(tcUserName, tcPassword, tcRealName, tcIsAdmin, tcRoleList))		

	PROCEDURE DeleteUser
	LPARAMETERS tcUserName
	return this.CallAPI("DELETEUSER",tcUserName)		
	
	PROCEDURE GetUsers
	return this.CallAPI("GETUSERS","")		

	PROCEDURE AddFolder
	LPARAMETERS tcFolderFullPath
	return this.CallAPI("ADDFOLDER",MergeParameters1(tcFolderFullPath))

	PROCEDURE RemoveFolder
	LPARAMETERS tcFolderFullPath
	return this.CallAPI("REMOVEFOLDER",MergeParameters1(tcFolderFullPath))

	PROCEDURE AddFolderRights
	LPARAMETERS tcFolderFullPath, tcUserList, tcRoleList
	return this.CallAPI("ADDFOLDERRIGHTS",MergeParameters3(ADDS(tcFolderFullPath), tcUserList, tcRoleList))		

	PROCEDURE UpdateFolderRights
	LPARAMETERS tcFolderFullPath, tcUserList, tcRoleList
	return this.CallAPI("UPDATEFOLDERRIGHTS",MergeParameters3(ADDS(tcFolderFullPath), tcUserList, tcRoleList))

	PROCEDURE DeleteFolderRights
	LPARAMETERS tcFolderFullPath, tcUserList, tcRoleList
	return this.CallAPI("DELETEFOLDERRIGHTS",MergeParameters3(ADDS(tcFolderFullPath), tcUserList, tcRoleList))		

	PROCEDURE AddReportRights
	LPARAMETERS tcReportFullPath, tcUserList, tcRoleList
	return this.CallAPI("ADDREPORTRIGHTS",MergeParameters3(tcReportFullPath, tcUserList, tcRoleList))
	
	PROCEDURE GetFolderRights
	return this.CallAPI("GETFOLDERRIGHTS","")		

	PROCEDURE UploadReport
	LPARAMETERS tcXmlFileName, tcRemoteLocation
	return this.CallAPI("UPLOADREPORT",MergeParameters2(tcXmlFileName, tcRemoteLocation))

	PROCEDURE UploadExportedFile
	LPARAMETERS tcXmlFileName, tcType, tcRemoteLocation
	return this.CallAPI("UPLOADEXPORTEDFILE",MergeParameters3(tcXmlFileName, tcType, tcRemoteLocation))
	
ENDDEFINE

* source http://www.west-wind.com/wconnect/weblog/ShowEntry.blog?id=533
************************************************************************
* wwAPI :: Createprocess
****************************************
***  Function: Calls the CreateProcess API to run a Windows application
***    Assume: Gets around RUN limitations which has command line
***            length limits and problems with long filenames.
***            Can do everything EXCEPT REDIRECTION TO FILE!
***      Pass: lcExe - Name of the Exe
***            lcCommandLine - Any command line arguments
***    Return: .t. or .f.
************************************************************************

LPARAMETERS lcExe,lcCommandLine
LOCAL hProcess, cProcessInfo, cStartupInfo, lnShowWindow,llWaitForCompletion
DECLARE INTEGER CreateProcess IN kernel32 as _CreateProcess; 
    STRING   lpApplicationName,; 
    STRING   lpCommandLine,; 
    INTEGER  lpProcessAttributes,; 
    INTEGER  lpThreadAttributes,; 
    INTEGER  bInheritHandles,; 
    INTEGER  dwCreationFlags,; 
    INTEGER  lpEnvironment,; 
    STRING   lpCurrentDirectory,; 
    STRING   lpStartupInfo,; 
    STRING @ lpProcessInformation 

lnShowWindow = 0
llWaitForCompletion = .T.
cProcessinfo = REPLICATE(CHR(0),128)
cStartupInfo = GetStartupInfo(lnShowWindow)

IF !EMPTY(lcCommandLine)
   lcCommandLine = ["] + lcExe + [" ]+ lcCommandLine
ELSE
   lcCommandLine = ""
ENDIF

LOCAL CREATE_NO_WINDOW
CREATE_NO_WINDOW = 8
*CREATE_NO_WINDOW = 0
lnResult =  _CreateProcess(lcExe,lcCommandLine,0,0,0,CREATE_NO_WINDOW ,0,SYS(5)+CURDIR(),cStartupInfo,@cProcessInfo)
lhProcess = CHARTOBIN( SUBSTR(cProcessInfo,1,4) )

IF llWaitForCompletion
   #DEFINE WAIT_TIMEOUT 0x00000102
   DECLARE INTEGER WaitForSingleObject IN kernel32.DLL ;
         INTEGER hHandle, INTEGER dwMilliseconds
   DO WHILE .T.
       *** Update every 100 milliseconds
       IF WaitForSingleObject(lhProcess, 100) != WAIT_TIMEOUT
          EXIT
       ELSE
          DOEVENTS
       ENDIF
   ENDDO
ENDIF

DECLARE INTEGER CloseHandle IN kernel32.DLL ;
        INTEGER hObject
CloseHandle(lhProcess)

RETURN IIF(lnResult=1,.t.,.f.)

FUNCTION getStartupInfo(lnShowWindow)
LOCAL lnFlags
* creates the STARTUP structure to specify main window
* properties if a new window is created for a new process

IF EMPTY(lnShowWindow)
  lnShowWindow = 1
ENDIF
*| typedef struct _STARTUPINFO {
*| DWORD cb; 4
*| LPTSTR lpReserved; 4
*| LPTSTR lpDesktop; 4
*| LPTSTR lpTitle; 4
*| DWORD dwX; 4
*| DWORD dwY; 4
*| DWORD dwXSize; 4
*| DWORD dwYSize; 4
*| DWORD dwXCountChars; 4
*| DWORD dwYCountChars; 4
*| DWORD dwFillAttribute; 4
*| DWORD dwFlags; 4
*| WORD wShowWindow; 2
*| WORD cbReserved2; 2
*| LPBYTE lpReserved2; 4
*| HANDLE hStdInput; 4
*| HANDLE hStdOutput; 4
*| HANDLE hStdError; 4
*| } STARTUPINFO, *LPSTARTUPINFO; total: 68 bytes
#DEFINE STARTF_USESTDHANDLES 0x0100
#DEFINE STARTF_USESHOWWINDOW 0
#DEFINE SW_HIDE 0
#DEFINE SW_SHOWMAXIMIZED 3
#DEFINE SW_SHOWNORMAL 1
lnFlags = 4
*STARTF_USESHOWWINDOW

RETURN binToChar(80) +;
    binToChar(0) + binToChar(0) + binToChar(0) +;
    binToChar(0) + binToChar(0) + binToChar(0) + binToChar(0) +;
    binToChar(0) + binToChar(0) + binToChar(0) +;
    binToChar(lnFlags) +;
    binToWordChar(lnShowWindow) +;
    binToWordChar(0) + binToChar(0) +;
    binToChar(0) + binToChar(0) + binToChar(0) + REPLICATE(CHR(0),30)

************************************************************************

FUNCTION CharToBin(lcBinString,llSigned)
****************************************
***  Function: Binary Numeric conversion routine. 
***            Converts DWORD or Unsigned Integer string
***            to Fox numeric integer value.
***      Pass: lcBinString -  String that contains the binary data 
***            llSigned    -  if .T. uses signed conversion
***                           otherwise value is unsigned (DWORD)
***    Return: Fox number
************************************************************************

LOCAL m.i, lnWord
lnWord = 0
FOR m.i = 1 TO LEN(lcBinString)
 lnWord = lnWord + (ASC(SUBSTR(lcBinString, m.i, 1)) * (2 ^ (8 * (m.i - 1))))
ENDFOR

IF llSigned AND lnWord > 0x80000000
  lnWord = lnWord - 1 - 0xFFFFFFFF
ENDIF
RETURN lnWord
*  wwAPI :: CharToBin

************************************************************************
FUNCTION BinToChar(lnValue)
****************************************
***  Function: Creates a DWORD value from a number
***      Pass: lnValue - VFP numeric integer (unsigned)
***    Return: binary string
************************************************************************
Local byte(4)
If lnValue < 0
    lnValue = lnValue + 4294967296
EndIf
byte(1) = lnValue % 256
byte(2) = BitRShift(lnValue, 8) % 256
byte(3) = BitRShift(lnValue, 16) % 256
byte(4) = BitRShift(lnValue, 24) % 256
RETURN Chr(byte(1))+Chr(byte(2))+Chr(byte(3))+Chr(byte(4))
*  wwAPI :: BinToChar

************************************************************************
FUNCTION BinToWordChar(lnValue)
****************************************
***  Function: Creates a DWORD value from a number
***      Pass: lnValue - VFP numeric integer (unsigned)
***    Return: binary string
************************************************************************
RETURN Chr(MOD(m.lnValue,256)) + CHR(INT(m.lnValue/256))
