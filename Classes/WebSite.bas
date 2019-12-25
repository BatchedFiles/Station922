#include "WebSite.bi"
#include "win\shlwapi.bi"
#include "CharacterConstants.bi"
#include "RequestedFile.bi"

Const DefaultFileNameDefaultXml = "default.xml"
Const DefaultFileNameDefaultXhtml = "default.xhtml"
Const DefaultFileNameDefaultHtm = "default.htm"
Const DefaultFileNameDefaultHtml = "default.html"
Const DefaultFileNameIndexXml = "index.xml"
Const DefaultFileNameIndexXhtml = "index.xhtml"
Const DefaultFileNameIndexHtm = "index.htm"
Const DefaultFileNameIndexHtml = "index.html"

Const MaxDefaultFileNameLength As Integer = 16 - 1

Declare Function OpenFileForReading( _
	ByVal PathTranslated As WString Ptr, _
	ByVal ForReading As FileAccess _
)As Handle

Declare Function GetDefaultFileName( _
	ByVal Buffer As WString Ptr, _
	ByVal Index As Integer _
)As Boolean

Extern IID_IUnknown_WithoutMinGW As Const IID

Dim Shared GlobalWebSiteVirtualTable As IWebSiteVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@WebSiteQueryInterface, _
		@WebSiteAddRef, _
		@WebSiteRelease _
	), _
	@WebSiteGetHostName, _
	@WebSiteGetExecutableDirectory, _
	@WebSiteGetSitePhysicalDirectory, _
	@WebSiteGetVirtualPath, _
	@WebSiteGetIsMoved, _
	@WebSiteGetMovedUrl, _
	@WebSiteMapPath, _
	@WebSiteGetRequestedFile, _
	@WebSiteNeedCgiProcessing, _
	@WebSiteNeedDllProcessing _
)

Sub InitializeWebSite( _
		ByVal pWebSite As WebSite Ptr _
	)
	
	pWebSite->pVirtualTable = @GlobalWebSiteVirtualTable
	pWebSite->ReferenceCounter = 0
	pWebSite->pHostName = NULL
	pWebSite->pPhysicalDirectory = NULL
	pWebSite->pExecutableDirectory = NULL
	pWebSite->pVirtualPath = NULL
	pWebSite->IsMoved = False
	pWebSite->pMovedUrl = NULL
	
End Sub

Function InitializeWebSiteOfIWebSite( _
		ByVal pWebSite As WebSite Ptr _
	)As IWebSite Ptr
	
	InitializeWebSite(pWebSite)
	pWebSite->ExistsInStack = True
	
	Dim pIWebSite As IWebSite Ptr = Any
	
	WebSiteQueryInterface( _
		pWebSite, @IID_IWebSite, @pIWebSite _
	)
	
	Return pIWebSite
	
End Function

Function WebSiteQueryInterface( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebSite, riid) Then
		*ppv = @pWebSite->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown_WithoutMinGW, riid) Then
			*ppv = @pWebSite->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebSiteAddRef(pWebSite)
	
	Return S_OK
	
End Function

Function WebSiteAddRef( _
		ByVal pWebSite As WebSite Ptr _
	)As ULONG
	
	pWebSite->ReferenceCounter += 1
	
	Return pWebSite->ReferenceCounter
	
End Function

Function WebSiteRelease( _
		ByVal pWebSite As WebSite Ptr _
	)As ULONG
	
	pWebSite->ReferenceCounter -= 1
	
	If pWebSite->ReferenceCounter = 0 Then
		
		If pWebSite->ExistsInStack = False Then
			HeapFree(GetProcessHeap(), 0, pWebSite)
		End If
		
		Return 0
	End If
	
	Return pWebSite->ReferenceCounter
	
End Function

Function WebSiteGetHostName( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal ppHost As WString Ptr Ptr _
	)As HRESULT
	
	*ppHost = pWebSite->pHostName
	
	Return S_OK
	
End Function

