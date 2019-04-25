#include "EzMySql.au3"
#include <Array.au3>

$SQLDriver = 'MySQL ODBC 3.51 Driver'
$SQLServer = "localhost"
$SQLDatabase = 'autoit_tutorial'
$SQLPort = '3306'
$SQLUser = 'root'
$SQLPassword = 'okxcVz2ZcXY3tgJP'
$MD5Pass = "MD5"
;id,name,userpass,premdays,hwid,group_id

If Not _EzMySql_Startup() Then
    MsgBox(0, "Error Starting MySql", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
    Exit
EndIf

If Not _EzMySql_Open($SQLServer, $SQLUser, $SQLPassword, $SQLDatabase, $SQLPort) Then
    MsgBox(0, "Error opening Database", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
    Exit
EndIf

If Not _EzMYSql_Query("SELECT * FROM users WHERE =1") Then
MsgBox(0, "Query Error", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
    Exit
EndIf

For $i = 1 To _EzMySql_Rows() Step 1
    $a1Row = _EzMySql_FetchData()
	MsgBox(0,"DATA",$a1Row[1])
Next