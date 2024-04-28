#include once "FileAsyncStream.bi"
#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalFileStreamVirtualTable As Const IFileAsyncStreamVirtualTable

Const SmallFileBytesSize As DWORD = 6 * 4096

Type FileStream
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IFileAsyncStreamVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pFilePath As HeapBSTR
	FileSize As LongInt
	FileOffset As LongInt
	FileHandle As HANDLE
	ZipFileHandle As HANDLE
	FileBytes As ZString Ptr
	SmallFileBytes As ZString Ptr
	Language As HeapBSTR
	ETag As HeapBSTR
	PreloadedBytesLength As UInteger
	ReservedFileBytesLength As UInteger
	pPreloadedBytes As UByte Ptr
	LastFileModifiedDate As FILETIME
	ZipMode As ZipModes
	ContentType As MimeType
	dwRequestedLength As DWORD
	PreviousAllocatedLength As DWORD
	PreviousAllocatedSmallLength As DWORD
End Type

Private Sub InitializeFileStream( _
		ByVal this As FileStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_FILESTREAM), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalFileStreamVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pFilePath = NULL
	this->FileHandle = INVALID_HANDLE_VALUE
	this->ZipFileHandle = INVALID_HANDLE_VALUE
	this->FileBytes = NULL
	this->SmallFileBytes = NULL
	this->ZipMode = ZipModes.None
	this->Language = NULL
	this->ETag = NULL
	this->FileSize = 0
	this->FileOffset = 0
	this->PreviousAllocatedLength = 0
	this->PreviousAllocatedSmallLength = 0
	this->PreloadedBytesLength = 0
	this->ReservedFileBytesLength = 0
	this->pPreloadedBytes = NULL
	ZeroMemory(@this->LastFileModifiedDate, SizeOf(FILETIME))
	this->ContentType.ContentType = ContentTypes.AnyAny
	this->ContentType.CharsetWeakPtr = NULL
	this->ContentType.Format = MimeFormats.Binary
	
End Sub

Private Sub UnInitializeFileStream( _
		ByVal this As FileStream Ptr _
	)
	
	HeapSysFreeString(this->ETag)
	HeapSysFreeString(this->Language)
	HeapSysFreeString(this->pFilePath)
	
	If this->FileBytes Then
		VirtualFree( _
			this->FileBytes, _
			0, _
			MEM_RELEASE _
		)
	End If
	
	If this->SmallFileBytes Then
		IMalloc_Free(this->pIMemoryAllocator, this->SmallFileBytes)
	End If
	
	If this->FileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->FileHandle)
	End If
	
	If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->ZipFileHandle)
	End If
	
End Sub

Private Sub FileStreamCreated( _
		ByVal this As FileStream Ptr _
	)
	
End Sub

Private Sub FileStreamDestroyed( _
		ByVal this As FileStream Ptr _
	)
	
End Sub

