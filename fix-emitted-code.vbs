Option Explicit

Dim FSO
Set FSO = CreateObject("Scripting.FileSystemObject")

Dim Lines
Lines = ReadTextFile(WScript.Arguments(1))

Dim LinesArray
LinesArray = Split(Lines, vbCrLf)

ParseFile

Dim OneLine
OneLine = Join(LinesArray, vbCrLf)

WriteTextFile WScript.Arguments(1), OneLine

Set FSO = Nothing

Function ReadTextFile(FileName)
	Dim TextStream
	Set TextStream = FSO.OpenTextFile(FileName, 1)
	
	Dim strLines
	strLines = TextStream.ReadAll
	
	TextStream.Close
	Set TextStream = Nothing
	
	ReadTextFile = strLines
End Function

Sub WriteTextFile(FileName, strText)
	Dim TextStream
	Set TextStream = FSO.OpenTextFile(FileName, 2)
	
	TextStream.Write strText
	
	TextStream.Close
	Set TextStream = Nothing
End Sub

Function CommentLine(strLine)
	CommentLine = "/* " & strLine & " */"
End Function

Function FixWinApiDeclaration(strLine)
	
	' Add "const" keyword to parameters
	' Add "volatile" keyword to parameters
	
	Select Case strLine
		
		Case "int32 memcmp( void*, void*, uint64 );"
			FixWinApiDeclaration = "int32 memcmp( const void*, const void*, uint64 );"
		
		Case "int32 memcmp( void*, void*, uint32 );"
			FixWinApiDeclaration = "int32 memcmp( const void*, const void*, uint32 );"
		
		Case "void* memcpy( void*, void*, uint64 );"
			FixWinApiDeclaration = "void* memcpy( void*, const void*, uint64 );"
			
		Case "void* memcpy( void*, void*, uint32 );"
			FixWinApiDeclaration = "void* memcpy( void*, const void*, uint32 );"
			
		Case "void* memmove( void*, void*, uint64 );"
			FixWinApiDeclaration = "void* memmove( void*, const void*, uint64 );"
		
		Case "void* memmove( void*, void*, uint32 );"
			FixWinApiDeclaration = "void* memmove( void*, const void*, uint32 );"
		
		Case "int64 _InterlockedExchangeAdd64( int64*, int64 );"
			FixWinApiDeclaration = "int64 _InterlockedExchangeAdd64( volatile int64*, int64 );"
		
		Case "int64 _InterlockedCompareExchange64( int64*, int64, int64 );"
			FixWinApiDeclaration = "long long _InterlockedCompareExchange64(volatile long long *, long long, long long);"
		
		Case "int32 _InterlockedExchangeAdd( int32*, int32 );"
			FixWinApiDeclaration = "long _InterlockedExchangeAdd( volatile long*, long );"
			
		Case Else
			FixWinApiDeclaration = strLine
			
	End Select
	
End Function

Function RemoveZeroedFunctionRetval(strLine, InsideMain)
	If InStr(strLine, "__builtin_memset( &fb$result") Then
		If InsideMain = True Then
			RemoveZeroedFunctionRetval = strLine
		Else
			RemoveZeroedFunctionRetval = CommentLine(strLine)
		End If
	Else
		RemoveZeroedFunctionRetval = strLine
	End If
End Function

Function RemoveStaticAssert(strLine)
	If InStr(strLine, "__FB_STATIC_ASSERT") Then
		RemoveStaticAssert = CommentLine(strLine)
	Else
		RemoveStaticAssert = strLine
	End If
End Function

Sub ParseFile()
	Dim RemarkFlag
	RemarkFlag = False
	
	Dim InsideMainFunction
	InsideMainFunction = False
	
	Dim i
	For i = 0 To UBound(LinesArray)
		
		If LinesArray(i) = "int32 main( int32 __FB_ARGC__, char** __FB_ARGV__ )" Then
			InsideMainFunction = True
		End If
		
		If LinesArray(i) = "int32 main( int32 __FB_ARGC__$0, char** __FB_ARGV__$0 )" Then
			InsideMainFunction = True
		End If
		
		If LinesArray(i) = "}" Then
			InsideMainFunction = False
		End If
		
		If WScript.Arguments(0) = "/debug" Then
			LinesArray(i) = FixWinApiDeclaration(LinesArray(i))
			LinesArray(i) = RemoveZeroedFunctionRetval(LinesArray(i), InsideMainFunction)
			LinesArray(i) = RemoveStaticAssert(LinesArray(i))
		Else
			Dim LastChar
			
			If RemarkFlag Then
				LastChar = Right(LinesArray(i), 1)
				If LastChar = "}" Then
					RemarkFlag = False
				Else
					Dim LastChar2
					LastChar2 = Right(LinesArray(i), 2)
					If LastChar2 = "};" Then
						RemarkFlag = False
					Else
						RemarkFlag = True
					End If
				End If
				LinesArray(i) = CommentLine(LinesArray(i))
			Else
				
				LinesArray(i) = FixWinApiDeclaration(LinesArray(i))
				LinesArray(i) = RemoveZeroedFunctionRetval(LinesArray(i), InsideMainFunction)
				LinesArray(i) = RemoveStaticAssert(LinesArray(i))
				
				If InStr(LinesArray(i), "__attribute__") Then
					LastChar = Right(LinesArray(i), 1)
					If LastChar = ";" Then
						RemarkFlag = False
						If InStr(LinesArray(i), "packed") Then
						Else
							LinesArray(i) = CommentLine(LinesArray(i))
						End If
					Else
						If InStr(LinesArray(i), "gcc_struct") Then
						Else
							LinesArray(i) = CommentLine(LinesArray(i))
							RemarkFlag = True
						End If
					End If
				End If
			End If
		End If
	Next
End Sub
