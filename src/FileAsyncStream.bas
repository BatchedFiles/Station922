#include once "FileAsyncStream.bi"
#include once "AsyncResult.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalFileStreamVirtualTable As Const IFileAsyncStreamVirtualTable

Const SmallFileBytesSize As DWORD = 5 * 4096

' this dude must be less then max(DWORD)
Const ReservedBytesLengthMaximum As UInteger = 3 * 1024 * 1024 * 1024
Const ReservedBytesLengthDefault As UInteger = 8 * 1024 * 1024

Type BytesVector
	pBytes As Any Ptr
	Length As UInteger
End Type

Type FileStream
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IFileAsyncStreamVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pFilePath As HeapBSTR
	Language As HeapBSTR
	ETag As HeapBSTR
	FileSize As LongInt
	FileOffset As LongInt
	FileHandle As HANDLE
	ZipFileHandle As HANDLE
	BigFileBytes As BytesVector
	SmallFileBytes As BytesVector
	PreloadedBytes As BytesVector
	LastFileModifiedDate As FILETIME
	ReservedBytesLength As UInteger
	RequestedBytesLength As UInteger
	ZipMode As ZipModes
	ContentType As MimeType
End Type

Private Sub InitializeFileStream( _
		ByVal self As FileStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_FILESTREAM), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalFileStreamVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pFilePath = NULL
	self->Language = NULL
	self->ETag = NULL
	self->FileSize = 0
	self->FileOffset = 0
	self->FileHandle = INVALID_HANDLE_VALUE
	self->ZipFileHandle = INVALID_HANDLE_VALUE
	ZeroMemory(@self->BigFileBytes, SizeOf(BytesVector))
	ZeroMemory(@self->SmallFileBytes, SizeOf(BytesVector))
	ZeroMemory(@self->PreloadedBytes, SizeOf(BytesVector))
	ZeroMemory(@self->LastFileModifiedDate, SizeOf(FILETIME))
	self->ReservedBytesLength = ReservedBytesLengthDefault
	' self->RequestedBytesLength = 0
	self->ZipMode = ZipModes.None
	self->ContentType.ContentType = ContentTypes.AnyAny
	self->ContentType.CharsetWeakPtr = NULL
	self->ContentType.Format = MimeFormats.Binary
End Sub

Private Sub UnInitializeFileStream( _
		ByVal self As FileStream Ptr _
	)

	HeapSysFreeString(self->ETag)
	HeapSysFreeString(self->Language)
	HeapSysFreeString(self->pFilePath)

	If self->BigFileBytes.pBytes Then
		Deallocate( _
			self->BigFileBytes.pBytes _
		)
	End If

	If self->SmallFileBytes.pBytes Then
		IMalloc_Free( _
			self->pIMemoryAllocator, _
			self->SmallFileBytes.pBytes _
		)
	End If

	If self->FileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(self->FileHandle)
	End If

	If self->ZipFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(self->ZipFileHandle)
	End If

End Sub

