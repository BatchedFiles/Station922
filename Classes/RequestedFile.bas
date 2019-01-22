#include "RequestedFile.bi"
#include "HttpConst.bi"

Common Shared GlobalRequestedFileVirtualTable As IRequestedFileVirtualTable
Common Shared GlobalRequestedFileSendableVirtualTable As ISendableVirtualTable

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

Function InitializeRequestedFileOfIRequestedFile( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)As IRequestedFile Ptr
	
	InitializeRequestedFile(pRequestedFile)
	pRequestedFile->ExistsInStack = True
	
	Dim pIRequestedFile As IRequestedFile Ptr = Any
	
	RequestedFileQueryInterface( _
		pRequestedFile, @IID_IREQUESTEDFILE, @pIRequestedFile _
	)
	
	Return pIRequestedFile
	
End Function

Function RequestedFileQueryInterface( _
		ByVal pRequestedFile As RequestedFile Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = 0
	
	If IsEqualIID(@IID_IUnknown, riid) Then
		*ppv = CPtr(IUnknown Ptr, @pRequestedFile->pRequestedFileVirtualTable)
	End If
	
	If IsEqualIID(@IID_IREQUESTEDFILE, riid) Then
		*ppv = CPtr(IRequestedFile Ptr, @pRequestedFile->pRequestedFileVirtualTable)
	End If
	
	If IsEqualIID(@IID_ISENDABLE, riid) Then
		*ppv = CPtr(ISendable Ptr, @pRequestedFile->pSendableVirtualTable)
	End If
	
	If *ppv = 0 Then
		Return E_NOINTERFACE
	End If
	
	RequestedFileAddRef(pRequestedFile)
	
	Return S_OK
	
End Function

Function RequestedFileAddRef( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)As ULONG
	
	Return InterlockedIncrement(@pRequestedFile->ReferenceCounter)
	
End Function

Function RequestedFileRelease( _
		ByVal pRequestedFile As RequestedFile Ptr _
	)As ULONG
	
	InterlockedDecrement(@pRequestedFile->ReferenceCounter)
	
	If pRequestedFile->ReferenceCounter = 0 Then
		
		If pRequestedFile->ExistsInStack = False Then
		
		End If
		
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
