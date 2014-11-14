#include "reportlisteners.h"

**************************************************
*-- Class:        utilityreportlistener (c:\program files\microsoft visual foxpro 9\ffc\_reportlistener.vcx)
*-- ParentClass:  _reportlistener (c:\program files\microsoft visual foxpro 9\ffc\_reportlistener.vcx)
*-- BaseClass:    reportlistener
*-- Time Stamp:   09/14/04 03:59:07 AM
*-- Adds configuration table handling and output target file handling to _reportListener class
*
*
DEFINE CLASS utilityreportlistener AS _reportlistener


	FRXDataSession = -1
	*-- Indicates the conditions under which SetConfiguration code will run. 0=never, 1 = when the class instance Init runs, 2 = when the class instance runs BeforeReport, 3 = at both Init and BeforeReport.
	readconfiguration = (0)
	*-- Provides the default file extension for file output.
	targetfileext = ("TXT")
	*-- Provides the filename to which output will be written.  A unique name is generated for the class instance, which will be overwritten for successive report runs if not adjusted by the user.
	targetfilename = (FORCEPATH(SYS(2015),SYS(2023)))
	*-- Provides a low-level file handle, to which output is written directly when the class provides raw data to the file, otherwise reserves the file during the report run so other applications don't write to it .
	targethandle = -1
	*-- Holds the reserved value used to indicate that a configuration table row provides dynamic configuration information at runtime.
	configurationobjtype = 1000
	*-- Holds a reference to an FRXCursor helper object to aid in run-time calculations related to FRX metadata and structure.
	frxcursor = (NULL)
	*-- Holds the name of the current configuration table.
	PROTECTED configurationtable
	configurationtable = ("")

	*-- Determines whether this class should dynamically load an instance of the helper class FRXCursor when attempting to access a reference to it.
	loadfrxcursor = .F.


	PROCEDURE readconfiguration_assign
		LPARAMETERS vNewVal
		IF VARTYPE(m.vNewVal) = "N" AND NOT THIS.IsRunning
		   THIS.ReadConfiguration = m.vNewVal
		ENDIF   
	ENDPROC


	*-- Checks the current configuration table for dynamic information in records of appropriate type, and executes these instructions if found.
	PROCEDURE setconfiguration
		LPARAMETERS tlCalledFromInit

		IF NOT THIS.IsRunning 
		   * do some config work, don't change sessions --
		   * at this point we don't have our private session
		   * if we're being called in the Init

		   LOCAL liSelect, lcPEM, llOpened, lcOrder, liType, llQuiet
		  
		   liSelect = select(0)

		   IF NOT USED("OutputConfig")
		      * if called from Init, 
		      * do this in quietmode
		      * because the caller has no
		      * opportunity to 
		      * turn off the message
		      llQuiet = (tlCalledFromInit AND NOT THIS.QuietMode)
		      IF llQuiet
		         THIS.QuietMode = .T.
		      ENDIF
		      THIS.GetConfigTable()
		      IF llQuiet
		         THIS.QuietMode = .F.
		      ENDIF
		      USE (THIS.ConfigurationTable) ALIAS "OutputConfig" IN 0 AGAIN NOUPDATE SHARED
		      llOpened = .T.
		   ELSE 
		      lcOrder = ORDER("OutputConfig")
		      SET ORDER TO ObjCode
		   ENDIF

		   IF (NOT THIS.HadError) AND THIS.VerifyConfigTable("OutputConfig")

		      SELECT OutputConfig
		      liType = THIS.ConfigurationObjtype

		      SCAN FOR ObjType = liType AND ;
		            NOT(DELETED() OR ;
		                ObjName == "" OR ;
		                ObjValue =="" )
		          
		         IF PEMSTATUS(THIS,ObjName,5) 
		            lcPEM = UPPER(PEMSTATUS(THIS,ObjName,3))
		            DO CASE
		            CASE lcPEM == "PROPERTY"
		               STORE EVAL(ObjValue) TO ("THIS."+ObjName)
		            CASE INLIST("|"+lcPEM+"|","|METHOD|","|EVENT|")
		               EVAL("THIS."+ObjName+"("+ObjValue+")")
		            OTHERWISE
		            ENDCASE
		          ENDIF

		      ENDSCAN

		      IF llOpened
		         USE IN OutputConfig
		      ELSE
		         SET ORDER TO (lcOrder) IN OutputConfig   
		      ENDIF   

		   ENDIF   

		   SELECT (liSelect)

		ENDIF   
	ENDPROC


	*-- Assesses and provides the name of the current configuration table, optionally creating it on disk if it is not available.
	PROCEDURE getconfigtable
		LPARAMETERS tlForceExternal

		LOCAL lcDBF, lcPath

		lcDBF = ""

		IF tlForceExternal OR FILE(FULLPATH(FORCEEXT(OUTPUTCLASS_EXTERNALDBF,"DBF")))
		   lcDBF = FULLPATH(FORCEEXT(OUTPUTCLASS_EXTERNALDBF,"DBF"))
		ELSE
		   lcDBF = FORCEEXT(OUTPUTCLASS_INTERNALDBF,"DBF")
		ENDIF
		   
		IF NOT (FILE(lcDBF) OR THIS.IsRunning)

		      lcPath = THIS.GetPathForExternals()
		      * this may be the internal *or* external dbf name;
		      * we could be testing and not yet built into an app,
		      * so accept either, before the next test:
		      lcDBF = FORCEPATH(lcDBF,lcPath) 
		      
		      IF NOT FILE(lcDBF)
		         * now force to the external name:
		         lcDBF = FORCEEXT(FORCEPATH(OUTPUTCLASS_EXTERNALDBF,lcPath),"DBF")
		         * now check again
		         IF NOT FILE(lcDBF)
		            THIS.CreateConfigTable(lcDBF)
		            IF FILE(lcDBF)
		               THIS.DoMessage(OUTPUTCLASS_CONFIGTABLECREATED_LOC)
		            ENDIF
		         ENDIF
		      ENDIF

		ENDIF 

		IF NOT FILE(lcDBF)
		   lcDBF = ""
		ENDIF  

		THIS.ConfigurationTable = lcDBF

		RETURN lcDBF
	ENDPROC


	*-- Creates a configuration table on demand.
	PROCEDURE createconfigtable
		LPARAMETERS tcDBF, tlOverWrite
		LOCAL liSelect, lcFile

		lcFile = FORCEEXT(tcDBF,"DBF")

		IF FILE(lcFile) AND tlOverWrite
		   ERASE (lcFile) RECYCLE
		   ERASE (FORCEEXT(lcFile,"FPT")) RECYCLE
		   ERASE (FORCEEXT(lcFile,"CDX")) RECYCLE   
		ENDIF   

		liSelect = select(0)

		SELECT 0

		CREATE TABLE (lcFile) FREE ;
		   (objtype i, ;
		    objcode i, ;
		    objname v(60), ;
		    objvalue v(60), ;
		    objinfo m)

		IF NOT EMPTY(ALIAS()) && can happen if SAFETY ON and they decide not to overwrite    

		   INDEX ON Objtype TAG ObjType
		   INDEX ON ObjCode TAG ObjCode
		   INDEX ON ObjName TAG ObjName
		   INDEX ON ObjValue TAG ObjValue
		   INDEX ON DELETED() TAG OnDeleted    
		   
		   INSERT INTO (ALIAS()) VALUES ;
		      (OUTPUTCLASS_OBJTYPE_CONFIG,0,'DoMessage','"Welcome to the demo run!",64','Sample initialization/config method call')
		   DELETE NEXT 1

		   INSERT INTO (ALIAS()) VALUES ;
		     (OUTPUTCLASS_OBJTYPE_CONFIG,0,'TargetFileName','"xxx"','Sample initialization/config property')
		   DELETE NEXT 1
		   USE
		   
		ENDIF   

		SELECT (liSelect)   
	ENDPROC


	*-- Initializes a file for output purposes.
	PROTECTED PROCEDURE opentargetfile
		   THIS.VerifyTargetFile() 

		   THIS.TargetHandle = FCREATE(THIS.TargetFileName)
		 
		   IF THIS.TargetHandle < 0 OR THIS.HadError
		      THIS.HadError = .T.
		      THIS.DoMessage(OUTPUTCLASS_NOFILECREATE_LOC,MB_ICONSTOP )
		   ENDIF

		RETURN (NOT THIS.HadError)
		     
	ENDPROC


	*-- Assures that the nominated filename and its network location are available at the beginning of a file-based report run.
	PROCEDURE verifytargetfile
		LOCAL lcFile

		lcFile =  ALLTR(CHRTRAN(THIS.TargetFileName,;
		                       OUTPUTCLASS_FILENAME_CHARS_DISALLOWED,"_"))

		IF NOT DIRECTORY(JUSTPATH(lcFile))
		   lcFile = FULLPATH(ALLTR(lcFile))
		ENDIF   

		IF DIRECTORY(lcFile)
		   * we have to generate a filename
		   lcFile = FORCEPATH(SYS(2015), lcFile)
		ENDIF

		THIS.TargetFileName = lcFile   

		IF JUSTEXT(THIS.TargetFileName) == "" AND ;
		   RIGHT(THIS.TargetFileName,1) # "."      

		   THIS.TargetFileExt = CHRTRAN(THIS.TargetFileExt,;
		                        OUTPUTCLASS_FILENAME_CHARS_DISALLOWED,"_")

		   THIS.TargetFileName = FORCEEXT(THIS.TargetFileName, ;
		                                    THIS.TargetFileExt)
		ENDIF                                 
		 
		IF FILE(THIS.TargetFileName)
		   ERASE (THIS.TargetFileName) NORECYCLE
		ENDIF
	ENDPROC


	PROCEDURE targetfileext_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "C" AND NOT THIS.IsRunning
		   THIS.targetfileext = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE targetfilename_assign
		LPARAMETERS vNewVal
		IF VARTYPE(m.vNewVal) = "C" AND NOT THIS.IsRunning
		   THIS.targetfilename = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE targethandle_assign
		LPARAMETERS vNewVal
		* Readonly during report run
		IF VARTYPE(m.vNewVal) = "N" AND NOT THIS.IsRunning
		   THIS.targethandle = m.vNewVal
		ENDIF   
	ENDPROC


	*-- Finalizes file output.
	PROTECTED PROCEDURE closetargetfile
		   LOCAL laDummy[1]
		     
		   IF THIS.TargetHandle > -1    

		      =FCLOSE(THIS.TargetHandle)
		      THIS.TargetHandle = -1
		     
		      IF ADIR(laDummy,THIS.TargetFileName) = 1 AND ;
		         laDummy[1,2] > 0
		         * NB: have to check this as well as
		         * error because some COM errors may not
		         * end up in THIS.HadError.
		          * if continuation, update status rather than
		          * modal message
		         IF THIS.HadError
		            THIS.DoMessage(OUTPUTCLASS_CREATEERRORS_LOC,MB_ICONEXCLAMATION  )
		        ELSE
		            IF THIS.DoMessage( OUTPUTCLASS_SUCCESS_LOC + ;
		                            IIF(SYS(2024)="Y",CHR(13)+OUTPUTCLASS_REPORT_INCOMPLETE_LOC,""),;
		                            MB_ICONINFORMATION + MB_YESNO ) = IDYES
		               _CLIPTEXT = THIS.TargetFileName
		            ENDIF
		         ENDIF
		      ELSE
		         THIS.DoMessage(OUTPUTCLASS_NOCREATE_LOC,MB_ICONSTOP )
		       
		      ENDIF                 
		     
		   ENDIF
	ENDPROC


	*-- Ascertains that the format and and contents of the configuration meet requirements, adjusting it if necessary.
	PROCEDURE verifyconfigtable
		LPARAMETERS tcAlias, tcFailureMsgTable, tcFailureMsgIndexes

		IF EMPTY(tcAlias) OR VARTYPE(tcAlias) # "C"
		   RETURN .F.
		ENDIF
		LOCAL lcTable, lcMessage, lcAlias, liSelect, ;
		      llReturn, liTagCount ,laRequired[1], laKeys[1], ;
		      liFound, llExactOff, llSafetyOn

		llReturn = ;
		       TYPE(tcAlias+".OBJTYPE") = "N" AND ;
		       TYPE(tcAlias+".OBJCODE") = "N" AND ;  
		       TYPE(tcAlias+".OBJNAME") = "C" AND ;
		       TYPE(tcAlias+".OBJVALUE") = "C" AND ;
		       TYPE(tcAlias+".OBJINFO") = "M" 
		       
		* additional fields may be included and order
		* is not significant
		       
		IF NOT llReturn
		   
		   lcMessage = IIF(EMPTY(tcFailureMsgTable),;
		                         OUTPUTCLASS_CONFIGTABLEWRONG_LOC, ;
		                         tcFailureMsgTable)  + ;
		               CHR(13)+CHR(13)+ ;
		               DBF(tcAlias)
		ENDIF   


		IF llReturn

		   IF (SET("EXACT") = "OFF")
		      SET EXACT ON
		      llExactOff = .T.
		   ENDIF
		   
		   liSelect = select(0)
		   SELECT (tcAlias)

		   * check for required keys...

		   DIME laRequired[5]
		   laRequired[1] = "OBJTYPE"
		   laRequired[2] = "OBJCODE"
		   laRequired[3] = "OBJNAME"
		   laRequired[4] = "OBJVALUE"
		   laRequired[5] = "DELETED()"   

		   IF TAGCOUNT() > 0
		      DIME laKeys[TAGCOUNT()]

		      FOR liTagCount = 1 TO TAGCOUNT()
		          laKeys[liTagCount] = UPPER(KEY(liTagCount))
		      ENDFOR
		   
		      FOR liTagCount = 1 TO ALEN(laRequired)
		         liFound = ASCAN(laKeys,UPPER(laRequired[liTagCount]))
		         IF liFound = 0
		            llReturn = .F.
		            EXIT
		         ENDIF
		      ENDFOR
		   ELSE
		      llReturn = .F.
		   ENDIF      
		   
		   IF NOT llReturn
		   
		     llSafetyOn = (SET("SAFETY") = "ON")
		     SET SAFETY OFF
		   
		     TRY
		         USE (DBF(tcAlias)) EXCLU ALIAS (tcAlias)
		         INDEX ON Objtype TAG ObjType
		         INDEX ON ObjCode TAG ObjCode
		         INDEX ON ObjName TAG ObjName
		         INDEX ON ObjValue TAG ObjValue
		         INDEX ON DELETED() TAG OnDeleted    
		         llReturn = .T.
		      CATCH
		      ENDTRY   
		      
		      IF llSafetyOn
		         SET SAFETY OFF
		      ENDIF
		      
		      IF llReturn
		         DIME laKeys[TAGCOUNT()]

		         FOR liTagCount = 1 TO TAGCOUNT()
		             laKeys[liTagCount] = UPPER(KEY(liTagCount))
		         ENDFOR
		   
		         FOR liTagCount = 1 TO ALEN(laRequired)
		            liFound = ASCAN(laKeys,UPPER(laRequired[liTagCount]))
		            IF liFound = 0
		               llReturn = .F.
		               EXIT
		            ENDIF
		         ENDFOR
		      ENDIF

		      USE (DBF(tcAlias)) SHARED ALIAS (tcAlias)
		   
		   ENDIF
		   
		   IF NOT llReturn
		      lcMessage =  IIF(EMPTY(tcFailureMsgIndexes),;
		                         OUTPUTCLASS_CONFIGINDEXMISSING_LOC, ;
		                         tcFailureMsgTable) + CHR(13) 
		      FOR liTagCount = 1 TO ALEN(laRequired)
		          lcMessage = lcMessage +  CHR(13) + ;
		                      laRequired[liTagCount] 
		      ENDFOR
		   ENDIF
		   
		   IF llExactOff
		      SET EXACT OFF
		   ENDIF
		   SELECT (liSelect) 

		ENDIF

		IF NOT(llReturn)
		   THIS.DoMessage(lcMessage,MB_ICONSTOP )
		ENDIF   

		RETURN llReturn       

		   
	ENDPROC

	*-- Determines the location at which the current configuration table and any other required external files will be expected.
	PROCEDURE getpathforexternals
		* this is  mostly for standalone use
		* first figure out where to put it
		* with the idea of not littering
		* the disk too much based on CURDIR().
		   
		* For app pieces, look for a container module
		* and put it there.
		* if there isn't one,
		* put it with the VCX


		      
		LOCAL liLevel, lcSys16, lcPath
		      
		FOR liLevel = PROGRAM(-1) TO 1 STEP -1
		   lcSys16 = UPPER(SYS(16,liLevel))
		   IF INLIST(RIGHT(lcSys16,3),"APP","EXE","DLL")
		      lcPath = JUSTPATH(lcSys16)
		      EXIT
		   ENDIF
		ENDFOR
		      
		IF EMPTY(lcPath)
		   lcPath = JUSTPATH(THIS.ClassLibrary)
		ENDIF
		IF NOT DIRECTORY(lcPath)
		   lcPath = ""
		ENDIF

		RETURN lcPath
	ENDPROC


	PROCEDURE configurationobjtype_access
		* readonly property
		   
		RETURN OUTPUTCLASS_OBJTYPE_CONFIG
	ENDPROC


	PROCEDURE Init
		IF DODEFAULT()

		   IF INLIST(THIS.ReadConfiguration,;
		                  OUTPUTCLASS_READCONFIG_INIT,;
		                  OUTPUTCLASS_READCONFIG_BOTH)
		     THIS.SetConfiguration(.T.)
		   ENDIF   

		ELSE

		   RETURN .F.   

		ENDIF

		RETURN NOT THIS.HadError
	ENDPROC


	PROCEDURE Destroy
		THIS.CloseTargetFile()
		STORE NULL TO THIS.FRXCursor
		DODEFAULT()
	ENDPROC


	PROCEDURE setfrxdatasessionenvironment
		DODEFAULT()
		SET DELETED ON
		SET EXCLUSIVE OFF
		SET TALK OFF
	ENDPROC


	PROCEDURE BeforeReport
		DODEFAULT()

		 IF INLIST(THIS.ReadConfiguration,;
		                  OUTPUTCLASS_READCONFIG_REPORT,;
		                  OUTPUTCLASS_READCONFIG_BOTH)
		     THIS.SetConfiguration()
		ENDIF   
	ENDPROC