Private Sub DestroyFileStream( _
		ByVal self As FileStream Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeFileStream(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function FileStreamAddRef( _
		ByVal self As FileStream Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function FileStreamRelease( _
		ByVal self As FileStream Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyFileStream(self)

	Return 0

End Function

Private Function FileStreamQueryInterface( _
		ByVal self As FileStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IFileAsyncStream, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IAttributedAsyncStream, riid) Then
			*ppv = @self->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @self->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If

	FileStreamAddRef(self)

	Return S_OK

End Function

Public Function CreateFileStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As FileStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(FileStream) _
	)

	If self Then
		InitializeFileStream( _
			self, _
			pIMemoryAllocator _
		)

		Dim hrQueryInterface As HRESULT = FileStreamQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyFileStream(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function FileStreamAllocateBufferSink( _
		ByVal self As FileStream Ptr, _
		ByVal Length As UInteger _
	)As Any Ptr

	Dim pMem As Any Ptr = Any

	If Length <= SmallFileBytesSize Then

		Dim pOld As Any Ptr = self->SmallFileBytes.pBytes
		If pOld Then
			IMalloc_Free( _
				self->pIMemoryAllocator, _
				pOld _
			)
			self->SmallFileBytes.pBytes = NULL
		End If

		pMem = IMalloc_Alloc( _
			self->pIMemoryAllocator, _
			Length _
		)

		If pMem Then
			self->SmallFileBytes.pBytes = pMem
		End If
	Else

		Dim pOld As Any Ptr = self->BigFileBytes.pBytes
		pMem = Reallocate( _
			pOld, _
			Length _
		)

		If pMem Then
			self->BigFileBytes.pBytes = pMem
		End If
	End If

	Return pMem

End Function

Private Function FileStreamBeginReadSlice( _
		ByVal self As FileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim VirtualStartIndex As LongInt = StartIndex + self->FileOffset

	If VirtualStartIndex >= self->FileSize Then
		*ppIAsyncResult = NULL
		Return HRESULT_FROM_WIN32(ERROR_SEEK)
	End If

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
			self->pIMemoryAllocator, _
			@IID_IAsyncResult, _
			@pINewAsyncResult _
		)
		If FAILED(hrCreateAsyncResult) Then
			*ppIAsyncResult = NULL
			Return hrCreateAsyncResult
		End If
	End Scope

	Dim pMem As Any Ptr = Any
	Scope
		Dim liReservedBytesLength As LongInt = CLngInt(self->ReservedBytesLength)
		Dim NumberOfBytesToRead As LongInt = min( _
			liReservedBytesLength, _
			Length _
		)

		Dim nNumberOfBytesToRead As UInteger = CUInt(NumberOfBytesToRead)
		pMem = FileStreamAllocateBufferSink( _
			self, _
			nNumberOfBytesToRead _
		)
		If pMem = NULL Then
			IAsyncResult_Release(pINewAsyncResult)
			*ppIAsyncResult = NULL
			Return E_OUTOFMEMORY
		End If

		self->RequestedBytesLength = nNumberOfBytesToRead
	End Scope

	Scope
		IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

		Dim pOverlap As OVERLAPPED Ptr = Any
		IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)

		Scope
			Dim liStartIndex As LARGE_INTEGER = Any
			liStartIndex.QuadPart = VirtualStartIndex

			pOverlap->Offset = liStartIndex.LowPart
			pOverlap->OffsetHigh = liStartIndex.HighPart
		End Scope

		Dim hMapFile As HANDLE = Any
		If self->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			hMapFile = self->ZipFileHandle
		Else
			hMapFile = self->FileHandle
		End If

		Dim dwNumberOfBytesToRead As DWORD = Cast(DWORD, self->RequestedBytesLength)

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
		ByVal self As FileStream Ptr, _
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
		Dim nBytesTransferred As UInteger = CUInt(dwBytesTransferred)

		Scope
			Dim pMem As Any Ptr = Any
			If self->SmallFileBytes.pBytes Then
				pMem = self->SmallFileBytes.pBytes
			Else
				pMem = self->BigFileBytes.pBytes
			End If

			pBufferSlice->pSlice = pMem
			pBufferSlice->Length = nBytesTransferred
		End Scope

		If dwBytesTransferred = 0 Then
			Return S_FALSE
		End If

		If self->RequestedBytesLength < nBytesTransferred Then
			Return S_OK
		End If

		Return S_FALSE

	End If

	Return S_OK

End Function

Private Function FileStreamBeginWriteSlice( _
		ByVal self As FileStream Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr, _
		ByVal Offset As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim VirtualStartIndex As LongInt = Offset + self->FileOffset

	If VirtualStartIndex >= self->FileSize Then
		*ppIAsyncResult = NULL
		Return HRESULT_FROM_WIN32(ERROR_SEEK)
	End If

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
			self->pIMemoryAllocator, _
			@IID_IAsyncResult, _
			@pINewAsyncResult _
		)
		If FAILED(hrCreateAsyncResult) Then
			*ppIAsyncResult = NULL
			Return E_OUTOFMEMORY
		End If
	End Scope

	Dim pMem As Any Ptr = pBufferSlice->pSlice

	Scope
		IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

		Dim pOverlap As OVERLAPPED Ptr = Any
		IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)

		Scope
			Dim liStartIndex As LARGE_INTEGER = Any
			liStartIndex.QuadPart = VirtualStartIndex

			pOverlap->Offset = liStartIndex.LowPart
			pOverlap->OffsetHigh = liStartIndex.HighPart
		End Scope

		Dim hMapFile As HANDLE = Any
		If self->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			hMapFile = self->ZipFileHandle
		Else
			hMapFile = self->FileHandle
		End If

		Dim dwNumberOfBytesToWrite As DWORD = Any
		Scope
			Dim nMinBytes As UInteger = min( _
				pBufferSlice->Length, _
				ReservedBytesLengthMaximum _
			)
			dwNumberOfBytesToWrite = Cast(DWORD, nMinBytes)
		End Scope

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
		ByVal self As FileStream Ptr, _
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
		ByVal self As FileStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	CopyMemory(ppType, @self->ContentType, SizeOf(MimeType))

	Return S_OK

End Function

Private Function FileStreamGetEncoding( _
		ByVal self As FileStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	*pZipMode = self->ZipMode

	Return S_OK

End Function

Private Function FileStreamGetLanguage( _
		ByVal self As FileStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(self->Language)
	*ppLanguage = self->Language

	Return S_OK

End Function

Private Function FileStreamGetETag( _
		ByVal self As FileStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(self->ETag)
	*ppETag = self->ETag

	Return S_OK

End Function

Private Function FileStreamGetLastFileModifiedDate( _
		ByVal self As FileStream Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT

	CopyMemory(pResult, @self->LastFileModifiedDate, SizeOf(FILETIME))

	Return S_OK

End Function

Private Function FileStreamGetLength( _
		ByVal self As FileStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	Dim VirtualFileSize As LongInt = self->FileSize - self->FileOffset

	If VirtualFileSize < 0 Then
		*pLength = 0
	Else
		*pLength = VirtualFileSize
	End If

	Return S_OK

End Function

Private Function FileStreamGetPreloadedBytes( _
		ByVal self As FileStream Ptr, _
		ByVal pPreloadedBytesLength As UInteger Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	*pPreloadedBytesLength = self->PreloadedBytes.Length
	*ppPreloadedBytes = self->PreloadedBytes.pBytes

	Return S_OK

End Function

Private Function FileStreamGetFilePath( _
		ByVal self As FileStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(self->pFilePath)
	*ppFilePath = self->pFilePath

	Return S_OK

End Function

Private Function FileStreamSetFilePath( _
		ByVal self As FileStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT

	LET_HEAPSYSSTRING(self->pFilePath, FilePath)

	Return S_OK

End Function

Private Function FileStreamGetFileHandle( _
		ByVal self As FileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT

	*pResult = self->FileHandle

	Return S_OK

End Function

Private Function FileStreamSetFileHandle( _
		ByVal self As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT

	self->FileHandle = hFile

	Return S_OK

End Function

Private Function FileStreamGetZipFileHandle( _
		ByVal self As FileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT

	*pResult = self->ZipFileHandle

	Return S_OK

End Function

Private Function FileStreamSetZipFileHandle( _
		ByVal self As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT

	self->ZipFileHandle = hFile

	Return S_OK

End Function

Private Function FileStreamSetContentType( _
		ByVal self As FileStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT

	CopyMemory(@self->ContentType, pType, SizeOf(MimeType))

	Return S_OK

End Function

Private Function FileStreamSetFileOffset( _
		ByVal self As FileStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT

	self->FileOffset = Offset

	Return S_OK

End Function

Private Function FileStreamSetFileSize( _
		ByVal self As FileStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT

	self->FileSize = FileSize

	Return S_OK

End Function

Private Function FileStreamSetEncoding( _
		ByVal self As FileStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT

	self->ZipMode = ZipMode

	Return S_OK

End Function

Private Function FileStreamSetFileTime( _
		ByVal self As FileStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT

	CopyMemory(@self->LastFileModifiedDate, pTime, SizeOf(FILETIME))

	Return S_OK

End Function

Private Function FileStreamSetETag( _
		ByVal self As FileStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT

	LET_HEAPSYSSTRING(self->ETag, ETag)

	Return S_OK

End Function

Private Function FileStreamSetReservedFileBytes( _
		ByVal self As FileStream Ptr, _
		ByVal Length As UInteger _
	)As HRESULT

	Dim Value As UInteger = min(Length, ReservedBytesLengthMaximum)

	If Value Then
		self->ReservedBytesLength = Value
	Else
		self->ReservedBytesLength = ReservedBytesLengthDefault
	End If

	Return S_OK

End Function

Private Function FileStreamSetPreloadedBytes( _
		ByVal self As FileStream Ptr, _
		ByVal PreloadedBytesLength As UInteger, _
		ByVal pPreloadedBytes As UByte Ptr _
	)As HRESULT

	self->PreloadedBytes.Length = PreloadedBytesLength
	self->PreloadedBytes.pBytes = pPreloadedBytes

	Return S_OK

End Function

Private Function FileStreamAllocSlice( _
		ByVal self As FileStream Ptr, _
		ByVal DesiredLength As UInteger, _
		ByVal pSlice As BufferSlice Ptr _
	)As HRESULT

	Dim Length As UInteger = min(DesiredLength, self->ReservedBytesLength)

	Dim pMem As Any Ptr = FileStreamAllocateBufferSink( _
		self, _
		Length _
	)
	If pMem = NULL Then
		Return E_OUTOFMEMORY
	End If

	pSlice->pSlice = pMem
	pSlice->Length = Length

	Return S_OK

End Function


Private Function IFileAsyncStreamQueryInterface( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return FileStreamQueryInterface(CONTAINING_RECORD(self, FileStream, lpVtbl), riid, ppvObject)
End Function

Private Function IFileAsyncStreamAddRef( _
		ByVal self As IFileAsyncStream Ptr _
	)As ULONG
	Return FileStreamAddRef(CONTAINING_RECORD(self, FileStream, lpVtbl))
End Function

Private Function IFileAsyncStreamRelease( _
		ByVal self As IFileAsyncStream Ptr _
	)As ULONG
	Return FileStreamRelease(CONTAINING_RECORD(self, FileStream, lpVtbl))
End Function

Private Function IFileAsyncStreamGetContentType( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return FileStreamGetContentType(CONTAINING_RECORD(self, FileStream, lpVtbl), ppType)
End Function

Private Function IFileAsyncStreamGetEncoding( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return FileStreamGetEncoding(CONTAINING_RECORD(self, FileStream, lpVtbl), pZipMode)
End Function

Private Function IFileAsyncStreamGetLanguage( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetLanguage(CONTAINING_RECORD(self, FileStream, lpVtbl), ppLanguage)
End Function

Private Function IFileAsyncStreamGetETag( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetETag(CONTAINING_RECORD(self, FileStream, lpVtbl), ppETag)
End Function

Private Function IFileAsyncStreamGetLastFileModifiedDate( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return FileStreamGetLastFileModifiedDate(CONTAINING_RECORD(self, FileStream, lpVtbl), ppDate)
End Function

Private Function IFileAsyncStreamGetLength( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	Return FileStreamGetLength(CONTAINING_RECORD(self, FileStream, lpVtbl), pLength)
End Function

Private Function IFileAsyncStreamGetPreloadedBytes( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pPreloadedBytesLength As UInteger Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return FileStreamGetPreloadedBytes(CONTAINING_RECORD(self, FileStream, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Private Function IFileAsyncStreamBeginReadSlice( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return FileStreamBeginReadSlice(CONTAINING_RECORD(self, FileStream, lpVtbl), StartIndex, Length, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IFileAsyncStreamEndReadSlice( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return FileStreamEndReadSlice(CONTAINING_RECORD(self, FileStream, lpVtbl), pIAsyncResult, pBufferSlice)
End Function

Private Function IFileAsyncStreamGetFilePath( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	Return FileStreamGetFilePath(CONTAINING_RECORD(self, FileStream, lpVtbl), ppFilePath)
End Function

Private Function IFileAsyncStreamSetFilePath( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	Return FileStreamSetFilePath(CONTAINING_RECORD(self, FileStream, lpVtbl), FilePath)
End Function

Private Function IFileAsyncStreamGetFileHandle( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileStreamGetFileHandle(CONTAINING_RECORD(self, FileStream, lpVtbl), pResult)
End Function

Private Function IFileAsyncStreamSetFileHandle( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetFileHandle(CONTAINING_RECORD(self, FileStream, lpVtbl), hFile)
End Function

Private Function IFileAsyncStreamGetZipFileHandle( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	Return FileStreamGetZipFileHandle(CONTAINING_RECORD(self, FileStream, lpVtbl), pResult)
End Function

Private Function IFileAsyncStreamSetZipFileHandle( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	Return FileStreamSetZipFileHandle(CONTAINING_RECORD(self, FileStream, lpVtbl), hFile)
End Function

Private Function IFileAsyncStreamSetContentType( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return FileStreamSetContentType(CONTAINING_RECORD(self, FileStream, lpVtbl), pType)
End Function

Private Function IFileAsyncStreamSetFileOffset( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	Return FileStreamSetFileOffset(CONTAINING_RECORD(self, FileStream, lpVtbl), Offset)
End Function

Private Function IFileAsyncStreamSetFileSize( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	Return FileStreamSetFileSize(CONTAINING_RECORD(self, FileStream, lpVtbl), FileSize)
End Function

Private Function IFileAsyncStreamSetEncoding( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return FileStreamSetEncoding(CONTAINING_RECORD(self, FileStream, lpVtbl), ZipMode)
End Function

Private Function IFileAsyncStreamSetFileTime( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	Return FileStreamSetFileTime(CONTAINING_RECORD(self, FileStream, lpVtbl), pTime)
End Function

Private Function IFileAsyncStreamSetETag( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	Return FileStreamSetETag(CONTAINING_RECORD(self, FileStream, lpVtbl), ETag)
End Function

Private Function IFileAsyncStreamSetReservedFileBytes( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT
	Return FileStreamSetReservedFileBytes(CONTAINING_RECORD(self, FileStream, lpVtbl), ReservedFileBytes)
End Function

Private Function IFileAsyncStreamSetPreloadedBytes( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal PreloadedBytesLength As UInteger, _
		ByVal pPreloadedBytes As UByte Ptr _
	)As HRESULT
	Return FileStreamSetPreloadedBytes(CONTAINING_RECORD(self, FileStream, lpVtbl), PreloadedBytesLength, pPreloadedBytes)
End Function

Private Function IFileAsyncStreamAllocSlice( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal DesiredLength As UInteger, _
		ByVal pSlice As BufferSlice Ptr _
	)As HRESULT
	Return FileStreamAllocSlice(CONTAINING_RECORD(self, FileStream, lpVtbl), DesiredLength, pSlice)
End Function

Private Function IFileAsyncStreamBeginWriteSlice( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr, _
		ByVal Offset As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return FileStreamBeginWriteSlice(CONTAINING_RECORD(self, FileStream, lpVtbl), pBufferSlice, Offset, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IFileAsyncStreamEndWriteSlice( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	Return FileStreamEndWriteSlice(CONTAINING_RECORD(self, FileStream, lpVtbl), pIAsyncResult, pWritedBytes)
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
	@IFileAsyncStreamAllocSlice, _
	@IFileAsyncStreamBeginWriteSlice, _
	@IFileAsyncStreamEndWriteSlice _
)
