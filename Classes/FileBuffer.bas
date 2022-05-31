#include once "FileBuffer.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "WebUtils.bi"

Extern GlobalFileBufferVirtualTable As Const IFileBufferVirtualTable

Type _FileBuffer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IFileBufferVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pFilePath As HeapBSTR
	FileHandle As Handle
	ZipFileHandle As HANDLE
	hMapFile As HANDLE
	FileSize As LongInt
	ChunkIndex As LongInt
	FileOffset As LongInt
	FileBytes As ZString Ptr
	fAccess As FileAccess
	ZipMode As ZipModes
	Language As HeapBSTR
	ETag As HeapBSTR
	LastFileModifiedDate As FILETIME
	ContentType As MimeType
End Type

Sub InitializeFileBuffer( _
		ByVal this As FileBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("FileBuffer______"), 16)
	#endif
	this->lpVtbl = @GlobalFileBufferVirtualTable
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

Sub UnInitializeFileBuffer( _
		ByVal this As FileBuffer Ptr _
	)
	
	HeapSysFreeString(this->ETag)
	HeapSysFreeString(this->Language)
	HeapSysFreeString(this->pFilePath)
	
	If this->FileBytes <> NULL Then
		UnmapViewOfFile(this->FileBytes)
	End If
	
	If this->hMapFile <> NULL Then
		CloseHandle(this->hMapFile)
	End If
	
	If this->FileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->FileHandle)
	End If
	
	If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->ZipFileHandle)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateFileBuffer( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As FileBuffer Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(FileBuffer)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"FileBuffer creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As FileBuffer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(FileBuffer) _
	)
	If this <> NULL Then
		
		InitializeFileBuffer( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("FileBuffer created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
		
	End If
	
	Return NULL
	
End Function

Sub DestroyFileBuffer( _
		ByVal this As FileBuffer Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("FileBuffer destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeFileBuffer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("FileBuffer destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function FileBufferQueryInterface( _
		ByVal this As FileBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IFileBuffer, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IBuffer, riid) Then
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
	
	FileBufferAddRef(this)
	
	Return S_OK
	
End Function

Function FileBufferAddRef( _
		ByVal this As FileBuffer Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function FileBufferRelease( _
		ByVal this As FileBuffer Ptr _
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
	
	DestroyFileBuffer(this)
	
	Return 0
	
End Function

Function FileBufferGetContentType( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(ppType, @this->ContentType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function FileBufferGetEncoding( _
		ByVal this As FileBuffer Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ZipMode
	
	Return S_OK
	
End Function

Function FileBufferGetLanguage( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Language)
	*ppLanguage = this->Language
	
	Return S_OK
	
End Function

Function FileBufferGetETag( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->ETag)
	*ppETag = this->ETag
	
	Return S_OK
	
End Function

Function FileBufferGetLastFileModifiedDate( _
		ByVal this As FileBuffer Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	CopyMemory(pResult, @this->LastFileModifiedDate, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Function FileBufferGetLength( _
		ByVal this As FileBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	*pLength = this->FileSize - this->FileOffset
	
	Return S_OK
	
End Function

Function FileBufferSetByteRange( _
		ByVal this As FileBuffer Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	
	this->FileOffset += Offset
	this->FileSize -= Length
	
	Return S_OK
	
End Function

Function FileBufferGetSlice( _
		ByVal this As FileBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	Dim VirtualStartIndex As LongInt = StartIndex + this->FileOffset
	Dim VirtualFileSize As LongInt = this->FileSize - this->FileOffset
	
	If VirtualStartIndex >= VirtualFileSize Then
		ZeroMemory(pBufferSlice, SizeOf(BufferSlice))
		Return E_OUTOFMEMORY
	End If
	
	Dim RequestChunkIndex As LongInt = Integer64Division( _
		VirtualStartIndex, _
		CLngInt(BUFFERSLICECHUNK_SIZE) _
	)
	
	If this->ChunkIndex <> RequestChunkIndex Then
		If this->FileBytes <> NULL Then
			UnmapViewOfFile(this->FileBytes)
			this->FileBytes = NULL
		End If
		
		this->ChunkIndex = RequestChunkIndex
	End If
	
	Dim dwNumberOfBytesToMap As DWORD = min( _
		BUFFERSLICECHUNK_SIZE, _
		VirtualFileSize - (RequestChunkIndex * CLngInt(BUFFERSLICECHUNK_SIZE)) _
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
	Dim SliceLength As DWORD = min(dwNumberOfBytesToMap, Length)
	
	pBufferSlice->pSlice = @this->FileBytes[IndexInChunck]
	pBufferSlice->Length = SliceLength
	
	If VirtualStartIndex + CLngInt(SliceLength) >= VirtualFileSize Then
		Return S_FALSE
	End If
	
	Return S_OK
	
End Function

Function FileBufferGetFilePath( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pFilePath)
	*ppFilePath = this->pFilePath
	
	Return S_OK
	
End Function

Function FileBufferSetFilePath( _
		ByVal this As FileBuffer Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pFilePath, FilePath)
	
	Return S_OK
	
End Function

Function FileBufferGetFileHandle( _
		ByVal this As FileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = this->FileHandle
	
	Return S_OK
	
End Function

Function FileBufferSetFileHandle( _
		ByVal this As FileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->FileHandle = hFile
	
	Return S_OK
	
End Function

Function FileBufferGetZipFileHandle( _
		ByVal this As FileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = this->ZipFileHandle
	
	Return S_OK
	
End Function

Function FileBufferSetZipFileHandle( _
		ByVal this As FileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->ZipFileHandle = hFile
	
	Return S_OK
	
End Function

Function FileBufferSetFileMappingHandle( _
		ByVal this As FileBuffer Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->fAccess = fAccess
	this->hMapFile = hFile
	
	Return S_OK
	
End Function

Function FileBufferSetContentType( _
		ByVal this As FileBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(@this->ContentType, pType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function FileBufferSetFileOffset( _
		ByVal this As FileBuffer Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	this->FileOffset = Offset
	
	Return S_OK
	
End Function

Function FileBufferSetFileSize( _
		ByVal this As FileBuffer Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	
	this->FileSize = FileSize
	
	Return S_OK
	
End Function

Function FileBufferSetEncoding( _
		ByVal this As FileBuffer Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	this->ZipMode = ZipMode
	
	Return S_OK
	
End Function

Function FileBufferSetFileTime( _
		ByVal this As FileBuffer Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	
	CopyMemory(@this->LastFileModifiedDate, pTime, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Function FileBufferSetETag( _
		ByVal this As FileBuffer Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ETag, ETag)
	
	Return S_OK
	
End Function


Function IFileBufferQueryInterface( _
		ByVal this As IFileBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return FileBufferQueryInterface(ContainerOf(this, FileBuffer, lpVtbl), riid, ppvObject)
End Function

Function IFileBufferAddRef( _
		ByVal this As IFileBuffer Ptr _
	)As ULONG
	Return FileBufferAddRef(ContainerOf(this, FileBuffer, lpVtbl))
End Function

Function IFileBufferRelease( _
		ByVal this As IFileBuffer Ptr _
	)As ULONG
	Return FileBufferRelease(ContainerOf(this, FileBuffer, lpVtbl))
End Function

Function IFileBufferGetContentType( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return FileBufferGetContentType(ContainerOf(this, FileBuffer, lpVtbl), ppType)
End Function

Function IFileBufferGetEncoding( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return FileBufferGetEncoding(ContainerOf(this, FileBuffer, lpVtbl), pZipMode)
End Function

Function IFileBufferGetLanguage( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return FileBufferGetLanguage(ContainerOf(this, FileBuffer, lpVtbl), ppLanguage)
End Function

Function IFileBufferGetETag( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return FileBufferGetETag(ContainerOf(this, FileBuffer, lpVtbl), ppETag)
End Function

Function IFileBufferGetLastFileModifiedDate( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return FileBufferGetLastFileModifiedDate(ContainerOf(this, FileBuffer, lpVtbl), ppDate)
End Function

Function IFileBufferGetLength( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	Return FileBufferGetLength(ContainerOf(this, FileBuffer, lpVtbl), pLength)
End Function

Function IFileBufferSetByteRange( _
		ByVal this As IFileBuffer Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	Return FileBufferSetByteRange(ContainerOf(this, FileBuffer, lpVtbl), Offset, Length)
End Function

Function IFileBufferGetSlice( _
		ByVal this As IFileBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return FileBufferGetSlice(ContainerOf(this, FileBuffer, lpVtbl), StartIndex, Length, pBufferSlice)
End Function

Function IFileBufferGetFilePath( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	Return FileBufferGetFilePath(ContainerOf(this, FileBuffer, lpVtbl), ppFilePath)
End Function

Function IFileBufferSetFilePath( _
		ByVal this As IFileBuffer Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	Return FileBufferSetFilePath(ContainerOf(this, FileBuffer, lpVtbl), FilePath)
End Function

Function IFileBufferGetFileHandle( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileBufferGetFileHandle(ContainerOf(this, FileBuffer, lpVtbl), pResult)
End Function

Function IFileBufferSetFileHandle( _
		ByVal this As IFileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileBufferSetFileHandle(ContainerOf(this, FileBuffer, lpVtbl), hFile)
End Function

Function IFileBufferGetZipFileHandle( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileBufferGetZipFileHandle(ContainerOf(this, FileBuffer, lpVtbl), pResult)
End Function

Function IFileBufferSetZipFileHandle( _
		ByVal this As IFileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileBufferSetZipFileHandle(ContainerOf(this, FileBuffer, lpVtbl), hFile)
End Function

Function IFileBufferSetFileMappingHandle( _
		ByVal this As IFileBuffer Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileBufferSetFileMappingHandle(ContainerOf(this, FileBuffer, lpVtbl), fAccess, hFile)
End Function

Function IFileBufferSetContentType( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return FileBufferSetContentType(ContainerOf(this, FileBuffer, lpVtbl), pType)
End Function

Function IFileBufferSetFileOffset( _
		ByVal this As IFileBuffer Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	Return FileBufferSetFileOffset(ContainerOf(this, FileBuffer, lpVtbl), Offset)
End Function

Function IFileBufferSetFileSize( _
		ByVal this As IFileBuffer Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	Return FileBufferSetFileSize(ContainerOf(this, FileBuffer, lpVtbl), FileSize)
End Function

Function IFileBufferSetEncoding( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return FileBufferSetEncoding(ContainerOf(this, FileBuffer, lpVtbl), ZipMode)
End Function

Function IFileBufferSetFileTime( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	Return FileBufferSetFileTime(ContainerOf(this, FileBuffer, lpVtbl), pTime)
End Function

Function IFileBufferSetETag( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	Return FileBufferSetETag(ContainerOf(this, FileBuffer, lpVtbl), ETag)
End Function

Dim GlobalFileBufferVirtualTable As Const IFileBufferVirtualTable = Type( _
	@IFileBufferQueryInterface, _
	@IFileBufferAddRef, _
	@IFileBufferRelease, _
	@IFileBufferGetContentType, _
	@IFileBufferGetEncoding, _
	@IFileBufferGetLanguage, _
	@IFileBufferGetETag, _
	@IFileBufferGetLastFileModifiedDate, _
	@IFileBufferGetLength, _
	@IFileBufferSetByteRange, _
	@IFileBufferGetSlice, _
	@IFileBufferGetFilePath, _
	@IFileBufferSetFilePath, _
	@IFileBufferGetFileHandle, _
	@IFileBufferSetFileHandle, _
	@IFileBufferGetZipFileHandle, _
	@IFileBufferSetZipFileHandle, _
	@IFileBufferSetFileMappingHandle, _
	@IFileBufferSetContentType, _
	@IFileBufferSetFileOffset, _
	@IFileBufferSetFileSize, _
	@IFileBufferSetEncoding, _
	@IFileBufferSetFileTime, _
	@IFileBufferSetETag _
)