Private Sub DestroyFileStream( _
		ByVal this As FileStream Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeFileStream(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	FileStreamDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function FileStreamAddRef( _
		ByVal this As FileStream Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Private Function FileStreamRelease( _
		ByVal this As FileStream Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyFileStream(this)
	
	Return 0
	
End Function

Private Function FileStreamQueryInterface( _
		ByVal this As FileStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IFileAsyncStream, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAttributedAsyncStream, riid) Then
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
	
	FileStreamAddRef(this)
	
	Return S_OK
	
End Function

Public Function CreateFileStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
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
		
		Dim hrQueryInterface As HRESULT = FileStreamQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyFileStream(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function FileStreamAllocateBufferSink( _
		ByVal this As FileStream Ptr, _
		ByVal dwLength As DWORD _
	)As Any Ptr
	
	Dim pMem As Any Ptr = Any
	
	If dwLength <= SmallFileBytesSize Then
		VirtualFree( _
			this->FileBytes, _
			0, _
			MEM_DECOMMIT _
		)
		
		If this->PreviousAllocatedSmallLength >= dwLength Then
			pMem = this->SmallFileBytes
		Else
			If this->SmallFileBytes Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					this->SmallFileBytes _
				)
			End If
			pMem = IMalloc_Alloc( _
				this->pIMemoryAllocator, _
				dwLength _
			)
			this->SmallFileBytes = pMem
			this->PreviousAllocatedSmallLength = dwLength
		End If
		
	Else
		If this->SmallFileBytes Then
			IMalloc_Free( _
				this->pIMemoryAllocator, _
				this->SmallFileBytes _
			)
			this->SmallFileBytes = NULL
		End If
		
		If this->PreviousAllocatedLength >= dwLength Then
			pMem = this->FileBytes
		Else
			pMem = VirtualAlloc( _
				this->FileBytes, _
				dwLength, _
				MEM_COMMIT, _
				PAGE_READWRITE _
			)
			this->FileBytes = pMem
			this->PreviousAllocatedLength = dwLength
		End If
	End If
	
	Return pMem
	
End Function

Private Function FileStreamBeginReadSlice( _
		ByVal this As FileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal dwLength As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim VirtualStartIndex As LongInt = StartIndex + this->FileOffset
	
	If VirtualStartIndex >= this->FileSize Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
			this->pIMemoryAllocator, _
			@IID_IAsyncResult, _
			@pINewAsyncResult _
		)
		If FAILED(hrCreateAsyncResult) Then
			*ppIAsyncResult = NULL
			Return hrCreateAsyncResult
		End If
	End Scope
	
	Dim dwNumberOfBytesToRead As DWORD = min( _
		Cast(DWORD, this->ReservedFileBytesLength), _
		dwLength _
	)
	this->dwRequestedLength = dwNumberOfBytesToRead
	
	Dim pMem As Any Ptr = FileStreamAllocateBufferSink( _
		this, _
		dwNumberOfBytesToRead _
	)
	If pMem = NULL Then
		IAsyncResult_Release(pINewAsyncResult)
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Scope
		Dim pOverlap As OVERLAPPED Ptr = Any
		IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)
		
		IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)
		
		Dim liStartIndex As LARGE_INTEGER = Any
		liStartIndex.QuadPart = VirtualStartIndex
		
		pOverlap->Offset = liStartIndex.LowPart
		pOverlap->OffsetHigh = liStartIndex.HighPart
		
		Dim hMapFile As HANDLE = Any
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			hMapFile = this->ZipFileHandle
		Else
			hMapFile = this->FileHandle
		End If
		
		Dim resReadFile As BOOL = ReadFile( _
			hMapFile, _
			pMem, _
			dwNumberOfBytesToRead, _
			NULL, _
			pOverlap _
		)
		If resReadFile = 0 Then
			Dim dwError As DWORD = GetLastError()
			If dwError <> ERROR_IO_PENDING Then
				IAsyncResult_Release(pINewAsyncResult)
				*ppIAsyncResult = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
		End If
	End Scope
	
	*ppIAsyncResult = pINewAsyncResult
	
	Return ATTRIBUTEDSTREAM_S_IO_PENDING
	
End Function

Private Function FileStreamEndReadSlice( _
		ByVal this As FileStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	Dim dwBytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	Dim dwError As DWORD = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@dwBytesTransferred, _
		@Completed, _
		@dwError _
	)
	If dwError Then
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	If Completed Then
		Scope
			Dim pMem As Any Ptr = Any
			If this->SmallFileBytes Then
				pMem = this->SmallFileBytes
			Else
				pMem = this->FileBytes
			End If
			
			pBufferSlice->pSlice = pMem
			pBufferSlice->Length = CInt(dwBytesTransferred)
		End Scope
		
		If dwBytesTransferred = 0 Then
			Return S_FALSE
		End If
		
		If this->dwRequestedLength < dwBytesTransferred Then
			Return S_OK
		End If
		
		Return S_FALSE
		
	End If
	
	Return S_OK
	
End Function

Private Function FileStreamBeginWriteSlice( _
		ByVal this As FileStream Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr, _
		ByVal Offset As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim VirtualStartIndex As LongInt = Offset + this->FileOffset
	
	If VirtualStartIndex >= this->FileSize Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
			this->pIMemoryAllocator, _
			@IID_IAsyncResult, _
			@pINewAsyncResult _
		)
		If FAILED(hrCreateAsyncResult) Then
			*ppIAsyncResult = NULL
			Return hrCreateAsyncResult
		End If
	End Scope
	
	Dim dwNumberOfBytesToWrite As DWORD = Cast(DWORD, pBufferSlice->Length)
	this->dwRequestedLength = dwNumberOfBytesToWrite
	
	Dim pMem As Any Ptr = pBufferSlice->pSlice
	
	Scope
		Dim pOverlap As OVERLAPPED Ptr = Any
		IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)
		
		IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)
		
		Dim liStartIndex As LARGE_INTEGER = Any
		liStartIndex.QuadPart = VirtualStartIndex
		
		pOverlap->Offset = liStartIndex.LowPart
		pOverlap->OffsetHigh = liStartIndex.HighPart
		
		Dim hMapFile As HANDLE = Any
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			hMapFile = this->ZipFileHandle
		Else
			hMapFile = this->FileHandle
		End If
		
		Dim resReadFile As BOOL = WriteFile( _
			hMapFile, _
			pMem, _
			dwNumberOfBytesToWrite, _
			NULL, _
			pOverlap _
		)
		If resReadFile = 0 Then
			Dim dwError As DWORD = GetLastError()
			If dwError <> ERROR_IO_PENDING Then
				IAsyncResult_Release(pINewAsyncResult)
				*ppIAsyncResult = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
		End If
	End Scope
	
	*ppIAsyncResult = pINewAsyncResult
	
	Return ATTRIBUTEDSTREAM_S_IO_PENDING
	
