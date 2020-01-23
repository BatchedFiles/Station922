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
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	Dim PathTranslated As WString Ptr = Any
	IRequestedFile_GetPathTranslated(pIRequestedFile, @PathTranslated)
	
	Dim FileHandle As HANDLE = Any
	IRequestedFile_GetFileHandle(pIRequestedFile, @FileHandle)
	
	Dim bFileExists As RequestedFileState = Any
	IRequestedFile_FileExists(pIRequestedFile, @bFileExists)
	
	Select Case bFileExists
		
		Case RequestedFileState.NotFound
			WriteHttpFileNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
			
		Case RequestedFileState.Gone
			WriteHttpFileGone(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
			
	End Select
	
	Scope
		
		Dim ClientURI As Station922Uri = Any
		IClientRequest_GetUri(pIRequest, @ClientURI)
		
		Dim NeedProcessing As Boolean = Any
		
		IWebSite_NeedCgiProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		If NeedProcessing Then
			CloseHandle(FileHandle)
			Return ProcessCGIRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
		End If
		
		IWebSite_NeedDllProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		If NeedProcessing Then
			CloseHandle(FileHandle)
			Return ProcessDllCgiRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
		End If
		
	End Scope
	
	Dim objRequestedFile As SafeHandle = Type<SafeHandle>(FileHandle)
	
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethodsForFile)
	WriteHttpNotImplemented(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
	
	Return False
	
End Function
