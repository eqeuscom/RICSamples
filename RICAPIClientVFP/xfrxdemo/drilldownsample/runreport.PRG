Lparameters tnReportType, tuPar1, toViewer

*
* when running this prg, make sure path is set to xfrxlib directory
* and xfrx.fxp, hndlib.dll, zlib.dll and xfrxlib.fll are in path
*

*
* This code checks the current VFP version and uses the VFP 9 vs. pre-VFP 9 approach accordingly.
* Look for Version(5) calls below
*
* When invoked without parameters, the previewer class is instantiated and the 1st report is done. 
* If user click the drill-down links in the previewer, this code is called recursively, sending the
* report code, report parameter and the existing previewer reference.
*
* See more information about drill-down in the Developer's guide, "Implementing custom event hyperlinks (drilldown) in XFRX previewer" chapter
*

Local loSession, lnRetval, lcPageCaption

If Empty(tnReportType)
  *
  * no report type was sent - we need to initialize the previewer and run the 1st report
  *
  Set Classlib To xfrxlib ADDITIVE 
  toViewer = Createobject("frmMPPreviewer")
  tnReportType = 1
Endif

*
* initialize the XFRX listener
*
IF VERSION(5)>=900
	loSession=Evaluate([xfrx("XFRX#LISTENER")])
ELSE
	loSession=Evaluate([xfrx("XFRX#INIT")])
ENDIF

lnRetval = loSession.SetParams(,,,,,,"XFF")
If lnRetval = 0
  *
  * now see which report we want to run, select the data and run the report
  *
  Do Case
  Case tnReportType = 1
    Select companynam as companyname From customers Order By companynam Into Cursor custindex
	*
	* run the 1st page report - customers index
	*
	IF VERSION(5)>=900
	    Report Form custindex Object loSession Nopageeject
	ELSE
		loSession.processReport("custindex")
	endif    		
    Select companynam as companyname, shippeddat as shippeddate, * ;
      FROM customers Join orders On customers.customerid = orders.customerid ;
      JOIN orderdetails On orders.orderid = orderdetails.orderid ;
      order By customers.companynam, customers.customerid, orderDate Desc, orders.orderid ;
      INTO Cursor custlist
	*
	* now run the 2nd report and merge these two together
	*      
	IF VERSION(5)>=900
    	Report Form custlist Object loSession
	ELSE
		loSession.processReport("custList")
	endif    	
    lcPageCaption = "Customers list"

  Case tnReportType = 2
    Select companynam as companyname, shippeddat as shippeddate, * ;
      FROM customers Join orders On customers.customerid = orders.customerid ;
      JOIN orderdetails On orders.orderid = orderdetails.orderid ;
      order By customers.companynam, customers.customerid, orders.orderid ;
      WHERE customers.customerid = tuPar1 ;
      INTO Cursor custlist
	IF VERSION(5)>=900
	    Report Form custDet Object loSession
	ELSE
		loSession.processReport("custDet")
	endif    	
    lcPageCaption = "Customers detail ("+Alltrim(tuPar1)+")"

  Case tnReportType = 3
    Select companynam as companyname, shippeddat as shippeddate, productnam as productname, * ;
      FROM customers Join orders On customers.customerid = orders.customerid ;
      JOIN orderdetails On orders.orderid = orderdetails.orderid ;
      JOIN products On products.productid = orderdetails.productid ;
      order By customers.companynam, customers.customerid, orders.orderid ;
      WHERE orders.orderid = tuPar1 ;
      INTO Cursor custlist
	IF VERSION(5)>=900
	    Report Form OrdDet Object loSession
	ELSE
		loSession.processReport("OrdDet")
	endif    	
    lcPageCaption = "Order detail ("+Alltrim(Str(tuPar1))+")"
  Endcase
Endif

*
* now preview the report
*
toViewer.iTool = 2 && we are using the "fake" toolbar

LOCAL loXFFDocument
IF VERSION(5)>=900
	loXFFDocument = loSession.oxfdocument
ELSE
	loXFFDocument = loSession.finalize()
ENDIF

toViewer.previewXFF(loXFFDocument, lcPageCaption)
*
* show the preview if not yet visible
*
If toViewer.Visible = .F.
  toViewer.Show(1)
Endif
