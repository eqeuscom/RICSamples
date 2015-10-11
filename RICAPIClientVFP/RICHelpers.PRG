
************************************************************************************
* obsolete functions
************************************************************************************
PROCEDURE RIC_UploadReport
 *
 * uploads the XML file into the repository for the given organization, using the secret token for authentication
 *
 LPARAMETERS m.tcXmlFileName, m.tcRemoteLocation, m.tcOrganization, m.tcSecret

 LOCAL m.loUserAPI, m.retval

 m.loUserAPI = m.goBridge.CreateInstance("RICAPIClientLib.API.UserAPIClient", m.tcOrganization, m.tcSecret)
 IF !EMPTY(m.goBridge.cErrorMsg)
    RETURN StructuredError(m.goBridge.cErrorMsg)
 ENDIF
 PostUserAPISetup(m.loUserAPI)
 m.retval = m.loUserAPI.UploadReport(m.tcXmlFileName, m.tcRemoteLocation)

 RETURN m.retval
ENDPROC

PROCEDURE RIC_UploadExportedFile
 *
 * uploads the XML file into the repository for the given organization, using the secret token for authentication
 *
 LPARAMETERS m.tcXmlFileName, m.tcType, m.tcRemoteLocation, m.tcOrganization, m.tcSecret

 LOCAL m.loUserAPI, m.retval

 m.loUserAPI = m.goBridge.CreateInstance("RICAPIClientLib.API.UserAPIClient", m.tcOrganization, m.tcSecret)
 IF !EMPTY(m.goBridge.cErrorMsg)
    RETURN StructuredError(m.goBridge.cErrorMsg)
 ENDIF
 PostUserAPISetup(m.loUserAPI)
 m.retval = m.loUserAPI.UploadExportedFile(m.tcXmlFileName, m.tcType, m.tcRemoteLocation)

 RETURN m.retval
ENDPROC


PROCEDURE StructuredError
LPARAMETERS m.lcErrorMessage
m.loReturnStructure = CREATEOBJECT("RIC_StructuredErrorValue")
m.loReturnStructure.IsOK = .F.
m.loReturnStructure.ErrorMessage = m.lcErrorMessage
RETURN m.loReturnStructure
ENDPROC

************************************************************************************
* obsolete functions - END
************************************************************************************

*!* PROCEDURE RIC_GetUserAPIClient
*!* LPARAMETERS m.tcOrg, m.tcSecret
*!* LOCAL m.loobj
*!* loobj = CREATEOBJECT("RIC_UserAPIClient")
*!* loobj.Organization = m.tcOrg
*!* loobj.Secret = m.tcSecret
*!* RETURN m.loobj
*!* ENDPROC


PROCEDURE RIC_GetOrganizationAPIClient
LPARAMETERS m.tcCustomerName, m.tcPassword
LOCAL m.loobj
m.loobj = CREATEOBJECT("RIC_OrganizationAPIClient")
m.loobj.CustomerName = m.tcCustomerName
m.loobj.Password = m.tcPassword
RETURN loobj
ENDPROC



#IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
 PROCEDURE ADDBS(m.tcPath)
  m.tcPath = ALLT(m.tcPath)
  RETURN IIF(RIGHT(m.tcPath,1) == "\",m.tcPath,m.tcPath+"\")
 ENDPROC
#ENDIF

PROCEDURE RIC_STRCONV(m.lcText,m.lnConversionSetting)
 IF EMPTY(m.lcText)
    RETURN ""
 ENDIF
 #IF INLIST(STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0",""),"5","6","7")
  DECLARE INTEGER WideCharToMultiByte IN kernel32.dll AS RIC_WideCharToMultiByte ;
          INTEGER, INTEGER, STRING @, INTEGER, STRING @, INTEGER,STRING @, STRING @
  DECLARE INTEGER MultiByteToWideChar IN kernel32.dll AS RIC_MultiByteToWideChar ;
          INTEGER, INTEGER, STRING @, INTEGER, STRING @, INTEGER
  
  LOCAL m.liIn,m.lcOut,m.liOut,m.lii, m.liCPFrom, m.liCPTo
  #DEFINE CP_ACP               0              && default to ANSI code page 
  #DEFINE CP_UTF8              65001          && UTF-8 translation 
  DO CASE 
     CASE m.lnConversionSetting=11 OR m.lnConversionSetting=9
          IF m.lnConversionSetting=11
             m.liCPFrom=CP_UTF8 
             m.liCPTo=CP_ACP
          ELSE
             m.liCPFrom=CP_ACP
             m.liCPTo=CP_UTF8 
          ENDIF
     
          m.liIn=LEN(m.lcText)
          m.lcOut=SPACE(m.liIn*4)
          m.liOut=LEN(m.lcOut)
          m.lii=RIC_MultiByteToWideChar(m.liCPFrom,0,@m.lcText,m.liIn,@m.lcOut,m.liOut)
          m.liOut=m.lii
          m.lcText=SPACE(m.lii*4)
          m.liIn=LEN(m.lcText)
          STORE .NULL. TO m.lcDef, m.liDef
          m.lii=RIC_WideCharToMultiByte(m.liCPTo,0,@m.lcOut,m.liOut,@m.lcText,m.liIn,@m.lcDef,@m.liDef)
          RETURN LEFT(lcText,lii)
          
     OTHERWISE
        RETURN m.lcText
  ENDCASE   
  #UNDEFINE CP_ACP
  #UNDEFINE CP_UTF8
 #ELSE
  RETURN STRCONV(m.lcText,m.lnConversionSetting)
 #ENDIF
ENDPROC


#IF NOT INLIST(STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0",""),"5","6")
 PROCEDURE RIC_CreateProcess(m.lpApplicationName, m.lpCommandLine, m.lpProcessAttributes, m.lpThreadAttributes, m.bInheritHandles,; 
                             m.dwCreationFlags, m.lpEnvironment, m.lpCurrentDirectory, m.lpStartupInfo, m.lpProcessInformation )
  DECLARE INTEGER CreateProcess IN kernel32 AS RIC_CreateProcess STRING   lpApplicationName, STRING   lpCommandLine,; 
                                                                 INTEGER  lpProcessAttributes, INTEGER  lpThreadAttributes,; 
                                                                 INTEGER  bInheritHandles, INTEGER  dwCreationFlags,; 
                                                                 INTEGER  lpEnvironment, STRING   lpCurrentDirectory,; 
                                                                 STRING   lpStartupInfo, STRING @ lpProcessInformation 
  RETURN RIC_CreateProcess(m.lpApplicationName, m.lpCommandLine, m.lpProcessAttributes, m.lpThreadAttributes, m.bInheritHandles,; 
                           m.dwCreationFlags, m.lpEnvironment, m.lpCurrentDirectory, m.lpStartupInfo, @m.lpProcessInformation)
 ENDPROC

 PROCEDURE RIC_WaitForSingleObject(m.hHandle, m.dwMilliseconds)
  DECLARE INTEGER WaitForSingleObject IN kernel32.DLL AS RIC_WaitForSingleObject INTEGER hHandle, INTEGER dwMilliseconds
  RETURN RIC_WaitForSingleObject(m.hHandle, m.dwMilliseconds)
 ENDPROC

 PROCEDURE RIC_CloseHandle(m.hObject)
  DECLARE INTEGER CloseHandle IN kernel32.DLL AS RIC_CloseHandle INTEGER hObject
  RETURN RIC_CloseHandle(m.hObject)
 ENDPROC

 PROCEDURE RIC_GetOEMCP
  DECLARE INTEGER GetOEMCP IN kernel32.DLL AS RIC_GetOEMCP
  RETURN RIC_GetOEMCP()
 ENDPROC

 PROCEDURE RIC_GetTempFileName(m.lpPathName, m.lpPrefixString, m.uUnique, m.lpTempFileName)
  DECLARE INTEGER GetTempFileName IN kernel32.dll AS RIC_GetTempFileName STRING @ lpPathName, STRING @ lpPrefixString, ;
                                                                         INTEGER  uUnique, STRING @  lpTempFileName
  RETURN RIC_GetTempFileName(@m.lpPathName, @m.lpPrefixString, m.uUnique, @m.lpTempFileName)
 ENDPROC


#ELSE

 PROCEDURE RIC_WINAPI
  DECLARE INTEGER CreateProcess IN kernel32 AS RIC_CreateProcess STRING   lpApplicationName, STRING   lpCommandLine,; 
                                                                 INTEGER  lpProcessAttributes, INTEGER  lpThreadAttributes,; 
                                                                 INTEGER  bInheritHandles, INTEGER  dwCreationFlags,; 
                                                                 INTEGER  lpEnvironment, STRING   lpCurrentDirectory,; 
                                                                 STRING   lpStartupInfo, STRING @ lpProcessInformation 

  DECLARE INTEGER WaitForSingleObject IN kernel32.DLL AS RIC_WaitForSingleObject INTEGER hHandle, INTEGER dwMilliseconds

  DECLARE INTEGER CloseHandle IN kernel32.DLL AS RIC_CloseHandle INTEGER hObject
  DECLARE INTEGER GetOEMCP IN kernel32.dll AS RIC_GetOEMCP


  DECLARE INTEGER GetTempFileName IN kernel32.dll AS RIC_GetTempFileName STRING @ lpPathName, STRING @ lpPrefixString, ;
                                                                         INTEGER  uUnique, STRING @  lpTempFileName
 ENDPROC
 
#ENDIF

DEFINE CLASS RIC_Custom AS CUSTOM
   Name="RIC_Custom"
   HIDDEN Application, BaseClass, Class, ClassLibrary, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Name, Objects, Parent, ParentClass, Picture, Tag, Top, WhatsThisHelpID, Width 
ENDDEFINE


DEFINE CLASS RIC_StructuredErrorValue AS CUSTOM
   Name="RIC_StructuredErrorValue"
   IsOK = .T.
   ErrorMessage = ""

   HIDDEN Application, BaseClass, Class, ClassLibrary, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Name, Objects, Parent, ParentClass, Picture, Tag, Top, WhatsThisHelpID, Width 
ENDDEFINE

DEFINE CLASS RIC_Data AS CUSTOM
   Name="RIC_Data"
   IsOK = .T.
   DIMENSION Data(1)
   dataCount = 0
   ErrorMessage = ""

   HIDDEN Application, BaseClass, Class, ClassLibrary, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Name, Objects, Parent, ParentClass, Picture, Tag, Top, WhatsThisHelpID, Width 
ENDDEFINE




#IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
PROCEDURE STRTOFILE(m.tcstr, m.tcHeaderFile, m.ladd)
LOCAL m.hn, m.lnRet
IF !m.ladd OR !FILE(m.tcHeaderFile)
   m.hn = FCREATE(m.tcHeaderFile)
ELSE
   m.hn = FOPEN(m.tcHeaderFile,11)
   IF m.hn>0
      =FSEEK(m.hn, 0, 2)
   ENDIF
ENDIF
IF m.hn<0
   RETURN 0
ENDIF
m.lnRet=FPUT(m.hn, m.tcstr)
=FCLOSE(m.hn)
RETURN m.lnRet
ENDPROC

PROCEDURE FILETOSTR(m.lcFile)
LOCAL m.hn, m.lcString
m.hn = FOPEN(m.lcFile,10)
IF m.hn<0
   RETURN ""
ENDIF
m.lcString=""
DO WHILE !FEOF(m.hn)
   m.lcString=m.lcString+FREAD(m.hn,1000)
ENDDO
=FCLOSE(m.hn)
RETURN m.lcString
ENDPROC
#ENDIF

DEFINE CLASS RIC_APIClient AS CUSTOM
   PROTECTED Application, Comment, ControlCount, Controls, Height, HelpContextID,; 
             Left, Objects, Parent, Picture, Tag, Top, WhatsThisHelpID, Width 

   Name="RIC_APIClient"
   LogFile = ""
   DeleteTempFile = .T.
	
   PROCEDURE INIT
      #IF INLIST(STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0",""),"5","6")
       =RIC_WINAPI()
      #ENDIF
   ENDPROC
    
   PROCEDURE AddToLog(m.lcData)
      IF !EMPTY(This.LogFile)
         =STRTOFILE(m.lcData,This.LogFile,.T. )
      ENDIF
   ENDPROC

   PROCEDURE CallAPI
      LPARAMETERS m.tcAction, m.tcParams

      #IF INLIST(STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0",""),"5","6")
       =RIC_WINAPI()
      #ENDIF
	
      LOCAL m.lcTempFile, m.execstring, m.lcFileName, m.lcParams
      m.lcTempFile = ADDBS(SYS(2023))+"_r"+SYS(3)
	
      m.lcFileName = FULLPATH("RICAPIClient\RICAPIClient.exe",SYS(16,0))
      m.lcParams = m.lcTempFile+" "+m.tcAction+" "+This.DefaultParameters()+" "+m.tcParams
		
      =ExecAndWait(m.lcFileName,m.lcParams)

      This.AddToLog(m.lcFileName+" "+m.lcParams+CHR(13)+CHR(10))

      RETURN This.ReadReturnValues(m.lcTempFile)
   ENDPROC
		
   PROCEDURE ReadReturnValues
      LPARAMETERS m.tcFileName
	
      LOCAL m.lnh, m.loRetval, m.lcLine, m.lcStatus, m.llInsideList, m.llInsideObject, m.loNewObject
      #IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
       LOCAL m.liProps
       LOCAL ARRAY m.laProps(1)
       m.liProps=0
      #ENDIF
	
      m.loRetval = CREATEOBJECT("RIC_Data")
	
      m.lnh = FOPEN(m.tcFileName)
      IF (m.lnh < 0)
         m.loRetval.IsOK = .F.
         m.loRetval.ErrorMessage = "Cannot read returned values"
         RETURN m.loRetval
      ENDIF
      m.lcStatus = FGETS(m.lnh)
      IF (m.lcStatus) == "ok"
         DO WHILE !FEOF(m.lnh)
            m.lcLine = FGETS(m.lnh,8192)
            m.lcLine = RIC_STRCONV(m.lcLine,11)
            IF m.lcLine == "["
               m.llInsideList = .T.
               #IF NOT STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
                m.loNewObject = CREATEOBJECT("RIC_custom")
                m.liProps=0
               #ENDIF
            ELSE
               IF m.llInsideList
                  IF (EMPTY(m.lcLine) OR m.lcLine=="]")
                     IF m.llInsideObject
                        m.loRetval.dataCount = m.loRetval.dataCount + 1
                        DIMENSION m.loRetval.data(m.loRetval.dataCount)
                        #IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
                         LOCAL m.lii, m.lcCMD, m.lcAlias, m.liSele
                         m.liSele=SELECT()
                         m.lcAlias=SYS(2015)
                         m.lcCMD="CREATE CURSOR "+m.lcAlias+" ("
                         FOR m.lii=1 TO m.liProps
                             IF ATC(m.laProps(m.lii,1)+" L,",m.lcCMD)=0
                                m.lcCMD=m.lcCMD+m.laProps(m.lii,1)+" L,"
                             ENDIF
                         NEXT
                         m.lcCMD=LEFT(m.lcCMD,LEN(m.lcCMD)-1)+")"
                         &lcCMD.
                         SELECT (m.lcAlias)
                         SCATTER NAME m.loNewObject BLANK
                         USE IN (m.lcAlias)
                         FOR m.lii=1 TO m.liProps
                             STORE m.laProps(m.lii,2) TO ("m.loNewObject."+m.laProps(m.lii,1))
                         NEXT
                         SELECT (m.liSele)
                         RELE m.lii, m.lcCMD, m.lcAlias, m.liSele
                         m.loRetval.data(m.loRetval.dataCount) = m.loNewObject
                        #ELSE
                         m.loRetval.data(m.loRetval.dataCount) = m.loNewObject
                         m.loNewObject = CREATEOBJECT("RIC_custom")
                        #ENDIF
                        m.llInsideObject = .F.
                     ENDIF
                  ELSE
                     *
                     * adding a new property
                     *
                     m.llInsideObject = .T.
                     LOCAL m.lnPos, m.lcKey, m.lcValue, m.lcField
                     m.lnPos = AT(" ", m.lcLine)
                     m.lcValue = SUBSTR(m.lcLine, m.lnPos+1)
                     m.lcField = SUBSTR(m.lcLine, 1, m.lnPos-1)
                     IF LEFT(m.lcField,2)=="B_"
                        m.lcField = SUBSTR(m.lcField,3)
                        m.lcValue = IIF(UPPER(ALLT(m.lcValue))=="TRUE", .T., .F.)
                     ENDIF
                     m.lcKey = 'RIC_' + m.lcField
                     #IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
                      m.liProps=m.liProps+1
                      DIME m.laProps(m.liProps,2)
                      m.laProps(m.liProps,1)=m.lcKey
                      m.laProps(m.liProps,2)=m.lcValue
                     #ELSE
                       m.loNewObject.AddProperty(m.lcKey, m.lcValue)
                     #ENDIF
                     RELE m.lnPos, m.lcKey, m.lcValue, m.lcField
                  ENDIF					
               ENDIF				
            ENDIF
         ENDDO 
      ELSE
         m.loRetval.IsOK = .F.
         DO WHILE !FEOF(m.lnh)
            m.loRetval.ErrorMessage = m.loRetval.ErrorMessage + RIC_STRCONV(FGETS(m.lnh,8192),11)
         ENDDO 		
      ENDIF	
      =FCLOSE(m.lnh)
      IF This.DeleteTempFile
         ERASE (m.tcFileName)
      ENDIF	
      RETURN m.loRetval
   ENDPROC

   PROCEDURE GetTempFileName(m.lpPathName, m.lpPrefixString, m.uUnique)
      LOCAL m.lpTempFileName
      m.lpTempFileName=SPACE(512)
      =RIC_GetTempFileName(@m.lpPathName, @m.lpPrefixString, m.uUnique, @m.lpTempFileName)
      RETURN LEFT(m.lpTempFileName,AT(CHR(0),m.lpTempFileName)-1)
   ENDPROC


   PROCEDURE MergeParameters1
      LPARAMETERS m.lParam1
      RETURN ["]+ALLTRIM(m.lParam1)+[" ]
   ENDPROC

   PROCEDURE MergeParameters2
      LPARAMETERS m.lParam1, m.lParam2
      RETURN ["]+ALLTRIM(m.lParam1)+[" ]+["]+ALLTRIM(m.lParam2)+[" ]
   ENDPROC

   PROCEDURE MergeParameters3
      LPARAMETERS m.lParam1, m.lParam2, m.lParam3
      RETURN ["]+ALLTRIM(m.lParam1)+[" ]+["]+ALLTRIM(m.lParam2)+[" ]+["]+ALLTRIM(m.lParam3)+[" ]
   ENDPROC

   PROCEDURE MergeParameters4
      LPARAMETERS m.lParam1, m.lParam2, m.lParam3, m.lParam4
      RETURN ["]+ALLTRIM(m.lParam1)+[" ]+["]+ALLTRIM(m.lParam2)+[" ]+["]+ALLTRIM(m.lParam3)+[" ]+["]+ALLTRIM(m.lParam4)+[" ]
   ENDPROC

   PROCEDURE MergeParameters5
      LPARAMETERS m.lParam1, m.lParam2, m.lParam3, m.lParam4, m.lParam5
      RETURN ["]+ALLTRIM(m.lParam1)+[" ]+["]+ALLTRIM(m.lParam2)+[" ]+["]+ALLTRIM(m.lParam3)+[" ]+["]+ALLTRIM(m.lParam4)+[" ]+'"'+ALLTRIM(m.lParam5)+[" ]
   ENDPROC

   PROCEDURE AddS
      LPARAMETERS m.tcPath
      m.tcPath = ALLT(m.tcPath)
      IF EMPTY(m.tcPath)
         RETURN m.tcPath+"/"
      ENDIF
      RETURN IIF(RIGHT(m.tcPath,1) == "/",m.tcPath,m.tcPath+"/")
   ENDPROC
   
	
ENDDEFINE



DEFINE CLASS RIC_Organization AS Custom
   HIDDEN Application, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Objects, Picture, Tag, Top, WhatsThisHelpID, Width 

   RIC_ID=""
   RIC_Name=""
   RIC_SubDomainName=""
   RIC_LoginMessage=""
   RIC_UserQuota=0
   RIC_AdminUserName=""
   RIC_AdminUserPassword=""
   RIC_AdminUserSecret=""

   RIC_BaseURL=""
   RIC_TotalUsers=0
   RIC_DefaultLanguage=""
   RIC_QuotaKB=0
   RIC_TotalSizeKB=0
   RIC_TotalReports=0

ENDDEFINE

DEFINE CLASS RIC_OrganizationAPIClient AS RIC_APIClient
   Name="RIC_OrganizationAPIClient"

   CustomerName = ""
   Password = ""		

   Organization = ""
   Secret = ""

   PROCEDURE Create(m.lcOrgName, m.lcOrgSubDomain, m.lcOrgAdminName, m.lcOrgAdminPWD, m.lnOrgUserQuota)
      LOCAL m.loOrg
      m.loOrg=CREATEOBJECT("RIC_Organization")

      IF NOT EMPTY(m.lcOrgName)
         m.loOrg.RIC_Name=m.lcOrgName
      ENDIF
      IF NOT EMPTY(m.lcOrgSubDomain)
         m.loOrg.RIC_SubDomainName=m.lcOrgSubDomain
      ENDIF
      IF NOT EMPTY(m.lcOrgAdminName)
         m.loOrg.RIC_AdminUserName=m.lcOrgAdminName
      ENDIF
      IF NOT EMPTY(m.lcOrgAdminPWD)
         m.loOrg.RIC_AdminUserPassword=m.lcOrgAdminPWD
      ENDIF
      IF NOT EMPTY(m.lnOrgUserQuota)
         m.loOrg.RIC_UserQuota=m.lnOrgUserQuota
      ENDIF
      RETURN m.loOrg
   ENDPROC

   PROTECTED PROCEDURE Serialize
      LPARAMETERS m.toOrg
      LOCAL m.lcFile, m.lnh
      m.lcFile = This.GetTempFileName(ADDBS(SYS(2023)),"_RO",0)
      m.lnh = FCREATE(m.lcFile)
      =FPUTS(m.lnh, "[")
      =FPUTS(m.lnh, "ID "+m.toOrg.RIC_ID)
      =FPUTS(m.lnh, "Name "+m.toOrg.RIC_Name)
      =FPUTS(m.lnh, "SubDomainName "+m.toOrg.RIC_SubDomainName)
      =FPUTS(m.lnh, "LoginMessage "+m.toOrg.RIC_LoginMessage)
      =FPUTS(m.lnh, "DefaultLanguage "+m.toOrg.RIC_DefaultLanguage)
      =FPUTS(m.lnh, "UserQuota "+LTRIM(STR(m.toOrg.RIC_UserQuota,11)))
      =FPUTS(m.lnh, "]")
      =FCLOSE(m.lnh)
      RETURN m.lcFile
   ENDPROC
	
   PROCEDURE DefaultParameters
      RETURN This.CustomerName+" "+This.Password
   ENDPROC

   PROCEDURE Add
      LPARAMETERS m.toOrg
      RETURN This.CallAPI("ADDORGANIZATION", This.MergeParameters5(m.toOrg.RIC_Name, m.toOrg.RIC_SubdomainName, m.toOrg.RIC_AdminUserName, m.toOrg.RIC_AdminUserPassword, LTRIM(STR(m.toOrg.RIC_UserQuota,11))))
   ENDPROC

   PROCEDURE GetList
      RETURN This.CallAPI("GETORGANIZATIONS","")
   ENDPROC
	
   PROCEDURE Get
      LPARAMETERS m.tcID
      LOCAL m.loData
      m.loData=This.CallAPI("GETORGANIZATION", This.MergeParameters1(m.tcID))
      IF m.loData.datacount > 0       
	      WITH m.loData.Data[1]
	      .RIC_TotalUsers=INT(VAL(.RIC_TotalUsers))
	      .RIC_QuotaKB=INT(VAL(.RIC_QuotaKB))
	      .RIC_TotalSizeKB=INT(VAL(.RIC_TotalSizeKB))
	      .RIC_UserQuota=INT(VAL(.RIC_UserQuota))
	      .RIC_TotalReports=INT(VAL(.RIC_TotalReports))
	      ENDWITH
	  ENDIF      
      RETURN m.loData
   ENDPROC

   PROCEDURE Update
      LPARAMETERS m.toOrg	
      LOCAL m.lcTempFile, m.loRetval
      m.lcTempFile = This.Serialize(m.toOrg)
      m.loRetval = This.CallAPI("UPDATEORGANIZATION", This.MergeParameters1(m.lcTempFile))
      This.AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF This.DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF	
      RETURN m.loRetval
   ENDPROC

   PROCEDURE Delete
      LPARAMETERS m.tcID
      RETURN This.CallAPI("DELETEORGANIZATION", This.MergeParameters1(m.tcID))
   ENDPROC
   
   
   PROCEDURE Open(m.tcOrg,m.tcSecret)
      This.Organization = m.tcOrg
      This.Secret = m.tcSecret
      
      =IIF(NOT PEMSTATUS(This,"Users",5),This.AddObject("Users","RIC_UsersAPIClient"),.T.)
      This.Users.UpdateOrgInfo(m.tcOrg,m.tcSecret,This.logFile,This.DeleteTempFile)

      =IIF(NOT PEMSTATUS(This,"Roles",5),This.AddObject("Roles","RIC_RolesAPIClient"),.T.)
      This.Roles.UpdateOrgInfo(m.tcOrg,m.tcSecret,This.logFile,This.DeleteTempFile)

      =IIF(NOT PEMSTATUS(This,"Folders",5),This.AddObject("Folders","RIC_FoldersAPIClient"),.T.)
      This.Folders.UpdateOrgInfo(m.tcOrg,m.tcSecret,This.logFile,This.DeleteTempFile)

      =IIF(NOT PEMSTATUS(This,"Reports",5),This.AddObject("Reports","RIC_ReportsAPIClient"),.T.)
      This.Reports.UpdateOrgInfo(m.tcOrg,m.tcSecret,This.logFile,This.DeleteTempFile)

      =IIF(NOT PEMSTATUS(This,"Dictionary",5),This.AddObject("Dictionary","RIC_DictionaryAPIClient"),.T.)
      This.Dictionary.UpdateOrgInfo(m.tcOrg,m.tcSecret,This.logFile,This.DeleteTempFile)

   ENDPROC
   

   PROCEDURE Close()
      This.Organization = ""
      This.Secret = ""
      
      This.Users.UpdateOrgInfo("","","",.F.)
      This.Roles.UpdateOrgInfo("","","",.F.)
      This.Folders.UpdateOrgInfo("","","",.F.)
      This.Reports.UpdateOrgInfo("","","",.F.)
      This.Dictionary.UpdateOrgInfo("","","",.F.)

   ENDPROC

ENDDEFINE


DEFINE CLASS RIC_Cache AS custom
   HIDDEN Application, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Objects, Picture, Tag, Top, WhatsThisHelpID, Width 

   DIME aCache(1)

   Name="Cache"
   
   nCache=0
   nCacheCols=1

   PROCEDURE Clear()
      DIMENSION This.aCache(1)
      This.nCache=0
   ENDPROC


   PROCEDURE Add()
      This.nCache=This.nCache+1
      DIMENSION This.aCache(This.nCache,This.nCacheCols)
   ENDPROC


   PROCEDURE FlushCache(m.tcFolderFullPath)
   ENDPROC
   

   PROCEDURE Serialize
   ENDPROC


ENDDEFINE



DEFINE CLASS RIC_ObjectsAPIClient AS RIC_APIClient
   Name="RIC_ObjectsAPIClient"
   Organization = ""
   Secret = ""

   PROCEDURE UpdateOrgInfo(m.tcOrg, m.tcSecret, m.lclogFile, m.llDeleteTempFile)
      This.Organization = m.tcOrg
      This.Secret = m.tcSecret
      This.logFile = m.lclogFile
      This.DeleteTempFile = m.llDeleteTempFile
   ENDPROC

    
   PROTECTED PROCEDURE DefaultParameters
      RETURN This.Organization+" "+ALLTRIM(This.Secret)
   ENDPROC


   PROTECTED PROCEDURE Serialize()
   ENDPROC
    

   PROCEDURE Create()
   ENDPROC


   PROCEDURE Add()
   ENDPROC


   PROCEDURE Update()
   ENDPROC


   PROCEDURE Delete()
   ENDPROC
    

   PROCEDURE GetList
   ENDPROC


   PROCEDURE Get()
   ENDPROC
    
ENDDEFINE


DEFINE CLASS RIC_User AS Custom
   HIDDEN Application, BaseClass, Class, ClassLibrary, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Objects, Parent, ParentClass, Picture, Tag, Top, WhatsThisHelpID, Width 

   RIC_ID=""
   RIC_UserName=""
   RIC_RealName=""
   RIC_IsAdmin=.F.
   RIC_Roles=""
   RIC_Email=""
   RIC_Language=""

   RIC_Password = ""
ENDDEFINE


DEFINE CLASS RIC_UsersAPIClient AS RIC_ObjectsAPIClient
   Name="RIC_UsersAPIClient"

   PROTECTED PROCEDURE Serialize
      LPARAMETERS m.toUser
      LOCAL m.lcFile, m.lnh
      m.lcFile = This.GetTempFileName(ADDBS(SYS(2023)),"_RU",0)
      m.lnh = FCREATE(m.lcFile)
      =FPUTS(m.lnh, "[")
      =FPUTS(m.lnh, "ID "+m.toUser.RIC_ID)
      =FPUTS(m.lnh, "UserName "+m.toUser.RIC_UserName)
      =FPUTS(m.lnh, "RealName "+m.toUser.RIC_RealName)
      =FPUTS(m.lnh, "IsAdmin "+IIF(m.toUser.RIC_IsAdmin,"true","false"))
      =FPUTS(m.lnh, "Roles "+m.toUser.RIC_Roles)
      =FPUTS(m.lnh, "Email "+m.toUser.RIC_Email)
      =FPUTS(m.lnh, "Language "+m.toUser.RIC_Language)
      =FPUTS(m.lnh, "]")
      =FCLOSE(m.lnh)
      RETURN m.lcFile
   ENDPROC
	
   PROCEDURE Create(m.tcUserName, m.tcPassword, m.tcRealName, m.tlIsAdmin, m.tcRoleList)
      LOCAL m.loUser
      m.loUser=CREATEOBJECT("RIC_User")

      IF NOT EMPTY(m.tcUserName)
         m.loUser.RIC_UserName=m.tcUserName
      ENDIF
      IF NOT EMPTY(m.tcRealName)
         m.loUser.RIC_RealName=m.tcRealName
      ENDIF
      IF NOT EMPTY(m.tcPassword)
         m.loUser.RIC_Password=m.tcPassword
      ENDIF
      m.loUser.RIC_IsAdmin=IIF(EMPTY(m.tlIsAdmin),.F.,.T.)
      IF NOT EMPTY(m.tcRoleList)
         m.loUser.RIC_Roles=m.tcRoleList
      ENDIF
      RETURN m.loUser
   ENDPROC


   PROCEDURE Add
      LPARAMETERS m.loUser
      RETURN This.CallAPI("ADDUSER",This.MergeParameters5(m.loUser.RIC_UserName, m.loUser.RIC_Password, m.loUser.RIC_RealName, ;
                                                          IIF(m.loUser.RIC_IsAdmin,"true","false"), m.loUser.RIC_Roles))
   ENDPROC

   PROCEDURE Update
      LPARAMETERS m.toUser
      LOCAL m.lcTempFile, m.loRetval
      m.lcTempFile = This.Serialize(m.toUser)
      m.loRetval = This.CallAPI("UPDATEUSER", This.MergeParameters1(m.lcTempFile))
      This.AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF This.DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF	
      RETURN m.loRetval
   ENDPROC

   PROCEDURE Delete
      LPARAMETERS m.tcUserName
      RETURN This.CallAPI("DELETEUSER",m.tcUserName)
   ENDPROC
	
   PROCEDURE GetList
      RETURN This.CallAPI("GETUSERS","")
   ENDPROC

   PROCEDURE Get
      LPARAMETERS m.tcUserName
      LOCAL m.loUser, m.lii, m.loRICDATA
      m.loRICDATA = This.GetList()
      IF !m.loRICDATA.IsOK
         RETURN m.loRICDATA
      ENDIF
      FOR m.lii = 1 TO m.loRICDATA.datacount
          IF RTRIM(m.tcUserName) == RTRIM(m.loRICDATA.data(m.lii).RIC_UserName)
             m.loUser = m.loRICDATA.data(m.lii)
             EXIT
          ENDIF
      ENDFOR
      IF m.lii <=m.loRICDATA.datacount
         m.loRICDATA.datacount=1
         DIMENSION m.loRICDATA.data(1)
         m.loRICDATA.data(1)=m.loUser
      ELSE
         m.loRICDATA.datacount = 0
         m.loRICDATA.IsOK = .f.
         m.loRICDATA.ErrorMessage = "User ("+RTRIM(m.tcUserName)+") does not exist."      	 
      ENDIF
      RETURN m.loRICDATA
   ENDPROC
    
ENDDEFINE



DEFINE CLASS RIC_RolesAPIClient AS RIC_ObjectsAPIClient
   Name="RIC_RolesAPIClient"
   

   PROCEDURE Add
      LPARAMETERS m.tcRoleName, m.tcUserList
      RETURN This.CallAPI("ADDROLE",This.MergeParameters2(m.tcRoleName,m.tcUserList))
   ENDPROC
   
   PROCEDURE Update
      LPARAMETERS m.tcRoleName, m.tcUserList
      RETURN This.CallAPI("UPDATEROLE",This.MergeParameters2(m.tcRoleName,m.tcUserList))
   ENDPROC

   PROCEDURE Delete
      LPARAMETERS m.tcRoleName
      RETURN This.CallAPI("DELETEROLE",m.tcRoleName)
   ENDPROC

   PROCEDURE GetList
      RETURN This.CallAPI("GETROLES","")
   ENDPROC
   
   PROCEDURE Get
      LPARAMETERS m.tcRoleName
      LOCAL m.loRole, m.lii, m.loRICDATA
      m.loRICDATA = This.GetList()
      IF !m.loRICDATA.IsOK
         RETURN m.loRICDATA
      ENDIF
      FOR m.lii = 1 TO m.loRICDATA.datacount
          IF RTRIM(m.tcRoleName)==m.loRICDATA.data(m.lii).RIC_Name
             m.loRole = m.loRICDATA.data(m.lii)
             EXIT
          ENDIF
      ENDFOR
      IF m.lii <=m.loRICDATA.datacount
         m.loRICDATA.datacount=1
         DIMENSION m.loRICDATA.data(1)
         m.loRICDATA.data(1)=m.loRole
	  ELSE
         m.loRICDATA.datacount = 0
         m.loRICDATA.IsOK = .f.
         m.loRICDATA.ErrorMessage = "Role ("+RTRIM(m.tcRoleName)+") does not exist."  	           
      ENDIF
      RETURN m.loRICDATA
   ENDPROC

    
ENDDEFINE


********************************************************************************
DEFINE CLASS RIC_FoldersAPIClient AS RIC_ObjectsAPIClient
   Name="RIC_FoldersAPIClient"
   
   PROCEDURE Add
      LPARAMETERS m.tcFolderFullPath
      RETURN This.CallAPI("ADDFOLDER",This.MergeParameters1(m.tcFolderFullPath))
   ENDPROC

   PROCEDURE Delete
      LPARAMETERS m.tcFolderFullPath
      RETURN This.CallAPI("DELETEFOLDER",This.MergeParameters1(m.tcFolderFullPath))
   ENDPROC


*!*    PROCEDURE GetList
*!*       RETURN This.CallAPI("GETFOLDERS","")
*!*    ENDPROC

*!*    PROCEDURE Get
*!*       LPARAMETERS m.tcFolderFullPath
*!*       LOCAL m.loFolder, m.lii, m.loRICDATAU
*!*       m.loRICDATAU = This.GetList()
*!*       IF !m.loRICDATAU.IsOK
*!*          RETURN m.loRICDATAU
*!*       ENDIF
*!*       FOR m.lii = 1 TO m.loRICDATAU.datacount
*!*           IF m.tcFolderFullPath==m.loRICDATAU.data(m.lii).RIC_Name
*!*              m.loFolder = m.loRICDATAU.data(m.lii)
*!*              EXIT
*!*           ENDIF
*!*       ENDFOR
*!*       IF m.lii <=m.loRICDATAU.datacount
*!*          m.loRICDATAU.datacount=1
*!*          DIMENSION m.loRICDATAU.data(1)
*!*          m.loRICDATAU.data(1)=m.loFolder
*!*       ENDIF
*!*       RETURN m.loRICDATAU
*!*    ENDPROC


   PROCEDURE AddRights
      LPARAMETERS m.tcFolderFullPath, m.tcUserList, m.tcRoleList
      RETURN This.CallAPI("ADDFOLDERRIGHTS",This.MergeParameters3(This.ADDS(m.tcFolderFullPath), m.tcUserList, m.tcRoleList))
   ENDPROC

   PROCEDURE UpdateRights
      LPARAMETERS m.tcFolderFullPath, m.tcUserList, m.tcRoleList
      RETURN This.CallAPI("UPDATEFOLDERRIGHTS",This.MergeParameters3(This.ADDS(m.tcFolderFullPath), m.tcUserList, m.tcRoleList))
   ENDPROC

   PROCEDURE DeleteRights
      LPARAMETERS m.tcFolderFullPath, m.tcUserList, m.tcRoleList
      RETURN This.CallAPI("DELETEFOLDERRIGHTS",This.MergeParameters3(This.ADDS(m.tcFolderFullPath), m.tcUserList, m.tcRoleList))
   ENDPROC

   PROCEDURE GetRights()
      LPARAMETERS m.tcFolderFullPath
      RETURN This.CallAPI("GETFOLDERRIGHTS",This.MergeParameters1(This.ADDS(m.tcFolderFullPath)))
   ENDPROC
 
   ADD OBJECT PCache AS RIC_Cache WITH nCacheCols=2


   PROCEDURE PCache.Add(m.lcID, m.luValue)
      LOCAL m.lcValue, m.loRetVal
      DODEFAULT()
      m.lcValue = This.Parent.Parent.Dictionary.ToString(m.lcID,m.luValue)
   	  m.loRetVal = CREATEOBJECT("RIC_StructuredErrorValue")
	  IF SUBSTR(m.lcValue,1,1) = "####RIC_ERROR#### "
	      m.loRetVal.isOK = .f.
	      m.loRetVal.ErrorMessage = SUBSTR(m.lcValue,19)
          This.nCache=This.nCache-1
	  ELSE
	  	  m.loRetVal.isOK = .t.
          This.aCache(This.nCache,1) = m.lcID
          This.aCache(This.nCache,2) = m.lcValue      
	  ENDIF
	  RETURN m.loRetVal
   ENDPROC

   PROCEDURE PCache.Flush(m.tcFolderFullPath)
      LOCAL m.loRetVal, m.lcTempFile
      WITH This.Parent
      m.lcTempFile = This.Serialize()
      m.loRetVal=.CallAPI("UPDATEFOLDERPROPERTIES",.MergeParameters2(.ADDS(m.tcFolderFullPath),m.lcTempFile))
      This.Clear()
      .AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF .DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF
      ENDWITH
      RETURN m.loRetVal
   ENDPROC
   
   PROCEDURE PCache.Serialize
      LPARAMETERS m.llUpdate
      LOCAL m.lcFile, m.lnh, m.lii
      m.lcFile = This.Parent.GetTempFileName(ADDBS(SYS(2023)),"_FP",0)
      m.lnh = FCREATE(m.lcFile)
      FOR lii=1 TO This.nCache
          =FPUTS(m.lnh, "["+CHR(13)+CHR(10)+;
                        This.aCache(m.lii,1)+" "+This.aCache(m.lii,2)+CHR(13)+CHR(10)+;
                        "]";
                )
      NEXT
      =FCLOSE(m.lnh)
      RETURN m.lcFile
   ENDPROC


   PROCEDURE UpdateProperties(m.tcFolderFullPath, m.lcID, m.luValue)
      LOCAL m.loRetVal, m.lcTempFile
      m.loRetVal = This.PCache.Add(m.lcID, m.luValue)
      IF m.loRetVal.isOK 
	      m.lcTempFile = This.PCache.Serialize()
	      m.loRetVal = This.CallAPI("UPDATEFOLDERPROPERTIES",This.MergeParameters2(This.ADDS(m.tcFolderFullPath),m.lcTempFile))
	      This.PCache.Clear()
	      This.AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
	      IF This.DeleteTempFile
	         ERASE (m.lcTempFile)
	      ENDIF
      ENDIF
      RETURN m.loRetVal
   ENDPROC


   PROCEDURE DeleteProperties(m.tcFolderFullPath, m.tcProperty)
      RETURN This.CallAPI("DELETEFOLDERPROPERTIES",This.MergeParameters2(This.ADDS(m.tcFolderFullPath), m.tcProperty))
   ENDPROC


   PROCEDURE GetProperties(m.tcFolderFullPath)
      LOCAL m.loRICDATA, m.lii, m.liPCount, m.liy
      LOCAL ARRAY m.laProps(1)
      m.loRICDATA = This.CallAPI("GETFOLDERPROPERTIES",This.MergeParameters1(This.ADDS(m.tcFolderFullPath)))

      IF !m.loRICDATA.IsOK
         RETURN m.loRICDATA
      ENDIF
      FOR m.lii = 1 TO m.loRICDATA.datacount
          m.liPCount=AMEMBERS(m.laProps,m.loRICDATA.data(m.lii),0)
          FOR liy=1 TO m.liPCount
              STORE This.Parent.Dictionary.ToValue(SUBSTR(m.laProps(m.liy),5),EVALUATE("m.loRICDATA.data(m.lii)."+m.laProps(m.liy))) TO ("m.loRICDATA.data(m.lii)."+m.laProps(m.liy))
          NEXT
      NEXT

      RETURN m.loRICDATA
   ENDPROC

    
ENDDEFINE


********************************************************************************
DEFINE CLASS RIC_ReportsAPIClient AS RIC_ObjectsAPIClient
   Name="RIC_ReportsAPIClient"


   PROCEDURE Delete
      LPARAMETERS m.tcReportFullPath
      RETURN This.CallAPI("DELETEREPORT",This.MergeParameters1(m.tcReportFullPath))
   ENDPROC


*!*    PROCEDURE GetList
*!*       RETURN This.CallAPI("GETREPORTS","")
*!*    ENDPROC

*!*    PROCEDURE Get
*!*       LPARAMETERS m.tcReportFullPath
*!*       LOCAL m.loReport, m.lii, m.loRICDATAU
*!*       m.loRICDATAU = This.GetList()
*!*       IF !m.loRICDATAU.IsOK
*!*          RETURN m.loRICDATAU
*!*       ENDIF
*!*       FOR m.lii = 1 TO m.loRICDATAU.datacount
*!*           IF m.tcReportFullPath==m.loRICDATAU.data(m.lii).RIC_Name
*!*              m.loReport = m.loRICDATAU.data(m.lii)
*!*              EXIT
*!*           ENDIF
*!*       ENDFOR
*!*       IF m.lii <=m.loRICDATAU.datacount
*!*          m.loRICDATAU.datacount=1
*!*          DIMENSION m.loRICDATAU.data(1)
*!*          m.loRICDATAU.data(1)=m.loReport
*!*       ENDIF
*!*       RETURN m.loRICDATAU
*!*    ENDPROC

   PROCEDURE Upload
      LPARAMETERS m.tcXmlFileName, m.tcRemoteLocation
      RETURN This.CallAPI("UPLOADREPORT",This.MergeParameters2(m.tcXmlFileName, m.tcRemoteLocation))
   ENDPROC

   PROCEDURE UploadExportedFile
      LPARAMETERS m.tcXmlFileName, m.tcType, m.tcRemoteLocation
      RETURN This.CallAPI("UPLOADEXPORTEDFILE",This.MergeParameters3(m.tcXmlFileName, m.tcType, m.tcRemoteLocation))
   ENDPROC



   PROCEDURE AddRights
      LPARAMETERS m.tcReportFullPath, m.tcUserList, m.tcRoleList
      RETURN This.CallAPI("ADDREPORTRIGHTS",This.MergeParameters3(m.tcReportFullPath, m.tcUserList, m.tcRoleList))
   ENDPROC

   PROCEDURE UpdateRights
      LPARAMETERS m.tcReportFullPath, m.tcUserList, m.tcRoleList
      RETURN This.CallAPI("UPDATEREPORTRIGHTS",This.MergeParameters3(m.tcReportFullPath, m.tcUserList, m.tcRoleList))
   ENDPROC

   PROCEDURE DeleteRights
      LPARAMETERS m.tcReportFullPath, m.tcUserList, m.tcRoleList
      RETURN This.CallAPI("DELETEREPORTRIGHTS",This.MergeParameters3(m.tcReportFullPath, m.tcUserList, m.tcRoleList))
   ENDPROC

   PROCEDURE GetRights
      LPARAMETERS m.tcReportFullPath
      RETURN This.CallAPI("GETREPORTRIGHTS",This.MergeParameters1(m.tcReportFullPath))
   ENDPROC
 

   ADD OBJECT PCache AS RIC_Cache WITH nCacheCols=2
   
   PROCEDURE PCache.Add(m.lcID, m.luValue)
      LOCAL m.lcValue, m.loRetVal
      DODEFAULT()
      m.lcValue = This.Parent.Parent.Dictionary.ToString(m.lcID,m.luValue)
   	  m.loRetVal = CREATEOBJECT("RIC_StructuredErrorValue")
	  IF SUBSTR(m.lcValue,1,18) = "####RIC_ERROR#### "
	      m.loRetVal.isOK = .f.
	      m.loRetVal.ErrorMessage = SUBSTR(m.lcValue,19)
          This.nCache=This.nCache-1	      
	  ELSE
	  	  m.loRetVal.isOK = .t.
          This.aCache(This.nCache,1) = m.lcID
          This.aCache(This.nCache,2) = m.lcValue      
	  ENDIF
	  RETURN m.loRetval 
   ENDPROC

   PROCEDURE PCache.Flush(m.tcReportFullPath)
      LOCAL m.loRetVal, m.lcTempFile
      WITH This.Parent
      m.lcTempFile = This.Serialize()
      m.loRetVal=.CallAPI("UPDATEREPORTPROPERTIES",.MergeParameters2(m.tcReportFullPath,m.lcTempFile))
      This.Clear()
      .AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF .DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF
      ENDWITH
      RETURN m.loRetVal
   ENDPROC

   PROCEDURE PCache.Serialize
      LPARAMETERS m.llUpdate
      LOCAL m.lcFile, m.lnh, m.lii
      m.lcFile = This.Parent.GetTempFileName(ADDBS(SYS(2023)),"_FP",0)
      m.lnh = FCREATE(m.lcFile)
      FOR lii=1 TO This.nCache
          =FPUTS(m.lnh, "["+CHR(13)+CHR(10)+;
                        This.aCache(m.lii,1)+" "+This.aCache(m.lii,2)+CHR(13)+CHR(10)+;
                        "]";
                )
      NEXT
      =FCLOSE(m.lnh)
      RETURN m.lcFile
   ENDPROC
   
   PROCEDURE UpdateProperties(m.tcReportFullPath, m.lcID, m.luValue)
      LOCAL m.loRetVal, m.lcTempFile
      m.loRetVal = This.PCache.Add(m.lcID, m.luValue)
	  IF m.loRetVal.isOK
	      m.lcTempFile = This.PCache.Serialize()
	      m.loRetVal=This.CallAPI("UPDATEREPORTPROPERTIES",This.MergeParameters2(m.tcReportFullPath, m.lcTempFile))
	      This.PCache.Clear()
	      This.AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
	      IF This.DeleteTempFile
	         ERASE (m.lcTempFile)
	      ENDIF
      ENDIF
      RETURN m.loRetVal
   ENDPROC


   PROCEDURE DeleteProperties(m.tcReportFullPath, m.tcProperty)
      RETURN This.CallAPI("DELETEREPORTPROPERTIES",This.MergeParameters2(m.tcReportFullPath, m.tcProperty))
   ENDPROC


   PROCEDURE GetProperties(m.tcReportFullPath)
      LOCAL m.loRICDATA, m.lii, m.liPCount, m.liy
      LOCAL ARRAY m.laProps(1)
      m.loRICDATA = This.CallAPI("GETREPORTPROPERTIES",This.MergeParameters1(m.tcReportFullPath))

      IF !m.loRICDATA.IsOK
         RETURN m.loRICDATA
      ENDIF
      FOR m.lii = 1 TO m.loRICDATA.datacount
          m.liPCount=AMEMBERS(m.laProps,m.loRICDATA.data(m.lii),0)
          FOR liy=1 TO m.liPCount
              STORE This.Parent.Dictionary.ToValue(SUBSTR(m.laProps(m.liy),5),EVALUATE("m.loRICDATA.data(m.lii)."+m.laProps(m.liy))) TO ("m.loRICDATA.data(m.lii)."+m.laProps(m.liy))
          NEXT
      NEXT

      RETURN m.loRICDATA
   ENDPROC

ENDDEFINE



********************************************************************************

DEFINE CLASS RIC_DictionaryItem AS Custom
   HIDDEN Application, BaseClass, Class, ClassLibrary, Comment, ControlCount, Controls, Height, HelpContextID,; 
          Left, Objects, Parent, ParentClass, Picture, Tag, Top, WhatsThisHelpID, Width, Name

   RIC_ID=""
   RIC_Name=""
   RIC_Order=0
   RIC_Show=.F.
   RIC_Showingrid=.F.
   RIC_DataType=""

ENDDEFINE

DEFINE CLASS RIC_DictionaryAPIClient AS RIC_ObjectsAPIClient
   Name="RIC_DictionaryAPIClient"
   PROTECTED ARRAY aICache(1)
   PROTECTED nICache, nICacheTimeOut, nICacheTime
   nICache=0
   nICacheTimeOut=300 && seconds
   nICacheTime=.NULL.
  
   ADD OBJECT Cache AS RIC_Cache WITH nCacheCols=1
   
   PROCEDURE Cache.Flush(m.llUpdate)
      LOCAL m.lnRetVal, m.lcTempFile
      WITH This.Parent
      m.lcTempFile = This.Serialize(m.llUpdate)
      m.lnRetVal=.CallAPI(IIF(NOT m.llUpdate,"ADDPROPERTIESDICTIONARYITEM","UPDATEPROPERTIESDICTIONARYITEM"),.MergeParameters1(m.lcTempFile))
      This.Clear()
      .AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF .DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF
      ENDWITH
      RETURN m.lnRetVal
   ENDPROC

   PROCEDURE Cache.Add(m.loDI)
      DODEFAULT()
      This.aCache(This.nCache,1)=m.loDI
   ENDPROC

   PROCEDURE Cache.Serialize
      LPARAMETERS m.llUpdate
      LOCAL m.lcFile, m.lnh, m.lii
      m.lcFile = This.Parent.GetTempFileName(ADDBS(SYS(2023)),"_DI",0)
      m.lnh = FCREATE(m.lcFile)
      FOR lii=1 TO This.nCache
          =FPUTS(m.lnh, "["+CHR(13)+CHR(10)+;
                        "ID "+This.aCache(m.lii).RIC_ID;
                        +CHR(13)+CHR(10)+;
                        "Name "+This.aCache(m.lii).RIC_Name+CHR(13)+CHR(10)+;
                        "Order "+LTRIM(STR(This.aCache(m.lii).RIC_Order,11))+CHR(13)+CHR(10)+;
                        "Show "+IIF(This.aCache(m.lii).RIC_Show,"true","false")+CHR(13)+CHR(10)+;
                        "ShowInGrid "+IIF(This.aCache(m.lii).RIC_Showingrid,"true","false")+CHR(13)+CHR(10)+;
                        IIF(NOT EMPTY(This.aCache(m.lii).RIC_DataType) AND NOT m.llUpdate,"DataType "+This.aCache(m.lii).RIC_DataType+CHR(13)+CHR(10),"")+;
                        "]";
                )
&&                                        +IIF(m.llUpdate," Updated","")
      NEXT
      =FCLOSE(m.lnh)
      RETURN m.lcFile
   ENDPROC

     
   PROCEDURE Create(m.lcID, m.lcName, m.liOrder, m.llShow, m.llShowInGrid, m.lcDataType)
      LOCAL m.loDI
      m.loDI=CREATEOBJECT("RIC_DictionaryItem")

      IF NOT EMPTY(m.lcID)
         m.loDI.RIC_ID=m.lcID
      ENDIF
      IF NOT EMPTY(m.lcName)
         m.loDI.RIC_Name=m.lcName
      ENDIF
      IF NOT EMPTY(m.liOrder)
         m.loDI.RIC_Order=m.liOrder
      ENDIF
      m.loDI.RIC_Show=IIF(EMPTY(m.llShow),.F.,.T.)
      m.loDI.RIC_Showingrid=IIF(EMPTY(m.llShowingrid),.F.,.T.)
      IF NOT EMPTY(m.lcDataType)
         m.loDI.RIC_DataType=m.lcDataType
      ENDIF
      RETURN m.loDI
   ENDPROC
      
   PROCEDURE Add(m.loDI)
      LOCAL m.lnRetVal, m.lcTempFile
      This.Cache.Add(m.loDI)
      m.lcTempFile = This.Cache.Serialize()
      m.lnRetVal=This.CallAPI("ADDPROPERTIESDICTIONARYITEM",This.MergeParameters1(m.lcTempFile))
      This.Cache.Clear()
      This.AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF This.DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF
      =IIF(m.lnRetVal.IsOK,This.UpdateFromICache(m.loDI),.T.)
      RETURN m.lnRetVal
   ENDPROC

   PROCEDURE Update(m.loDI)
      LOCAL m.lnRetVal, m.lcTempFile, m.liIndex
      This.Cache.Add(m.loDI)
      m.lcTempFile = This.Cache.Serialize(.T.)
      m.lnRetVal=This.CallAPI("UPDATEPROPERTIESDICTIONARYITEM",This.MergeParameters1(m.lcTempFile))
      This.Cache.Clear()
      This.AddToLog(m.lcTempFile+": "+FILETOSTR(m.lcTempFile))
      IF This.DeleteTempFile
         ERASE (m.lcTempFile)
      ENDIF
      =IIF(m.lnRetVal.IsOK,This.UpdateFromICache(m.loDI),.T.)
      RETURN m.lnRetVal
   ENDPROC


   PROCEDURE Delete(m.tcProperty)
      LOCAL m.loRICDATA
      m.loRICDATA=This.CallAPI("DELETEPROPERTIESDICTIONARYITEM",This.MergeParameters1(m.tcProperty))
      =IIF(m.loRICDATA.IsOK,This.DeleteFromICache(m.tcProperty),.T.)
      RETURN m.loRICDATA 
   ENDPROC


   PROCEDURE GetList()
      LOCAL m.lii, m.loRICDATA
      m.loRICDATA = This.CallAPI("GETPPROPERTIESDICTIONARYITEMS","")
      IF !m.loRICDATA.IsOK
         RETURN m.loRICDATA
      ENDIF
      FOR m.lii = 1 TO m.loRICDATA.datacount
          WITH m.loRICDATA.data(m.lii)
          .RIC_Order=INT(VAL(.RIC_Order))
          .RIC_Show=UPPER(.RIC_Show)=="TRUE"
          .RIC_ShowInGrid=UPPER(.RIC_ShowInGrid)=="TRUE"
          ENDWITH
      ENDFOR
      This.CheckICache(m.loRICDATA)
      RETURN m.loRICDATA
   ENDPROC
   

   PROCEDURE Get
      LPARAMETERS m.tcID
      LOCAL m.loProperty, m.lii, m.loRICDATA
      m.loRICDATA = This.GetList()
      IF !m.loRICDATA.IsOK
         RETURN m.loRICDATA
      ENDIF
      FOR m.lii = 1 TO m.loRICDATA.datacount
          IF RTRIM(m.tcID)==RTRIM(m.loRICDATA.data(m.lii).RIC_ID)
             m.loProperty = m.loRICDATA.data(m.lii)
             EXIT
          ENDIF
      ENDFOR
      IF m.lii <=m.loRICDATA.datacount
         m.loRICDATA.datacount=1
         DIMENSION m.loRICDATA.data(1)
         m.loRICDATA.data(1)=m.loProperty
      ELSE
         m.loRICDATA.datacount = 0
         m.loRICDATA.IsOK = .f.
         m.loRICDATA.ErrorMessage = "Property ("+RTRIM(m.tcID)+") does not exist."  	           
      ENDIF
      RETURN m.loRICDATA
   ENDPROC


   PROTECTED PROCEDURE ClearICache()
      This.nICache=0
      DIMENSION This.aICache(1)
      This.aICache(1)=.NULL.
   ENDPROC

   PROTECTED PROCEDURE FindInICache(m.lcID)
      LOCAL m.lnIndex

      #IF VAL(STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0",""))>=7
       m.lnIndex = ASCAN(This.aICache,UPPER(m.lcID), -1, -1, 1, 7+8)
      #ENDIF

      #IF VAL(STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0",""))<7
       m.lcID=UPPER(m.lcID)
       FOR m.lnIndex=1 TO This.nICache
           IF This.aICache(m.lnIndex,1)==m.lcID
              EXIT
           ENDIF
       NEXT
       m.lnIndex=IIF(m.lnIndex>ALEN(This.aICache,2),0,AELEMENT(This.aICache,m.lnIndex,1))
      #ENDIF
      RETURN m.lnIndex
   ENDPROC

   PROTECTED PROCEDURE CheckICache(m.loRICDATA)
      LOCAL m.lii
      This.ClearICache()
      FOR m.lii=1 TO m.loRICDATA.DataCount
          This.AddToICache(m.loRICDATA.data(m.lii))
      NEXT
   ENDPROC

   PROTECTED PROCEDURE AddToICache(m.loDI)
      This.nICache=This.nICache+1
      DIMENSION This.aICache(This.nICache,2)
      This.aICache(This.nICache,1)=UPPER(m.loDI.RIC_ID)
      This.aICache(This.nICache,2)=m.loDI
   ENDPROC

   PROCEDURE DeleteFromICache(m.lcID)
      LOCAL m.liIndex
      m.liIndex=This.FindInICache(m.lcID)
      IF m.liIndex>0
         =ADEL(This.aICache,m.liIndex,1)
         This.nICache=This.nICache-1
      ENDIF
   ENDPROC

   PROCEDURE UpdateFromICache(m.loDI)
      LOCAL m.liIndex
      m.liIndex=This.FindInICache(m.loDI.RIC_ID)
      IF m.liIndex>0
         This.aICache(m.liIndex,2)=m.loDI
      ELSE
         This.AddToICache(m.loDI)
      ENDIF
   ENDPROC

   PROTECTED PROCEDURE GetFromICache(m.lcID)
      IF ISNULL(This.nICacheTime) OR DATETIME()-This.nICacheTime>This.nICacheTimeOut
         This.nICacheTime=DATETIME()
         This.GetList()
      ENDIF

      LOCAL m.liIndex, m.loRICDATA
      m.liIndex=This.FindInICache(m.lcID)
      IF m.liIndex>0
         RETURN This.aICache(m.liIndex,2)
      ENDIF

      m.loRICDATA=This.Get(m.lcID)
      IF !m.loRICDATA.IsOK
         RETURN .NULL.
      ENDIF
      This.AddToICache(m.loRICDATA)
      RETURN m.loRICDATA.data(1)
   ENDPROC


   PROCEDURE ToString(m.lcID, m.luValue)
      LOCAL m.loDI, m.DataTypeProp, m.DataTypeValue
      
      loDI=This.GetFromICache(m.lcID)
      m.DataTypeProp = RTRIM(UPPER(loDI.RIC_DataType))
      m.DataTypeValue = VARTYPE(m.luValue)
      
      DO CASE
         CASE (m.DataTypeProp=="STRING" OR m.DataTypeProp=="VARCHAR") AND m.DataTypeValue == "C"
              RETURN m.luValue
              
         CASE m.DataTypeProp=="DECIMAL" AND m.DataTypeValue == "N"
              RETURN LTRIM(CHRTRAN(TRANSFORM(m.luValue,""),',','.'))
         
         CASE m.DataTypeProp=="DATE" AND m.DataTypeValue == "D"
              RETURN CHRTRAN("1234-56-78","12345678",DTOS(m.luValue))
         
         CASE m.DataTypeProp=="DATETIME" AND m.DataTypeValue == "T"
              RETURN CHRTRAN("1234-56-78 AB:CD:EF","12345678ABCDEF",TTOC(m.luValue,1))
         
         CASE m.DataTypeProp=="BIT" AND m.DataTypeValue == "L"
              RETURN IIF(TYPE("m.luValue")="L", IIF(m.luValue,"true","false"),IIF(m.luValue=0,"false","true"))
         
         OTHERWISE
              RETURN "####RIC_ERROR#### Property data type = "+m.DataTypeProp+" and value data type (VARTYPE) = "+m.DataTypeValue+" are not compatible.";
         
      ENDCASE
   ENDPROC
      
   PROCEDURE ToValue(m.lcID, m.lcValue)
      LOCAL m.loDI, m.DataTypeProp
      
      loDI=This.GetFromICache(m.lcID)
      m.DataTypeProp = RTRIM(UPPER(loDI.RIC_DataType))
      
      DO CASE
         CASE m.DataTypeProp=="STRING" OR m.DataTypeProp=="VARCHAR"
              RETURN m.lcValue
              
         CASE m.DataTypeProp=="DECIMAL"
              RETURN VAL(CHRTRAN(m.lcValue,".",SET("POINT")))
         
         CASE m.DataTypeProp=="DATE"
              RETURN CTOD("^"+m.lcValue)
         
         CASE m.DataTypeProp=="DATETIME"
              RETURN CTOT("^"+CHRTRAN(m.lcValue,"T"," "))
         
         CASE m.DataTypeProp=="BIT"
              RETURN UPPER(m.lcValue)="TRUE"
         
         OTHERWISE
              RETURN ""
         
      ENDCASE
   ENDPROC

    
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
PROCEDURE ExecAndWait
LPARAMETERS m.lcExe,m.lcCommandLine
LOCAL m.hProcess, m.cProcessInfo, m.cStartupInfo, m.lnShowWindow,m.llWaitForCompletion

m.lnShowWindow = 0
m.llWaitForCompletion = .T.
m.cProcessinfo = REPLICATE(CHR(0),128)
m.cStartupInfo = GetStartupInfo(m.lnShowWindow)

IF !EMPTY(m.lcCommandLine)
   m.lcCommandLine = ["] + m.lcExe + [" ]+ m.lcCommandLine
ELSE
   m.lcCommandLine = ""
ENDIF

LOCAL m.CREATE_NO_WINDOW
m.CREATE_NO_WINDOW = 8
*CREATE_NO_WINDOW = 0
m.lnResult =  RIC_CreateProcess(m.lcExe,m.lcCommandLine,0,0,0,m.CREATE_NO_WINDOW ,0,SYS(5)+CURDIR(),m.cStartupInfo,@m.cProcessInfo)
m.lhProcess = CHARTOBIN( SUBSTR(m.cProcessInfo,1,4) )

IF m.llWaitForCompletion
   #DEFINE WAIT_TIMEOUT 0x00000102
   DO WHILE .T.
      *** Update every 100 milliseconds
      IF RIC_WaitForSingleObject(m.lhProcess, 100) != WAIT_TIMEOUT
         EXIT
      ELSE
         DOEVENTS
      ENDIF
   ENDDO
ENDIF

=RIC_CloseHandle(m.lhProcess)

RETURN IIF(m.lnResult=1,.T.,.F.)
ENDPROC

FUNCTION getStartupInfo(m.lnShowWindow)
LOCAL m.lnFlags
* creates the STARTUP structure to specify main window
* properties if a new window is created for a new process

IF EMPTY(m.lnShowWindow)
   m.lnShowWindow = 1
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
m.lnFlags = 4
*STARTF_USESHOWWINDOW

RETURN binToChar(80) +;
       binToChar(0) + binToChar(0) + binToChar(0) +;
       binToChar(0) + binToChar(0) + binToChar(0) + binToChar(0) +;
       binToChar(0) + binToChar(0) + binToChar(0) +;
       binToChar(m.lnFlags) +;
       binToWordChar(m.lnShowWindow) +;
       binToWordChar(0) + binToChar(0) +;
       binToChar(0) + binToChar(0) + binToChar(0) + REPLICATE(CHR(0),30)
ENDFUNC
************************************************************************

FUNCTION CharToBin(m.lcBinString,m.llSigned)
****************************************
***  Function: Binary Numeric conversion routine. 
***            Converts DWORD or Unsigned Integer string
***            to Fox numeric integer value.
***      Pass: lcBinString -  String that contains the binary data 
***            llSigned    -  if .T. uses signed conversion
***                           otherwise value is unsigned (DWORD)
***    Return: Fox number
************************************************************************

LOCAL m.i, m.lnWord
m.lnWord = 0
FOR m.i = 1 TO LEN(m.lcBinString)
    m.lnWord = m.lnWord + (ASC(SUBSTR(m.lcBinString, m.i, 1)) * (2 ^ (8 * (m.i - 1))))
ENDFOR

IF m.llSigned AND m.lnWord > 0x80000000
   m.lnWord = m.lnWord - 1 - 0xFFFFFFFF
ENDIF
RETURN m.lnWord
ENDFUNC
*  wwAPI :: CharToBin

************************************************************************
FUNCTION BinToChar(m.lnValue)
****************************************
***  Function: Creates a DWORD value from a number
***      Pass: lnValue - VFP numeric integer (unsigned)
***    Return: binary string
************************************************************************
LOCAL ARRAY m.byte(4)
IF m.lnValue < 0
   m.lnValue = m.lnValue + 4294967296
ENDIF
m.byte(1) = m.lnValue % 256
m.byte(2) = BITRSHIFT(m.lnValue, 8) % 256
m.byte(3) = BITRSHIFT(m.lnValue, 16) % 256
m.byte(4) = BITRSHIFT(m.lnValue, 24) % 256
RETURN CHR(m.byte(1))+CHR(m.byte(2))+CHR(m.byte(3))+CHR(m.byte(4))
ENDFUNC
*  wwAPI :: BinToChar

************************************************************************
FUNCTION BinToWordChar(m.lnValue)
****************************************
***  Function: Creates a DWORD value from a number
***      Pass: lnValue - VFP numeric integer (unsigned)
***    Return: binary string
************************************************************************
RETURN CHR(MOD(m.lnValue,256)) + CHR(INT(m.lnValue/256))
ENDFUNC