Function WebSiteGetExecutableDirectory( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	*ppExecutableDirectory = pWebSite->pExecutableDirectory
	
	Return S_OK
	
End Function

Function WebSiteGetSitePhysicalDirectory( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal ppPhysicalDirectory As WString Ptr Ptr _
	)As HRESULT
	
	*ppPhysicalDirectory = pWebSite->pPhysicalDirectory
	
	Return S_OK
	
End Function

Function WebSiteGetVirtualPath( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal ppVirtualPath As WString Ptr Ptr _
	)As HRESULT
	
	*ppVirtualPath = pWebSite->pVirtualPath
	
	Return S_OK
	
End Function

Function WebSiteGetIsMoved( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	*pIsMoved = pWebSite->IsMoved
	
	Return S_OK
	
End Function

Function WebSiteGetMovedUrl( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal ppMovedUrl As WString Ptr Ptr _
	)As HRESULT
	
	*ppMovedUrl = pWebSite->pMovedUrl
	
	Return S_OK
	
End Function

Function WebSiteMapPath( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal Path As WString Ptr, _
		ByVal pResult As WString Ptr _
	)As HRESULT
	
	lstrcpy(pResult, pWebSite->pPhysicalDirectory)
	Dim BufferLength As Integer = lstrlen(pResult)
	
	If pResult[BufferLength - 1] <> Characters.ReverseSolidus Then
		pResult[BufferLength] = Characters.ReverseSolidus
		BufferLength += 1
		pResult[BufferLength] = 0
	End If
	
	If lstrlen(Path) <> 0 Then
		If Path[0] = Characters.Solidus Then
			lstrcat(pResult, @Path[1])
		Else
			lstrcat(pResult, Path)
		End If
	End If
	
	For i As Integer = 0 To lstrlen(pResult) - 1
		If pResult[i] = Characters.Solidus Then
			pResult[i] = Characters.ReverseSolidus
		End If
	Next
	
	Return S_OK
	
End Function

' TODO Убрать манипуляцию данными объекта, использовать интерфейс
Function WebSiteGetRequestedFile( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal FilePath As WString Ptr, _
		ByVal ForReading As FileAccess, _
		ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	
	*ppIRequestedFile = NULL
	
	Dim pRequestedFile As RequestedFile Ptr = CreateRequestedFile()
	
	If pRequestedFile = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	If FilePath[lstrlen(FilePath) - 1] <> Characters.Solidus Then
		' FilePath содержит имя конкретного файла
		lstrcpy(pRequestedFile->FilePath, FilePath)
		
		WebSiteMapPath( _
			pWebSite, _
			@pRequestedFile->FilePath, _
			@pRequestedFile->PathTranslated _
		)
		
		pRequestedFile->FileHandle = OpenFileForReading( _
			@pRequestedFile->PathTranslated, _
			ForReading _
		)
		
		Dim hr As HRESULT = RequestedFileQueryInterface( _
			pRequestedFile, @IID_IRequestedFile, ppIRequestedFile _
		)
		
		If FAILED(hr) Then
			DestroyRequestedFile(pRequestedFile)
			Return hr
		End If
		
		Return S_OK
		
	Else
		Dim DefaultFilenameIndex As Integer = 0
		Dim DefaultFilename As WString * (MaxDefaultFileNameLength + 1) = Any
		
		Dim GetDefaultFileNameResult As Boolean = GetDefaultFileName(@DefaultFilename, DefaultFilenameIndex)
		
		Do
			lstrcpy(@pRequestedFile->FilePath, FilePath)
			lstrcat(@pRequestedFile->FilePath, DefaultFilename)
			
			WebSiteMapPath( _
				pWebSite, _
				@pRequestedFile->FilePath, _
				@pRequestedFile->PathTranslated _
			)
			
			pRequestedFile->FileHandle = OpenFileForReading( _
				@pRequestedFile->PathTranslated, _
				ForReading _
			)
			
			If pRequestedFile->FileHandle <> INVALID_HANDLE_VALUE Then
				
				Dim hr As HRESULT = RequestedFileQueryInterface( _
					pRequestedFile, @IID_IRequestedFile, ppIRequestedFile _
				)
				
				If FAILED(hr) Then
					DestroyRequestedFile(pRequestedFile)
					Return hr
				End If
				
				Return S_OK
				
			End If
			
			DefaultFilenameIndex += 1
			GetDefaultFileNameResult = GetDefaultFileName(@DefaultFilename, DefaultFilenameIndex)
			
		Loop While GetDefaultFileNameResult
		
		' Файл по умолчанию не найден
		GetDefaultFileName(DefaultFilename, 0)
		
		lstrcpy(@pRequestedFile->FilePath, FilePath)
		lstrcat(@pRequestedFile->FilePath, @DefaultFilename)
		
		WebSiteMapPath( _
			pWebSite, _
			@pRequestedFile->FilePath, _
			@pRequestedFile->PathTranslated _
		)
		
		pRequestedFile->FileHandle = INVALID_HANDLE_VALUE
		
		Dim hr As HRESULT = RequestedFileQueryInterface( _
			pRequestedFile, @IID_IRequestedFile, ppIRequestedFile _
		)
		
		If FAILED(hr) Then
			DestroyRequestedFile(pRequestedFile)
			Return hr
		End If
		
		Return S_FALSE
		
	End If
	
End Function

Function WebSiteNeedCgiProcessing( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	If StrStrI(Path, "/cgi-bin/") = Path Then
		*pResult = True
	Else
		*pResult = False
	End If
	
	Return S_OK
	
End Function

Function WebSiteNeedDllProcessing( _
		ByVal pWebSite As WebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	If StrStrI(Path, "/cgi-dll/") = Path Then
		*pResult = True
	Else
		*pResult = False
	End If
	
	Return S_OK
	
End Function

Function GetDefaultFileName( _
		ByVal Buffer As WString Ptr, _
		ByVal Index As Integer _
	)As Boolean
	
	Select Case Index
		
		Case 0
			lstrcpy(Buffer, @DefaultFileNameDefaultXml)
			
		Case 1
			lstrcpy(Buffer, @DefaultFileNameDefaultXhtml)
			
		Case 2
			lstrcpy(Buffer, @DefaultFileNameDefaultHtm)
			
		Case 3
			lstrcpy(Buffer, @DefaultFileNameDefaultHtml)
			
		Case 4
			lstrcpy(Buffer, @DefaultFileNameIndexXml)
			
		Case 5
			lstrcpy(Buffer, @DefaultFileNameIndexXhtml)
			
		Case 6
			lstrcpy(Buffer, @DefaultFileNameIndexHtm)
			
		Case 7
			lstrcpy(Buffer, @DefaultFileNameIndexHtml)
			
		Case Else
			Buffer[0] = 0
			Return False
			
	End Select
	
	Return True
	
End Function

Function OpenFileForReading( _
		ByVal PathTranslated As WString Ptr, _
		ByVal ForReading As FileAccess _
	)As Handle
	
	Select Case ForReading
		
		Case FileAccess.ForPut
			Return INVALID_HANDLE_VALUE
			
		Case FileAccess.ForGetHead
			Return CreateFile( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_SEQUENTIAL_SCAN, _
				NULL _
			)
			
		Case FileAccess.ForDelete
			Return CreateFile( _
				PathTranslated, _
				0, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL, _
				NULL _
			)
			
	End Select
End Function
