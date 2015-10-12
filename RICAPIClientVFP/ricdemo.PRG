LOCAL m.lcPath, m.lcOrgName, m.lcOrgSubDomain, m.lcOrgAdminName, m.lcOrgAdminPWD, m.lnOrgUserQuota,;
      m.loRICAPI, m.loRICDATA, m.lcOrgID, m.loRICST, m.loRICDATAU, m.lcSecret
      
m.lcPath=JUSTPATH(SYS(16))+"\"

CLEAR
SET PATH TO (m.lcPath) ADDITIVE

SET PROCEDURE TO (m.lcPath+"RICHelpers") ADDITIVE

#DEFINE XFRX_CUSTOMER_NAME "COPY_YOUR_CUSTOMER_NAME_HERE"
#DEFINE XFRX_CUSTOMER_PWD  "COPY_YOUR_PASSWORD_HERE"

m.lcOrgName      = "org"+STRTRAN(sys(2015),'_','-') && Organization name
m.lcOrgSubDomain = m.lcOrgName                      && Organization subdomain
m.lcOrgAdminName = "admin"                          && Organization admin name
m.lcOrgAdminPWD  = "aaa"                            && Organization admin password
m.lnOrgUserQuota = 5                                && Organization user quota


*******************************
* Create organization manager *
*******************************
m.loRICAPI = RIC_GetOrganizationAPIClient(XFRX_CUSTOMER_NAME, XFRX_CUSTOMER_PWD)
m.loRICAPI.logFile = m.lcPath+"ric.log"
m.loRICAPI.DeleteTempFile = .F.


*******************************
* Create secrets table object *
*******************************
m.loRICST=CREATEOBJECT("RIC_SecretTable",m.lcPath+"Secrets.dbf")
m.loRICST.Open()

******************************
* Create organization object *
******************************
m.lcOrgID=m.loRICST.Get(m.lcOrgSubDomain, @m.lcSecret)
IF EMPTY(m.lcOrgID)
   * Because organization doesn't exist, add it
   ?"==================="
   ?"Create organization"
   
   m.loOrg=m.loRICAPI.Create(m.lcOrgName, m.lcOrgSubDomain, m.lcOrgAdminName, m.lcOrgAdminPWD, m.lnOrgUserQuota)
   m.loRICDATA = m.loRICAPI.Add(m.loOrg)
   IF m.loRICDATA.IsOK
      *
      * we got back a structure with details about the newly created organization
      *
      m.loOrg=m.loRICDATA.Data[1]
      m.lcSecret = m.loOrg.RIC_AdminUserSecret
      m.lcOrgID = m.loOrg.RIC_ID

      ? "organization "+m.lcOrgName+" added successfully"
      ? "URL: https://"+m.lcOrgSubDomain+".reportsincloud.com (copied to clipboard)"
      _cliptext = "https://"+m.lcOrgSubDomain+".reportsincloud.com"
      m.loRICST.Add(m.lcOrgID, m.lcOrgName, m.lcOrgSubDomain, m.lcSecret)

      ? "ID:", m.loOrg.RIC_ID
      ? "Name:", m.loOrg.RIC_Name
      ? "SubDomainName:", m.loOrg.RIC_SubDomainName
      ? "LoginMessage:", m.loOrg.RIC_LoginMessage
      ? "UserQuota:", m.loOrg.RIC_UserQuota
      ? "AdminUserName:", m.loOrg.RIC_AdminUserName
      ? "AdminUserPassword:", m.loOrg.RIC_AdminUserPassword
      ? "AdminUserSecret: "+m.loOrg.RIC_AdminUserSecret
      
      *
      * note: you need to store the secret to be able to authenticate when accessing the user api. In this demo we are storing the secret in a variable here, but also in the secrets dbf. 
      * You can call 
      *
      * lcSecret = GetSecret(lcOrganizationSubdomain)
      *
      * to retrieve the secret
   ELSE
      ? "could not add a new organization", "error:", m.loRICDATA.ErrorMessage
      =m.loRICAPI.AddToLog("could not add a new organization error: "+m.loRICDATA.ErrorMessage+CHR(13)+CHR(10))
      RETURN
   ENDIF
ENDIF

