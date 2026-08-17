Set WshShell = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
app = fs.GetParentFolderName(WScript.ScriptFullName)
runtime = ""
If fs.FileExists(app & "\runtime-11\bin\javaw.exe") And fs.FileExists(app & "\runtime-11\bin\awt.dll") Then
  runtime = app & "\runtime-11\bin\javaw.exe"
End If
If runtime = "" And fs.FileExists(app & "\runtime-11\bin\java.exe") And fs.FileExists(app & "\runtime-11\bin\awt.dll") Then
  runtime = app & "\runtime-11\bin\java.exe"
End If
If runtime = "" And fs.FileExists(app & "\runtime\bin\javaw.exe") And fs.FileExists(app & "\runtime\bin\awt.dll") Then
  runtime = app & "\runtime\bin\javaw.exe"
End If
If runtime = "" And fs.FileExists(app & "\runtime\bin\java.exe") And fs.FileExists(app & "\runtime\bin\awt.dll") Then
  runtime = app & "\runtime\bin\java.exe"
End If
If runtime = "" Then
  runtime = "javaw"
End If
cmd = """" & runtime & """ -jar """ & app & "\PrivBotLauncher.jar"""
WshShell.Run cmd, 0
