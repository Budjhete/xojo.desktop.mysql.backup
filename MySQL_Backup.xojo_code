#tag Class
Protected Class MySQL_Backup
	#tag Method, Flags = &h0
		Sub BackupNow()
		  Using Xojo.Core
		  Using Xojo.IO
		  
		  BackupNow(SpecialFolder.Documents)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BackupNow(fi as xojo.io.FolderItem)
		  Using Xojo.Core
		  Using Xojo.IO
		  
		  dim nowD as Date = Date.now
		  
		  fi = fi.Child("backup-" + me.mDatabase.DatabaseName.ToText + "-" + nowD.ToText(Locale.Current, Date.FormatStyles.Short, Date.FormatStyles.none) + ".sql")
		  
		  dim rc as RecordSet = me.mDatabase.TableSchema
		  
		  
		  Dim output As TextOutputStream
		  Try
		    output = TextOutputStream.Create(fi, TextEncoding.UTF8)
		    
		    output.WriteLine("-- Xojo Desktop MySQL backup")
		    output.WriteLine("-- version 0.0.1")
		    output.WriteLine("-- http://kanjo.ca")
		    output.WriteLine("--")
		    output.WriteLine("-- Host: " + me.mDatabase.Host.ToText + ":" + me.mDatabase.DatabaseName.ToText )
		    output.WriteLine("-- Generation Time: " + nowD.ToText )
		    output.WriteLine("-- File Name: " + mFileName )
		    
		    output.WriteLine("SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';")
		    output.WriteLine("SET time_zone = '+00:00';")  // TODO : find a way to detect the timezone ?
		    output.WriteLine("")
		    output.WriteLine("")
		    
		    while not rc.EOF // create table
		      
		      // check fields properties
		      dim rcf as RecordSet = me.mDatabase.SQLSelect("SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + rc.IdxField(1).StringValue + "' ORDER BY table_name, ordinal_position")
		      // check on Character Set for this table
		      dim rcc as RecordSet = me.mDatabase.SQLSelect("SELECT DEFAULT_CHARACTER_SET_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE Schema_name = '" + me.mDatabase.DatabaseName + "'")
		      // check DB engine for this table
		      dim rci as RecordSet = me.mDatabase.SQLSelect("SELECT ENGINE FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + rc.IdxField(1).StringValue + "'")
		      // check Primary Keys for this table
		      dim mPrimary as text = DefineEncoding(me.PrimaryKeys( rc.IdxField(1).StringValue ), Encodings.UTF8).ToText
		      // check Unique Keys for this table
		      Dim mUnique as text = DefineEncoding(me.UniqueKeys( rc.IdxField(1).StringValue ), Encodings.UTF8).ToText
		      
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
		      output.WriteLine("-- Table structure for table `" + rc.IdxField(1).StringValue.ToText + "`")
		      output.WriteLine("--")
		      output.WriteLine("")
		      output.WriteLine("CREATE TABLE IF NOT EXISTS `" + rc.IdxField(1).StringValue.ToText + "` (")
		      
		      Dim mColumnsDataTypes() as String
		      
		      While not rcf.EOF
		        
		        dim mfield as string = "  `" + rcf.Field("Column_Name").StringValue + "` " + rcf.Field("Column_Type").StringValue + me.notNil(rcf.Field("is_Nullable")) + me.default(rcf.Field("Column_Default").Value) + " " + rcf.Field("extra").StringValue
		        
		        mColumnsDataTypes.Append(rcf.Field("Data_Type").StringValue)
		        
		        rcf.MoveNext
		        
		        if Not rcf.EOF or mPrimary <> "" or mUnique <> "" then
		          mfield = mfield + ","
		        end if
		        output.WriteLine( DefineEncoding(mfield, Encodings.UTF8).ToText )
		        
		      wend
		      
		      output.WriteLine(mPrimary)
		      output.WriteLine(mUnique)
		      
		      dim mEngine as string = ") ENGINE=" + rci.Field("ENGINE").StringValue + " DEFAULT CHARSET=" + rcc.Field("DEFAULT_CHARACTER_SET_NAME").StringValue + " ;"
		      
		      output.WriteLine(DefineEncoding(mEngine, Encodings.UTF8).ToText)
		      output.WriteLine("")
		      output.WriteLine("")
		      
		      // now it's time to backup Datas
		      dim rcData as RecordSet = me.mDatabase.SQLSelect("Select * FROM " + rc.IdxField(1).StringValue )
		      
		      if rcData.RecordCount > 0 then
		        
		        output.WriteLine("LOCK TABLES `" + rc.IdxField(1).StringValue.ToText + "` WRITE;")
		        
		        
		        // INSERT INTO ...
		        dim mINSERT as string = "INSERT INTO `" + rc.IdxField(1).StringValue + "` ("
		        
		        For i as Integer = 1 to rcData.FieldCount
		          
		          mINSERT = mINSERT + "`" + rcData.IdxField(i).Name + "`"
		          
		          if i <> rcData.FieldCount then
		            mINSERT = mINSERT + ", "
		          end if
		        Next
		        
		        mINSERT = mINSERT + ")" + EndOfLine
		        output.WriteLine( DefineEncoding(mINSERT, Encodings.UTF8).ToText )
		        
		        // VALUES
		        output.WriteLine( "VALUES" )
		        
		        dim mData as string
		        
		        While Not rcData.EOF
		          mData = "("
		          For i as Integer = 1 to rcData.FieldCount
		            
		            dim mPreData as string
		            if rcData.IdxField(i).Value.IsNull then
		              mPreData = "NULL"
		            else
		              mPreData = ReplaceAll(rcData.IdxField(i).StringValue, "'", "\'")
		            end if
		            
		            
		            
		            if mColumnsDataTypes(i-1) = "int" _
		              or mColumnsDataTypes(i-1) = "tinyint" _
		              or mColumnsDataTypes(i-1) = "mediumint" _
		              or mColumnsDataTypes(i-1) = "smallint" _
		              or mColumnsDataTypes(i-1) = "decimal" _
		              or mPreData = "NULL" then
		              mData = mData + mPreData
		            Else
		              mData = mData + "'" + mPreData + "'"
		            End
		            
		            
		            
		            if i <> rcData.FieldCount then
		              mData = mData + ","
		            end if
		          Next
		          
		          mData = mData + ")"
		          rcData.MoveNext
		          
		          if Not rcData.EOF then
		            mData = mData + ","
		          else
		            mData = mData + ";"
		          end if
		          output.WriteLine( DefineEncoding(mData, Encodings.UTF8).ToText )
		          
		          
		        Wend
		        
		        output.WriteLine("UNLOCK TABLES;")
		        
		      end if
		      
		      rc.MoveNext
		    wend
		    
		    output.Close
		    
		  Catch e As IOException
		    System.DebugLog "Unable to append to file."
		  End Try
		  
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
		  dim rcp as RecordSet = me.mDatabase.SQLSelect("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + pTableName + "' AND constraint_name = 'PRIMARY'")
		  if rcp.Field("COLUMN_NAME").Value <> nil then
		    dim mPrimary as string = "PRIMARY KEY ("
		    
		    while Not rcp.EOF
		      mPrimary = mPrimary + "`" + rcp.Field("COLUMN_NAME").StringValue + "`"
		      rcp.MoveNext
		      if not rcp.EOF then
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
		Function UniqueKeys(pTableName as string) As String
		  dim rcu as RecordSet = me.mDatabase.SQLSelect("SELECT CONSTRAINT_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + pTableName + "' AND NOT constraint_name = 'PRIMARY'")
		  'System.DebugLog "SELECT CONSTRAINT_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE table_schema = '" + me.mDatabase.DatabaseName + "' AND table_name = '" + pTableName + "' AND NOT constraint_name = 'PRIMARY'"
		  if rcu.Field("CONSTRAINT_NAME").Value <> nil then
		    dim mPrimary as string = "UNIQUE KEY `" + rcu.Field("CONSTRAINT_NAME").StringValue + "` ("
		    
		    while Not rcu.EOF
		      mPrimary = mPrimary + "`" + rcu.Field("COLUMN_NAME").StringValue + "`"
		      rcu.MoveNext
		      if not rcu.EOF then
		        mPrimary = mPrimary + ", "
		      end if
		    wend
		    mPrimary = mPrimary + ")"
		    
		    Return mPrimary
		  end if
		  
		  Return ""
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		mDatabase As Database
	#tag EndProperty

	#tag Property, Flags = &h0
		mFileName As Text = "Untitle"
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="mDatabase"
			Group="Behavior"
			Type="Database"
		#tag EndViewProperty
		#tag ViewProperty
			Name="mFileName"
			Group="Behavior"
			InitialValue="Untitle"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
