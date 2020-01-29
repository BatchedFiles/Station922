#include "WebSite.bi"
#include "win\shlwapi.bi"
#include "CharacterConstants.bi"
#include "ContainerOf.bi"
#include "IMutableWebSite.bi"
#include "RequestedFile.bi"

Const DefaultFileNameDefaultXml = "default.xml"
Const DefaultFileNameDefaultXhtml = "default.xhtml"
Const DefaultFileNameDefaultHtm = "default.htm"
Const DefaultFileNameDefaultHtml = "default.html"
Const DefaultFileNameIndexXml = "index.xml"
Const DefaultFileNameIndexXhtml = "index.xhtml"
Const DefaultFileNameIndexHtm = "index.htm"
Const DefaultFileNameIndexHtml = "index.html"

Const WEBSITE_MAXDEFAULTFILENAMELENGTH As Integer = 16 - 1

Declare Function OpenFileForReading( _
	ByVal PathTranslated As WString Ptr, _
	ByVal ForReading As FileAccess _
)As HANDLE

Declare Function GetDefaultFileName( _
	ByVal Buffer As WString Ptr, _
	ByVal Index As Integer _
)As Boolean

Type _WebSite
	
	Dim pVirtualTable As IWebSiteVirtualTable Ptr
	Dim pMutableWebSiteVirtualTable As IMutableWebSiteVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim hHeap As HANDLE
	
	Dim pHostName As WString Ptr
	Dim pPhysicalDirectory As WString Ptr
	Dim pExecutableDirectory As WString Ptr
	Dim pVirtualPath As WString Ptr
	Dim IsMoved As Boolean
	Dim pMovedUrl As WString Ptr
	
End Type

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
	@WebSiteOpenRequestedFile, _
	@WebSiteNeedCgiProcessing, _
	@WebSiteNeedDllProcessing _
)

Dim Shared GlobalMutableWebSiteVirtualTable As IMutableWebSiteVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@MutableWebSiteQueryInterface, _
		@MutableWebSiteAddRef, _
		@MutableWebSiteRelease _
	), _
	@MutableWebSiteSetHostName, _
	@MutableWebSiteSetExecutableDirectory, _
	@MutableWebSiteSetSitePhysicalDirectory, _
	@MutableWebSiteSetVirtualPath, _
	@MutableWebSiteSetIsMoved, _
	@MutableWebSiteSetMovedUrl _
)

Sub InitializeWebSite( _
		ByVal this As WebSite Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->pVirtualTable = @GlobalWebSiteVirtualTable
	this->pMutableWebSiteVirtualTable = @GlobalMutableWebSiteVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	this->pHostName = NULL
	this->pPhysicalDirectory = NULL
	this->pExecutableDirectory = NULL
	this->pVirtualPath = NULL
	this->IsMoved = False
	this->pMovedUrl = NULL
	
End Sub

Sub UnInitializeWebSite( _
		ByVal this As WebSite Ptr _
	)
	
End Sub

Function CreateWebSite( _
		ByVal hHeap As HANDLE _
	)As WebSite Ptr
	
	Dim pWebSite As WebSite Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(WebSite) _
	)
	
	If pWebSite = NULL Then
		Return NULL
	End If
	
	InitializeWebSite(pWebSite, hHeap)
	
	Return pWebSite
	
End Function

Sub DestroyWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	UnInitializeWebSite(this)
	
	HeapFree( _
		this->hHeap, _
		HEAP_NO_SERIALIZE, _
		this _
	)
	
End Sub

Function WebSiteQueryInterface( _
		ByVal this As WebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebSite, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_IMutableWebSite, riid) Then
			*ppv = @this->pMutableWebSiteVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->pVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	WebSiteAddRef(this)
	
	Return S_OK
	
End Function

Function WebSiteAddRef( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function WebSiteRelease( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyWebSite(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function WebSiteGetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal ppHost As WString Ptr Ptr _
	)As HRESULT
	
	*ppHost = this->pHostName
	
	Return S_OK
	
End Function

Function WebSiteGetExecutableDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	*ppExecutableDirectory = this->pExecutableDirectory
	
	Return S_OK
	
End Function

Function WebSiteGetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal ppPhysicalDirectory As WString Ptr Ptr _
	)As HRESULT
	
	*ppPhysicalDirectory = this->pPhysicalDirectory
	
	Return S_OK
	
End Function

Function WebSiteGetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal ppVirtualPath As WString Ptr Ptr _
	)As HRESULT
	
	*ppVirtualPath = this->pVirtualPath
	
	Return S_OK
	
End Function

Function WebSiteGetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	*pIsMoved = this->IsMoved
	
	Return S_OK
	
End Function

Function WebSiteGetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal ppMovedUrl As WString Ptr Ptr _
	)As HRESULT
	
	*ppMovedUrl = this->pMovedUrl
	
	Return S_OK
	
End Function

Function WebSiteMapPath( _
		ByVal this As WebSite Ptr, _
		ByVal Path As WString Ptr, _
		ByVal pResult As WString Ptr _
	)As HRESULT
	
	lstrcpy(pResult, this->pPhysicalDirectory)
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

