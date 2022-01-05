VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} MLAconfigForm 
   Caption         =   "Configure MLA formatting"
   ClientHeight    =   1770
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   2940
   OleObjectBlob   =   "MLAconfigForm.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "MLAconfigForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Module by CoolandonRS on GitHub
'https://github.com/CoolandonRS/word-mla-macro

Private Sub NameToggle_UpdateCaption()
    If Me.NameToggle.Value Then t = "Use Document Name" Else t = "Do Not Use Document Name"
    Me.NameToggle.Caption = t
End Sub
Private Sub SaveButton_UpdateCaption()
    t = "Save Settings to Preset " & Me.GlobalIndexStepper.Value
    Me.SaveButton.Caption = t
End Sub
Private Sub GlobalIndexStepper_Change()
    If Me.GlobalIndexStepper.Value > 10 Then Me.GlobalIndexStepper.Value = 10 Else
    If Me.GlobalIndexStepper.Value < 1 Then Me.GlobalIndexStepper.Value = 1 Else
    Call SaveButton_UpdateCaption
    Call TeacherBox_UpdateValue
    Call ClassBox_UpdateValue
    Call NameToggle_UpdateValue
End Sub
Private Sub NameToggle_Click()
    Call NameToggle_UpdateCaption
End Sub
Private Sub SaveButton_Click()
    frmTeacher = Me.TeacherBox.Value
    frmClass = Me.ClassBox.Value
    frmName = Me.NameToggle.Value
    frmID = Me.GlobalIndexStepper.Value
    Call mlaConfSave(frmTeacher, frmClass, frmName, frmID)
    Unload Me
End Sub
Private Sub TeacherBox_UpdateValue()
    iniPath = Environ("USERPROFILE") & "\MacroVars\mla.ini"
    On Error Resume Next 'Yes, I do my indentation weird. No, you can't make me stop.
        Me.TeacherBox.Value = System.PrivateProfileString(iniPath, Me.GlobalIndexStepper.Value, "teacher")
        If Err.Number <> 0 Then Me.TeacherBox.Value = Empty
    On Error GoTo 0
End Sub
Private Sub ClassBox_UpdateValue()
    iniPath = Environ("USERPROFILE") & "\MacroVars\mla.ini"
    On Error Resume Next
        Me.ClassBox.Value = System.PrivateProfileString(iniPath, Me.GlobalIndexStepper.Value, "class")
        If Err.Number <> 0 Then Me.ClassBox.Value = Empty
    On Error GoTo 0
End Sub
Private Sub NameToggle_UpdateValue()
    iniPath = Environ("USERPROFILE") & "\MacroVars\mla.ini"
    Dim name As Boolean
    On Error Resume Next
        name = System.PrivateProfileString(iniPath, Me.GlobalIndexStepper.Value, "name")
        If Err.Number <> 0 Then name = False
    On Error GoTo 0
    Me.NameToggle.Value = name
    Call NameToggle_UpdateCaption
End Sub
Private Sub UserForm_Initialize()
    iniPath = Environ("USERPROFILE") & "\MacroVars\mla.ini"
    On Error Resume Next
        Me.GlobalIndexStepper.Value = ActiveDocument.Variables("mlaActiveID")
        If Err.Number <> 0 Then Me.GlobalIndexStepper.Value = 1
    On Error GoTo 0
    Call SaveButton_UpdateCaption
    Call TeacherBox_UpdateValue
    Call ClassBox_UpdateValue
    Call NameToggle_UpdateValue
End Sub
