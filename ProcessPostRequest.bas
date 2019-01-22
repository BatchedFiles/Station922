#include "ProcessPostRequest.bi"
#include "HttpConst.bi"
#include "WriteHttpError.bi"
#include "Mime.bi"
#include "WebUtils.bi"
#include "CharacterConstants.bi"
#include "ProcessCgiRequest.bi"
#include "ProcessDllRequest.bi"
#include "SafeHandle.bi"

Function ProcessPostRequest( _
		ByVal pRequest As WebRequest Ptr, _
		ByVal pResponse As WebResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pWebSite As SimpleWebSite Ptr, _
		ByVal pClientReader As StreamSocketReader Ptr, _
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
			WriteHttpFileNotFound(pRequest, pResponse, pINetworkStream, pWebSite)
			Return False
			
		Case RequestedFileState.Gone
			WriteHttpFileGone(pRequest, pResponse, pINetworkStream, pWebSite)
			Return False
			
	End Select
	
	If NeedCGIProcessing(pRequest->ClientUri.Path) Then
		CloseHandle(FileHandle)
		Return ProcessCGIRequest(pRequest, pResponse, pINetworkStream, pWebSite, pClientReader, pIRequestedFile)
	End If
	
	If NeedDLLProcessing(pRequest->ClientUri.Path) Then
		CloseHandle(FileHandle)
		Return ProcessDllCgiRequest(pRequest, pResponse, pINetworkStream, pWebSite, pClientReader, pIRequestedFile)
	End If
	
	Dim objRequestedFile As SafeHandle = Type<SafeHandle>(FileHandle)
	
	pResponse->ResponseHeaders(HttpResponseHeaders.HeaderAllow) = @AllSupportHttpMethodsForFile
	WriteHttpNotImplemented(pRequest, pResponse, pINetworkStream, pWebSite)
	
	Return False
End Function