Function WebSiteOpenRequestedFile( _
		ByVal this As WebSite Ptr, _
		ByVal pRequestedFile As IRequestedFile Ptr, _
		ByVal FilePath As WString Ptr, _
		ByVal fAccess As FileAccess _
	)As HRESULT
	
	Dim PathTranslated As WString * (MAX_PATH + 1) = Any
	
	If FilePath[lstrlen(FilePath) - 1] <> Characters.Solidus Then
		' FilePath содержит имя конкретного файла
		
		WebSiteMapPath(this, FilePath, @PathTranslated)
		Dim hFile As HANDLE = OpenFileForReading(@PathTranslated, fAccess)
		
		IRequestedFile_SetPathTranslated(pRequestedFile, PathTranslated)
		IRequestedFile_SetFilePath(pRequestedFile, FilePath)
		IRequestedFile_SetFileHandle(pRequestedFile, hFile)
		
		Return S_OK
		
	End If
	
	Dim DefaultFilenameIndex As Integer = 0
	Dim DefaultFilename As WString * (WEBSITE_MAXDEFAULTFILENAMELENGTH + 1) = Any
	Dim FullDefaultFilename As WString * (MAX_PATH + 1) = Any
	
	Dim GetDefaultFileNameResult As Boolean = GetDefaultFileName(@DefaultFilename, DefaultFilenameIndex)
	
	Do
		lstrcpy(@FullDefaultFilename, FilePath)
		lstrcat(@FullDefaultFilename, DefaultFilename)
		
		WebSiteMapPath(this, @FullDefaultFilename, @PathTranslated)
		
		Dim hFile As HANDLE = OpenFileForReading(@PathTranslated, fAccess)
		
		If hFile <> INVALID_HANDLE_VALUE Then
			
			IRequestedFile_SetPathTranslated(pRequestedFile, PathTranslated)
			IRequestedFile_SetFilePath(pRequestedFile, FullDefaultFilename)
			IRequestedFile_SetFileHandle(pRequestedFile, hFile)
			Return S_OK
			
		End If
		
		DefaultFilenameIndex += 1
		GetDefaultFileNameResult = GetDefaultFileName(@DefaultFilename, DefaultFilenameIndex)
		
	Loop While GetDefaultFileNameResult
	
	' Файл по умолчанию не найден
	GetDefaultFileName(DefaultFilename, 0)
	
	lstrcpy(@FullDefaultFilename, FilePath)
	lstrcat(@FullDefaultFilename, @DefaultFilename)
	
	WebSiteMapPath(this, @FullDefaultFilename, @PathTranslated)
	
	IRequestedFile_SetPathTranslated(pRequestedFile, PathTranslated)
	IRequestedFile_SetFilePath(pRequestedFile, FullDefaultFilename)
	IRequestedFile_SetFileHandle(pRequestedFile, INVALID_HANDLE_VALUE)
	
	Return S_FALSE
	
End Function

Function WebSiteNeedCgiProcessing( _
		ByVal this As WebSite Ptr, _
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
		ByVal this As WebSite Ptr, _
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
	)As HANDLE
	
	Dim dwError As DWORD = Any
	
	Select Case ForReading
		
		Case FileAccess.ReadAccess
			dwError = GetLastError()
			Return CreateFile( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_SEQUENTIAL_SCAN, _
				NULL _
			)
			
		Case FileAccess.DeleteAccess
			dwError = GetLastError()
			Return CreateFile( _
				PathTranslated, _
				0, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL, _
				NULL _
			)
			
		Case Else
			dwError = 0
			Return INVALID_HANDLE_VALUE
			
	End Select
	
End Function

Function MutableWebSiteQueryInterface( _
		ByVal this As WebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	Return WebSiteQueryInterface( _
		pWebSite, riid, ppv _
	)
	
End Function

Function MutableWebSiteAddRef( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	Return WebSiteAddRef(pWebSite)
	
End Function

Function MutableWebSiteRelease( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	Return WebSiteRelease(pWebSite)
	
End Function

Function MutableWebSiteSetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal pHost As WString Ptr _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	pWebSite->pHostName = pHost
	
	Return S_OK
	
End Function

Function MutableWebSiteSetExecutableDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal pExecutableDirectory As WString Ptr _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	pWebSite->pExecutableDirectory = pExecutableDirectory
	
	Return S_OK
	
End Function

Function MutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal pPhysicalDirectory As WString Ptr _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	pWebSite->pPhysicalDirectory = pPhysicalDirectory
	
	Return S_OK
	
End Function

Function MutableWebSiteSetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal pVirtualPath As WString Ptr _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	pWebSite->pVirtualPath = pVirtualPath
	
	Return S_OK
	
End Function

Function MutableWebSiteSetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	pWebSite->IsMoved = IsMoved
	
	Return S_OK
	
End Function

Function MutableWebSiteSetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal pMovedUrl As WString Ptr _
	)As HRESULT
	
	Dim pWebSite As WebSite Ptr = ContainerOf(this, WebSite, pMutableWebSiteVirtualTable)
	
	pWebSite->pMovedUrl = pMovedUrl
	
	Return S_OK
	
End Function