?"==========================="
?"Get the organization object"
?""
m.loRICDATA = m.loRICAPI.Get(m.lcOrgID)
IF !m.loRICDATA.IsOK
   ? "error:", m.loRICDATA.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATA.ErrorMessage+CHR(13)+CHR(10))
   RETURN
ENDIF

? "Organization details"
? "ID:", m.loRICDATA.Data[1].RIC_ID
? "Name:", m.loRICDATA.Data[1].RIC_Name
? "SubDomainName:", m.loRICDATA.Data[1].RIC_SubDomainName
? "BaseURL:", m.loRICDATA.Data[1].RIC_BaseURL
? "TotalUsers (RO):", m.loRICDATA.Data[1].RIC_TotalUsers
? "LoginMessage:", m.loRICDATA.Data[1].RIC_LoginMessage
? "DefaultLanguage:", m.loRICDATA.Data[1].RIC_DefaultLanguage
? "QuotaKB:", m.loRICDATA.Data[1].RIC_QuotaKB
? "TotalSizeKB (RO):", m.loRICDATA.Data[1].RIC_TotalSizeKB
? "UserQuota:", m.loRICDATA.Data[1].RIC_UserQuota
? "TotalReports (RO):", m.loRICDATA.Data[1].RIC_TotalReports


?"=========================="
?"Update organization object"
?""
m.loRICDATA.Data[1].RIC_UserQuota=10
m.loRICDATA.Data[1].RIC_LoginMessage="Welcome to the RIC demo organization"
m.loRICDATA.Data[1].RIC_DefaultLanguage="cs"
m.loRICDATA2=m.loRICAPI.Update(m.loRICDATA.Data[1])
IF !m.loRICDATA2.IsOK
   ? "error:", m.loRICDATA2.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATA2.ErrorMessage+CHR(13)+CHR(10))
ENDIF

****************************
* Initialize API interface *
****************************
m.loRICAPI.Open(m.lcOrgSubDomain, m.lcSecret)


?"================"
?"Add role denarii"
?""
m.loRICDATAU = m.loRICAPI.Roles.Add("denarii", "") && second parametr is user list, cam be empty string
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"==============="
?"Add role dollar"
?""
m.loRICDATAU = m.loRICAPI.Roles.Add("dollar", "") && second parametr is user list, cam be empty string
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


******************************
* Add users for organization *
******************************
?"============================================"
?"Add user gt_morgan and assign to role dollar"
?""
LOCAL m.loUser
*Create(m.tcUserName, m.tcPassword, m.tcRealName, m.tlIsAdmin, m.tcRoleList)
m.loUser=m.loRICAPI.Users.Create("gt_morgan", "anna", "George T. Morgan", .F., "dollar")
m.loRICDATAU = m.loRICAPI.Users.Add(m.loUser)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"============================================"
?"Add user ethelred and assign to role denarii"
?""
m.loUser=m.loRICAPI.Users.Create("ethelred", "elfgifa", "Ethelred", .F., "denarii")
m.loRICDATAU = m.loRICAPI.Users.Add(m.loUser)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"===================="
?"Add user emma_regina"
?""
m.loUser=m.loRICAPI.Users.Create("emma_regina", "MELNIC CIVITAS", "Ema Regina", .T., "") && Qeen Ema is admin
m.loRICDATAU = m.loRICAPI.Users.Add(m.loUser)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"===================="
?"Add user cu"
?""
m.loUser=m.loRICAPI.Users.Create("cu", "cu01", "common user", .F., "")
m.loRICDATAU = m.loRICAPI.Users.Add(m.loUser)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF
RELE m.loUser



******************************
* Add users for organization *
******************************

?"============================"
?"Add properties to dictionary"
?""
LOCAL m.loDI
*Create(m.lcID, m.lcName, m.liOrder, m.llShow, m.llShowInGrid, m.lcDataType)
m.loDI = m.loRICAPI.Dictionary.Create("Grain","Coin's grain",0,.T.,.T.,"string")
m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loDI = m.loRICAPI.Dictionary.Create("Weight","Coin's weight",0,.T.,.T.,"DECIMAL")
m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loDI = m.loRICAPI.Dictionary.Create("InvoiceNo","Invoice No.",0,.T.,.T.,"string")
m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loDI = m.loRICAPI.Dictionary.Create("CustomerNo","Customer No.",0,.T.,.T.,"string")
m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

