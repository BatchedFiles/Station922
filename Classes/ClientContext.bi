#ifndef CLIENTCONTEXT_BI
#define CLIENTCONTEXT_BI

#include once "IClientContext.bi"

Extern CLSID_CLIENTCONTEXT Alias "CLSID_CLIENTCONTEXT" As Const CLSID

Type ClientContext As _ClientContext

Type LPClientContext As _ClientContext Ptr

Declare Function CreateClientContext( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ClientContext Ptr

Declare Sub DestroyClientContext( _
	ByVal this As ClientContext Ptr _
)

Declare Function ClientContextQueryInterface( _
	ByVal this As ClientContext Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ClientContextAddRef( _
	ByVal this As ClientContext Ptr _
)As ULONG

Declare Function ClientContextRelease( _
	ByVal this As ClientContext Ptr _
)As ULONG

Declare Function ClientContextGetRemoteAddress( _
	ByVal this As ClientContext Ptr, _
	ByVal pRemoteAddress As SOCKADDR Ptr, _
	ByVal pRemoteAddressLength As Integer Ptr _
)As HRESULT

Declare Function ClientContextSetRemoteAddress( _
	ByVal this As ClientContext Ptr, _
	ByVal RemoteAddress As SOCKADDR Ptr, _
	ByVal RemoteAddressLength As Integer _
)As HRESULT

Declare Function ClientContextGetMemoryAllocator( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIMemoryAllocator As IMalloc Ptr Ptr _
)As HRESULT

' Declare Function ClientContextSetMemoryAllocator( _
	' ByVal this As ClientContext Ptr, _
	' ByVal pIMemoryAllocator As IMalloc Ptr _
' )As HRESULT

Declare Function ClientContextGetNetworkStream( _
	ByVal this As ClientContext Ptr, _
	ByVal ppINetworkStream As INetworkStream Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetNetworkStream( _
	ByVal this As ClientContext Ptr, _
	ByVal pINetworkStream As INetworkStream Ptr _
)As HRESULT

Declare Function ClientContextGetFrequency( _
	ByVal this As ClientContext Ptr, _
	ByVal pFrequency As LARGE_INTEGER Ptr _
)As HRESULT

Declare Function ClientContextSetFrequency( _
	ByVal this As ClientContext Ptr, _
	ByVal Frequency As LARGE_INTEGER _
)As HRESULT

Declare Function ClientContextGetStartTicks( _
	ByVal this As ClientContext Ptr, _
	ByVal pStartTicks As LARGE_INTEGER Ptr _
)As HRESULT

Declare Function ClientContextSetStartTicks( _
	ByVal this As ClientContext Ptr, _
	ByVal StartTicks As LARGE_INTEGER _
)As HRESULT

Declare Function ClientContextGetClientRequest( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIRequest As IClientRequest Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetClientRequest( _
	ByVal this As ClientContext Ptr, _
	ByVal pIRequest As IClientRequest Ptr _
)As HRESULT

Declare Function ClientContextGetServerResponse( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIResponse As IServerResponse Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetServerResponse( _
	ByVal this As ClientContext Ptr, _
	ByVal pIResponse As IServerResponse Ptr _
)As HRESULT

Declare Function ClientContextGetHttpReader( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIHttpReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetHttpReader( _
	ByVal this As ClientContext Ptr, _
	ByVal pIHttpReader As IHttpReader Ptr _
)As HRESULT

Declare Function ClientContextGetRequestedFile( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetRequestedFile( _
	ByVal this As ClientContext Ptr, _
	ByVal pIRequestedFile As IRequestedFile Ptr _
)As HRESULT

Declare Function ClientContextGetAsyncResult( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIAsync As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetAsyncResult( _
	ByVal this As ClientContext Ptr, _
	ByVal pIAsync As IAsyncResult Ptr _
)As HRESULT

Declare Function ClientContextGetRequestProcessor( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIProcessor As IRequestProcessor Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetRequestProcessor( _
	ByVal this As ClientContext Ptr, _
	ByVal pIProcessor As IRequestProcessor Ptr _
)As HRESULT

Declare Function ClientContextGetOperationCode( _
	ByVal this As ClientContext Ptr, _
	ByVal pCode As OperationCodes Ptr _
)As HRESULT

Declare Function ClientContextSetOperationCode( _
	ByVal this As ClientContext Ptr, _
	ByVal Code As OperationCodes _
)As HRESULT

#endif
