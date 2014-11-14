* locs for VCX super-classes

#DEFINE OUTPUTCLASS_APPNAME_LOC              "VFP Report Output Class"

#DEFINE OUTPUTCLASS_CONFIGTABLECREATED_LOC     "Configuration table "+ lcDBF + " was created."
#DEFINE OUTPUTCLASS_CONFIGTABLEWRONG_LOC     "Configuration table is not in correct format."

* this is different from XML because in the XML class they
* are used in SEEK() and require specific tagnames, whereas
* the superclasses just require certain indexes for optimizing LOCATES,

#DEFINE OUTPUTCLASS_CONFIGINDEXMISSING_LOC   "Configuration table is missing "+ CHR(13) + ;
                                                                                                   "one or more required indexes."

#DEFINE OUTPUTCLASS_INITSTATUS_LOC           "Initializing... "
#DEFINE OUTPUTCLASS_PREPSTATUS_LOC           "Running calculation prepass... "
#DEFINE OUTPUTCLASS_RUNSTATUS_LOC            "Creating output... "
#DEFINE OUTPUTCLASS_TIME_SECONDS_LOC         SPACE(1) + "sec(s)"
#DEFINE OUTPUTCLASS_CANCEL_INSTRUCTIONS_LOC  "Press Esc to cancel... "
#DEFINE OUTPUTCLASS_REPORT_CANCELQUERY_LOC   "Stop report execution?"+CHR(13) + ;
                                             "(If you press 'No', report execution will continue.)"
#DEFINE OUTPUTCLASS_REPORT_INCOMPLETE_LOC    "Report execution was cancelled." + CHR(13) + ;
                                             "Your results are not complete."

#DEFINE OUTPUTCLASS_SUCCESS_LOC              THIS.AppName+" created your report as"+;
                                             CHR(13)+THIS.TargetFileName+"." + CHR(13) + ;
                                             IIF(THIS.AllowModalMessages,;
                                              "Press 'Yes' to store" + CHR(13) + ;
                                             "this filename in the Clipboard.","")

#DEFINE OUTPUTCLASS_NOFILECREATE_LOC         "File " + THIS.TargetFileName+" cannot be created."

#DEFINE OUTPUTCLASS_CREATEERRORS_LOC         THIS.AppName+" created your report as"+ ;
                                             CHR(13)+THIS.TargetFileName+". "+CHR(13)+ ;
                                             "However, an error occurred during processing." + CHR(13) + ;
                                             OUTPUTCLASS_REPORT_INCOMPLETE_LOC

#DEFINE OUTPUTCLASS_NOCREATE_LOC             THIS.AppName +" was not able to create your report."
 
#DEFINE OUTPUTCLASS_ERRNOLABEL_LOC           "Error:           "
#DEFINE OUTPUTCLASS_ERRPROCLABEL_LOC         "Method:       "
#DEFINE OUTPUTCLASS_ERRLINELABEL_LOC         "Line:            " 

* the following loc is eval'd for updateListener's actual progress bar message.  
* In most cases,
* changing this value is overkill, as the localizable portions of
* the message are already localized as separate properties.
* All the status messagse as well as the therm caption can
* also be set at runtime without touching the locs.
#DEFINE OUTPUTCLASS_THERMCAPTION_LOC        [cMessage+ " "+ TRANSFORM(INT(THIS.PercentDone*100)) + "%" ] + ;
                                            [+ IIF(NOT THIS.IncludeSeconds, "" , " "+] + ;
                                            [TRANSFORM(IIF(THIS.IsRunning,DATETIME(), THIS.ReportStopRunDateTime)-] + ;
                                            [THIS.ReportStartRunDateTime)+" " + THIS.SecondsText)]


* locs for XML Listener class:

#DEFINE OUTPUTXML_APPNAME_LOC               "XML Listener"

#DEFINE OUTPUTXML_CONFIGTAGMISSING_LOC      "At least one required index tag is missing "+ CHR(13) + ;
                                            "from the configuration table."

#DEFINE OUTPUTXML_FRXMISSING_LOC            "Required FRX cursor is not available." 
   
   
#DEFINE OUTPUTXML_FRXCURSOR_MISSING_LOC     "FRX cursor helper object cannot be found in " + CHR(13)+ ;
                                            "_FRXCURSOR.VCX, "+CHR(13)+ ; 
                                            "_REPORTOUTPUT." + CHR(13) + CHR(13)+ ;
                                            "Some features of this class may not be active."   

* locs for XML Display Listener Class:

#DEFINE OUTPUTXMLDISPLAY_APPNAME_LOC        "XML Display Listener"

* locs for HTML:

#DEFINE OUTPUTHTML_APPNAME_LOC              "HTML Listener"