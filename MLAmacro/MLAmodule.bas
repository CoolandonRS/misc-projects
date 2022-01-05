Attribute VB_Name = "MLAmodule"
'Module by CoolandonRS on GitHub
'https://github.com/CoolandonRS/random-projects

Sub mlaDispConf()
    MLAconfigForm.Show
End Sub
Public Sub mlaConfSave(frmTeacher, frmClass, frmName, frmID)
    iniFolder = Environ("USERPROFILE") & "\MacroVars"
    iniFile = iniFolder & "\mla.ini"
    If Dir(iniFolder, vbDirectory) = "" Then MkDir iniFolder
    System.PrivateProfileString(iniFile, frmID, "teacher") = frmTeacher
    System.PrivateProfileString(iniFile, frmID, "class") = frmClass
    System.PrivateProfileString(iniFile, frmID, "name") = frmName
    On Error Resume Next
        ActiveDocument.Variables("mlaActiveID") = frmID
        If Err.Number <> 0 Then ActiveDocument.Variables.Add name:="mlaActiveID", Value:=frmID
    On Error GoTo 0
End Sub
Sub mlaFormatDoc()
    iniFolder = Environ("USERPROFILE") & "\MacroVars"
    iniFile = iniFolder & "\mla.ini"
    If Dir(iniFolder, vbDirectory) = "" Then
        MsgBox Prompt:="No configuration file found. Please run mlaDispConf.", Buttons:=vbCritical, Title:="ERROR - mlaFormatDoc"
        End
    End If
    Templates.LoadBuildingBlocks
    On Error Resume Next
        savID = ActiveDocument.Variables("mlaActiveId")
        If Err.Number <> 0 Then savID = 1 ' Should only be triggered on new doc
    On Error GoTo 0
    Dim savName As Boolean
    savTeacher = System.PrivateProfileString(iniFile, savID, "teacher")
    savClass = System.PrivateProfileString(iniFile, savID, "class")
    savName = System.PrivateProfileString(iniFile, savID, "name")
    Selection.Font.name = "Times New Roman": Selection.Font.Size = 12
    Selection.TypeText Text:=Application.UserName
    Selection.TypeParagraph
    Selection.Font.name = "Times New Roman": Selection.Font.Size = 12 ' Sometimes the font can reset on paragraph type, so we use redundancy
    Selection.TypeText Text:=savTeacher
    Selection.TypeParagraph
    Selection.Font.name = "Times New Roman": Selection.Font.Size = 12
    Selection.TypeText Text:=savClass
    Selection.TypeParagraph
    mlaDate = Format(Date, "dd mmm. yyyy")
    Selection.Font.name = "Times New Roman": Selection.Font.Size = 12
    Selection.TypeText Text:=mlaDate
    Selection.TypeParagraph
    If savName Then
        docName = ActiveDocument.name
        If InStr((Len(docName) - 4), docName, ".") <> 0 Then
            plnName = Left(docName, (Len(docName) - 4))
            If InStr((Len(plnName) - 1), plnName, ".") <> 0 Then plnName = Left(plnName, (Len(plnName) - 1))
            Selection.Font.name = "Times New Roman": Selection.Font.Size = 12
        Else
            plnName = docName
        End If
        Selection.TypeText Text:=plnName
        Selection.TypeParagraph
    End If
    Selection.TypeParagraph
    Selection.ParagraphFormat.Alignment = wdAlignParagraphCenter
    Selection.Font.name = "Times New Roman": Selection.Font.Size = 12
    ' Begin header manip
    If ActiveWindow.View.SplitSpecial <> wdPaneNone Then
           ActiveWindow.Panes(2).Close
    End If
    If ActiveWindow.ActivePane.View.Type = wdNormalView Or ActiveWindow. _
        ActivePane.View.Type = wdOutlineView Then
        ActiveWindow.ActivePane.View.Type = wdPrintView
    End If
    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageHeader
    Selection.ParagraphFormat.Alignment = wdAlignParagraphRight
    names = Split(Application.UserName)
    lastName = names((UBound(names) - LBound(names))) 'Will only grab the last last name, but this way if for some reason middle name or initial is included (which is much more likely to happen) it will ignore it.
    Selection.TypeText Text:=lastName
    Selection.TypeText Text:="        "
    ' \/ Change this line if you got the msgbox error! Try not to touch the "\" charecter unless you know what your doing, though.
    templateInts = "1033\16"
    ' /\ You want this line to be the name of the numbered file you see that has "Built-In Building Blocks.dotx" inside! You should be able to find these folders if you press WIN+R and paste in "%appdata%\microsoft\Document Building Blocks" (make sure to include the quotes for this string only, as it will break otherwise)
    templatePath = Environ("USERPROFILE") & "\AppData\Roaming\Microsoft\Document Building Blocks\" & templateInts
    If Dir(templatePath, vbDirectory) = "" Then
        MsgBox Prompt:="Please press Alt+F11, navigate to the bottom of the MLAmodule module, and update the value surrounded by comments.", Buttons:=vbCritical, Title:="ERROR - mlaFormatDoc"
        End
    End If
    templateFile = templatePath & "\Built-In Building Blocks.dotx"
    Application.Templates(templateFile).BuildingBlockEntries("Plain Number").Insert Where:=Selection.Range, RichText:=True
    Selection.WholeStory: Selection.Font.name = "Times New Roman": Selection.Font.Size = 12 'Selects whole story as otherwise page number is sometimes excluded. Will change other header items but that shouldn't matter as other things should theoretically be in Times New Roman 12pt as well.
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument 'Exit header
End Sub