*!* m.loDI = m.loRICAPI.Dictionary.Create("P1","P1",0,.T.,.T.,"string")
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loDI = m.loRICAPI.Dictionary.Create("P2","P2",0,.T.,.T.,"DECIMAL")
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loDI = m.loRICAPI.Dictionary.Create("P3","P3",0,.T.,.T.,"DATE")
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loDI = m.loRICAPI.Dictionary.Create("P4","P4",0,.T.,.T.,"VARCHAR")
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loDI = m.loRICAPI.Dictionary.Create("P5","P5",0,.T.,.T.,"DATETIME")
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loDI = m.loRICAPI.Dictionary.Create("P6","P6",0,.T.,.T.,"BIT")
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Add(m.loDI)
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF



*!* * This block is for future
*!* WITH m.loRICAPI.Dictionary
*!* m.loRICDATAU = .Cache.Add(.Create("Grain","Coin's grain",0,.T.,.T.,"string"))
*!* m.loRICDATAU = .Cache.Add(.Create("Weight","Coin's weight",0,.T.,.T.,"DECIMAL"))
*!* m.loRICDATAU = .Cache.Add(.Create("InvoiceNo","Invoice No.",0,.T.,.T.,"string"))
*!* *m.loRICDATAU = .Cache.Flush() && Insert
*!* m.loRICDATAU = .Cache.Flush(.T.) && Update
*!* ENDWITH
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF



?"=============================="
?"Get properties from dictionary"
?""
LOCAL m.loProperty, m.lii
m.loRICDATAU = m.loRICAPI.Dictionary.GetList()
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" property(ies)"
   FOR m.lii = 1 TO m.loRICDATAU.datacount
       m.loProperty = m.loRICDATAU.data(m.lii)
       ?m.loProperty.ric_datatype, m.loProperty.ric_id, m.loProperty.ric_name, m.loProperty.ric_order,;
        m.loProperty.ric_show, m.loProperty.ric_showingrid
   ENDFOR
ENDIF
RELE m.loProperty, m.lii


?"==============================="
?"Update properties to dictionary"
?""
LOCAL m.loProperty
m.loRICDATAU=m.loRICAPI.Dictionary.Get("Grain")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   m.loProperty=m.loRICDATAU.data(1)
   m.loProperty.ric_Order=99
   m.loRICDATAU = m.loRICAPI.Dictionary.Update(m.loProperty)
   IF !m.loRICDATAU.IsOK
      ? "error:", m.loRICDATAU.ErrorMessage    
      =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
   ENDIF
ENDIF
RELEASE m.loProperty



