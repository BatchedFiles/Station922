#include once "WebSite.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "FileBuffer.bi"

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

Function GetFileHandle( _
		ByVal PathTranslated As WString Ptr, _
		ByVal ForReading As FileAccess, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim FileHandle As HANDLE = Any
	Dim hrErrorCode As HRESULT = Any
	
	Select Case ForReading
		
		Case FileAccess.ReadAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL, _
				NULL _
			)
			If FileHandle = INVALID_HANDLE_VALUE Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
		Case FileAccess.DeleteAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				0, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_DELETE_ON_CLOSE, _
				NULL _
			)
			If FileHandle = INVALID_HANDLE_VALUE Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
		Case Else
			'FileAccess.CreateAccess, FileAccess.UpdateAccess
			FileHandle = INVALID_HANDLE_VALUE
			hrErrorCode = S_OK
			
	End Select
	
	*pFileHandle = FileHandle
	Return hrErrorCode
	
End Function

Sub ReplaceSolidus( _
		ByVal pBuffer As WString Ptr, _
		ByVal Length As Integer _
	)
	
	For i As Integer = 0 To Length - 1
		If pBuffer[i] = Characters.Solidus Then
			pBuffer[i] = Characters.ReverseSolidus
		End If
	Next
	
End Sub

Function WebSiteMapPath( _
		ByVal this As WebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pBuffer As WString Ptr _
	)As HRESULT
	
	lstrcpyW(pBuffer, this->pPhysicalDirectory)
	
	Scope
		Dim BufferLength As Integer = SysStringLen(this->pPhysicalDirectory)
		
		If pBuffer[BufferLength - 1] <> Characters.ReverseSolidus Then
			pBuffer[BufferLength] = Characters.ReverseSolidus
			BufferLength += 1
			pBuffer[BufferLength] = 0
		End If
	End Scope
	
	If SysStringLen(Path) Then
		If Path[0] = Characters.Solidus Then
			lstrcatW(pBuffer, @Path[1])
		Else
			lstrcatW(pBuffer, Path)
		End If
	End If
	
	Dim BufferLength As Integer = lstrlenW(pBuffer)
	ReplaceSolidus(pBuffer, BufferLength)
	
	Return S_OK
	
End Function

Function WebSiteOpenRequestedFile( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pFile As IFileBuffer Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal fAccess As FileAccess _
	)As HRESULT
	
	Dim PathTranslated As WString * (MAX_PATH + 1) = Any
	
	If Path[lstrlenW(Path) - 1] <> Characters.Solidus Then
		
		WebSiteMapPath(this, Path, @PathTranslated)
		Dim hFile As HANDLE = Any
		GetFileHandle(@PathTranslated, fAccess, @hFile)
		
		Dim pt As HeapBSTR = HeapSysAllocString(pIMalloc, @PathTranslated)
		IFileBuffer_SetPathTranslated(pFile, pt)
		
		IFileBuffer_SetFilePath(pFile, Path)
		IFileBuffer_SetFileHandle(pFile, hFile)
		
		HeapSysFreeString(pt)
		
		Return S_OK
		
	End If
	
	Dim DefaultFilenameIndex As Integer = 0
	Dim DefaultFilename As WString * (WEBSITE_MAXDEFAULTFILENAMELENGTH + 1) = Any
	Dim FullDefaultFilename As WString * (MAX_PATH + 1) = Any
	
	Dim GetDefaultFileNameResult As Boolean = GetDefaultFileName( _
		@DefaultFilename, _
		DefaultFilenameIndex _
	)
	
	Do
		lstrcpyW(@FullDefaultFilename, Path)
		lstrcatW(@FullDefaultFilename, DefaultFilename)
		
		WebSiteMapPath(this, @FullDefaultFilename, @PathTranslated)
		
		Dim hFile As HANDLE = Any
		Dim hrGetFile As HRESULT = GetFileHandle( _
			@PathTranslated, _
			fAccess, _
			@hFile _
		)
		
		If SUCCEEDED(hrGetFile) Then
			
			Dim pt As HeapBSTR = HeapSysAllocString(pIMalloc, @PathTranslated)
			Dim fp As HeapBSTR = HeapSysAllocString(pIMalloc, @FullDefaultFilename)
			
			IFileBuffer_SetPathTranslated(pFile, pt)
			IFileBuffer_SetFilePath(pFile, fp)
			IFileBuffer_SetFileHandle(pFile, hFile)
			
			HeapSysFreeString(fp)
			HeapSysFreeString(pt)
			
			Return S_OK
			
		End If
		
		DefaultFilenameIndex += 1
		GetDefaultFileNameResult = GetDefaultFileName( _
			@DefaultFilename, _
			DefaultFilenameIndex _
		)
		
	Loop While GetDefaultFileNameResult
	
	Scope
		GetDefaultFileName(DefaultFilename, 0)
		
		lstrcpyW(@FullDefaultFilename, Path)
		lstrcatW(@FullDefaultFilename, @DefaultFilename)
		
		WebSiteMapPath(this, @FullDefaultFilename, @PathTranslated)
		
		Dim pt As HeapBSTR = HeapSysAllocString(pIMalloc, @PathTranslated)
		Dim fp As HeapBSTR = HeapSysAllocString(pIMalloc, @FullDefaultFilename)
		
		IFileBuffer_SetPathTranslated(pFile, pt)
		IFileBuffer_SetFilePath(pFile, fp)
		IFileBuffer_SetFileHandle(pFile, INVALID_HANDLE_VALUE)
		
		HeapSysFreeString(fp)
		HeapSysFreeString(pt)
	End Scope
	
	Return S_FALSE
	
