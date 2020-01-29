#ifndef CLIENTCONTEXT_BI
#define CLIENTCONTEXT_BI

#include "IClientContext.bi"

Extern CLSID_CLIENTCONTEXT Alias "CLSID_CLIENTCONTEXT" As Const CLSID

Type ClientContext As _ClientContext

Type LPClientContext As _ClientContext Ptr

Declare Function CreateClientContext( _
	ByVal hHeap As HANDLE _
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
	ByVal pRemoteAddress As SOCKADDR_IN Ptr _
)As HRESULT

Declare Function ClientContextSetRemoteAddress( _
	ByVal this As ClientContext Ptr, _
	ByVal RemoteAddress As SOCKADDR_IN _
)As HRESULT

Declare Function ClientContextGetRemoteAddressLength( _
	ByVal this As ClientContext Ptr, _
	ByVal pRemoteAddressLength As Integer Ptr _
)As HRESULT

Declare Function ClientContextSetRemoteAddressLength( _
	ByVal this As ClientContext Ptr, _
	ByVal RemoteAddressLength As Integer _
)As HRESULT

Declare Function ClientContextGetThreadId( _
	ByVal this As ClientContext Ptr, _
	ByVal pThreadId As DWORD Ptr _
)As HRESULT

Declare Function ClientContextSetThreadId( _
	ByVal this As ClientContext Ptr, _
	ByVal ThreadId As DWORD _
)As HRESULT

Declare Function ClientContextGetThreadHandle( _
	ByVal this As ClientContext Ptr, _
	ByVal pThreadHandle As HANDLE Ptr _
)As HRESULT

Declare Function ClientContextSetThreadHandle( _
	ByVal this As ClientContext Ptr, _
	ByVal ThreadHandle As HANDLE _
)As HRESULT

Declare Function ClientContextGetExecutableDirectory( _
	ByVal this As ClientContext Ptr, _
	ByVal ppExecutableDirectory As WString Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetExecutableDirectory( _
	ByVal this As ClientContext Ptr, _
	ByVal pExecutableDirectory As WString Ptr _
)As HRESULT

Declare Function ClientContextGetWebSiteContainer( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIWebSiteContainer As IWebSiteContainer Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetWebSiteContainer( _
	ByVal this As ClientContext Ptr, _
	ByVal pIWebSiteContainer As IWebSiteContainer Ptr _
)As HRESULT

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

Declare Function ClientContextGetWebSite( _
	ByVal this As ClientContext Ptr, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

Declare Function ClientContextSetWebSite( _
	ByVal this As ClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)As HRESULT

#endif
