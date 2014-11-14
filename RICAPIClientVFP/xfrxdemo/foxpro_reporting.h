** Visual FoxPro Named Constant File                                              **

* revisions/additions to FOXPRO.H specific to reporting

* SYS(2040) values
#DEFINE REPORTENGINE_STATUS_INACTIVE 0
#DEFINE REPORTENGINE_STATUS_PREVIEW  1
#DEFINE REPORTENGINE_STATUS_RUNNING  2

* STRCONV() values -- should all go in?
#DEFINE STRCONV_DBCS_UNICODE  5
#DEFINE STRCONV_UNICODE_DBCS  6
#DEFINE STRCONV_DBCS_UTF8  9
#DEFINE STRCONV_UNICODE_UTF8  10

#DEFINE STRCONV_REGIONTYPE_LOCALE  0 
#DEFINE STRCONV_REGIONTYPE_CODEPAGE  1
#DEFINE STRCONV_REGIONTYPE_FONTCHARSET  2

* add all locale ids?

*-- FRX report builder constants
*-- FRX Report Builder return flags
#define FRX_REPBLDR_IGNORE_EVENT            0       
#define FRX_REPBLDR_HANDLE_EVENT            1
#define FRX_REPBLDR_DISCARD_CHANGES         0
#define FRX_REPBLDR_RELOAD_CHANGES          2

*-- FRX Report Builder event types
#define FRX_BLDR_EVENT_PROPERTIES           1
#define FRX_BLDR_EVENT_OBJECTCREATE         2
#define FRX_BLDR_EVENT_OBJECTREMOVE         4
#define FRX_BLDR_EVENT_OBJECTPASTE          5
#define FRX_BLDR_EVENT_REPORTSAVE           6
#define FRX_BLDR_EVENT_REPORTOPEN           7
#define FRX_BLDR_EVENT_REPORTCLOSE          8
#define FRX_BLDR_EVENT_DATAENV              9
#define FRX_BLDR_EVENT_PREVIEWMODE         10
#define FRX_BLDR_EVENT_OPTIONALBANDS       11
#define FRX_BLDR_EVENT_DATAGROUPING        12
#define FRX_BLDR_EVENT_VARIABLES           13
#define FRX_BLDR_EVENT_EDITINPLACE         14
#define FRX_BLDR_EVENT_SETGRIDSCALE        15
#define FRX_BLDR_EVENT_OBJECTDROP          16
#define FRX_BLDR_EVENT_IMPORTDE            17
#define FRX_BLDR_EVENT_PRINT               18
#define FRX_BLDR_EVENT_QUICKREPORT         19

*-- FRX object Protection flags.
*-- These are bit numbers or powers of 2.
*-- not numeric values. They are stored 
*-- in the ORDER column as a character 
*-- representation of the sum of their 
*-- binary equivalent values.)
#define FRX_PROTECT_OBJECT_LOCK             0
#define FRX_PROTECT_OBJECT_HIDE             1
#define FRX_PROTECT_OBJECT_NO_DELETE        2
#define FRX_PROTECT_OBJECT_NO_EDIT          3
#define FRX_PROTECT_OBJECT_NO_SELECT        6
#define FRX_PROTECT_BAND_NO_EDIT            4
#define FRX_PROTECT_BAND_NO_RESIZE         14
#define FRX_PROTECT_REPORT_NO_PREVIEW       7
#define FRX_PROTECT_REPORT_NO_OPTBAND       8
#define FRX_PROTECT_REPORT_NO_GROUP         9
#define FRX_PROTECT_REPORT_NO_VARIABLES    10
#define FRX_PROTECT_REPORT_NO_PAGESETUP    11
#define FRX_PROTECT_REPORT_NO_MULTISELECT  12
#define FRX_PROTECT_REPORT_NO_DATAENV      13
#define FRX_PROTECT_REPORT_NO_PRINT        15
#define FRX_PROTECT_REPORT_NO_QUICKREPORT  16

*-- FRX report structure constants
*-- FRX PLATFORM column values
#define FRX_PLATFORM_WINDOWS                "WINDOWS"

