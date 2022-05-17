#include once "WebSite.bi"
#include once "win\shlwapi.bi"
#include once "IMutableWebSite.bi"
#include once "CharacterConstants.bi"
#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalMutableWebSiteVirtualTable As Const IMutableWebSiteVirtualTable

Const DefaultFileNameDefaultXml = WStr("default.xml")
Const DefaultFileNameDefaultXhtml = WStr("default.xhtml")
Const DefaultFileNameDefaultHtm = WStr("default.htm")
Const DefaultFileNameDefaultHtml = WStr("default.html")
Const DefaultFileNameIndexXml = WStr("index.xml")
Const DefaultFileNameIndexXhtml = WStr("index.xhtml")
Const DefaultFileNameIndexHtm = WStr("index.htm")
Const DefaultFileNameIndexHtml = WStr("index.html")

Const WEBSITE_MAXDEFAULTFILENAMELENGTH As Integer = 16 - 1
Const MaxHostNameLength As Integer = 1024 - 1

Type _WebSite
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IMutableWebSiteVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pHostName As HeapBSTR
	pPhysicalDirectory As HeapBSTR
	pVirtualPath As HeapBSTR
	pMovedUrl As HeapBSTR
	IsMoved As Boolean
End Type

Sub InitializeWebSite( _
		ByVal this As WebSite Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("WebSiteWebSiteWe"), 16)
	#endif
	this->lpVtbl = @GlobalMutableWebSiteVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pHostName = NULL
	this->pPhysicalDirectory = NULL
	this->pVirtualPath = NULL
	this->pMovedUrl = NULL
	this->IsMoved = False
	
End Sub

Sub UnInitializeWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	HeapSysFreeString(this->pHostName)
	HeapSysFreeString(this->pPhysicalDirectory)
	HeapSysFreeString(this->pVirtualPath)
	HeapSysFreeString(this->pMovedUrl)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateWebSite( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WebSite Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(WebSite)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"WebSite creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As WebSite Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSite) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeWebSite(this, pIMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebSite created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebSite destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebSite(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebSite destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WebSiteQueryInterface( _
		ByVal this As WebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebSite, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IMutableWebSite, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
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
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function WebSiteRelease( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyWebSite(this)
	
	Return 0
	
End Function

Function WebSiteGetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pHostName)
	*ppHost = this->pHostName
	
	Return S_OK
	
End Function

Function WebSiteGetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pPhysicalDirectory)
	*ppPhysicalDirectory = this->pPhysicalDirectory
	
	Return S_OK
	
End Function

Function WebSiteGetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pVirtualPath)
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
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pMovedUrl)
	*ppMovedUrl = this->pMovedUrl
	
	Return S_OK
	
End Function

Function WebSiteMapPath( _
		ByVal this As WebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As HeapBSTR Ptr _
	)As HRESULT
	/'
	lstrcpyW(pResult, this->pPhysicalDirectory)
	Dim BufferLength As Integer = lstrlenW(pResult)
	
	If pResult[BufferLength - 1] <> Characters.ReverseSolidus Then
		pResult[BufferLength] = Characters.ReverseSolidus
		BufferLength += 1
		pResult[BufferLength] = 0
	End If
	
	If lstrlenW(Path) <> 0 Then
		If Path[0] = Characters.Solidus Then
			lstrcatW(pResult, @Path[1])
		Else
			lstrcatW(pResult, Path)
		End If
	End If
	
	For i As Integer = 0 To lstrlenW(pResult) - 1
		If pResult[i] = Characters.Solidus Then
			pResult[i] = Characters.ReverseSolidus
		End If
	Next
	'/
	Return S_OK
	
End Function

/'
Function WebSiteOpenRequestedFile( _
		ByVal this As WebSite Ptr, _
		ByVal pRequestedFile As IRequestedFile Ptr, _
		ByVal FilePath As HeapBSTR, _
		ByVal fAccess As FileAccess _
	)As HRESULT
	/'
	Dim PathTranslated As WString * (MAX_PATH + 1) = Any
	
	If FilePath[lstrlenW(FilePath) - 1] <> Characters.Solidus Then
		
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
		lstrcpyW(@FullDefaultFilename, FilePath)
		lstrcatW(@FullDefaultFilename, DefaultFilename)
		
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
	
	GetDefaultFileName(DefaultFilename, 0)
	
	lstrcpyW(@FullDefaultFilename, FilePath)
	lstrcatW(@FullDefaultFilename, @DefaultFilename)
	
	WebSiteMapPath(this, @FullDefaultFilename, @PathTranslated)
	
	IRequestedFile_SetPathTranslated(pRequestedFile, PathTranslated)
	IRequestedFile_SetFilePath(pRequestedFile, FullDefaultFilename)
	IRequestedFile_SetFileHandle(pRequestedFile, INVALID_HANDLE_VALUE)
	'/
	Return S_FALSE
	
End Function
'/