********************************
* Add folders for organization *
********************************
* Note: you do not need to create folders explicitly. Folders are created automatically when you upload 
* reports into them
?"=================="
?"Add folder denarii"
?""
m.loRICDATAU = m.loRICAPI.Folders.Add("denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"========================================================"
?"set access rights to folder 'denarii' for role 'denarii'"
?""
m.loRICDATAU = m.loRICAPI.Folders.AddRights("denarii", "", "denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF




?"======================================="
?"Update folder rights for folder denarii"
?""
m.loRICDATAU = m.loRICAPI.Folders.UpdateRights("denarii", "gt_morgan", "denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"================="
?"Get folder rights"
?""
LOCAL m.loFolderRights, m.lii
m.loRICDATAU = m.loRICAPI.Folders.GetRights("denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" folder's right(s)"
*!*    FOR m.lii = 1 TO m.loRICDATAU.datacount
*!*        m.loUser = m.loRICDATAU.data(m.lii)
*!*        ? ALLTRIM(STR(m.lii))+":",m.loUser.ID, m.loUser.Name+" ("+m.loUser.Roles+")"
*!*    ENDFOR
ENDIF
RELE m.loFolderRights,  m.lii




?"==================="
?"update role denarii"
?""
m.loRICDATAU = m.loRICAPI.Roles.Update("denarii", "ethelred,emma_regina") 
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"========"
?"Get role"
?""
LOCAL m.loRole
m.loRICDATAU = m.loRICAPI.Roles.Get("denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" role(s)"
   m.loRole = m.loRICDATAU.data(1)
   ? m.loRole.RIC_ID, m.loRole.RIC_Name+" ("+m.loRole.RIC_UserList+")"
ENDIF
RELE m.loRole



?"========="
?"Get roles"
?""
LOCAL m.loRole, m.lii
m.loRICDATAU = m.loRICAPI.Roles.GetList()
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" role(s)"
   FOR m.lii = 1 TO m.loRICDATAU.datacount
       m.loRole = m.loRICDATAU.data(m.lii)
       ? ALLTRIM(STR(m.lii))+":",m.loRole.RIC_ID, m.loRole.RIC_Name+" ("+m.loRole.RIC_UserList+")"
   ENDFOR
ENDIF
RELE m.loRole, m.lii


?"====================="
?"Update user gt_morgan"
?""
LOCAL m.loGTMorgan
m.loRICDATAU = m.loRICAPI.Users.Get("gt_morgan")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   m.loGTMorgan=m.loRICDATAU.data(1)

   m.loGTMorgan.RIC_Roles="dollar"
   m.loGTMorgan.RIC_Email="gtmorgan@dollar.com"
   m.loGTMorgan.RIC_RealName = "G.T.Morgan X"
   m.loGTMorgan.RIC_UserName = "gt_morganX"
   *m.loGTMorgan.RIC_Password = "AnnaX"
   m.loGTMorgan.RIC_Language = "cs"
   m.loGTMorgan.RIC_IsAdmin = .T.
   m.loRICDATAU = m.loRICAPI.Users.Update(m.loGTMorgan)
   IF !m.loRICDATAU.IsOK
      ? "error:", m.loRICDATAU.ErrorMessage
      =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
   ENDIF
ENDIF
RELE m.loGTMorgan



?"========="
?"Get users"
?""
LOCAL m.loUser, m.lii
m.loRICDATAU = m.loRICAPI.Users.GetList()
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" user(s)"
   FOR m.lii = 1 TO m.loRICDATAU.datacount
       m.loUser = m.loRICDATAU.data(m.lii)
       ? ALLTRIM(STR(m.lii)),"ID:",m.loUser.RIC_ID, "UserName:",m.loUser.RIC_UserName, "RealName:",m.loUser.RIC_RealName, ;
         "Language:",m.loUser.RIC_Language, "IsAdmin:",m.loUser.RIC_IsAdmin, "Roles:",m.loUser.RIC_Roles, "Email:",m.loUser.RIC_Email
   ENDFOR
ENDIF
RELE m.loUser, m.lii


?"====================="
?"Update user gt_morgan"
?""
LOCAL m.loGTMorgan
m.loRICDATAU = m.loRICAPI.Users.Get("gt_morganX")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   m.loGTMorgan=m.loRICDATAU.data(1)

   m.loGTMorgan.RIC_UserName = "gt_morgan"
   m.loRICDATAU = m.loRICAPI.Users.Update(m.loGTMorgan)
   IF !m.loRICDATAU.IsOK
      ? "error:", m.loRICDATAU.ErrorMessage
      =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
   ENDIF
ENDIF
RELE m.loGTMorgan



************************
* Generate XML and PDF *
************************
SET PATH TO (lcPath+"xfrxdemo") ADDITIVE
SET PROCEDURE TO (m.lcPath+"xfrxdemo\utilityreportlistener") ADDITIVE 
USE (m.lcPath+"xfrxdemo\demoreps\invoices") ORDER CUSTOMER
LOCAL m.loXFRX, m.lnRetVal, m.loXFF, m.loXFRX_T
#IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="9"
 m.loXFRX = EVALUATE([XFRX("XFRX#LISTENER")])
#ELSE
 m.loXFRX = EVALUATE([XFRX("XFRX#INIT")])
#ENDIF 
m.lnRetVal = m.loXFRX.SetParams(,,.T.,,,,"XFF")
IF m.lnRetVal = 0
   #IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="9"
    REPORT FORM (m.lcPath+"xfrxdemo\demoreps\splash") OBJECT m.loXFRX NOPAGEEJECT
    REPORT FORM (m.lcPath+"xfrxdemo\demoreps\invhead") OBJECT m.loXFRX NOPAGEEJECT NORESET
    REPORT FORM (m.lcPath+"xfrxdemo\demoreps\invoices") OBJECT m.loXFRX NORESET 
    m.loXFF=m.loXFRX.oxfDocument
    m.loXFRX.Finalize()
   #ELSE
    m.loXFRX.ProcessReport(m.lcPath+"xfrxdemo\demoreps\splash")
    m.loXFRX.ProcessReport(m.lcPath+"xfrxdemo\demoreps\invhead")
    m.loXFRX.ProcessReport(m.lcPath+"xfrxdemo\demoreps\invoices")
    m.loXFF=m.loXFRX.Finalize()
   #ENDIF

   
   m.loXFRX_T=EVALUATE([XFRX("XFRX#INIT")])

   m.lnRetVal = m.loXFRX_T.SetParams(m.lcPath+"invoices.xml",,.T.,,,,"XML")
   IF m.lnRetVal = 0
      m.loXFRX_T.TransformReport(m.loXFF)
   ENDIF
   m.lnRetVal = m.loXFRX_T.SetParams(m.lcPath+"invoices.pdf",,.T.,,,,"PDF")
   IF m.lnRetVal = 0
      m.loXFRX_T.TransformReport(m.loXFF)
   ENDIF
   m.lnRetVal = m.loXFRX_T.SetParams(m.lcPath+"invoices.xlsx",,.T.,,,,"NATIVE_FXLSX")
   IF m.lnRetVal = 0
      m.loXFRX_T.TransformReport(m.loXFF)
   ENDIF
   m.lnRetVal = m.loXFRX_T.SetParams(m.lcPath+"invoices.docx",,.T.,,,,"NATIVE_DOCX")
   IF m.lnRetVal = 0
      m.loXFRX_T.TransformReport(m.loXFF)
   ENDIF
ENDIF
USE IN "invoices"
RELE m.loXFRX, m.lnRetVal, m.loXFF, m.loXFRX_T


?"========================"
?"Upload report data (XML)"
?""
m.loRICDATAU = m.loRICAPI.Reports.Upload(m.lcPath+"invoices.xml", "denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"=========================="
?"Upload exported file - PDF"
?""
m.loRICDATAU = m.loRICAPI.Reports.UploadExportedFile(m.lcPath+"invoices.pdf", "pdf", "denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"==========================="
?"Upload exported file - DOCX"
?""
m.loRICDATAU = m.loRICAPI.Reports.UploadExportedFile(m.lcPath+"invoices.docx", "docx", "denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"==========================="
?"Upload exported file - XLSX"
?""
m.loRICDATAU = m.loRICAPI.Reports.UploadExportedFile(m.lcPath+"invoices.xlsx", "xlsx", "denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF



?"================="
?"Add report rights"
?""
m.loRICDATAU = m.loRICAPI.Reports.AddRights("denarii/invoices report","ethelred,emma_regina","")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"===================="
?"Update report rights"
?""
m.loRICDATAU = m.loRICAPI.Reports.UpdateRights("denarii/invoices report","ethelred,emma_regina","denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"================="
?"Get report rights"
?""
m.loRICDATAU = m.loRICAPI.Reports.GetRights("denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" report's right(s)"
*!*    FOR m.lii = 1 TO m.loRICDATAU.datacount
*!*        m.loUser = m.loRICDATAU.data(m.lii)
*!*        ? ALLTRIM(STR(m.lii))+":",m.loUser.ID, m.loUser.Name+" ("+m.loUser.Roles+")"
*!*    ENDFOR

ENDIF




?"======================"
?"Update folder property"
?""
*UpdateFolderProperties(m.tcFolderFullPath, m.lcID, m.lcValue)
m.loRICDATAU = m.loRICAPI.Folders.UpdateProperties("denarii","Weight",16)
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Folders.UpdateProperties("denarii","Grain","900/1000")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("Weight",17)
m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("Grain","900/1000")
m.loRICDATAU = m.loRICAPI.Folders.PCache.Flush("denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("P1","aaaaa")
*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("P2","12.3")
*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("P3",DATE())
*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("P4","bbbbb")
*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("P5",DATETIME())
*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Add("P6",.T.)
*!* m.loRICDATAU = m.loRICAPI.Folders.PCache.Flush("denarii")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage    
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF


?"======================"
?"Get folder properties"
?""
LOCAL m.loProperty, m.lii
m.loRICDATAU = m.loRICAPI.Folders.GetProperties("denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
*!*	   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" property(ies)"
*!*	   FOR m.lii = 1 TO m.loRICDATAU.datacount
*!*	       WITH m.loRICDATAU.data(m.lii)       
*!*	       ?.ric_sys_modified, .ric_weight, .ric_grain
*!*	       *!*?.ric_sys_modified, .RIC_P1, .RIC_P2, .RIC_P3, .RIC_P4, .RIC_P5, .RIC_P6
*!*	       ENDWITH
*!*	   ENDFOR
   AMEMBERS(propArray,m.loRICDATAU.data[1])	
   ? ALLTRIM(STR(ALEN(m.propArray)))+" property(ies)"
   FOR lnX = 1 TO ALEN(m.propArray)
	  ? propArray[lnX], m.loRICDATAU.data[1].&propArray[lnX]
   ENDFOR	
   ? m.loRICDATAU.data[1].ric_sys_modified, m.loRICDATAU.data[1].ric_weight, m.loRICDATAU.data[1].ric_grain
ENDIF
RELE m.loProperty, m.lii




?"======================"
?"Update report property"
?""
*UpdateReportProperties(m.tcReportFullPath, m.lcID, m.lcValue)
m.loRICDATAU = m.loRICAPI.Reports.UpdateProperties("denarii/invoices report","InvoiceNo","201509#0125-BAD")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Reports.PCache.Add("CustomerNo","C00121")
m.loRICDATAU = m.loRICAPI.Reports.PCache.Add("InvoiceNo","201509#0125")
m.loRICDATAU = m.loRICAPI.Reports.PCache.Flush("denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"====================="
?"Get report properties"
?""
LOCAL m.loProperty, m.lii
m.loRICDATAU = m.loRICAPI.Reports.GetProperties("denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ELSE
*!*   ? ALLTRIM(STR(m.loRICDATAU.datacount))+" property(ies)"   
*!*	   FOR m.lii = 1 TO m.loRICDATAU.datacount
*!*	       m.loProperty = m.loRICDATAU.data(m.lii)
*!*	       ?m.loProperty.ric_sys_modified, m.loProperty.ric_invoiceno, m.loProperty.ric_CustomerNo
*!*	   ENDFOR
   AMEMBERS(propArray,m.loRICDATAU.data[1])	
   ? ALLTRIM(STR(ALEN(m.propArray)))+" property(ies)"
   FOR lnX = 1 TO ALEN(m.propArray)
	  ? propArray[lnX], m.loRICDATAU.data[1].&propArray[lnX]
   ENDFOR	
   ? m.loRICDATAU.data[1].ric_sys_modified, m.loRICDATAU.data[1].ric_invoiceno, m.loRICDATAU.data[1].ric_CustomerNo
ENDIF
RELE m.loProperty, m.lii


IF MESSAGEBOX("The demo organization has been set up. You can now review the organization online at "+CHR(13)+;
	"https://"+m.lcOrgSubDomain+".reportsincloud.com"+CHR(13)+;
	"(the address was copied to your clipboard)"+CHR(13)+;
	+CHR(13)+;
	"Would you like to continue with the demo?"+CHR(13)+CHR(13)+;
	"If you click yes, the process will delete the demo reports, properties and users it has just created."+CHR(13)+;
	"if you click no, the process will stop and leave the demo data as it is now", 4) <> 6
	RETURN
ENDIF


?"===================="
?"Delete report rights"
?""
m.loRICDATAU = m.loRICAPI.Reports.DeleteRights("denarii/invoices report","","denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"========================"
?"Delete report properties"
?""
m.loRICDATAU = m.loRICAPI.Reports.DeleteProperties("denarii/invoices report","InvoiceNo")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Reports.DeleteProperties("denarii/invoices report","") && Delete all properties
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"=============="
?"Delete report"
?""
m.loRICDATAU = m.loRICAPI.Reports.Delete("denarii/invoices report")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage    
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF



?"=============================================="
?"Drop denarii folders property for organization"
?""
m.loRICDATAU = m.loRICAPI.Folders.DeleteProperties("denarii","Weight")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Folders.DeleteProperties("denarii","") && Delete all properties
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"============================================"
?"Drop denarii folders rights for organization"
?""
m.loRICDATAU = m.loRICAPI.Folders.DeleteRights("denarii","gt_morgan", "denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

?"====================================="
?"Drop folder denarii for organization"
?""
m.loRICDATAU = m.loRICAPI.Folders.Delete("denarii")
IF !m.loRICDATAU.IsOK && the folder does not exist
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF



?"==========================="
?"Drop users for organization"
?""
m.loRICDATAU = m.loRICAPI.Users.Delete("gt_morgan")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Users.Delete("ethelred")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Users.Delete("emma_regina")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Users.Delete("cu")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"==========================="
?"Drop roles for organization"
?""
m.loRICDATAU = m.loRICAPI.Roles.Delete("denarii")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF
m.loRICDATAU = m.loRICAPI.Roles.Delete("dollar")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF


?"==============================="
?"Delete property from dictionary"
?""
m.loRICDATAU = m.loRICAPI.Dictionary.Delete("Grain")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Dictionary.Delete("Weight")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Dictionary.Delete("InvoiceNo")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

m.loRICDATAU = m.loRICAPI.Dictionary.Delete("CustomerNo")
IF !m.loRICDATAU.IsOK
   ? "error:", m.loRICDATAU.ErrorMessage
   =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
ENDIF

*!* m.loRICDATAU = m.loRICAPI.Dictionary.Delete("P1")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Delete("P2")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Delete("P3")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Delete("P4")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Delete("P5")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF
*!* m.loRICDATAU = m.loRICAPI.Dictionary.Delete("P6")
*!* IF !m.loRICDATAU.IsOK
*!*    ? "error:", m.loRICDATAU.ErrorMessage
*!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATAU.ErrorMessage+CHR(13)+CHR(10))
*!* ENDIF


m.loRICST.Close()

*!* *!* ?"======================="
*!* *!* ?"Delete the organization"
*!* *!* ?""
*!* *!* m.loRICDATA = m.loRICAPI.Delete(m.lcOrgID)
*!* *!* IF !m.loRICDATA.IsOK
*!* *!*    ? "error:", m.loRICDATA.ErrorMessage
*!* *!*    =m.loRICAPI.AddToLog("error: "+m.loRICDATA.ErrorMessage+CHR(13)+CHR(10))
*!* *!*    RETURN
*!* *!* ENDIF



**********************************************************************************************
DEFINE CLASS RIC_SecretTable AS CUSTOM
   Name="RIC_SecretTable"
   Alias=""
   File=""

   PROCEDURE Init(m.lcFile)
      *
      * RIC_SecretTable::Init()
      *
      This.File=m.lcFile
      This.Alias=SYS(2015)
   ENDPROC

   PROCEDURE Close()
      *
      * RIC_SecretTable::Close()
      *
      IF USED(This.Alias)
         USE IN (This.Alias)
      ENDIF
   ENDPROC

   PROCEDURE Open()
      *
      * RIC_SecretTable::Open()
      *
      IF FILE(This.File)
         IF !USED(This.Alias)
            USE (This.File) IN 0 ALIAS (This.Alias) AGAIN
         ENDIF
      ELSE   
         This.Create()
      ENDIF
   ENDPROC
   
   PROCEDURE Create()
      *
      * RIC_SecretTable::Create()
      *
      SELECT 0
      CREATE TABLE (This.File) (orgID C(100), orgName C(100), subdomain C(100), Secret C(100))
      USE
      USE (This.File) IN 0 ALIAS (This.Alias) AGAIN
   ENDPROC

   PROCEDURE Get(m.lcOrgSubDomain, m.lcSecret)
      *
      * RIC_SecretTable::Get()
      *
      This.Open()
      
      SELECT (This.Alias)
      LOCATE ALL FOR subDomain = m.lcOrgSubDomain
      IF NOT FOUND()
         RETURN ""
      ENDIF
      m.lcSecret=ALLT(EVALUATE(This.Alias+".Secret"))
      RETURN ALLT(EVALUATE(This.Alias+".orgID"))
   ENDPROC

   PROCEDURE Add(m.lcOrgID, m.lcOrgName, m.lcOrgSubDomain, m.lcSecret)
      *
      * RIC_SecretTable::Add()
      *
      This.Open()
      INSERT INTO (This.Alias) VALUES (m.lcOrgID, m.lcOrgName, m.lcOrgSubDomain, m.lcSecret)
   ENDPROC

ENDDEF

#IF STRTRAN(SUBS(VERSION(),LEN("Visual FoxPro ")+1,2),"0","")="5"
PROCEDURE JUSTPATH(m.lcPath)
 RETURN LEFT(m.lcPath,RAT("\",m.lcPath)-1)
ENDPROC
#ENDIF