*-- FRX OBJTYPE column values
#define FRX_OBJTYP_COMMENT                  0
#define FRX_OBJTYP_REPORTHEADER             1
#define FRX_OBJTYP_WORKAREA                 2
#define FRX_OBJTYP_INDEX                    3
#define FRX_OBJTYP_RELATION                 4
#define FRX_OBJTYP_LABEL                    5
#define FRX_OBJTYP_LINE                     6
#define FRX_OBJTYP_RECTANGLE                7
#define FRX_OBJTYP_FIELD                    8
#define FRX_OBJTYP_BAND                     9
#define FRX_OBJTYP_GROUP                   10
#define FRX_OBJTYP_PICTURE                 17
#define FRX_OBJTYP_VARIABLE                18
#define FRX_OBJTYP_PDRIVER                 21
#define FRX_OBJTYP_FONTRES                 23
#define FRX_OBJTYP_DATAENV                 25
#define FRX_OBJTYP_DATAOBJ                 26

*-- FRX OBJCODE column values
#define FRX_OBJCOD_TITLE                    0
#define FRX_OBJCOD_PAGEHEADER               1
#define FRX_OBJCOD_COLHEADER                2
#define FRX_OBJCOD_GROUPHEADER              3
#define FRX_OBJCOD_DETAIL                   4
#define FRX_OBJCOD_GROUPFOOTER              5
#define FRX_OBJCOD_COLFOOTER                6
#define FRX_OBJCOD_PAGEFOOTER               7
#define FRX_OBJCOD_SUMMARY                  8
#define FRX_OBJCOD_DETAILHEADER             9
#define FRX_OBJCOD_DETAILFOOTER            10
#define FRX_OBJCOD_RECTANGLE                4
#define FRX_OBJCOD_REPORTHEADER            53
#define FRX_OBJCOD_OTHER                    0

*-- FRX PENSIZE column values
#define FRX_PENSIZE_HAIRLINE                0
#define FRX_PENSIZE_1POINTS                 1
#define FRX_PENSIZE_2POINTS                 2
#define FRX_PENSIZE_4POINTS                 4
#define FRX_PENSIZE_6POINTS                 6

*-- FRX PENPAT column values
#define FRX_PENPAT_NONE                     0 
#define FRX_PENPAT_DOTTED                   1
#define FRX_PENPAT_DASHED                   2
#define FRX_PENPAT_DASHDOT                  3
#define FRX_PENPAT_DASHDOTDOT               4
#define FRX_PENPAT_SOLID                    8

*-- FRX FILLPAT column values
#define FRX_FILLPAT_NONE                    0
#define FRX_FILLPAT_SOLID                   1
#define FRX_FILLPAT_HORIZONTAL              2
#define FRX_FILLPAT_VERTICAL                3
#define FRX_FILLPAT_LEFTDIAGONAL            4
#define FRX_FILLPAT_RIGHTDIAGONAL           5
#define FRX_FILLPAT_GRID                    6
#define FRX_FILLPAT_CROSSHATCH              7

*-- FRX FONTSTYLE column flags (sum to obtain value)
#define FRX_FONTSTYLE_NORMAL                0
#define FRX_FONTSTYLE_BOLD                  1
#define FRX_FONTSTYLE_ITALIC                2
#define FRX_FONTSTYLE_UNDERLINED            4
#define FRX_FONTSTYLE_STRIKETHROUGH       128 

*-- FRX MODE column flags (sum to obtain value)
#define FRX_MODE_OPAQUE                     0
#define FRX_MODE_TRANSPARENT                1
#define FRX_MODE_LTR                        0  && Left-to-Right
#define FRX_MODE_RTL                        2  && Right-to-Left
#define FRX_MODE_CONTEXT                    4  

*-- FRX RULER column / measurement units
#define FRX_RULER_OFF                       0
#define FRX_RULER_INCHES                    1
#define FRX_RULER_METRIC                    2
#define FRX_RULER_PIXELS                    3
#define FRX_RULER_CHARACTERS                4
#define FRX_RULER_SYSDEFAULT                5

*-- FRX RULERLINES column values 
*-- (header record)
#define FRX_RULERLINES_OFF                  0
#define FRX_RULERLINES_ON                   1

*-- (String trimming for OBJTYPE=8 records)
#define FRX_STRINGTRIM_DEFAULT              0
#define FRX_STRINGTRIM_CHAR                 1
#define FRX_STRINGTRIM_WORD                 2
#define FRX_STRINGTRIM_ELLIPSIS_CHAR        3
#define FRX_STRINGTRIM_ELLIPSIS_WORD        4
#define FRX_STRINGTRIM_ELLIPSIS_PATH        5

*-- FRX GENERAL column values for RECTANGLE/SHAPEs
#define FRX_PICTUREMODE_CLIP                0
#define FRX_PICTUREMODE_SCALE_KEEP_SHAPE    1
#define FRX_PICTUREMODE_SCALE_STRETCH       2

