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
		Function BackupNow(fi as FolderItem, pWithDate as Boolean) As FolderItem
		  dim nowD as DateTime = DateTime.now
		  
		  dim sNowD as String = nowD.SQLDateTime().ReplaceAll(":", "")
		  
		  dim filename as String = "backup-" + me.mDatabase.DatabaseName
		  
		  if pWithDate then filename = filename + "-" + sNowD
		  fi = fi.Child( filename + ".sql", false)
		  
		  dim rc as RowSet = me.mDatabase.Tables
		  
		  
		  Dim output As TextOutputStream
		  Try
		    output = TextOutputStream.Create(fi)
		    
		    output.WriteLine("-- Xojo Desktop MySQL backup")
		    output.WriteLine("-- version 0.0.1")
		    output.WriteLine("-- https://kanjo.ca")
		    output.WriteLine("--")
		    output.WriteLine("-- Host: " + me.mDatabase.Host + ":" + me.mDatabase.DatabaseName )
		    output.WriteLine("-- Generation Time: " + nowD.SQLDateTime )
		    output.WriteLine("-- File Name: " + mFileName )
		    
		    output.WriteLine("SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';")
		    output.WriteLine("SET time_zone = '+00:00';")  // TODO : find a way to detect the timezone ?
		    output.WriteLine("")
		    output.WriteLine("")
		    
		    while not rc.AfterLastRow // create table
		      
		      // check fields properties
		      dim rcf as RowSet = me.mDatabase.SelectSQL("SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + rc.ColumnAt(0).StringValue + "' ORDER BY table_name, ordinal_position")
		      // check on Character Set for this table
		      dim rcc as RowSet = me.mDatabase.SelectSQL("SELECT DEFAULT_CHARACTER_SET_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE Schema_name = '" + me.mDatabase.DatabaseName + "'")
		      // check DB engine for this table
		      dim rci as RowSet = me.mDatabase.SelectSQL("SELECT ENGINE FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + rc.ColumnAt(0).StringValue + "'")
		      // check Primary Keys for this table
		      dim mPrimary as String = DefineEncoding(me.PrimaryKeys( rc.ColumnAt(0).StringValue ), Encodings.UTF8)
		      // check Unique Keys for this table
		      Dim mUnique as String = DefineEncoding(me.UniqueKeys( rc.ColumnAt(0).StringValue ), Encodings.UTF8)
		      
		      if mUnique <> "" then
		        if mPrimary <> "" then
		          mPrimary = mPrimary + "," + Text.FromUnicodeCodepoint(10)
		        end if
		      else
		        if mPrimary <> "" then
		          mPrimary = mPrimary + Text.FromUnicodeCodepoint(10)
		        end if
		      end if
		      
		      output.WriteLine("--")
		      output.WriteLine("-- Table structure for table `" + rc.ColumnAt(0).StringValue + "`")
		      output.WriteLine("--")
		      output.WriteLine("")
		      output.WriteLine("CREATE TABLE IF NOT EXISTS `" + rc.ColumnAt(0).StringValue + "` (")
		      
		      Dim mColumnsDataTypes() as String
		      
		      While not rcf.AfterLastRow
		        
		        dim mfield as string = "  `" + rcf.Column("Column_Name").StringValue + "` " + rcf.Column("Column_Type").StringValue + me.notNil(rcf.Column("is_Nullable")) + me.default(rcf.Column("Column_Default").Value) + " " + rcf.Column("extra").StringValue
		        
		        mColumnsDataTypes.Add(rcf.Column("Data_Type").StringValue)
		        
		        rcf.MoveToNextRow
		        
		        if Not rcf.AfterLastRow or mPrimary <> "" or mUnique <> "" then
		          mfield = mfield + ","
		        end if
		        output.WriteLine( DefineEncoding(mfield, Encodings.UTF8) )
		        
		      wend
		      
		      output.WriteLine(mPrimary)
		      output.WriteLine(mUnique)
		      
		      dim mEngine as string = ") ENGINE=" + rci.Column("ENGINE").StringValue + " DEFAULT CHARSET=" + rcc.Column("DEFAULT_CHARACTER_SET_NAME").StringValue + " ;"
		      
		      output.WriteLine(DefineEncoding(mEngine, Encodings.UTF8))
		      output.WriteLine("")
		      output.WriteLine("")
		      
		      // now it's time to backup Datas
		      dim rcData as RowSet = me.mDatabase.SelectSQL("Select * FROM " + rc.ColumnAt(0).StringValue )
		      
		      if rcData.RowCount > 0 then
		        
		        output.WriteLine("LOCK TABLES `" + rc.ColumnAt(0).StringValue + "` WRITE;")
		        
		        
		        // INSERT INTO ...
		        dim mINSERT as string = "INSERT INTO `" + rc.ColumnAt(0).StringValue + "` ("
		        
		        For i as Integer = 0 to rcData.ColumnCount-1
		          
		          mINSERT = mINSERT + "`" + rcData.ColumnAt(i).Name + "`"
		          
		          if i <> rcData.ColumnCount then
		            mINSERT = mINSERT + ", "
		          end if
		        Next
		        
		        mINSERT = mINSERT + ")" + EndOfLine
		        output.WriteLine( DefineEncoding(mINSERT, Encodings.UTF8) )
		        
		        // VALUES
		        output.WriteLine( "VALUES" )
		        
		        dim mData as string
		        
		        While Not rcData.AfterLastRow
		          mData = "("
		          For i as Integer = 0 to rcData.ColumnCount -1
		            
		            dim mPreData as string
		            if rcData.ColumnAt(i).Value.IsNull then
		              mPreData = "NULL"
		            else
		              mPreData = rcData.ColumnAt(i).StringValue.ReplaceAll("'", "\'")
		            end if
		            
		            
		            
		            if mColumnsDataTypes(i) = "int" _
		              or mColumnsDataTypes(i) = "tinyint" _
		              or mColumnsDataTypes(i) = "mediumint" _
		              or mColumnsDataTypes(i) = "smallint" _
		              or mColumnsDataTypes(i) = "decimal" _
		              or mPreData = "NULL" then
		              mData = mData + mPreData
		            Else
		              mData = mData + "'" + mPreData + "'"
		            End
		            
		            
		            
		            if i <> rcData.ColumnCount then
		              mData = mData + ","
		            end if
		          Next
		          
		          mData = mData + ")"
		          rcData.MoveToNextRow
		          
		          if Not rcData.AfterLastRow then
		            mData = mData + ","
		          else
		            mData = mData + ";"
		          end if
		          output.WriteLine( DefineEncoding(mData, Encodings.UTF8) )
		          
		          
		        Wend
		        
		        output.WriteLine("UNLOCK TABLES;")
		        
		      end if
		      
		      rc.MoveToNextRow
		    wend
		    
		    output.Close
		    Return fi
		  Catch e As IOException
		    
		    Return nil
		  End Try
		  
		End Function
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
