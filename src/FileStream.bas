#include once "FileStream.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalFileStreamVirtualTable As Const IFileStreamVirtualTable

Type _FileStream
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IFileStreamVirtualTable Ptr
	ReferenceCounter As UInteger
	FileSize As LongInt
	FileOffset As LongInt
	ChunkIndex As LongInt
	pIMemoryAllocator As IMalloc Ptr
	pFilePath As HeapBSTR
	FileHandle As Handle
	ZipFileHandle As HANDLE
	hMapFile As HANDLE
	FileBytes As ZString Ptr
	Language As HeapBSTR
	ETag As HeapBSTR
	LastFileModifiedDate As FILETIME
	fAccess As FileAccess
	ZipMode As ZipModes
	ContentType As MimeType
End Type

Sub InitializeFileStream( _
		ByVal this As FileStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_FILESTREAM), _
			Len(FileStream.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalFileStreamVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pFilePath = NULL
	this->FileHandle = INVALID_HANDLE_VALUE
	this->ZipFileHandle = INVALID_HANDLE_VALUE
	this->hMapFile = NULL
	this->FileBytes = NULL
	this->ZipMode = ZipModes.None
	this->Language = NULL
	this->ETag = NULL
	this->FileSize = 0
	this->ChunkIndex = 0
	this->FileOffset = 0
	ZeroMemory(@this->LastFileModifiedDate, SizeOf(FILETIME))
	this->ContentType.ContentType = ContentTypes.AnyAny
	this->ContentType.Charset = DocumentCharsets.ASCII
	this->ContentType.IsTextFormat = False
	
End Sub

Sub UnInitializeFileStream( _
		ByVal this As FileStream Ptr _
	)
	
	HeapSysFreeString(this->ETag)
	HeapSysFreeString(this->Language)
	HeapSysFreeString(this->pFilePath)
	
	If this->FileBytes Then
		UnmapViewOfFile(this->FileBytes)
	End If
	
	If this->hMapFile Then
		CloseHandle(this->hMapFile)
	End If
	
	If this->FileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->FileHandle)
	End If
	
	If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->ZipFileHandle)
	End If
	
End Sub

Sub FileStreamCreated( _
		ByVal this As FileStream Ptr _
	)
	
End Sub

Function CreateFileStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As FileStream Ptr
	
	Dim this As FileStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(FileStream) _
	)
	If this Then
		
		InitializeFileStream( _
			this, _
			pIMemoryAllocator _
		)
		
		FileStreamCreated(this)
		
		Return this
		
	End If
	
	Return NULL
	
End Function

Sub FileStreamDestroyed( _
		ByVal this As FileStream Ptr _
	)
	
End Sub

