#include "RequestedFile.bi"
#include "ContainerOf.bi"
#include "HttpConst.bi"

Dim Shared GlobalRequestedFileVirtualTable As IRequestedFileVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@RequestedFileQueryInterface, _
		@RequestedFileAddRef, _
		@RequestedFileRelease _
	), _
	NULL, _
	@RequestedFileGetFilePath, _
	NULL, _
	@RequestedFileGetPathTranslated, _
	NULL, _
	@RequestedFileFileExists, _
	@RequestedFileGetFileHandle, _
	@RequestedFileGetLastFileModifiedDate, _
	NULL, _
	NULL _
)

' TODO Заполнить виртуальную таблицу RequestedFile
Dim Shared GlobalRequestedFileSendableVirtualTable As ISendableVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		NULL, _
		NULL, _
		NULL _
	), _
	NULL _
)

/'
Function Remove()As Boolean
	' TODO Узнать код ошибки и отправить его клиенту
	If DeleteFile(@pRequestedFile->PathTranslated) <> 0 Then
		' Удалить возможные заголовочные файлы
		Dim sExtHeadersFile As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
		lstrcpy(@sExtHeadersFile, @pWebSite->PathTranslated)
		lstrcat(@sExtHeadersFile, @HeadersExtensionString)
		DeleteFile(@sExtHeadersFile)
		
		' Создать файл «.410», показывающий, что файл был удалён
		lstrcpy(@sExtHeadersFile, @pWebSite->PathTranslated)
		lstrcat(@sExtHeadersFile, @FileGoneExtension)
		Dim hRequestedFile As HANDLE = CreateFile(@sExtHeadersFile, GENERIC_WRITE, 0, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL)
		CloseHandle(hRequestedFile)
		
		Return True
	Else
		Return False
	End If
	
End Function
'/

Sub InitializeRequestedFile( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)
	
	pRequestedFile->pRequestedFileVirtualTable = @GlobalRequestedFileVirtualTable
	pRequestedFile->pSendableVirtualTable = @GlobalRequestedFileSendableVirtualTable
	pRequestedFile->ReferenceCounter = 0
	
	pRequestedFile->FilePath[0] = 0
	pRequestedFile->PathTranslated[0] = 0
	
	' Dim FileExists As FileState
	' Dim LastFileModifiedDate As FILETIME
	
	pRequestedFile->FileHandle = INVALID_HANDLE_VALUE
	pRequestedFile->FileDataLength = 0
	
	pRequestedFile->GZipFileHandle = INVALID_HANDLE_VALUE
	pRequestedFile->GZipFileDataLength = 0
	
	pRequestedFile->DeflateFileHandle = INVALID_HANDLE_VALUE
	pRequestedFile->DeflateFileDataLength = 0
	
End Sub

Sub UnInitializeRequestedFile( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)
	
	If pRequestedFile->FileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(pRequestedFile->FileHandle)
	End If
	
	If pRequestedFile->GZipFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(pRequestedFile->GZipFileHandle)
	End If
	
	If pRequestedFile->DeflateFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(pRequestedFile->DeflateFileHandle)
	End If
	
End Sub

Function CreateRequestedFile( _
	)As RequestedFile Ptr
	
	Dim pRequestedFile As RequestedFile Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(RequestedFile) _
	)
	
	If pRequestedFile = NULL Then
		Return NULL
	End If
	
	InitializeRequestedFile(pRequestedFile)
	
	Return pRequestedFile
	
End Function

Sub DestroyRequestedFile( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)
	
	UnInitializeRequestedFile(pRequestedFile)
	
	HeapFree(GetProcessHeap(), 0, pRequestedFile)
	
End Sub

Function RequestedFileQueryInterface( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IRequestedFile, riid) Then
		*ppv = @pRequestedFile->pRequestedFileVirtualTable
	Else
		If IsEqualIID(@IID_ISendable, riid) Then
			*ppv = @pRequestedFile->pSendableVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @pRequestedFile->pRequestedFileVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	RequestedFileAddRef(pRequestedFile)
	
	Return S_OK
	
End Function

Function RequestedFileAddRef( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)As ULONG
	
	pRequestedFile->ReferenceCounter += 1
	
	Return pRequestedFile->ReferenceCounter
	
End Function

Function RequestedFileRelease( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)As ULONG
	
	pRequestedFile->ReferenceCounter -= 1
	
	If pRequestedFile->ReferenceCounter = 0 Then
		
		DestroyRequestedFile(pRequestedFile)
		
		Return 0
	End If
	
	Return pRequestedFile->ReferenceCounter
	
End Function

' Declare Function RequestedFileChoiseFile( _
	' ByVal pRequestedFile As RequestedFile Ptr, _
	' ByVal pUri As Uri Ptr _
' )As HRESULT

Function RequestedFileGetFilePath( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal ppFilePath As WString Ptr Ptr _
	)As HRESULT
	
	*ppFilePath = @pRequestedFile->FilePath
	
	Return S_OK
	
End Function

' Declare Function RequestedFileSetFilePath( _
	' ByVal pRequestedFile As RequestedFile Ptr, _
	' ByVal FilePath As WString Ptr _
' )As HRESULT

Function RequestedFileGetPathTranslated( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal ppPathTranslated As WString Ptr Ptr _
	)As HRESULT
	
	*ppPathTranslated = @pRequestedFile->PathTranslated
	
	Return S_OK
	
End Function

' Declare Function RequestedFileSetPathTranslated( _
	' ByVal pRequestedFile As RequestedFile Ptr, _
	' ByVal PathTranslated As WString Ptr Ptr _
' )As HRESULT

Function RequestedFileFileExists( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal pResult As RequestedFileState Ptr _
	)As HRESULT
	
	If pRequestedFile->FileHandle = INVALID_HANDLE_VALUE Then
		' TODO Проверить код ошибки через GetLastError, могут быть не только File Not Found
		Dim buf410 As WString * (MAX_PATH + 1) = Any
		lstrcpy(@buf410, @pRequestedFile->PathTranslated)
		lstrcat(@buf410, @FileGoneExtension)
		
		Dim hFile410 As HANDLE = CreateFile( _
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

Function RequestedFileGetFileHandle( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	*pResult = pRequestedFile->FileHandle
	
	Return S_OK
	
End Function

Function RequestedFileGetLastFileModifiedDate( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	Dim DateLastFileModified As FILETIME = Any
	
	If GetFileTime(pRequestedFile->FileHandle, NULL, NULL, @DateLastFileModified) = 0 Then
		Return HRESULT_FROM_WIN32(GetLastError())
	End If
	
	*pResult = DateLastFileModified
	
	Return S_OK
	
End Function
' Declare Function RequestedFileGetFileLength( _
	' ByVal pRequestedFile As RequestedFile Ptr, _
	' ByVal pResult As ULongInt Ptr _
' )As HRESULT

' Declare Function RequestedFileGetVaryHeaders( _
	' ByVal pRequestedFile As RequestedFile Ptr, _
	' ByVal pHeadersLength As Integer Ptr, _
	' ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
' )As HRESULT