End Function

Sub InitializeWebSite( _
		ByVal this As WebSite Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("WebSite_________"), 16)
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

Function WebSiteGetBuffer( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal fAccess As FileAccess, _
		ByVal pNegotiation As ContentNegotiationContext Ptr, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	
	Dim pIFile As IFileBuffer Ptr = Any
	Dim hrCreateFileBuffer As HRESULT = CreateInstance( _
		pIMalloc, _
		@CLSID_FILEBUFFER, _
		@IID_IFileBuffer, _
		@pIFile _
	)
	If FAILED(hrCreateFileBuffer) Then
		Return hrCreateFileBuffer
	End If
	
	/'
	Dim PathTranslated As WString Ptr = Any
	IRequestedFile_GetPathTranslated(pc->pIRequestedFile, @PathTranslated)
	
	IRequestedFile_GetFileHandle(pc->pIRequestedFile, @this->FileHandle)
	
	Dim FileState As RequestedFileState = Any
	IRequestedFile_FileExists(pc->pIRequestedFile, @FileState)
	
	Select Case FileState
		
		Case RequestedFileState.NotFound
			Return HTTPASYNCPROCESSOR_E_FILENOTFOUND
			
		Case RequestedFileState.Gone
			Return HTTPASYNCPROCESSOR_E_FILEGONE
			
	End Select
	'/
	
	' Получить FilePath — путь + имя файл (с расширением)
	' Получить PathTranslated — путь к файлу на диске
	Dim hrOpenFile As HRESULT = WebSiteOpenRequestedFile( _
		this, _
		pIMalloc, _
		pIFile, _
		Path, _
		fAccess _
	)
	If FAILED(hrOpenFile) Then
		IFileBuffer_Release(pIFile)
		*ppResult = NULL
		Return hrOpenFile
	End If
	
	' Получить ZipPath — путь к сжатому файлу если есть
	
	' Открыть оба файла — в зависимости от метода доступа
	
	' Проверить MIME, если текстовое — сдвинуть указатель на SizeOf(BOM) байт
	' для несжатого файла
	
	' Установить флаги согласованного содержимого
	
	' Вернуть IFileBuffer
	
	IFileBuffer_Release(pIFile)
	*ppResult = NULL
	
	Return E_UNEXPECTED
	
End Function

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

Function IMutableWebSiteGetBuffer( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal fAccess As FileAccess, _
		ByVal pNegotiation As ContentNegotiationContext Ptr, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	Return WebSiteGetBuffer(ContainerOf(this, WebSite, lpVtbl), pIMalloc, Path, fAccess, pNegotiation, pFlags, ppResult)
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
	@IMutableWebSiteGetBuffer, _
	@IMutableWebSiteNeedCgiProcessing, _
	@IMutableWebSiteNeedDllProcessing, _
	@IMutableWebSiteSetHostName, _
	@IMutableWebSiteSetSitePhysicalDirectory, _
	@IMutableWebSiteSetVirtualPath, _
	@IMutableWebSiteSetIsMoved, _
	@IMutableWebSiteSetMovedUrl _
)

