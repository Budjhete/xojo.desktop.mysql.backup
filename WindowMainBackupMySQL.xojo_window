#tag Window
Begin Window WindowMainBackupMySQL
   BackColor       =   &cFFFFFF00
   Backdrop        =   0
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   FullScreenButton=   False
   HasBackColor    =   False
   Height          =   700
   ImplicitInstance=   True
   LiveResize      =   "True"
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   True
   MaxWidth        =   32000
   MenuBar         =   1963620351
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "Untitled"
   Visible         =   True
   Width           =   1014
   Begin Listbox Listbox1
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   True
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   1
      ColumnWidths    =   ""
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLinesHorizontalStyle=   0
      GridLinesVerticalStyle=   0
      HasBorder       =   True
      HasHeader       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   610
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Nom tables"
      Italic          =   False
      Left            =   41
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   64
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   222
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin Listbox Listbox2
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   True
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   5
      ColumnWidths    =   ""
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLinesHorizontalStyle=   0
      GridLinesVerticalStyle=   0
      HasBorder       =   True
      HasHeader       =   True
      HasHorizontalScrollbar=   True
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   221
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Nom	Type	Primary	NotNull	Longueur"
      Italic          =   False
      Left            =   275
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   64
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   680
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin Listbox Listbox3
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   True
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   -1
      ColumnWidths    =   ""
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLinesHorizontalStyle=   0
      GridLinesVerticalStyle=   0
      HasBorder       =   True
      HasHeader       =   True
      HasHorizontalScrollbar=   True
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   377
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Nom	ColumType	Data"
      Italic          =   False
      Left            =   275
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   297
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   680
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin PushButton PushButton1
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "SQL text ouput"
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   515
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   32
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   132
   End
   Begin MySQL_Backup mMySQL_Backup
      Enabled         =   True
      Index           =   -2147483648
      LockedInPosition=   False
      mDatabase       =   0
      mFileName       =   "Untitle"
      Scope           =   0
      TabPanelIndex   =   0
   End
   Begin PushButton PushButton2
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Show Users"
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   659
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   32
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   132
   End
   Begin PushButton PushButton3
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Connect"
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   41
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   32
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   222
   End
End
#tag EndWindow

#tag WindowCode
#tag EndWindowCode

#tag Events Listbox1
	#tag Event
		Function CellClick(row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  Listbox2.DeleteAllRows
		  
		  dim rc as RecordSet = mMySQL_Backup.mDatabase.FieldSchema(me.Cell(row, column))
		  
		  dim rcf as new Dictionary
		  dim heads as string
		  while not rc.EOF
		    
		    rcf.Value(rc.Field("ColumnName").StringValue) = rc.Field("FieldType").IntegerValue
		    
		    
		    Listbox2.AddRow(rc.Field("ColumnName").StringValue, mMySQL_Backup.columnType(rc.Field("FieldType").IntegerValue), rc.Field("IsPrimary").StringValue, rc.Field("NotNull").StringValue, rc.Field("Length").StringValue)
		    
		    heads = heads + rc.Field("ColumnName").StringValue
		    
		    rc.MoveNext
		    if not rc.EOF then
		      heads = heads + Chr(9)
		    end if
		  wend
		  
		  Listbox3.DeleteAllRows
		  
		  rc = mMySQL_Backup.mDatabase.SQLSelect("Select * FROM " + me.Cell(row, column))
		  Listbox3.ColumnCount = rc.FieldCount
		  listbox3.Heading(-1) = heads
		  
		  
		  While Not rc.EOF
		    dim items() as string
		    
		    For i as Integer = 1 to rc.FieldCount
		      items.Append(rc.IdxField(i).StringValue)
		    Next
		    Listbox3.AddRow(items)
		    rc.MoveNext
		  Wend
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events PushButton1
	#tag Event
		Sub Action()
		  mMySQL_Backup.BackupNow
		  'mCompany.WriteLog(ModelLogs.Types.System, "Database Backup  dans le warehouse de base" )
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PushButton2
	#tag Event
		Sub Action()
		  WindowUsers.Show(mMySQL_Backup)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PushButton3
	#tag Event
		Sub Action()
		  if mMySQL_Backup.mDatabase <> Nil then
		    mMySQL_Backup.mDatabase.Close
		  end if
		  
		  
		  Dim db As New MySQLCommunityServer
		  db.Host = "localhost"
		  db.Port = 3306
		  db.DatabaseName = "k_test"
		  db.UserName = "test"
		  db.Password = "123"
		  
		  If db.Connect Then
		    db.ExecuteSQL("SET NAMES 'utf8'")
		    
		    mMySQL_Backup.mDatabase = db
		  Else
		    ' Connection error
		    MsgBox(db.ErrorMessage)
		  End If
		  
		  dim rc as RecordSet = mMySQL_Backup.mDatabase.TableSchema
		  Listbox1.DeleteAllRows
		  
		  while not rc.EOF
		    Listbox1.AddRow(rc.IdxField(1).StringValue)
		    rc.MoveNext
		  wend
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="0"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&hFFFFFF"
		Type="Color"
		EditorType="Color"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="MenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=false
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
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
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
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
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