Function WebSiteNeedCgiProcessing( _
		ByVal this As WebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	If StrStrIW(Path, WStr("/cgi-bin/")) = NULL Then
		*pResult = False
	Else
		*pResult = True
	End If
	
	Return S_OK
	
End Function

Function WebSiteNeedDllProcessing( _
		ByVal this As WebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	If StrStrIW(Path, WStr("/cgi-dll/")) = NULL Then
		*pResult = False
	Else
		*pResult = True
	End If
	
	Return S_OK
	
End Function

Function GetDefaultFileName( _
		ByVal Buffer As WString Ptr, _
		ByVal Index As Integer _
	)As Boolean
	
	Select Case Index
		
		Case 0
			lstrcpyW(Buffer, @DefaultFileNameDefaultXml)
			
		Case 1
			lstrcpyW(Buffer, @DefaultFileNameDefaultXhtml)
			
		Case 2
			lstrcpyW(Buffer, @DefaultFileNameDefaultHtm)
			
		Case 3
			lstrcpyW(Buffer, @DefaultFileNameDefaultHtml)
			
		Case 4
			lstrcpyW(Buffer, @DefaultFileNameIndexXml)
			
		Case 5
			lstrcpyW(Buffer, @DefaultFileNameIndexXhtml)
			
		Case 6
			lstrcpyW(Buffer, @DefaultFileNameIndexHtm)
			
		Case 7
			lstrcpyW(Buffer, @DefaultFileNameIndexHtml)
			
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
	
	' Dim dwError As DWORD = Any
	
	Select Case ForReading
		
		Case FileAccess.ReadAccess
			' dwError = GetLastError()
			Return CreateFileW( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_SEQUENTIAL_SCAN, _
				NULL _
			)
			
		Case FileAccess.DeleteAccess
			' dwError = GetLastError()
			Return CreateFileW( _
				PathTranslated, _
				0, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL, _
				NULL _
			)
			
		Case Else
			' dwError = 0
			Return INVALID_HANDLE_VALUE
			
	End Select
	
End Function

Function MutableWebSiteSetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pHostName, pHost)
	
	Return S_OK
	
End Function

Function MutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pPhysicalDirectory, pPhysicalDirectory)
	
	Return S_OK
	
End Function

Function MutableWebSiteSetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pVirtualPath, pVirtualPath)
	
	Return S_OK
	
End Function

Function MutableWebSiteSetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	this->IsMoved = IsMoved
	
	Return S_OK
	
End Function

Function MutableWebSiteSetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pMovedUrl, pMovedUrl)
	
	Return S_OK
	
End Function


Function IMutableWebSiteQueryInterface( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return WebSiteQueryInterface(ContainerOf(this, WebSite, lpVtbl), riid, ppvObject)
End Function

Function IMutableWebSiteAddRef( _
		ByVal this As IMutableWebSite Ptr _
	)As ULONG
	Return WebSiteAddRef(ContainerOf(this, WebSite, lpVtbl))
End Function

Function IMutableWebSiteRelease( _
		ByVal this As IMutableWebSite Ptr _
	)As ULONG
	Return WebSiteRelease(ContainerOf(this, WebSite, lpVtbl))
End Function

Function IMutableWebSiteGetHostName( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetHostName(ContainerOf(this, WebSite, lpVtbl), ppHost)
End Function

Function IMutableWebSiteGetSitePhysicalDirectory( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetSitePhysicalDirectory(ContainerOf(this, WebSite, lpVtbl), ppPhysicalDirectory)
End Function

Function IMutableWebSiteGetVirtualPath( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetVirtualPath(ContainerOf(this, WebSite, lpVtbl), ppVirtualPath)
End Function

Function IMutableWebSiteGetIsMoved( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	Return WebSiteGetIsMoved(ContainerOf(this, WebSite, lpVtbl), pIsMoved)
End Function

Function IMutableWebSiteGetMovedUrl( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetMovedUrl(ContainerOf(this, WebSite, lpVtbl), ppMovedUrl)
End Function

Function IMutableWebSiteMapPath( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteMapPath(ContainerOf(this, WebSite, lpVtbl), Path, pResult)
End Function

Function IMutableWebSiteNeedCgiProcessing( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	Return WebSiteNeedCgiProcessing(ContainerOf(this, WebSite, lpVtbl), path, pResult)
End Function

Function IMutableWebSiteNeedDllProcessing( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	Return WebSiteNeedDllProcessing(ContainerOf(this, WebSite, lpVtbl), path, pResult)
End Function

Function IMutableWebSiteSetHostName( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetHostName(ContainerOf(this, WebSite, lpVtbl), pHost)
End Function

Function IMutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetSitePhysicalDirectory(ContainerOf(this, WebSite, lpVtbl), pPhysicalDirectory)
End Function

Function IMutableWebSiteSetVirtualPath( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetVirtualPath(ContainerOf(this, WebSite, lpVtbl), pVirtualPath)
End Function

Function IMutableWebSiteSetIsMoved( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	Return MutableWebSiteSetIsMoved(ContainerOf(this, WebSite, lpVtbl), IsMoved)
End Function

Function IMutableWebSiteSetMovedUrl( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetMovedUrl(ContainerOf(this, WebSite, lpVtbl), pMovedUrl)
End Function

Dim GlobalMutableWebSiteVirtualTable As Const IMutableWebSiteVirtualTable = Type( _
	@IMutableWebSiteQueryInterface, _
	@IMutableWebSiteAddRef, _
	@IMutableWebSiteRelease, _
	@IMutableWebSiteGetHostName, _
	@IMutableWebSiteGetSitePhysicalDirectory, _
	@IMutableWebSiteGetVirtualPath, _
	@IMutableWebSiteGetIsMoved, _
	@IMutableWebSiteGetMovedUrl, _
	@IMutableWebSiteMapPath, _
	@IMutableWebSiteNeedCgiProcessing, _
	@IMutableWebSiteNeedDllProcessing, _
	@IMutableWebSiteSetHostName, _
	@IMutableWebSiteSetSitePhysicalDirectory, _
	@IMutableWebSiteSetVirtualPath, _
	@IMutableWebSiteSetIsMoved, _
	@IMutableWebSiteSetMovedUrl _
)