End Function

Private Function FileStreamEndWriteSlice( _
		ByVal this As FileStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	Dim dwBytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	Dim dwError As DWORD = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@dwBytesTransferred, _
		@Completed, _
		@dwError _
	)
	If dwError Then
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	*pWritedBytes = dwBytesTransferred
	
	If dwBytesTransferred = 0 Then
		Return S_FALSE
	End If
	
	Return S_OK
	
End Function

Private Function FileStreamGetContentType( _
		ByVal this As FileStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(ppType, @this->ContentType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Private Function FileStreamGetEncoding( _
		ByVal this As FileStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ZipMode
	
	Return S_OK
	
End Function

Private Function FileStreamGetLanguage( _
		ByVal this As FileStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Language)
	*ppLanguage = this->Language
	
	Return S_OK
	
End Function

Private Function FileStreamGetETag( _
		ByVal this As FileStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->ETag)
	*ppETag = this->ETag
	
	Return S_OK
	
End Function

Private Function FileStreamGetLastFileModifiedDate( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	CopyMemory(pResult, @this->LastFileModifiedDate, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Private Function FileStreamGetLength( _
		ByVal this As FileStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	Dim VirtualFileSize As LongInt = this->FileSize - this->FileOffset
	
	If VirtualFileSize < 0 Then
		*pLength = 0
	Else
		*pLength = VirtualFileSize
	End If
	
	Return S_OK
	
End Function

Private Function FileStreamGetPreloadedBytes( _
		ByVal this As FileStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pPreloadedBytesLength = this->PreloadedBytesLength
	*ppPreloadedBytes = this->pPreloadedBytes
	
	Return S_OK
	
End Function

Private Function FileStreamGetFilePath( _
		ByVal this As FileStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pFilePath)
	*ppFilePath = this->pFilePath
	
	Return S_OK
	
End Function

Private Function FileStreamSetFilePath( _
		ByVal this As FileStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pFilePath, FilePath)
	
	Return S_OK
	
End Function

Private Function FileStreamGetFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = this->FileHandle
	
	Return S_OK
	
End Function

Private Function FileStreamSetFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->FileHandle = hFile
	
	Return S_OK
	
End Function

Private Function FileStreamGetZipFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = this->ZipFileHandle
	
	Return S_OK
	
End Function

Private Function FileStreamSetZipFileHandle( _
		ByVal this As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	this->ZipFileHandle = hFile
	
	Return S_OK
	
End Function

Private Function FileStreamSetContentType( _
		ByVal this As FileStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(@this->ContentType, pType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Private Function FileStreamSetFileOffset( _
		ByVal this As FileStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	this->FileOffset = Offset
	
	Return S_OK
	
End Function

Private Function FileStreamSetFileSize( _
		ByVal this As FileStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	
	this->FileSize = FileSize
	
	Return S_OK
	
End Function

Private Function FileStreamSetEncoding( _
		ByVal this As FileStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	this->ZipMode = ZipMode
	
	Return S_OK
	
End Function

Private Function FileStreamSetFileTime( _
		ByVal this As FileStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	
	CopyMemory(@this->LastFileModifiedDate, pTime, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Private Function FileStreamSetETag( _
		ByVal this As FileStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ETag, ETag)
	
	Return S_OK
	
End Function

Private Function FileStreamSetReservedFileBytes( _
		ByVal this As FileStream Ptr, _
		ByVal ReservedFileBytesLength As UInteger _
	)As HRESULT
	
	Dim FileBytes As ZString Ptr = VirtualAlloc( _
		NULL, _
		ReservedFileBytesLength, _
		MEM_RESERVE, _
		PAGE_READWRITE _
	)
	If FileBytes = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	this->FileBytes = FileBytes
	this->ReservedFileBytesLength = ReservedFileBytesLength
	
	Return S_OK
	
End Function

Private Function FileStreamSetPreloadedBytes( _
		ByVal this As FileStream Ptr, _
		ByVal PreloadedBytesLength As UInteger, _
		ByVal pPreloadedBytes As UByte Ptr _
	)As HRESULT
	
	this->PreloadedBytesLength = PreloadedBytesLength
	this->pPreloadedBytes = pPreloadedBytes
	
	Return S_OK
	
End Function

Private Function FileStreamGetReservedBytes( _
		ByVal this As FileStream Ptr, _
		ByVal pReservedBytesLength As Integer Ptr, _
		ByVal ppReservedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	Dim pMem As Any Ptr = VirtualAlloc( _
		this->FileBytes, _
		this->ReservedFileBytesLength, _
		MEM_COMMIT, _
		PAGE_READWRITE _
	)
	*ppReservedBytes = pMem
	*pReservedBytesLength = this->ReservedFileBytesLength
	
	If pMem = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Return S_OK
	
End Function


Private Function IFileAsyncStreamQueryInterface( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return FileStreamQueryInterface(ContainerOf(this, FileStream, lpVtbl), riid, ppvObject)
End Function

Private Function IFileAsyncStreamAddRef( _
		ByVal this As IFileAsyncStream Ptr _
	)As ULONG
	Return FileStreamAddRef(ContainerOf(this, FileStream, lpVtbl))
End Function

Private Function IFileAsyncStreamRelease( _
		ByVal this As IFileAsyncStream Ptr _
	)As ULONG
	Return FileStreamRelease(ContainerOf(this, FileStream, lpVtbl))
End Function

Private Function IFileAsyncStreamGetContentType( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return FileStreamGetContentType(ContainerOf(this, FileStream, lpVtbl), ppType)
End Function

Private Function IFileAsyncStreamGetEncoding( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return FileStreamGetEncoding(ContainerOf(this, FileStream, lpVtbl), pZipMode)
End Function

Private Function IFileAsyncStreamGetLanguage( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetLanguage(ContainerOf(this, FileStream, lpVtbl), ppLanguage)
End Function

Private Function IFileAsyncStreamGetETag( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetETag(ContainerOf(this, FileStream, lpVtbl), ppETag)
End Function

Private Function IFileAsyncStreamGetLastFileModifiedDate( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return FileStreamGetLastFileModifiedDate(ContainerOf(this, FileStream, lpVtbl), ppDate)
End Function

Private Function IFileAsyncStreamGetLength( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	Return FileStreamGetLength(ContainerOf(this, FileStream, lpVtbl), pLength)
End Function

Private Function IFileAsyncStreamGetPreloadedBytes( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return FileStreamGetPreloadedBytes(ContainerOf(this, FileStream, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Private Function IFileAsyncStreamBeginReadSlice( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return FileStreamBeginReadSlice(ContainerOf(this, FileStream, lpVtbl), StartIndex, Length, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IFileAsyncStreamEndReadSlice( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return FileStreamEndReadSlice(ContainerOf(this, FileStream, lpVtbl), pIAsyncResult, pBufferSlice)
End Function

Private Function IFileAsyncStreamGetFilePath( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetFilePath(ContainerOf(this, FileStream, lpVtbl), ppFilePath)
End Function

Private Function IFileAsyncStreamSetFilePath( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	Return FileStreamSetFilePath(ContainerOf(this, FileStream, lpVtbl), FilePath)
End Function

Private Function IFileAsyncStreamGetFileHandle( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileStreamGetFileHandle(ContainerOf(this, FileStream, lpVtbl), pResult)
End Function

Private Function IFileAsyncStreamSetFileHandle( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetFileHandle(ContainerOf(this, FileStream, lpVtbl), hFile)
End Function

Private Function IFileAsyncStreamGetZipFileHandle( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileStreamGetZipFileHandle(ContainerOf(this, FileStream, lpVtbl), pResult)
End Function

Private Function IFileAsyncStreamSetZipFileHandle( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetZipFileHandle(ContainerOf(this, FileStream, lpVtbl), hFile)
End Function

Private Function IFileAsyncStreamSetContentType( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return FileStreamSetContentType(ContainerOf(this, FileStream, lpVtbl), pType)
End Function

Private Function IFileAsyncStreamSetFileOffset( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	Return FileStreamSetFileOffset(ContainerOf(this, FileStream, lpVtbl), Offset)
End Function

Private Function IFileAsyncStreamSetFileSize( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	Return FileStreamSetFileSize(ContainerOf(this, FileStream, lpVtbl), FileSize)
End Function

Private Function IFileAsyncStreamSetEncoding( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return FileStreamSetEncoding(ContainerOf(this, FileStream, lpVtbl), ZipMode)
End Function

Private Function IFileAsyncStreamSetFileTime( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	Return FileStreamSetFileTime(ContainerOf(this, FileStream, lpVtbl), pTime)
End Function

Private Function IFileAsyncStreamSetETag( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	Return FileStreamSetETag(ContainerOf(this, FileStream, lpVtbl), ETag)
End Function

Private Function IFileAsyncStreamSetReservedFileBytes( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT
	Return FileStreamSetReservedFileBytes(ContainerOf(this, FileStream, lpVtbl), ReservedFileBytes)
End Function

Private Function IFileAsyncStreamSetPreloadedBytes( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal PreloadedBytesLength As UInteger, _
		ByVal pPreloadedBytes As UByte Ptr _
	)As HRESULT
	Return FileStreamSetPreloadedBytes(ContainerOf(this, FileStream, lpVtbl), PreloadedBytesLength, pPreloadedBytes)
End Function

Private Function IFileAsyncStreamGetReservedBytes( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pReservedBytesLength As Integer Ptr, _
		ByVal ppReservedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return FileStreamGetReservedBytes(ContainerOf(this, FileStream, lpVtbl), pReservedBytesLength, ppReservedBytes)
End Function

Private Function IFileAsyncStreamBeginWriteSlice( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr, _
		ByVal Offset As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return FileStreamBeginWriteSlice(ContainerOf(this, FileStream, lpVtbl), pBufferSlice, Offset, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IFileAsyncStreamEndWriteSlice( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	Return FileStreamEndWriteSlice(ContainerOf(this, FileStream, lpVtbl), pIAsyncResult, pWritedBytes)
End Function

Dim GlobalFileStreamVirtualTable As Const IFileAsyncStreamVirtualTable = Type( _
	@IFileAsyncStreamQueryInterface, _
	@IFileAsyncStreamAddRef, _
	@IFileAsyncStreamRelease, _
	@IFileAsyncStreamBeginReadSlice, _
	@IFileAsyncStreamEndReadSlice, _
	@IFileAsyncStreamGetContentType, _
	@IFileAsyncStreamGetEncoding, _
	@IFileAsyncStreamGetLanguage, _
	@IFileAsyncStreamGetETag, _
	@IFileAsyncStreamGetLastFileModifiedDate, _
	@IFileAsyncStreamGetLength, _
	@IFileAsyncStreamGetPreloadedBytes, _
	@IFileAsyncStreamGetFilePath, _
	@IFileAsyncStreamSetFilePath, _
	@IFileAsyncStreamGetFileHandle, _
	@IFileAsyncStreamSetFileHandle, _
	@IFileAsyncStreamGetZipFileHandle, _
	@IFileAsyncStreamSetZipFileHandle, _
	@IFileAsyncStreamSetContentType, _
	@IFileAsyncStreamSetFileOffset, _
	@IFileAsyncStreamSetFileSize, _
	@IFileAsyncStreamSetEncoding, _
	@IFileAsyncStreamSetFileTime, _
	@IFileAsyncStreamSetETag, _
	@IFileAsyncStreamSetReservedFileBytes, _
	@IFileAsyncStreamSetPreloadedBytes, _
	@IFileAsyncStreamGetReservedBytes, _
	@IFileAsyncStreamBeginWriteSlice, _
	@IFileAsyncStreamEndWriteSlice _
)
