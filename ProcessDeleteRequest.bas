#include "ProcessDeleteRequest.bi"
#include "HttpConst.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Function ProcessDeleteRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pResponse As WebResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	Dim PathTranslated As WString Ptr = Any
	IRequestedFile_GetPathTranslated(pIRequestedFile, @PathTranslated)
	
	Dim FileHandle As HANDLE = Any
	IRequestedFile_GetFileHandle(pIRequestedFile, @FileHandle)
	
	Dim FileExists As RequestedFileState = Any
	IRequestedFile_FileExists(pIRequestedFile, @FileExists)
	
	Select Case FileExists
		
		Case RequestedFileState.NotFound
			WriteHttpFileNotFound(pIRequest, pResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
			
		Case RequestedFileState.Gone
			WriteHttpFileGone(pIRequest, pResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
			
	End Select
	
	CloseHandle(FileHandle)
	
	' Проверка заголовка Authorization
	If HttpAuthUtil(pIRequest, pResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite, False) = False Then
		Return False
	End If
	
	' TODO Узнать код ошибки и отправить его клиенту
	If DeleteFile(PathTranslated) = 0 Then
		WriteHttpFileNotAvailable(pIRequest, pResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
		Return False
	End If
	
	' TODO Удалить возможные заголовочные файлы
	Dim sExtHeadersFile As WString * (MAX_PATH + 1) = Any
	lstrcpy(@sExtHeadersFile, PathTranslated)
	lstrcat(@sExtHeadersFile, @HeadersExtensionString)
	
	DeleteFile(@sExtHeadersFile)
	
	' Создать файл «.410», показывающий, что файл был удалён
	lstrcpy(@sExtHeadersFile, PathTranslated)
	lstrcat(@sExtHeadersFile, @FileGoneExtension)
	
	Dim hFile410 As HANDLE = CreateFile( _
		@sExtHeadersFile, _
		GENERIC_WRITE, _
		0, _
		NULL, _
		CREATE_NEW, _
		FILE_ATTRIBUTE_NORMAL, _
		NULL _
	)
	
	CloseHandle(hFile410)
	
	pResponse->StatusCode = HttpStatusCodes.NoContent
	
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	
	Dim WritedBytes As Integer = Any
	Dim hr As HRESULT = INetworkStream_Write(pINetworkStream, _
		@SendBuffer, 0, AllResponseHeadersToBytes(pIRequest, pResponse, @SendBuffer, 0), @WritedBytes _
	)
	
	If FAILED(hr) Then
		Return False
	End If
	
	Return True
End Function