*-- FRX SPACING column, line spacing values for LABEL objects:
#define FRX_SPACING_SINGLE                  0
#define FRX_SPACING_ONE_POINT_FIVE          1
#define FRX_SPACING_DOUBLE                  2

*-- FRX Field object justification (OFFSET column)
#define FRX_JUSTIFICATION_LEFT              0
#define FRX_JUSTIFICATION_RIGHT             1
#define FRX_JUSTIFICATION_CENTER            2

*-- FRX Picture object source type (OFFSET column)
#define FRX_PICTURE_SOURCE_FILENAME         0  && stored in PICTURE column
#define FRX_PICTURE_SOURCE_GENERAL          1  && stored in NAME    column
#define FRX_PICTURE_SOURCE_EXPRESSION       2  && stored in NAME    column

*-- FRX TOTALTYPE column calculation types
#define FRX_TOTALTYPE_NONE                  0
#define FRX_TOTALTYPE_COUNT                 1
#define FRX_TOTALTYPE_SUM                   2
#define FRX_TOTALTYPE_AVERAGE               3
#define FRX_TOTALTYPE_LOWEST                4
#define FRX_TOTALTYPE_HIGHEST               5
#define FRX_TOTALTYPE_STDDEV                6
#define FRX_TOTALTYPE_VARIANCE              7

*-- FRX RESETTOTAL column values 
#define FRX_RESETTOTAL_ENDOFREPORT          1
#define FRX_RESETTOTAL_ENDOFPAGE            2
#define FRX_RESETTOTAL_ENDOFCOLUMN          3
#define FRX_RESETTOTAL_GROUP_OFFSET         5   && add to group index
#define FRX_RESETTOTAL_DETAIL_OFFSET        79  && add to detail band index

* ReportListener baseclass constants

#DEFINE LISTENER_TYPE_DEF    -1
#DEFINE LISTENER_TYPE_PRN     0
#DEFINE LISTENER_TYPE_PRV     1
#DEFINE LISTENER_TYPE_PAGED   2
#DEFINE LISTENER_TYPE_ALLPGS  3

#DEFINE LISTENER_CONTINUATION_NONE    0
#DEFINE LISTENER_CONTINUATION_START   1 
#DEFINE LISTENER_CONTINUATION_MIDDLE  2
#DEFINE LISTENER_CONTINUATION_END     3

#DEFINE LISTENER_DEVICE_TYPE_NONE    -1
#DEFINE LISTENER_DEVICE_TYPE_HDC      0
#DEFINE LISTENER_DEVICE_TYPE_GRF      1
#DEFINE LISTENER_DEVICE_TYPE_CTL      2
#DEFINE LISTENER_DEVICE_TYPE_EMF      100
#DEFINE LISTENER_DEVICE_TYPE_TIF      101
#DEFINE LISTENER_DEVICE_TYPE_JPG      102
#DEFINE LISTENER_DEVICE_TYPE_GIF      103
#DEFINE LISTENER_DEVICE_TYPE_PNG      104
#DEFINE LISTENER_DEVICE_TYPE_BMP      105
#DEFINE LISTENER_DEVICE_TYPE_MTIF     201            

#DEFINE LISTENER_SEND_GDI_IMAGE_NONE     0
#DEFINE LISTENER_SEND_GDI_IMAGE_HANDLE 1

#DEFINE LISTENER_PREPASS 0
#DEFINE LISTENER_FULLPASS 1

* subset of existing FOXPRO.H used in reportoutput app and classes

*-- DrawMode
#DEFINE DRAWMODE_BLACKNESS       1       && 1 - Blackness
#DEFINE DRAWMODE_NOT_MERGE_PEN   2       && 2 - Not Merge Pen
#DEFINE DRAWMODE_MASK_NOT_PEN    3       && 3 - Mask Not Pen
#DEFINE DRAWMODE_NOT_COPY_PEN    4       && 4 - Not Copy Pen
#DEFINE DRAWMODE_MASK_PEN_NOT    5       && 5 - Mask Pen Not
#DEFINE DRAWMODE_INVERT          6       && 6 - Invert
#DEFINE DRAWMODE_XOR_PEN         7       && 7 - Xor Pen
#DEFINE DRAWMODE_NOT_MASK_PEN    8       && 8 - Not Mask Pen
#DEFINE DRAWMODE_MASK_PEN        9       && 9 - Mask Pen
#DEFINE DRAWMODE_NOT_XOR_PEN     10      && 10 - Not Xor Pen
#DEFINE DRAWMODE_NOP             11      && 11 - Nop
#DEFINE DRAWMODE_MERGE_NOT_PEN   12      && 12 - Merge Not Pen
#DEFINE DRAWMODE_COPY_PEN        13      && 13 - Copy Pen
#DEFINE DRAWMODE_MERGE_PEN_NOT   14      && 14 - Merge Pen Not
#DEFINE DRAWMODE_MERGE_PEN       15      && 15 - Merge Pen
#DEFINE DRAWMODE_WHITENESS       16      && 16 - Whiteness