ENDDEFINE
*
*-- EndDefine: utilityreportlistener
**************************************************

**************************************************
*-- Class:        _reportlistener (c:\program files\microsoft visual foxpro 9\ffc\_reportlistener.vcx)
*-- ParentClass:  reportlistener
*-- BaseClass:    reportlistener
*-- Time Stamp:   09/14/04 12:19:02 AM
*-- Adds error handling, session handling, and other common report run-time tasks to ReportListener base class.
*-- Provides the ability to chain a series of reports as well as the means to delegate or share output activities to a chain of Listener-successors.
*
*
DEFINE CLASS _reportlistener AS reportlistener


	Height = 23
	Width = 23
	FRXDataSession = -1
	AllowModalMessages = (INLIST(_VFP.Startmode, 0, 4))
	QuietMode = (NOT INLIST(_VFP.Startmode, 0, 4))
	*-- Localizable application name string for use in user feedback.
	appname = ("VFP Report Listener")
	PROTECTED lasterrormessage
	lasterrormessage = ("")
	*-- Stores the filenames of reports to be managed and executed in a series.
	PROTECTED reportfilenames
	reportfilenames = .NULL.
	*-- Stores REPORT FORM command clauses associated with each report in the ReportFileNames collection.
	PROTECTED reportclauses
	reportclauses = .NULL.
	*-- Collection of ReportListeners associated with each report in this Listener's ReportFileNames collection.
	PROTECTED listeners
	listeners = .NULL.
	*-- Saves the DataSessionID in which the Listener originated.
	PROTECTED listenerdatasession
	listenerdatasession = 1
	*-- An object reference to the next Listener in a succession chain.
	successor = (.NULL.)
	*-- Provides a readwrite copy of the the Engine's GDIPlusGraphics handle which the Listener can share with a succession chain.
	sharedgdiplusgraphics = 0
	*-- Shares information gathered by the GetPageHeight method with other Listeners linked in a succession chain.
	sharedpageheight = 0
	*-- Shares information gathered by the GetPageWidth method with other Listeners linked in a succession chain.
	sharedpagewidth = 0
	*-- Holds the alias of the table or cursor driving the report scope.
	PROTECTED drivingalias
	drivingalias = ("")
	*-- XML Metadata for customizable properties
	sharedoutputpagecount = 0
	*-- Provides a readwrite copy of the the Engine's PageNo property which the Listener can share with a succession chain.
	sharedpageno = 0
	*-- Provides a readwrite copy of the the Engine's PageTotal property which the Listener can share with a succession chain.
	sharedpagetotal = 0
	Name = "_reportlistener"

	*-- Provides a flag to determine how this class handles activities subsequent to an error.
	lignoreerrors = .F.

	*-- Provides a flag indicating whether an error occurred.
	PROTECTED haderror

	*-- Provides a flag to indicate whether a report run is underway.  When IsRunning is true, the class may wish to disallow certain activities or method calls.
	PROTECTED isrunning

	*-- Provides a flag to indicate this ReportListener is running a series of reports using its collection.
	PROTECTED isrunningreports

	*-- Provides a flag to indicate whether this report shares the data session from which it was executed or maintains a private data session.
	reportusesprivatedatasession = .F.

	*-- Indicates whether this Listener is chained to one or more others to provide output during a report run.  When .T., this Listener was not the object referenced in the REPORT FORM command OBJECT clauses.
	issuccessor = .F.

	*-- Holds the page count for each report when this Listener runs a collection of reports as a series.
	PROTECTED reportpages[1]


	PROCEDURE allowmodalmessages_assign
		LPARAMETERS vNewVal
		IF VARTYPE(m.vNewVal) = "L"
		   THIS.AllowModalMessages = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE lignoreerrors_assign
		LPARAMETERS vNewVal
		IF VARTYPE(m.vNewVal) = "L"
		   THIS.lIgnoreErrors = m.vNewVal
		ENDIf   
	ENDPROC


	*-- Organizes common error information values (nError, cMethod, nLine, cName, cMessage, cCodeLine) into a coherent string for presentation to the user.
	PROCEDURE prepareerrormessage
		LPARAMETERS nError, cMethod, nLine, cName, cMessage, cCodeLine

		LOCAL lcErrorMessage, lcCodeLineMsg

		IF VARTYPE(cMessage) = "C"
		   lcErrorMessage = cMessage
		ELSE
		   lcErrorMessage = MESSAGE()
		ENDIF

		lcErrorMessage = lcErrorMessage + CHR(13) + CHR(13)

		IF VARTYPE(cName) = "C"
		   lcErrorMessage = lcErrorMessage + cName
		ELSE
		   lcErrorMessage = lcErrorMessage + this.Name
		ENDIF

		lcErrorMessage = lcErrorMessage + CHR(13)+ ;
		 		 OUTPUTCLASS_ERRNOLABEL_LOC +ALLTRIM(STR(nError))+CHR(13)+ ;
				 OUTPUTCLASS_ERRPROCLABEL_LOC +LOWER(ALLTRIM(cMethod))

		IF VARTYPE(cCodeLine) = "C"
		   lcCodeLineMsg = cCodeLine
		ELSE
		   lcCodeLineMsg = MESSAGE(1)
		ENDIF

		IF BETWEEN(nLine,1,100000) AND NOT lcCodeLineMsg="..."
			lcErrorMessage= ;
		       lcErrorMessage+CHR(13)+ OUTPUTCLASS_ERRLINELABEL_LOC+ ;
			    ALLTRIM(STR(nLine))
			IF NOT EMPTY(lcCodeLineMsg)
		       lcErrorMessage= ;
				   lcErrorMessage+CHR(13)+CHR(13)+lcCodeLineMsg
			ENDIF
		ENDIF

		RETURN lcErrorMessage
	ENDPROC


	*-- Provides a hook for Listeners to save global settings not scoped to a data session for later restoration with PopGlobalSets.
	PROTECTED PROCEDURE pushglobalsets
		  * abstract: set any globals here that aren't session-bound
	ENDPROC


	*-- Provides a hook for Listeners to restore global settings not scoped to a data session after saving them with PushGlobalSets.
	PROTECTED PROCEDURE popglobalsets
		* abstract: restore any globals here that aren't session-bound      
	ENDPROC


	*-- Resets the class's error status.
	PROCEDURE clearerrors
		THIS.HadError = .F.
		THIS.LastErrorMessage = ""
	ENDPROC


	*-- Provides information about the last error that occurred.
	PROCEDURE getlasterrormessage
		RETURN THIS.LastErrorMessage
	ENDPROC


	*-- Adds to the class's collection of ReportFileNames, optionally associating REPORT FORM clauses and a listener for the specified report.
	PROCEDURE addreport
		LPARAMETERS tcFRXName, tcClauses, toListener

		* can this one be done while report is running?
		* Possibly yes because we're always adding to the end.

		IF VARTYPE(tcFrxName) = "C" AND ;
		   (FILE(tcFRXName) OR FILE(FORCEEXT(tcFRXName,"FRX")) OR FILE(FORCEEXT(tcFRXName,"LBX")))

		   * If any is null, create all collections
		   * always add to all three collections
		   * to keep them in synch
		   
		   IF ISNULL(THIS.ReportFileNames) OR ;
		      ISNULL(THIS.ReportClauses) OR ;
		      ISNULL(THIS.Listeners) 
		      * start fresh
		      THIS.ReportFileNames = CREATEOBJECT("Collection")
		      THIS.ReportClauses = CREATEOBJECT("Collection")
		      THIS.Listeners = CREATEOBJECT("Collection")
		      DIME THIS.ReportPages[1]
		   ENDIF
		   
		   THIS.ReportFileNames.Add(tcFRXName)
		   
		   DIME THIS.ReportPages[THIS.ReportFileNames.Count]
		   THIS.ReportPages[THIS.ReportFileNames.Count] = 0

		   IF VARTYPE(tcClauses) = "C"
		      THIS.ReportClauses.Add(tcClauses)
		   ELSE
		      THIS.ReportClauses.Add("")   
		   ENDIF

		   IF TYPE("toListener.BaseClass") = "C" AND ;
		      UPPER(toListener.BaseClass) == "REPORTLISTENER"
		      THIS.Listeners.Add(toListener)
		   ELSE
		      THIS.Listeners.Add(NULL)      
		   ENDIF
		   
		ELSE

		   * TBD: should we error here?   
		   
		ENDIF   
	ENDPROC


	*-- Removes report filenames as well as associated clauses and listeners from this Listeners' various collections.
	PROCEDURE removereports
		IF NOT (THIS.IsRunningReports)
		   THIS.ReportFileNames = NULL
		   THIS.ReportClauses = NULL
		   THIS.Listeners = NULL
		   DIME THIS.ReportPages[1]
		   THIS.ReportPages[1] = 0
		   
		ENDIF   
	ENDPROC


	*-- Executes a series of REPORT FORM commands according to the instructions in the ReportFileNames, ReportClauses, and Listeners collections.  Optionally clears collection after run and issues the REPORT FORM commands without OBJECTreferences.
	PROCEDURE runreports
		LPARAMETERS tlRemoveReportsAfterRun, tlOmitListenerReferences

		IF NOT ;
		 (THIS.IsRunningReports OR ;
		  ISNULL(THIS.ReportFileNames) OR ;
		  THIS.ReportFileNames.Count = 0)

		  LOCAL oError, liIndex, lcClauses, loListener
		  oError = NULL

		  THIS.IsRunningReports = .T.

		  TRY 
		  
		    FOR liIndex = 1 TO THIS.ReportFileNames.Count
		       * these collections are 
		       * protected properties, we're
		       * taking care of how they match up, 
		       * that FRXs exist, etc.
		       lcClauses = UPPER(THIS.ReportClauses[liIndex])
		       loListener = THIS.Listeners[liIndex]
		       DO CASE 
		       CASE " OBJE " $ STRTRAN(" "+lcClauses,"CT", " ") OR ;
		            " OBJEC " $ " "+lcClauses OR ;
		            tlOmitListenerReferences
		          REPORT FORM (THIS.ReportFileNames[liIndex]) &lcClauses  
		       CASE ISNULL(loListener)
		          REPORT FORM (THIS.ReportFileNames[liIndex]) &lcClauses  OBJECT THIS
		       OTHERWISE
		          REPORT FORM (THIS.ReportFileNames[liIndex]) &lcClauses  OBJECT loListener
		       ENDCASE
		       IF NOT (" NOWA " $ STRTRAN(" "+lcClauses,"IT"," ") OR ;
		               " NOWAI " $ " " + lcClauses) 
		          THIS.ReportPages[liIndex] = THIS.SharedPageTotal
		          * TBD: make this a two-column array with 
		          * output pages (responsive to RANGE clause)
		          * represented as well?
		       ENDIF
		    ENDFOR
		    
		         
		  CATCH TO oError
		     IF NOT (ISNULL(oError))
		         THIS.DoMessage(;
		               THIS.PrepareErrorMessage(;
		               oError.ErrorNo, ;
		               oError.PROCEDURE, ;
		               oError.LINENO, ;
		               THIS.AppName, ;
		               oError.MESSAGE, ;
		               oError.LineContents), ;
		               MB_ICONSTOP )
		        #IF OUTPUTCLASS_DEBUGGING
		         SUSPEND
		        #ENDIF                   
		         EXIT  
		      ENDIF
		  FINALLY
		  
		     THIS.IsRunningReports = .F.  
		     IF tlRemoveReportsAfterRun
		       THIS.RemoveReports()
		     ENDIF  
		     STORE NULL TO loListener, oError

		  ENDTRY
		  
		  
		ENDIF   
	ENDPROC


	*-- Provides a hook for classes to determine the datasession-scoped SETs they wish to add to the private FRX data session.
	PROTECTED PROCEDURE setfrxdatasessionenvironment
		THIS.setFRXDataSession()
		SET TALK OFF 
	ENDPROC


	*-- Provides a hook for listeners to evaluate whether they wish to generate output or perform other actions during the current report execution pass.
	PROCEDURE invokeoncurrentpass
		RETURN .T.
	ENDPROC


	*-- Sets the DataSessionID to the session where the Listener originated.
	PROTECTED PROCEDURE resetdatasession
		IF (THIS.listenerDataSession > -1) 

		   TRY
		      SET DATASESSION TO (THIS.listenerDataSession)
		   CATCH WHEN .T.
		      THIS.ResetToDefault("listenerDataSession")
		   ENDTRY
		   
		ENDIF   
	ENDPROC


	*-- Sets the DataSessionID to the data session in which the Engine has opened a readonly copy of the report file as a table for the Listener's use.
	PROTECTED PROCEDURE setfrxdatasession
		IF (THIS.FRXDataSession > -1) AND (THIS.FRXDataSession # SET("DATASESSION"))

		   TRY
		      SET DATASESSION TO (THIS.FRXDataSession)
		   CATCH WHEN .T.
		      THIS.ResetToDefault("FRXDataSession")
		   ENDTRY
		   
		ENDIF   
	ENDPROC


	*-- Sets the DataSessionID to the data session holding report's data tables.
	PROTECTED PROCEDURE setcurrentdatasession
		IF (THIS.CurrentDataSession # SET("DATASESSION"))
		   TRY
		      SET DATASESSION TO (THIS.CurrentDataSession)
		   CATCH WHEN .T.
		      THIS.ResetToDefault("CurrentDataSession")
		   ENDTRY
		ENDIF   
	ENDPROC


	PROCEDURE quietmode_assign
		LPARAMETERS vNewVal
		IF VARTYPE(m.vNewVal) = "L"
		   THIS.quietmode = m.vNewVal
		ENDIF 
	ENDPROC


	PROCEDURE issuccessor_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "L"
		   THIS.isSuccessor = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE successor_assign
		LPARAMETERS vNewVal
		IF (NOT THIS.IsRunning) AND ;
		   (ISNULL(vNewVal) OR ;
		   (VARTYPE(vNewVal) = "O" AND UPPER(vNewVal.BaseClass) == "REPORTLISTENER"))
		   THIS.Successor = m.vNewVal
		ENDIF   
	ENDPROC


	*-- Provides a hook for gathering FRX information during BeforeReport method processing.
	PROTECTED PROCEDURE getfrxstartupinfo
		THIS.SetFRXDataSession()
		IF USED("FRX")
		   SELECT FRX
		   LOCATE FOR ObjType = FRX_OBJTYP_DATAENV 
		   THIS.ReportUsesPrivateDataSession = Frx.Environ
		   * could also use 
		   * THIS.CommandClauses.StartDataSession # THIS.CurrentDataSession
		ELSE
		   THIS.ReportUsesPrivateDataSession = .F.   
		ENDIF   
		THIS.SetCurrentDataSession()
		IF THIS.reportUsesPrivateDataSession
		   SET TALK OFF
		ENDIF
		THIS.DrivingAlias = UPPER(ALIAS())
	ENDPROC


	*-- Provides a hook for the Listener to share information changed by the Engine with a succession of Listeners, during the run of a report.
	PROCEDURE setsuccessordynamicproperties
		IF NOT THIS.isSuccessor
		   THIS.sharedOutputPageCount = THIS.OutputPageCount
		   THIS.sharedPageTotal = THIS.PageTotal
		   THIS.sharedPageNo = THIS.PageNo
		   THIS.sharedGdiplusGraphics = THIS.GDIPlusGraphics 
		ENDIF
		WITH THIS.Successor
		   .CurrentPass = THIS.CurrentPass
		   .TwoPassProcess = THIS.TwoPassProcess   
		   .sharedOutputPageCount = THIS.sharedOutputPageCount
		   .sharedPageTotal = THIS.sharedPageTotal   
		   .sharedPageNo = THIS.sharedPageNo
		   .sharedGdiplusGraphics  = THIS.sharedGdiplusGraphics
		ENDWITH   
	ENDPROC


	PROCEDURE appname_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "C"
		   THIS.appname = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE sharedgdiplusgraphics_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N"
		   THIS.SharedGDIplusGraphics = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE sharedpageheight_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N"
		   THIS.sharedPageHeight = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE sharedpagewidth_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N"
		   THIS.sharedPageWidth = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE listenertype_assign
		LPARAMETERS vNewVal
		IF THIS.SupportsListenerType(vNewVal) AND ;
		   NOT THIS.IsRunning
		   THIS.ListenerType = m.vNewVal
		ENDIF
	ENDPROC


	PROCEDURE outputtype_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N" AND NOT THIS.IsRunning
		   THIS.OutputType = INT(m.vNewVal)
		   IF THIS.SupportsListenerType(THIS.OutputType) 
		      THIS.ListenerType = THIS.OutputType
		   ENDIF    
		ENDIF
	ENDPROC


	*-- Provides a readwrite copy of the the Engine's OutputPageCount property which the Listener can share with a succession chain.
	PROCEDURE sharedoutputpagecount_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N"
		   THIS.sharedOutputPageCount = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE sharedpageno_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N"
		   THIS.sharedPageNo = m.vNewVal
		ENDIF   
	ENDPROC


	PROCEDURE sharedpagetotal_assign
		LPARAMETERS vNewVal
		IF VARTYPE(vNewVal) = "N"
		   THIS.sharedPageTotal = m.vNewVal
		ENDIF   
	ENDPROC


	*-- Hook method called in BeforeReport, allowing you to set up CommandClauses properties or other attributes required by your class.
	PROTECTED PROCEDURE setfrxrunstartupconditions
		IF ISNULL(THIS.CommandClauses)
		   THIS.CommandClauses = CREATEOBJECT("Empty")
		ENDIF
		IF TYPE("THIS.CommandClauses.NoDialog") # "L"
		   ADDPROPERTY(THIS.CommandClauses,"NoDialog",.F.)
		ENDIF      


		* add anything critical during a run
		* that might not be available, whether
		* because this is a custom attribute
		* or because public methods of ReportListener
		* might be called outside a normal report run.
	ENDPROC


	PROCEDURE DoStatus
		LPARAMETERS cMessage
		NODEFAULT
		IF NOT (THIS.QuietMode OR (THIS.IsRunning AND THIS.CommandClauses.Nodialog))
		   IF THIS.TwoPassProcess AND THIS.CurrentPass = 0
		      WAIT WINDOW NOWAIT OUTPUTCLASS_PREPSTATUS_LOC 
		   ELSE
		      IF VARTYPE(cMessage) = "C"
		         DODEFAULT(cMessage)      
		      ENDIF
		   ENDIF
		ENDIF
	ENDPROC


	PROCEDURE LoadReport
		THIS.clearErrors()

		THIS.setFRXDataSessionEnvironment()

		THIS.resetDataSession()
		   
		IF NOT ISNULL(THIS.Successor)
		   WITH THIS.Successor
		      .AddProperty("IsSuccessor",.T.)
		      .OutputType = THIS.OutputType
		      .PrintJobName = THIS.PrintJobName 
		      .CommandClauses = THIS.CommandClauses
		      .LoadReport()
		   ENDWITH
		ENDIF
		   
	ENDPROC


	PROCEDURE ClearStatus
		DODEFAULT()
		IF NOT ISNULL(THIS.Successor)
		   THIS.SetSuccessorDynamicProperties()
		   THIS.Successor.ClearStatus()
		ENDIF   
	ENDPROC


	PROCEDURE UpdateStatus
		DODEFAULT()
		IF NOT ISNULL(THIS.Successor)
		   THIS.SetSuccessorDynamicProperties()
		   THIS.Successor.UpdateStatus()
		ENDIF   
	ENDPROC


	PROCEDURE UnloadReport
		IF NOT THIS.IsSuccessor
		   THIS.SharedPageWidth = THIS.GetPageWidth()
		   THIS.SharedPageHeight = THIS.GetPageHeight()
		ENDIF

		THIS.resetDataSession()

		IF NOT ISNULL(THIS.Successor)

		   WITH THIS.Successor
		      .FRXDataSession = THIS.FRXDataSession
		      .CurrentDataSession = THIS.CurrentDataSession
		      .TwoPassProcess = THIS.TwoPassProcess
		      .CommandClauses = THIS.CommandClauses
		      .SharedPageHeight = THIS.SharedPageHeight
		      .SharedPageWidth = THIS.SharedPageWidth
		      THIS.SetSuccessorDynamicProperties()      
		      .UnloadReport()
		      .IsSuccessor = .F.
		   ENDWITH
		   
		ENDIF
	ENDPROC


	PROCEDURE CancelReport
		IF NOT THIS.IsSuccessor
		   DODEFAULT()
		   NODEFAULT
		ENDIF   
		IF NOT ISNULL(THIS.Successor)
		   THIS.SetSuccessorDynamicProperties()
		   THIS.Successor.CancelReport()
		ENDIF
	ENDPROC


	PROCEDURE AfterReport
		IF NOT THIS.IsSuccessor
		   THIS.SharedPageWidth = THIS.GetPageWidth()
		   THIS.SharedPageHeight = THIS.GetPageHeight()
		ENDIF

		IF NOT ISNULL(THIS.Successor)
		   WITH THIS.Successor
		      .FRXDataSession = THIS.FRXDataSession
		      .CurrentDataSession = THIS.CurrentDataSession
		      .TwoPassProcess = THIS.TwoPassProcess
		      .CommandClauses = THIS.CommandClauses
		      .SharedPageHeight = THIS.SharedPageHeight
		      .SharedPageWidth = THIS.SharedPageWidth
		      THIS.SetSuccessorDynamicProperties()
		      .AfterReport()
		   ENDWITH
		ENDIF
		IF NOT THIS.IsSuccessor
		   NODEFAULT
		   DODEFAULT()
		ENDIF   
	ENDPROC


	PROCEDURE Init
		THIS.listenerDataSession = SET("DATASESSION")  

		IF DODEFAULT() 
		   THIS.AppName = OUTPUTCLASS_APPNAME_LOC
		ELSE
		   RETURN .F.
		ENDIF      

		RETURN NOT THIS.HadError
	ENDPROC


	PROCEDURE BeforeBand
		LPARAMETERS nBandObjCode, nFRXRecNo

		IF NOT ISNULL(THIS.Successor)
		   THIS.SetSuccessorDynamicProperties()
		   THIS.Successor.BeforeBand(nBandObjCode, nFRXRecNo)
		ENDIF
	ENDPROC


	PROCEDURE DoMessage
		LPARAMETERS cMessage,iParams,cTitle
		NODEFAULT
		IF THIS.QuietMode OR ;
		  (THIS.IsRunning AND THIS.CommandClauses.NoDialog)
		   * to emulate the base class behavior, do both checks,
		   * in case the call to DoMessage() occurs
		   * before the baseclass sets QuietMode .T. in response
		   * to NoDialog at the beginning of the report run,
		   * or after the baseclass re-sets Quietmode to .F.
		   * at the end of the report run.
		   RETURN 0
		ELSE
		   IF THIS.AllowModalMessages
		      IF VARTYPE(cTitle) = "C"
		         RETURN MESSAGEBOX(TRANS(cMessage),VAL(TRANS(iParams)),cTitle)
		      ELSE
		         RETURN MESSAGEBOX(TRANS(cMessage),VAL(TRANS(iParams)),THIS.AppName)
		      ENDIF
		   ELSE
		      THIS.DoStatus(cMessage)
		      RETURN 0
		   ENDIF
		ENDIF   
	ENDPROC

	PROCEDURE Error
		LPARAMETERS nError, cMethod, nLine
		LOCAL lcOnError,lcErrorMsg,lcCodeLineMsg
		THIS.HadError = .T.
		IF this.lIgnoreErrors OR _vfp.StartMode>0
			RETURN .F.
		ENDIF
		lcOnError=UPPER(ALLTRIM(ON("ERROR")))
		IF NOT EMPTY(lcOnError)
			lcOnError=STRTRAN(STRTRAN(STRTRAN(lcOnError,"ERROR()","nError"), ;
					"PROGRAM()","cMethod"),"LINENO()","nLine")
			&lcOnError
			RETURN
		ENDIF
		lcErrorMsg = THIS.PrepareErrorMessage(nError,cMethod, nLine)
		THIS.LastErrorMessage = lcErrorMsg

		THIS.DoMessage(lcErrorMsg, MB_ICONSTOP )

		#IF OUTPUTCLASS_DEBUGGING
		    ERROR nError
		#ENDIF    
	ENDPROC

	PROCEDURE BeforeReport
		THIS.setFRXRunStartupConditions()

		THIS.GetFRXStartupInfo()

		THIS.setCurrentDataSession()

		IF NOT THIS.IsSuccessor
		   THIS.sharedPageHeight = THIS.GetPageHeight()
		   THIS.sharedPageWidth = THIS.GetPageWidth()
		ENDIF

		IF NOT ISNULL(THIS.Successor)
		   WITH THIS.Successor
		      .AddProperty("sharedGDIPlusGraphics", THIS.sharedGDIPlusGraphics)      
		      .AddProperty("sharedPageHeight", THIS.sharedPageHeight)
		      .AddProperty("sharedPageWidth", THIS.sharedPageWidth)      
		      .AddProperty("sharedOutputPageCount", THIS.sharedOutputPageCount)
		      .AddProperty("sharedPageNo", THIS.sharedPageNo)      
		      .AddProperty("sharedPageTotal", THIS.sharedPageTotal)    
		       THIS.setSuccessorDynamicProperties()        
		      .FRXDataSession = THIS.FRXDataSession
		      .CurrentDataSession = THIS.CurrentDataSession
		      .TwoPassProcess = THIS.TwoPassProcess
		      .CommandClauses = THIS.CommandClauses
		      .BeforeReport()
		   ENDWITH
		ENDIF
	ENDPROC


	PROCEDURE Destroy
		STORE NULL TO ;
		  THIS.Successor, ;
		  THIS.Listeners, ;
		  THIS.ReportClauses, ;
		  THIS.ReportFileNames, ;
		  THIS.PreviewContainer, ;
		  THIS.CommandClauses
	ENDPROC


	PROCEDURE AfterBand
		LPARAMETERS nBandObjCode, nFRXRecno
		IF NOT ISNULL(THIS.Successor)
		   THIS.SetSuccessorDynamicProperties()
		   THIS.Successor.AfterBand(nBandObjCode, nFRXRecNo)
		ENDIF
	ENDPROC


	PROCEDURE Render
		LPARAMETERS nFRXRecno, nLeft, nTop, nWidth, nHeight, nObjectContinuationType, cContentsToBeRendered, GDIPlusImage
		IF NOT ISNULL(THIS.Successor)
		   THIS.SetSuccessorDynamicProperties()
		   THIS.Successor.Render(nFRXRecno, nLeft, nTop, nWidth, nHeight, nObjectContinuationType, cContentsToBeRendered, GDIPlusImage)
		ENDIF
	ENDPROC

	PROCEDURE EvaluateContents
	LPARAMETERS NFRXRECNO, OOBJPROPERTIES
	IF NOT ISNULL(THIS.SUCCESSOR)
	    THIS.SETSUCCESSORDYNAMICPROPERTIES()
	    THIS.SUCCESSOR.EvaluateContents(NFRXRECNO, OOBJPROPERTIES)
	ENDIF
	ENDPROC

	PROCEDURE AdjustObjectSize
	LPARAMETERS NFRXRECNO, OOBJPROPERTIES
	IF NOT ISNULL(THIS.SUCCESSOR)
	    THIS.SETSUCCESSORDYNAMICPROPERTIES()
	    THIS.SUCCESSOR.AdjustObjectSize(NFRXRECNO, OOBJPROPERTIES)
	ENDIF
	ENDPROC

ENDDEFINE
*
*-- EndDefine: _reportlistener
**************************************************
