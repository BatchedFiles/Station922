#include once "ProcessPostRequest.bi"
#include once "HttpConst.bi"
#include once "WriteHttpError.bi"
#include once "Mime.bi"
#include once "WebUtils.bi"
#include once "CharConstants.bi"
#include once "ProcessCgiRequest.bi"
#include once "ProcessDllRequest.bi"
#include once "SafeHandle.bi"

Function ProcessPostRequest( _
		ByVal pState As ReadHeadersResult Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pWebSite As SimpleWebSite Ptr, _
		ByVal fileExtention As WString Ptr, _
		ByVal pClientReader As StreamSocketReader Ptr, _
		ByVal hRequestedFile As Handle _
	)As Boolean
	
	' Проверка существования файла
	If hRequestedFile = INVALID_HANDLE_VALUE Then
		' TODO Проверить код ошибки через GetLastError, могут быть не только File Not Found.
		Dim buf410 As WString * (SimpleWebSite.MaxFilePathTranslatedLength + 1) = Any
		lstrcpy(buf410, pWebSite->PathTranslated)
		lstrcat(buf410, @FileGoneExtension)
		
		Dim hFile410 As HANDLE = CreateFile(@buf410, 0, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
		Dim objHFile410 As SafeHandle = Type<SafeHandle>(hFile410)
		If hFile410 = INVALID_HANDLE_VALUE Then
			WriteHttpFileNotFound(pState, ClientSocket, pWebSite)
		Else
			WriteHttpFileGone(pState, ClientSocket, pWebSite)
		End If
		Return False
	End If
	
	' Проверка на CGI
	If NeedCGIProcessing(pState->ClientRequest.ClientUri.Path) Then
		CloseHandle(hRequestedFile)
		Return ProcessCGIRequest(pState, ClientSocket, pWebSite, fileExtention, pClientReader)
	End If
	
	' Проверка на dll-cgi
	If NeedDLLProcessing(pState->ClientRequest.ClientUri.Path) Then
		CloseHandle(hRequestedFile)
		Return ProcessDllCgiRequest(pState, ClientSocket, pWebSite, fileExtention)
	End If
	
	Return False
End Function