Sub DestroyFileStream( _
		ByVal this As FileStream Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeFileStream(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	FileStreamDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function FileStreamQueryInterface( _
		ByVal this As FileStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IFileStream, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAttributedStream, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IBaseStream, riid) Then
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
	End If
	
	FileStreamAddRef(this)
	
	Return S_OK
	
End Function

Function FileStreamAddRef( _
		ByVal this As FileStream Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function FileStreamRelease( _
		ByVal this As FileStream Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyFileStream(this)
	
	Return 0
	
End Function

Function FileStreamGetContentType( _
		ByVal this As FileStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(ppType, @this->ContentType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function FileStreamGetEncoding( _
		ByVal this As FileStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ZipMode
	
	Return S_OK
	
End Function

Function FileStreamGetLanguage( _
		ByVal this As FileStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Language)
	*ppLanguage = this->Language
	
	Return S_OK
	
End Function

Function FileStreamGetETag( _
		ByVal this As FileStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->ETag)
	*ppETag = this->ETag
	
	Return S_OK
	
End Function

Function FileStreamGetLastFileModifiedDate( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	CopyMemory(pResult, @this->LastFileModifiedDate, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Function FileStreamGetLength( _
		ByVal this As FileStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	Dim VirtualFileSize As LongInt = this->FileSize - this->FileOffset
	
	*pLength = VirtualFileSize
	
	Return S_OK
	
End Function

Function FileStreamGetSlice( _
		ByVal this As FileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	Dim VirtualStartIndex As LongInt = StartIndex + this->FileOffset
	
	If VirtualStartIndex >= this->FileSize Then
		ZeroMemory(pBufferSlice, SizeOf(BufferSlice))
		Return E_OUTOFMEMORY
	End If
	
	Dim RequestChunkIndex As LongInt = Integer64Division( _
		VirtualStartIndex, _
		CLngInt(BUFFERSLICECHUNK_SIZE) _
	)
	
	If this->ChunkIndex <> RequestChunkIndex Then
		If this->FileBytes Then
			UnmapViewOfFile(this->FileBytes)
			this->FileBytes = NULL
		End If
		
		this->ChunkIndex = RequestChunkIndex
	End If
	
	Dim dwNumberOfBytesToMap As DWORD = min( _
		BUFFERSLICECHUNK_SIZE, _
		this->FileSize - (RequestChunkIndex * CLngInt(BUFFERSLICECHUNK_SIZE)) _
	)
	
	If this->FileBytes = NULL Then
		Dim dwDesiredAccess As DWORD = Any
		
		Select Case this->fAccess
			
			Case FileAccess.CreateAccess, FileAccess.UpdateAccess
				dwDesiredAccess = FILE_MAP_WRITE
				
			Case Else
				dwDesiredAccess = FILE_MAP_READ
				
		End Select
		
		Dim liStartIndex As LARGE_INTEGER = Any
		liStartIndex.QuadPart = RequestChunkIndex * CLngInt(BUFFERSLICECHUNK_SIZE)
		
		this->FileBytes = MapViewOfFile( _
			this->hMapFile, _
			dwDesiredAccess, _
			liStartIndex.HighPart, liStartIndex.LowPart, _
			dwNumberOfBytesToMap _
		)
		If this->FileBytes = NULL Then
			Dim dwError As DWORD = GetLastError()
			ZeroMemory(pBufferSlice, SizeOf(BufferSlice))
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End If
	
	Dim IndexInChunck As LongInt = VirtualStartIndex - RequestChunkIndex * CLngInt(BUFFERSLICECHUNK_SIZE)
	Dim VirtualFileSize As LongInt = this->FileSize - this->FileOffset
	
	Dim SliceLength As DWORD = min( _
		dwNumberOfBytesToMap - Cast(DWORD, IndexInChunck), _
		min(Length, VirtualFileSize - RequestChunkIndex * CLngInt(BUFFERSLICECHUNK_SIZE)) _
	)
	
	pBufferSlice->pSlice = @this->FileBytes[IndexInChunck]
	pBufferSlice->Length = SliceLength
	
	Dim NextChunkIndex As LongInt = Integer64Division( _
		VirtualStartIndex + Length - SliceLength, _
		CLngInt(BUFFERSLICECHUNK_SIZE) _
	)
	If RequestChunkIndex < NextChunkIndex Then
		Return S_OK
	End If
	
	Return S_FALSE
	
End Function

Function FileStreamBeginGetSlice( _
		ByVal this As FileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Function FileStreamEndGetSlice( _
		ByVal this As FileStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Function FileStreamGetFilePath( _
		ByVal this As FileStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pFilePath)
	*ppFilePath = this->pFilePath
	
	Return S_OK
	
End Function

Function FileStreamSetFilePath( _
		ByVal this As FileStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pFilePath, FilePath)
	
	Return S_OK
	
End Function

Function FileStreamGetFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = this->FileHandle
	
	Return S_OK
	
End Function

Function FileStreamSetFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->FileHandle = hFile
	
	Return S_OK
	
End Function

Function FileStreamGetZipFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = this->ZipFileHandle
	
	Return S_OK
	
End Function

Function FileStreamSetZipFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->ZipFileHandle = hFile
	
	Return S_OK
	
End Function

Function FileStreamSetFileMappingHandle( _
		ByVal this As FileStream Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->fAccess = fAccess
	this->hMapFile = hFile
	
	Return S_OK
	
End Function

Function FileStreamSetContentType( _
		ByVal this As FileStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(@this->ContentType, pType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function FileStreamSetFileOffset( _
		ByVal this As FileStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	this->FileOffset = Offset
	
	Return S_OK
	
End Function

Function FileStreamSetFileSize( _
		ByVal this As FileStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	
	this->FileSize = FileSize
	
	Return S_OK
	
End Function

Function FileStreamSetEncoding( _
		ByVal this As FileStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	this->ZipMode = ZipMode
	
	Return S_OK
	
End Function

Function FileStreamSetFileTime( _
		ByVal this As FileStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	
	CopyMemory(@this->LastFileModifiedDate, pTime, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Function FileStreamSetETag( _
		ByVal this As FileStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ETag, ETag)
	
	Return S_OK
	
End Function


Function IFileStreamQueryInterface( _
		ByVal this As IFileStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return FileStreamQueryInterface(ContainerOf(this, FileStream, lpVtbl), riid, ppvObject)
End Function

Function IFileStreamAddRef( _
		ByVal this As IFileStream Ptr _
	)As ULONG
	Return FileStreamAddRef(ContainerOf(this, FileStream, lpVtbl))
End Function

Function IFileStreamRelease( _
		ByVal this As IFileStream Ptr _
	)As ULONG
	Return FileStreamRelease(ContainerOf(this, FileStream, lpVtbl))
End Function

Function IFileStreamGetContentType( _
		ByVal this As IFileStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return FileStreamGetContentType(ContainerOf(this, FileStream, lpVtbl), ppType)
End Function

Function IFileStreamGetEncoding( _
		ByVal this As IFileStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return FileStreamGetEncoding(ContainerOf(this, FileStream, lpVtbl), pZipMode)
End Function

Function IFileStreamGetLanguage( _
		ByVal this As IFileStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetLanguage(ContainerOf(this, FileStream, lpVtbl), ppLanguage)
End Function

Function IFileStreamGetETag( _
		ByVal this As IFileStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetETag(ContainerOf(this, FileStream, lpVtbl), ppETag)
End Function

Function IFileStreamGetLastFileModifiedDate( _
		ByVal this As IFileStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return FileStreamGetLastFileModifiedDate(ContainerOf(this, FileStream, lpVtbl), ppDate)
End Function

Function IFileStreamGetLength( _
		ByVal this As IFileStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	Return FileStreamGetLength(ContainerOf(this, FileStream, lpVtbl), pLength)
End Function

Function IFileStreamGetSlice( _
		ByVal this As IFileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return FileStreamGetSlice(ContainerOf(this, FileStream, lpVtbl), StartIndex, Length, pBufferSlice)
End Function

Function IFileStreamBeginGetSlice( _
		ByVal this As IFileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return FileStreamBeginGetSlice(ContainerOf(this, FileStream, lpVtbl), StartIndex, Length, StateObject, ppIAsyncResult)
End Function

Function IFileStreamEndGetSlice( _
		ByVal this As IFileStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return FileStreamEndGetSlice(ContainerOf(this, FileStream, lpVtbl), pIAsyncResult, pBufferSlice)
End Function

Function IFileStreamGetFilePath( _
		ByVal this As IFileStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetFilePath(ContainerOf(this, FileStream, lpVtbl), ppFilePath)
End Function

Function IFileStreamSetFilePath( _
		ByVal this As IFileStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	Return FileStreamSetFilePath(ContainerOf(this, FileStream, lpVtbl), FilePath)
End Function

Function IFileStreamGetFileHandle( _
		ByVal this As IFileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileStreamGetFileHandle(ContainerOf(this, FileStream, lpVtbl), pResult)
End Function

Function IFileStreamSetFileHandle( _
		ByVal this As IFileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetFileHandle(ContainerOf(this, FileStream, lpVtbl), hFile)
End Function

Function IFileStreamGetZipFileHandle( _
		ByVal this As IFileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileStreamGetZipFileHandle(ContainerOf(this, FileStream, lpVtbl), pResult)
End Function

Function IFileStreamSetZipFileHandle( _
		ByVal this As IFileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetZipFileHandle(ContainerOf(this, FileStream, lpVtbl), hFile)
End Function

Function IFileStreamSetFileMappingHandle( _
		ByVal this As IFileStream Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetFileMappingHandle(ContainerOf(this, FileStream, lpVtbl), fAccess, hFile)
End Function

Function IFileStreamSetContentType( _
		ByVal this As IFileStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return FileStreamSetContentType(ContainerOf(this, FileStream, lpVtbl), pType)
End Function

Function IFileStreamSetFileOffset( _
		ByVal this As IFileStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	Return FileStreamSetFileOffset(ContainerOf(this, FileStream, lpVtbl), Offset)
End Function

Function IFileStreamSetFileSize( _
		ByVal this As IFileStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	Return FileStreamSetFileSize(ContainerOf(this, FileStream, lpVtbl), FileSize)
End Function

Function IFileStreamSetEncoding( _
		ByVal this As IFileStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return FileStreamSetEncoding(ContainerOf(this, FileStream, lpVtbl), ZipMode)
End Function

Function IFileStreamSetFileTime( _
		ByVal this As IFileStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	Return FileStreamSetFileTime(ContainerOf(this, FileStream, lpVtbl), pTime)
End Function

Function IFileStreamSetETag( _
		ByVal this As IFileStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	Return FileStreamSetETag(ContainerOf(this, FileStream, lpVtbl), ETag)
End Function

Dim GlobalFileStreamVirtualTable As Const IFileStreamVirtualTable = Type( _
	@IFileStreamQueryInterface, _
	@IFileStreamAddRef, _
	@IFileStreamRelease, _
	NULL, _ /'BeginRead'/
	NULL, _ /'BeginWrite'/
	NULL, _ /'EndRead'/
	NULL, _ /'EndWrite'/
	NULL, _ /'BeginReadScatter'/
	NULL, _ /'BeginWriteGather'/
	NULL, _ /'BeginWriteGatherAndShutdown'/
	@IFileStreamGetContentType, _
	@IFileStreamGetEncoding, _
	@IFileStreamGetLanguage, _
	@IFileStreamGetETag, _
	@IFileStreamGetLastFileModifiedDate, _
	@IFileStreamGetLength, _
	@IFileStreamGetSlice, _
	@IFileStreamBeginGetSlice, _
	@IFileStreamEndGetSlice, _
	@IFileStreamGetFilePath, _
	@IFileStreamSetFilePath, _
	@IFileStreamGetFileHandle, _
	@IFileStreamSetFileHandle, _
	@IFileStreamGetZipFileHandle, _
	@IFileStreamSetZipFileHandle, _
	@IFileStreamSetFileMappingHandle, _
	@IFileStreamSetContentType, _
	@IFileStreamSetFileOffset, _
	@IFileStreamSetFileSize, _
	@IFileStreamSetEncoding, _
	@IFileStreamSetFileTime, _
	@IFileStreamSetETag _
)
