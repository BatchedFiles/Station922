#ifndef ICLIENTCONTEXT_BI
#define ICLIENTCONTEXT_BI

#include once "IClientRequest.bi"
#include once "IHttpReader.bi"
#include once "ILogger.bi"
#include once "INetworkStream.bi"
#include once "IRequestedFile.bi"
#include once "IRequestProcessor.bi"
#include once "IServerResponse.bi"

Enum OperationCodes
	ReadRequest = 1
	WriteResponse
End Enum

Type IClientContext As IClientContext_

Type LPICLIENTCONTEXT As IClientContext Ptr

Extern IID_IClientContext Alias "IID_IClientContext" As Const IID

Type IClientContextVirtualTable
	
	Dim QueryInterface As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim AddRef As Function( _
		ByVal this As IClientContext Ptr _
	)As ULONG
	
	Dim Release As Function( _
		ByVal this As IClientContext Ptr _
	)As ULONG
	
	Dim GetRemoteAddress As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	Dim SetRemoteAddress As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	Dim GetMemoryAllocator As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIMemoryAllocator As IMalloc Ptr Ptr _
	)As HRESULT
	
	Dim GetNetworkStream As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppINetworkStream As INetworkStream Ptr Ptr _
	)As HRESULT
	
	Dim SetNetworkStream As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr _
	)As HRESULT
	
	Dim GetFrequency As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pFrequency As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Dim SetFrequency As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal Frequency As LARGE_INTEGER _
	)As HRESULT
	
	Dim GetStartTicks As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pStartTicks As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Dim SetStartTicks As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal StartTicks As LARGE_INTEGER _
	)As HRESULT
	
	Dim GetClientRequest As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	Dim SetClientRequest As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	Dim GetServerResponse As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIResponse As IServerResponse Ptr Ptr _
	)As HRESULT
	
	Dim SetServerResponse As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)As HRESULT
	
	Dim GetHttpReader As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	Dim SetHttpReader As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	
	Dim GetRequestedFile As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	
	Dim SetRequestedFile As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As HRESULT
	
	Dim GetAsyncResult As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIAsync As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim SetAsyncResult As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIAsync As IAsyncResult Ptr _
	)As HRESULT
	
	Dim GetRequestProcessor As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIProcessor As IRequestProcessor Ptr Ptr _
	)As HRESULT
	
	Dim SetRequestProcessor As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIProcessor As IRequestProcessor Ptr _
	)As HRESULT
	
	Dim GetOperationCode As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pCode As OperationCodes Ptr _
	)As HRESULT
	
	Dim SetOperationCode As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal Code As OperationCodes _
	)As HRESULT
	
	Dim GetLogger As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppILogger As ILogger Ptr Ptr _
	)As HRESULT
	
End Type

Type IClientContext_
	Dim lpVtbl As IClientContextVirtualTable Ptr
End Type

#define IClientContext_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IClientContext_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IClientContext_Release(this) (this)->lpVtbl->Release(this)
' #define IClientContext_GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength)
#define IClientContext_SetRemoteAddress(this, RemoteAddress, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddress(this, RemoteAddress, RemoteAddressLength)
' #define IClientContext_GetRemoteAddressLength(this, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddressLength(this, pRemoteAddressLength)
' #define IClientContext_SetRemoteAddressLength(this, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddressLength(this, RemoteAddressLength)
#define IClientContext_GetMemoryAllocator(this, ppIMemoryAllocator) (this)->lpVtbl->GetMemoryAllocator(this, ppIMemoryAllocator)
#define IClientContext_GetNetworkStream(this, ppINetworkStream) (this)->lpVtbl->GetNetworkStream(this, ppINetworkStream)
' #define IClientContext_SetNetworkStream(this, pINetworkStream) (this)->lpVtbl->SetNetworkStream(this, pINetworkStream)
#define IClientContext_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
' #define IClientContext_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IClientContext_GetServerResponse(this, ppIResponse) (this)->lpVtbl->GetServerResponse(this, ppIResponse)
' #define IClientContext_SetServerResponse(this, pIResponse) (this)->lpVtbl->SetServerResponse(this, pIResponse)
#define IClientContext_GetHttpReader(this, ppIHttpReader) (this)->lpVtbl->GetHttpReader(this, ppIHttpReader)
' #define IClientContext_SetHttpReader(this, pIHttpReader) (this)->lpVtbl->SetHttpReader(this, pIHttpReader)
#define IClientContext_GetRequestedFile(this, ppIRequestedFile) (this)->lpVtbl->GetRequestedFile(this, ppIRequestedFile)
#define IClientContext_SetRequestedFile(this, pIRequestedFile) (this)->lpVtbl->SetRequestedFile(this, pIRequestedFile)
' #define IClientContext_GetAsyncResult(this, ppIAsync) (this)->lpVtbl->GetAsyncResult(this, ppIAsync)
' #define IClientContext_SetAsyncResult(this, pIAsync) (this)->lpVtbl->SetAsyncResult(this, pIAsync)
#define IClientContext_GetRequestProcessor(this, ppIProcessor) (this)->lpVtbl->GetRequestProcessor(this, ppIProcessor)
#define IClientContext_SetRequestProcessor(this, pIProcessor) (this)->lpVtbl->SetRequestProcessor(this, pIProcessor)
#define IClientContext_GetOperationCode(this, pCode) (this)->lpVtbl->GetOperationCode(this, pCode)
#define IClientContext_SetOperationCode(this, Code) (this)->lpVtbl->SetOperationCode(this, Code)
#define IClientContext_GetLogger(this, ppILogger) (this)->lpVtbl->GetLogger(this, ppILogger)

#endif
