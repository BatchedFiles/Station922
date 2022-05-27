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
	ZipFileHandle As HANDLE
	Encoding As HeapBSTR
	Charset As HeapBSTR
	Language As HeapBSTR
	FileOffset As LongInt
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
	this->pPathTranslated = NULL
	this->FileHandle = INVALID_HANDLE_VALUE
	this->ZipFileHandle = INVALID_HANDLE_VALUE
	this->Encoding = NULL
	this->Charset = NULL
	this->Language = NULL
	this->FileOffset = 0
	ZeroMemory(@this->LastFileModifiedDate, SizeOf(FILETIME))
	this->ContentType.ContentType = ContentTypes.AnyAny
	this->ContentType.Charset = DocumentCharsets.ASCII
	this->ContentType.IsTextFormat = False
	
End Sub

Sub UnInitializeFileBuffer( _
		ByVal this As FileBuffer Ptr _
	)
	
	HeapSysFreeString(this->Language)
	HeapSysFreeString(this->Charset)
	HeapSysFreeString(this->Encoding)
	HeapSysFreeString(this->pPathTranslated)
	HeapSysFreeString(this->pFilePath)
	
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
	
	memcpy(ppType, @this->ContentType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function FileBufferGetEncoding( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppEncoding As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Encoding)
	*ppEncoding = this->Encoding
	
	Return S_OK
	
End Function

Function FileBufferGetCharset( _
		ByVal this As FileBuffer Ptr, _
		ByVal ppCharset As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Charset)
	*ppCharset = this->Charset
	
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
	
	' Dim strETag As WString * 256 = Any
	' GetETag( _
		' @strETag, _
		' @DateLastFileModified, _
		' ResponseZipEnable, _
		' ResponseZipMode _
	' )
	' *ppETag = HeapSysAllocString(this->pIMemoryAllocator, strETag)
	
	*ppETag = NULL
	
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
	
	Dim FileSize As LARGE_INTEGER = Any
	
	Dim resGetFileSize As BOOL = Any
	If this->ZipFileHandle = INVALID_HANDLE_VALUE Then
		resGetFileSize = GetFileSizeEx(this->FileHandle, @FileSize)
	Else
		resGetFileSize = GetFileSizeEx(this->ZipFileHandle, @FileSize)
	End If
	
	If resGetFileSize = 0 Then
		*pLength = 0
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	*pLength = FileSize.QuadPart - this->FileOffset
	
	Return S_OK
	
End Function

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
		' TODO ��������� ��� ������ ����� GetLastError, ����� ���� �� ������ File Not Found
		Dim buf410 As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@buf410, this->pPathTranslated)
		lstrcatW(@buf410, @FileGoneExtension)
		
		Dim Attributes As DWORD = GetFileAttributesW( _
			@buf410 _
		)
		If Attributes = INVALID_FILE_ATTRIBUTES Then
			*pResult = RequestedFileState.NotFound
		Else
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
	
	If this->FileHandle <> INVALID_HANDLE_VALUE Then
		GetFileTime( _
			this->FileHandle, _
			NULL, _
			NULL, _
			@this->LastFileModifiedDate _
		)
	End If
	
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

Function FileBufferSetContentType( _
		ByVal this As FileBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	memcpy(@this->ContentType, pType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function FileBufferSetFileOffset( _
		ByVal this As FileBuffer Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	this->FileOffset = Offset
	
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
		ByVal ppEncoding As HeapBSTR Ptr _
	)As HRESULT
	Return FileBufferGetEncoding(ContainerOf(this, FileBuffer, lpVtbl), ppEncoding)
End Function

Function IFileBufferGetCharset( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppCharset As HeapBSTR Ptr _
	)As HRESULT
	Return FileBufferGetCharset(ContainerOf(this, FileBuffer, lpVtbl), ppCharset)
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

' Function IFileBufferGetSlice( _
		' ByVal this As IFileBuffer Ptr, _
		' ByVal StartIndex As LongInt, _
		' ByVal Length As DWORD, _
		' ByVal pBufferSlice As BufferSlice Ptr _
	' )As HRESULT
	' Return FileBufferGetSlice(ContainerOf(this, FileBuffer, lpVtbl), StartIndex, Length, pBufferSlice)
' End Function

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

Dim GlobalFileBufferVirtualTable As Const IFileBufferVirtualTable = Type( _
	@IFileBufferQueryInterface, _
	@IFileBufferAddRef, _
	@IFileBufferRelease, _
	@IFileBufferGetContentType, _
	@IFileBufferGetEncoding, _
	@IFileBufferGetCharset, _
	@IFileBufferGetLanguage, _
	@IFileBufferGetETag, _
	@IFileBufferGetLastFileModifiedDate, _
	@IFileBufferGetLength, _
	NULL, _ /' @IFileBufferGetSlice, _ '/
	@IFileBufferGetFilePath, _
	@IFileBufferSetFilePath, _
	@IFileBufferGetPathTranslated, _
	@IFileBufferSetPathTranslated, _
	@IFileBufferFileExists, _
	@IFileBufferGetFileHandle, _
	@IFileBufferSetFileHandle, _
	@IFileBufferGetZipFileHandle, _
	@IFileBufferSetZipFileHandle, _
	@IFileBufferSetContentType, _
	@IFileBufferSetFileOffset _
)