*-- DrawStyle
#DEFINE DRAWSTYLE_SOLID           0       && 0 - Solid
#DEFINE DRAWSTYLE_DASH            1       && 1 - Dash
#DEFINE DRAWSTYLE_DOT             2       && 2 - Dot
#DEFINE DRAWSTYLE_DASH_DOT        3       && 3 - Dash-Dot
#DEFINE DRAWSTYLE_DASH_DOT_DOT    4       && 4 - Dash-Dot-Dot
#DEFINE DRAWSTYLE_INVISIBLE       5       && 5 - Invisible
#DEFINE DRAWSTYLE_INSIDE_SOLID    6       && 6 - Inside Solid

*-- FillStyle
#DEFINE FILLSTYLE_SOLID                   0       && 0 - Solid
#DEFINE FILLSTYLE_TRANSPARENT             1       && 1 - Transparent
#DEFINE FILLSTYLE_HORIZONTAL_LINE         2       && 2 - Horizontal Line
#DEFINE FILLSTYLE_VERTICAL_LINE           3       && 3 - Vertical Line
#DEFINE FILLSTYLE_UPWARD_DIAGONAL         4       && 4 - Upward Diagonal
#DEFINE FILLSTYLE_DOWNWARD_DIAGONAL       5       && 5 - Downward Diagonal
#DEFINE FILLSTYLE_CROSS                   6       && 6 - Cross
#DEFINE FILLSTYLE_DIAGONAL_CROSS          7       && 7 - Diagonal Cross

*-- ScaleMode
#DEFINE SCALEMODE_PIXELS          3       && 3 - Pixel
#DEFINE SCALEMODE_FOXELS          0       && 0 - Foxels

*-- Window Borders
#DEFINE BORDER_NONE     0
#DEFINE BORDER_SINGLE   1
#DEFINE BORDER_DOUBLE   2
#DEFINE BORDER_SYSTEM   3

*-- Button parameter masks
#DEFINE BUTTON_LEFT     1
#DEFINE BUTTON_RIGHT    2
#DEFINE BUTTON_MIDDLE   4

*-- Function Parameters
*-- MessageBox parameters
#DEFINE MB_OK                   0       && OK button only
#DEFINE MB_OKCANCEL             1       && OK and Cancel buttons
#DEFINE MB_ABORTRETRYIGNORE     2       && Abort, Retry, and Ignore buttons
#DEFINE MB_YESNOCANCEL          3       && Yes, No, and Cancel buttons
#DEFINE MB_YESNO                4       && Yes and No buttons
#DEFINE MB_RETRYCANCEL          5       && Retry and Cancel buttons

#DEFINE MB_ICONSTOP             16      && Critical message
#DEFINE MB_ICONQUESTION         32      && Warning query
#DEFINE MB_ICONEXCLAMATION      48      && Warning message
#DEFINE MB_ICONINFORMATION      64      && Information message

#DEFINE MB_APPLMODAL            0       && Application modal message box
#DEFINE MB_DEFBUTTON1           0       && First button is default
#DEFINE MB_DEFBUTTON2           256     && Second button is default
#DEFINE MB_DEFBUTTON3           512     && Third button is default
#DEFINE MB_SYSTEMMODAL          4096    && System Modal

*-- MsgBox return values
#DEFINE IDOK            1       && OK button pressed
#DEFINE IDCANCEL        2       && Cancel button pressed
#DEFINE IDABORT         3       && Abort button pressed
#DEFINE IDRETRY         4       && Retry button pressed
#DEFINE IDIGNORE        5       && Ignore button pressed
#DEFINE IDYES           6       && Yes button pressed
#DEFINE IDNO            7       && No button pressed

*-- Sysmetric() parameter values
#DEFINE SYSMETRIC_SCREENWIDTH         1 && Screen width
#DEFINE SYSMETRIC_SCREENHEIGHT        2 && Screen width
