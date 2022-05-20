#include once "FileBuffer.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HttpConst.bi"
#include once "Logger.bi"

Extern GlobalFileBufferVirtualTable As Const IFileBufferVirtualTable

Const MEMORYPAGE_SIZE As Integer = 4096

Const REQUESTEDFILE_MAXPATHLENGTH As Integer = (MEMORYPAGE_SIZE) \ SizeOf(WString) - 1
Const REQUESTEDFILE_MAXPATHTRANSLATEDLENGTH As Integer = (MEMORYPAGE_SIZE) \ SizeOf(WString) - 1

Type _FileBuffer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IFileBufferVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pFilePath As HeapBSTR
	pPathTranslated As HeapBSTR
	FileHandle As Handle
	LastFileModifiedDate As FILETIME
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
	this->pPathTranslated = NULL
	this->FileHandle = INVALID_HANDLE_VALUE
	
End Sub

Sub UnInitializeFileBuffer( _
		ByVal this As FileBuffer Ptr _
	)
	
	HeapSysFreeString(this->pPathTranslated)
	HeapSysFreeString(this->pFilePath)
	
	If this->FileHandle <> INVALID_HANDLE_VALUE Then
		If CloseHandle(this->FileHandle) = 0 Then
			#if __FB_DEBUG__
			Scope
				Dim dwError As DWORD = GetLastError()
				If dwError <> ERROR_SUCCESS Then
					Dim vtErrorCode As VARIANT = Any
					vtErrorCode.vt = VT_UI4
					vtErrorCode.ulVal = dwError
					LogWriteEntry( _
						LogEntryType.Debug, _
						WStr(!"RequestedFile Close FileHandle Error\t"), _
						@vtErrorCode _
					)
				End If
			End Scope
			#endif
		End If
		this->FileHandle = INVALID_HANDLE_VALUE
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

' Declare Function FileBufferGetCapacity( _
	' ByVal this As FileBuffer Ptr, _
	' ByVal pCapacity As LongInt Ptr _
' )As HRESULT

' Declare Function FileBufferGetLength( _
	' ByVal this As FileBuffer Ptr, _
	' ByVal pLength As LongInt Ptr _
' )As HRESULT

' Declare Function FileBufferGetSlice( _
	' ByVal this As FileBuffer Ptr, _
	' ByVal StartIndex As LongInt, _
	' ByVal Length As DWORD, _
	' ByVal pBufferSlice As BufferSlice Ptr _
' )As HRESULT


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

Function FileBufferGetPathTranslated( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppPathTranslated As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pPathTranslated)
	*ppPathTranslated = this->pPathTranslated
	
	Return S_OK
	
End Function

Function FileBufferSetPathTranslated( _
		ByVal this As FileBuffer Ptr, _
		ByVal PathTranslated As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pPathTranslated, PathTranslated)
	
	Return S_OK
	
End Function

Function FileBufferFileExists( _
		ByVal this As FileBuffer Ptr, _
		ByVal pResult As RequestedFileState Ptr _
	)As HRESULT
	
	If this->FileHandle = INVALID_HANDLE_VALUE Then
		' TODO Проверить код ошибки через GetLastError, могут быть не только File Not Found
		Dim buf410 As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@buf410, this->pPathTranslated)
		lstrcatW(@buf410, @FileGoneExtension)
		
		Dim hFile410 As HANDLE = CreateFileW( _
			@buf410, _
			0, _
			FILE_SHARE_READ, _
			NULL, _
			OPEN_EXISTING, _
			FILE_ATTRIBUTE_NORMAL, _
			NULL _
		)
		
		If hFile410 = INVALID_HANDLE_VALUE Then
			*pResult = RequestedFileState.NotFound
		Else
			CloseHandle(hFile410)
			*pResult = RequestedFileState.Gone
		End If
		
	Else
		*pResult = RequestedFileState.Exist
	End If
	
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

Function FileBufferGetLastFileModifiedDate( _
		ByVal this As FileBuffer Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	Dim DateLastFileModified As FILETIME = Any
	
	If GetFileTime(this->FileHandle, NULL, NULL, @DateLastFileModified) = 0 Then
		Return HRESULT_FROM_WIN32(GetLastError())
	End If
	
	*pResult = DateLastFileModified
	
	Return S_OK
	
End Function

' Declare Function FileBufferGetFileLength( _
	' ByVal this As FileBuffer Ptr, _
	' ByVal pResult As ULongInt Ptr _
' )As HRESULT

' Declare Function FileBufferGetVaryHeaders( _
	' ByVal this As FileBuffer Ptr, _
	' ByVal pHeadersLength As Integer Ptr, _
	' ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
' )As HRESULT


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

Function IFileBufferGetPathTranslated( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppPathTranslated As HeapBSTR Ptr _
	)As HRESULT
	Return FileBufferGetPathTranslated(ContainerOf(this, FileBuffer, lpVtbl), ppPathTranslated)
End Function

Function IFileBufferSetPathTranslated( _
		ByVal this As IFileBuffer Ptr, _
		ByVal PathTranslated As HeapBSTR _
	)As HRESULT
	Return FileBufferSetPathTranslated(ContainerOf(this, FileBuffer, lpVtbl), PathTranslated)
End Function

Function IFileBufferFileExists( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As RequestedFileState Ptr _
	)As HRESULT
	Return FileBufferFileExists(ContainerOf(this, FileBuffer, lpVtbl), pResult)
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

Function IFileBufferGetLastFileModifiedDate( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	Return FileBufferGetLastFileModifiedDate(ContainerOf(this, FileBuffer, lpVtbl), pResult)
End Function

' Function IFileBufferGetFileLength( _
		' ByVal this As IFileBuffer Ptr, _
		' ByVal pResult As ULongInt Ptr _
	' )As HRESULT
	' Return FileBufferGetFileLength(ContainerOf(this, FileBuffer, lpVtbl), pResult)
' End Function

' Function IFileBufferGetVaryHeaders( _
		' ByVal this As IFileBuffer Ptr, _
		' ByVal pHeadersLength As Integer Ptr, _
		' ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
	' )As HRESULT
	' Return FileBufferGetVaryHeaders(ContainerOf(this, FileBuffer, lpVtbl), pHeadersLength, ppHeaders)
' End Function

Dim GlobalFileBufferVirtualTable As Const IFileBufferVirtualTable = Type( _
	@IFileBufferQueryInterface, _
	@IFileBufferAddRef, _
	@IFileBufferRelease, _
	NULL, _ /' @IFileBufferGetCapacity, _ '/
	NULL, _ /' @IFileBufferGetLength, _ '/
	NULL, _ /' @IFileBufferGetSlice, _ '/
	@IFileBufferGetFilePath, _
	@IFileBufferSetFilePath, _
	@IFileBufferGetPathTranslated, _
	@IFileBufferSetPathTranslated, _
	@IFileBufferFileExists, _
	@IFileBufferGetFileHandle, _
	@IFileBufferSetFileHandle, _
	@IFileBufferGetLastFileModifiedDate, _
	NULL _
)
