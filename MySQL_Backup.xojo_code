#tag Class
Protected Class MySQL_Backup
	#tag Method, Flags = &h0
		Sub BackupNow()
		  call  BackupNow(SpecialFolder.Temporary, true)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BackupNow(fi as FolderItem) As boolean
		  return BackupNow(fi, true)<>nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BackupNow(fi as FolderItem, pWithDate as Boolean, pThread As Thread = Nil, pProgressStart As Integer = 0, pProgressEnd As Integer = 100) As FolderItem
		  If fi Is Nil Or mDatabase Is Nil Or Not (mDatabase IsA MySQLCommunityServer) Then Return Nil

		  Dim nowD As DateTime = DateTime.Now
		  Dim filename As String = "backup-" + mDatabase.DatabaseName
		  If pWithDate Then filename = filename + "-" + nowD.SQLDateTime.ReplaceAll(":", "")
		  Dim backupFile As FolderItem = fi.Child(filename + ".sql", False)
		  If backupFile Is Nil Then Return Nil

		  Dim progressSpan As Integer = pProgressEnd - pProgressStart
		  If progressSpan < 1 Then progressSpan = 1
		  PostProgress(pThread, pProgressStart, kCreationDunBackupEnCours_(App.Lang))

		  Dim output As TextOutputStream
		  Dim transactionStarted As Boolean
		  Try
		    Dim tables As RowSet = mDatabase.SelectSQL("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME", mDatabase.DatabaseName)
		    Dim tableNames() As String
		    While Not tables.AfterLastRow
		      tableNames.Add(tables.Column("TABLE_NAME").StringValue)
		      tables.MoveToNextRow
		    Wend
		    Dim totalTables As Integer = tableNames.Count
		    If totalTables < 1 Then totalTables = 1

		    mDatabase.ExecuteSQL("SET time_zone = '+00:00'")
		    mDatabase.ExecuteSQL("SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ")
		    mDatabase.ExecuteSQL("START TRANSACTION WITH CONSISTENT SNAPSHOT")
		    transactionStarted = True

		    output = TextOutputStream.Create(backupFile)
		    output.WriteLine(kBackupVersionHeader)
		    output.WriteLine("-- Kanjo Desktop MySQL/MariaDB backup")
		    output.WriteLine("-- Database: " + mDatabase.DatabaseName)
		    output.WriteLine("-- Generation time: " + nowD.SQLDateTime)
		    WriteStatement(output, "SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO'")
		    WriteStatement(output, "SET NAMES utf8mb4")
		    WriteStatement(output, "SET time_zone = '+00:00'")
		    WriteStatement(output, "SET FOREIGN_KEY_CHECKS = 0")

		    Dim processedTables As Integer
		    For Each tableName As String In tableNames
		      PostProgress(pThread, pProgressStart + ((processedTables * progressSpan) / totalTables), kBackup(App.Lang) + " : " + tableName)

		      Dim createRow As RowSet = mDatabase.SelectSQL("SHOW CREATE TABLE " + QuoteIdentifier(tableName))
		      If createRow Is Nil Or createRow.AfterLastRow Then
		        output.Close
		        output = Nil
		        mDatabase.ExecuteSQL("ROLLBACK")
		        transactionStarted = False
		        If backupFile.Exists Then backupFile.Remove
		        PostProgress(pThread, pProgressStart, kBackupFailed(App.Lang))
		        Return Nil
		      End If

		      WriteStatement(output, "DROP TABLE IF EXISTS " + QuoteIdentifier(tableName))
		      WriteStatement(output, createRow.ColumnAt(1).StringValue)

		      Dim dataTypes As New Dictionary
		      Dim generatedColumns As New Dictionary
		      Dim columnTypes As RowSet = mDatabase.SelectSQL("SELECT COLUMN_NAME, DATA_TYPE, EXTRA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION", mDatabase.DatabaseName, tableName)
		      While Not columnTypes.AfterLastRow
		        Dim metadataColumnName As String = columnTypes.Column("COLUMN_NAME").StringValue.Lowercase
		        dataTypes.Value(metadataColumnName) = columnTypes.Column("DATA_TYPE").StringValue.Lowercase
		        Dim extraMetadata As String = columnTypes.Column("EXTRA").StringValue.Lowercase
		        If extraMetadata.Contains("virtual generated") Or extraMetadata.Contains("stored generated") Then generatedColumns.Value(metadataColumnName) = True
		        columnTypes.MoveToNextRow
		      Wend

		      Dim dataRows As RowSet = mDatabase.SelectSQL("SELECT * FROM " + QuoteIdentifier(tableName))
		      Dim rowCount As Integer = dataRows.RowCount
		      output.WriteLine("-- KANJO_TABLE_ROWS " + tableName + "=" + rowCount.ToString)

		      If Not dataRows.AfterLastRow Then
		        Dim insertPrefix As String = "INSERT INTO " + QuoteIdentifier(tableName) + " ("
		        Dim includedColumnIndexes() As Integer
		        For columnIndex As Integer = 0 To dataRows.ColumnCount - 1
		          Dim columnName As String = dataRows.ColumnAt(columnIndex).Name
		          If Not generatedColumns.HasKey(columnName.Lowercase) Then
		            If includedColumnIndexes.Count > 0 Then insertPrefix = insertPrefix + ","
		            insertPrefix = insertPrefix + QuoteIdentifier(columnName)
		            includedColumnIndexes.Add(columnIndex)
		          End If
		        Next
		        insertPrefix = insertPrefix + ") VALUES ("

		        While Not dataRows.AfterLastRow
		          Dim insertSQL As String = insertPrefix
		          For valueIndex As Integer = 0 To includedColumnIndexes.LastIndex
		            If valueIndex > 0 Then insertSQL = insertSQL + ","
		            Dim columnIndex As Integer = includedColumnIndexes(valueIndex)
		            Dim columnName As String = dataRows.ColumnAt(columnIndex).Name
		            Dim dataType As String = dataTypes.Lookup(columnName.Lowercase, "").StringValue
		            insertSQL = insertSQL + SQLValue(dataRows.ColumnAt(columnIndex), dataType)
		          Next
		          WriteStatement(output, insertSQL + ")")
		          dataRows.MoveToNextRow
		        Wend
		      End If

		      processedTables = processedTables + 1
		      PostProgress(pThread, pProgressStart + ((processedTables * progressSpan) / totalTables), kBackup(App.Lang) + " : " + tableName)
		    Next

		    WriteStatement(output, "SET FOREIGN_KEY_CHECKS = 1")
		    output.WriteLine(kBackupCompleteMarker)
		    output.Close
		    output = Nil

		    mDatabase.ExecuteSQL("COMMIT")
		    transactionStarted = False
		    PostProgress(pThread, pProgressEnd, kBackupFait(App.Lang))
		    Return backupFile
		  Catch error As RuntimeException
		    If output <> Nil Then
		      Try
		        output.Close
		      Catch
		      End Try
		    End If
		    If transactionStarted Then
		      Try
		        mDatabase.ExecuteSQL("ROLLBACK")
		      Catch
		      End Try
		    End If
		    If backupFile.Exists Then
		      Try
		        backupFile.Remove
		      Catch
		      End Try
		    End If
		    PostProgress(pThread, pProgressStart, kBackupFailed(App.Lang))
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function QuoteIdentifier(pName As String) As String
		  Return "`" + pName.ReplaceAll("`", "``") + "`"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function RestoreDump(pBackupFile As FolderItem, pDatabase As Database, ByRef pDetails As String) As Boolean
		  pDetails = ""
		  If pBackupFile Is Nil Or Not pBackupFile.Exists Then
		    pDetails = "Backup file is missing."
		    Return False
		  End If
		  If pDatabase Is Nil Or Not (pDatabase IsA MySQLCommunityServer) Then
		    pDetails = "A connected MySQL/MariaDB database is required."
		    Return False
		  End If

		  Dim input As TextInputStream
		  Dim headerFound As Boolean
		  Dim completeMarkerFound As Boolean
		  Dim statement As String
		  Dim statementCount As Integer

		  Try
		    input = TextInputStream.Open(pBackupFile)
		    input.Encoding = Encodings.UTF8

		    While Not input.EndOfFile
		      Dim line As String = input.ReadLine
		      Dim trimmedLine As String = line.Trim

		      If trimmedLine = kBackupVersionHeader Then
		        headerFound = True
		      ElseIf trimmedLine = kStatementEndMarker Then
		        If Not headerFound Then
		          pDetails = "Backup statement found before the version header."
		          input.Close
		          Return False
		        End If
		        If statement.Trim <> "" Then
		          pDatabase.ExecuteSQL(statement)
		          statementCount = statementCount + 1
		        End If
		        statement = ""
		      ElseIf trimmedLine = kBackupCompleteMarker Then
		        completeMarkerFound = True
		      ElseIf headerFound And Not trimmedLine.BeginsWith("--") Then
		        statement = statement + line + EndOfLine.UNIX
		      End If
		    Wend
		    input.Close
		    input = Nil

		    If Not headerFound Then
		      pDetails = "Unsupported backup format: version header missing."
		      Return False
		    End If
		    If statement.Trim <> "" Then
		      pDetails = "Incomplete backup: unterminated SQL statement."
		      Return False
		    End If
		    If Not completeMarkerFound Then
		      pDetails = "Incomplete backup: completion marker missing."
		      Return False
		    End If

		    pDetails = statementCount.ToString + " statements restored."
		    Return True
		  Catch error As RuntimeException
		    If input <> Nil Then
		      Try
		        input.Close
		      Catch
		      End Try
		    End If
		    Try
		      pDatabase.ExecuteSQL("SET FOREIGN_KEY_CHECKS = 1")
		    Catch
		    End Try
		    pDetails = "Restore failed after " + statementCount.ToString + " statements: " + error.Message
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function SQLValue(pColumn As DatabaseColumn, pDataType As String) As String
		  If pColumn.Value.IsNull Then Return "NULL"

		  Dim normalizedType As String = pDataType.Trim.Lowercase
		  Select Case normalizedType
		  Case "binary", "varbinary", "tinyblob", "blob", "mediumblob", "longblob", "bit"
		    Return "X'" + EncodeHex(pColumn.NativeValue) + "'"
		  Case "tinyint", "smallint", "mediumint", "int", "integer", "bigint", "decimal", "numeric", "float", "double", "real", "year"
		    Return pColumn.StringValue
		  End Select

		  Dim escapedValue As String = pColumn.StringValue
		  escapedValue = escapedValue.ReplaceAll(Chr(92), Chr(92) + Chr(92))
		  escapedValue = escapedValue.ReplaceAll(Chr(0), Chr(92) + "0")
		  escapedValue = escapedValue.ReplaceAll(Chr(10), Chr(92) + "n")
		  escapedValue = escapedValue.ReplaceAll(Chr(13), Chr(92) + "r")
		  escapedValue = escapedValue.ReplaceAll(Chr(9), Chr(92) + "t")
		  escapedValue = escapedValue.ReplaceAll(Chr(26), Chr(92) + "Z")
		  escapedValue = escapedValue.ReplaceAll("'", "''")
		  Return "'" + escapedValue + "'"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub WriteStatement(pOutput As TextOutputStream, pSQL As String)
		  Dim statement As String = pSQL.Trim
		  If Not statement.EndsWith(";") Then statement = statement + ";"
		  pOutput.WriteLine(statement.ConvertEncoding(Encodings.UTF8))
		  pOutput.WriteLine(kStatementEndMarker)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Cancel()
		  mCancel = True

		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ColumnType(pType as integer) As string
		  select case pType
		  case 0
		    return "null"
		  case 1
		    return "Byte"
		  case 2
		    return "SmallInt"
		  case 3
		    return "Int"
		  case 4
		    return "Char"
		  case 5
		    return "VarChar"
		  case 6
		    return "Float"
		  case 7
		    return "Double"
		  case 8
		    return "Date"
		  case 9
		    return "Time"
		  case 10
		    return "TimeStamp"
		  case 11
		    return "Currency"
		  case 12
		    return "Boolean"
		  case 13
		    return "Decimal"
		  case 14
		    return "Binary"
		  case 15
		    return "LongText"
		  case 16
		    return "LongVarBinary"
		  case 17
		    return "MacPict"
		  case 18
		    return "String"
		  case 19
		    return "int64"
		  case 255
		    return "blob"
		  else
		    return "blob"
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Default(pDefault as Variant) As string
		  if pDefault <> nil then
		    if pDefault = "CURRENT_TIMESTAMP" then
		      Return "DEFAULT " + pDefault
		    else
		      Return "DEFAULT '" + pDefault + "'"
		    end if
		  else
		    Return ""
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoBackupWithProgress(t As Thread) As FolderItem
		  // Example sketch – adapt to your real loops/rowsets
		  Var target As FolderItem = SpecialFolder.Temporary // or pass it in
		  Var withDate As Boolean = True
		  
		  // Tell UI where we’ll write
		  t.AddUserInterfaceUpdate(New Dictionary("event":"progress","message":"Preparing output file…","percent":0.02))
		  
		  
		  Var result As FolderItem = BackupNow(target, withDate)
		  If result = Nil Then
		    t.AddUserInterfaceUpdate(New Dictionary("event":"progress","message":"No result produced.","percent":1.0))
		  Else
		    t.AddUserInterfaceUpdate(New Dictionary("event":"progress","message":"Backup file saved: " + result.NativePath,"percent":1.0))
		  End If
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NotNil(pNotNil as string) As string
		  if pNotNil = "No" then
		    Return " NOT NULL "
		  else
		    Return " "
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PostProgress(pThread As Thread, pProgress As Integer, pMessage As String)
		  If pThread = Nil Then Return
		  
		  If pProgress < 0 Then
		    pProgress = 0
		  ElseIf pProgress > 100 Then
		    pProgress = 100
		  End If
		  
		  pThread.AddUserInterfaceUpdate("UIProgress":pProgress, "UIMessage":pMessage)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PrimaryKeys(pTableName as string) As String
		  dim rcp as RowSet = me.mDatabase.SelectSQL("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + pTableName + "' AND constraint_name = 'PRIMARY'")
		  if rcp.Column("COLUMN_NAME").Value <> nil then
		    dim mPrimary as string = "PRIMARY KEY ("
		    
		    while Not rcp.AfterLastRow
		      mPrimary = mPrimary + "`" + rcp.Column("COLUMN_NAME").StringValue + "`"
		      rcp.MoveToNextRow
		      if not rcp.AfterLastRow then
		        mPrimary = mPrimary + ", "
		      end if
		    wend
		    mPrimary = mPrimary + ")"
		    
		    Return mPrimary
		  end if
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartAsync(targetFolder As FolderItem, withDate As Boolean = True)
		  If mIsRunning Then Return
		  
		  mCancel = False
		  mLastResult = Nil
		  
		  mWorker = New Thread
		  AddHandler mWorker.Run, AddressOf Worker_Run
		  'AddHandler mWorker.AddUserInterfaceUpdate, AddressOf Worker_UIUpdate
		  
		  mIsRunning = True
		  RaiseEvent Started
		  
		  // Kick off
		  mWorker.Run
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UniqueKeys(pTableName as string) As String
		  dim rcu as RowSet = me.mDatabase.SelectSQL("SELECT CONSTRAINT_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + pTableName + "' AND NOT constraint_name = 'PRIMARY'")
		  'System.DebugLog "SELECT CONSTRAINT_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + pTableName + "' AND NOT constraint_name = 'PRIMARY'"
		  if rcu.Column("CONSTRAINT_NAME").Value <> nil then
		    dim mPrimary as string = "UNIQUE KEY `" + rcu.Column("CONSTRAINT_NAME").StringValue + "` ("
		    
		    while Not rcu.AfterLastRow
		      mPrimary = mPrimary + "`" + rcu.Column("COLUMN_NAME").StringValue + "`"
		      rcu.MoveToNextRow
		      if not rcu.AfterLastRow then
		        mPrimary = mPrimary + ", "
		      end if
		    wend
		    mPrimary = mPrimary + ")"
		    
		    Return mPrimary
		  end if
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Worker_Run(t As Thread)
		  Try
		    // Example: announce “starting” to UI
		    t.AddUserInterfaceUpdate(New Dictionary("event":"progress","message":"Starting backup…","percent":0.0))
		    
		    // >>> Your long work here <<<
		    // If you want to keep all the logic in your current BackupNow(...),
		    // call a new private wrapper that checks mCancel and posts progress.
		    
		    mLastResult = DoBackupWithProgress(t) // returns FolderItem or Nil
		    
		    // Signal finished success
		    t.AddUserInterfaceUpdate(New Dictionary("event":"finished","hadError": (mLastResult Is Nil)))
		  Catch e As RuntimeException
		    t.AddUserInterfaceUpdate(New Dictionary("event":"error","message": e.Message))
		    t.AddUserInterfaceUpdate(New Dictionary("event":"finished","hadError": True))
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Worker_UIUpdate(t As Thread, info As Dictionary)
		  Var ev As String = info.Value("event").StringValue
		  
		  Select Case ev
		  Case "progress"
		    Var msg As String = info.Lookup("message","").StringValue
		    Var pct As Double =  info.Lookup("percent", -1.0).DoubleValue
		    RaiseEvent Progress(msg, pct)
		    
		  Case "error"
		    RaiseEvent ErrorOccurred(info.Lookup("message","Unknown error").StringValue)
		    
		  Case "finished"
		    Var hadErr As Boolean = info.Lookup("hadError", False).BooleanValue
		    RaiseEvent Finished(mLastResult, hadErr)
		    
		    // Cleanup
		    mIsRunning = False
		    If mWorker <> Nil Then
		      RemoveHandler mWorker.Run, AddressOf Worker_Run
		      'RemoveHandler mWorker.UserInterfaceUpdate, AddressOf Worker_UIUpdate
		      mWorker = Nil
		    End If
		  End Select
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ErrorOccurred(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Finished(result As FolderItem, hadError As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Progress(message As String, percent As Double)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Started()
	#tag EndHook


	#tag Property, Flags = &h21
		Private mCancel As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		mDatabase As Database
	#tag EndProperty

	#tag Property, Flags = &h0
		mFileName As String = "Untitle"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIsRunning As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastResult As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWorker As Thread
	#tag EndProperty


	#tag Constant, Name = kBackupCompleteMarker, Type = String, Dynamic = False, Default = \"-- KANJO_BACKUP_COMPLETE", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kBackupVersionHeader, Type = String, Dynamic = False, Default = \"-- KANJO_BACKUP_VERSION=2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kStatementEndMarker, Type = String, Dynamic = False, Default = \"-- KANJO_STATEMENT_END", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mDatabase"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Database"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="mFileName"
			Visible=false
			Group="Behavior"
			InitialValue="Untitle"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
