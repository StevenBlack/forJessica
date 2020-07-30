
* See blog post: http://mattslay.com/foxpro-class-to-generate-scctext-for-all-files-in-a-project/
*
*===========================================================================
LPARAMETERS tlReverse

IF ! tlReverse
	lnResponse = MessageBox('Run SSCText to generate ascii code files?', 3, 'Generate SCC files?')
ELSE
	lnResponse = MessageBox('Run SSCText to generate VFP Structure files?', 3, 'Reverse-Generate SCC files?')
ENDIF

If lnResponse <> 6
    Return
EndIf

*Clear All
*Release All
Set ClassLib to && Must clear them out, cause we're about to generate ascii files of them

loCreateSccText = CreateObject('CreateSCCText')

llReturn = loCreateSccText.DoSCCTextOnProject( tlReverse )

If llReturn = .t.
    ? Chr(10)+Chr(13)
    ? 'Done. ' + Str(loCreateSccText.nFileCount) + ' files processed.'
Else
    ? 'Result:' + loCreateSccText.cMessage
Endif


*================================================================
Define Class CreateSCCText as Custom

    cSkipFiles = 'LIST-FILES-TO-SKIP-HERE'
    nFileCount = 0
    cSccTextApp = Home(1) + 'SCCTextx.prg'
    cMessage = ''

*----------------------------------------------------------------------
Procedure DoSCCTextOnProject( tlReverse )

    Local loFile, loProject

    If !File(This.cSccTextApp)
        This.cMessage = 'Unable to find file ' + lcSCCText
        Return .f.
    Endif

    Try
        loProject = _vfp.ActiveProject
    Catch To loEx
    Endtry

    If Type('loEx') = 'O'
        This.cMessage = 'There are no active projects'
        Return .f.
    Endif

    For Each loFile In loProject.Files

        DO CASE
        CASE tlReverse

	        IF Inlist(loFile.Type, 'V', 'K', 'R') and ;
	             !InList(Upper(JustFname(loFile.name)), Upper(This.cSkipFiles))
	                    ? 'Generating: ' + loFile.Name
 	                    newext= LEFT( JUSTEXT(loFile.name), 2)+"a"
	                    Do ( This.cSCCTextApp ) With LOWER( FORCEEXT( loFile.Name, newExt ) )
	                    This.nFileCount = This.nFileCount + 1
	        ENDIF

        OTHERWISE
	        IF Inlist(loFile.Type, 'V', 'K', 'R') and ;
	             !InList(Upper(JustFname(loFile.name)), Upper(This.cSkipFiles)) ;
	             AND ( Fdate(loFile.name, 1) > This.SCCFileDateTime(loFile.name) OR Fdate( LEFT( loFile.name, LEN( loFile.name )-1) + "t", 1) > This.SCCFileDateTime(loFile.name))

	                    ? 'Generating: ' + loFile.Name
	                    Do ( This.cSCCTextApp ) With loFile.Name
	                    newext= LEFT( JUSTEXT(loFile.name), 2)+"a"

   	                    * RENAME FORCEEXT( loFile.Name, newExt ) TO LOWER(FORCEEXT( loFile.Name, newExt ))

	                    lcContent= FILETOSTR( FORCEEXT( loFile.Name, newExt ) )
	                    ERASE ( FORCEEXT( loFile.Name, newExt ) )
	                    STRTOFILE( lcContent, LOWER(FORCEEXT( loFile.Name, newExt )) )
	                    This.nFileCount = This.nFileCount + 1
	        ENDIF
        ENDCASE
    Endfor

    Return .t.

*------------------------------------------------------------------
Procedure SCCFileDateTime(tcFile)

        Local lcSCCFilename

        lcSCCFilename = Upper(Strtran(Upper(tcFile), '.SCX', '.SCA'))
        lcSCCFilename = Strtran(lcSCCFilename, '.VCX', '.VCA')
        lcSCCFilename = Strtran(lcSCCFilename, '.FRX', '.FRA')

        If File(lcSCCFilename)
            Return Fdate(lcSCCFilename, 1)
        Else
            Return {^1900-01-01 00:00:00}
        EndIf

    EndProc



*----------------------------------------------------------------
Procedure DoSccTextOnFile

    Lparameters tcFile

    Local lcOutput, lcType

    If !File(tcFile)
        Messagebox('File not found: ' + tcFile, 0, 'Error')
        Return .F.
    Endif

    Do Case
    Case '.VCX' $ Upper(tcFile)
        lcOutput = Getwordnum(tcFile, 1, '.') + '.vca'
        lcType = 'V'
    Case '.SCX' $ Upper(tcFile)
        lcOutput = Getwordnum(tcFile, 1, '.') + '.sca'
        lcType = 'K'
    Otherwise
        Return
    Endcase

    Do (SCCText) With  tcFile, lcType, LOWER(lcOutput), .T.

    Endproc


EndDefine