#include "ClientContext.bi"
#include "CreateInstance.bi"

Type _ClientContext
	Dim pVirtualTable As IClientContextVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim hHeap As HANDLE
	Dim RemoteAddress As SOCKADDR_IN
	Dim RemoteAddressLength As Integer
	
	Dim ThreadId As DWORD
	Dim hThread As HANDLE
	Dim pExeDir As WString Ptr
	
	Dim pIWebSites As IWebSiteContainer Ptr
	Dim pINetworkStream As INetworkStream Ptr
	Dim pIRequest As IClientRequest Ptr
	Dim pIHttpReader As IHttpReader Ptr
	Dim pIResponse As IServerResponse Ptr
	Dim pIRequestedFile As IRequestedFile Ptr
	Dim pIWebSite As IWebSite Ptr
	
	Dim Frequency As LARGE_INTEGER
	Dim StartTicks As LARGE_INTEGER
	
End Type

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID
Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID
Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID
Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID
Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID

Dim Shared GlobalClientContextVirtualTable As IClientContextVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@ClientContextQueryInterface, _
		@ClientContextAddRef, _
		@ClientContextRelease _
	), _
	@ClientContextGetRemoteAddress, _
	@ClientContextSetRemoteAddress, _
	@ClientContextGetRemoteAddressLength, _
	@ClientContextSetRemoteAddressLength, _
	@ClientContextGetThreadId, _
	@ClientContextSetThreadId, _
	@ClientContextGetThreadHandle, _
	@ClientContextSetThreadHandle, _
	@ClientContextGetExecutableDirectory, _
	@ClientContextSetExecutableDirectory, _
	@ClientContextGetWebSiteContainer, _
	@ClientContextSetWebSiteContainer, _
	@ClientContextGetNetworkStream, _
	@ClientContextSetNetworkStream, _
	@ClientContextGetFrequency, _
	@ClientContextSetFrequency, _
	@ClientContextGetStartTicks, _
	@ClientContextSetStartTicks, _
	@ClientContextGetClientRequest, _
	@ClientContextSetClientRequest, _
	@ClientContextGetServerResponse, _
	@ClientContextSetServerResponse, _
	@ClientContextGetHttpReader, _
	@ClientContextSetHttpReader, _
	@ClientContextGetRequestedFile, _
	@ClientContextSetRequestedFile, _
	@ClientContextGetWebSite, _
	@ClientContextSetWebSite _
)

Sub InitializeClientContext( _
		ByVal this As ClientContext Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->pVirtualTable = @GlobalClientContextVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	
	ZeroMemory(@this->RemoteAddress, SizeOf(SOCKADDR_IN))
	this->RemoteAddressLength = 0
	
	this->ThreadId = 0
	this->hThread = NULL
	this->pExeDir = NULL
	
	this->pIWebSites = NULL
	this->pINetworkStream = NULL
	this->pIRequest = NULL
	this->pIHttpReader = NULL
	this->pIResponse = NULL
	this->pIRequestedFile = NULL
	this->pIWebSite = NULL
	
	this->Frequency.QuadPart = 0
	this->StartTicks.QuadPart = 0
	
End Sub

Sub UnInitializeClientContext( _
		ByVal this As ClientContext Ptr _
	)
	
	If this->hThread <> NULL Then
		CloseHandle(this->hThread)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteContainer_Release(this->pIWebSites)
	End If
	
	If this->pINetworkStream <> NULL Then
		INetworkStream_Release(this->pINetworkStream)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIResponse <> NULL Then
		IServerResponse_Release(this->pIResponse)
	End If
	
	If this->pIRequestedFile <> NULL Then
		IRequestedFile_Release(this->pIRequestedFile)
	End If
	
	If this->pIWebSite <> NULL Then
		IWebSite_Release(this->pIWebSite)
	End If
	
End Sub

Function CreateClientContext( _
		ByVal hHeap As HANDLE _
	)As ClientContext Ptr
	
	Dim pContext As ClientContext Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(ClientContext) _
	)
	
	If pContext = NULL Then
		Return NULL
	End If
	
	InitializeClientContext(pContext, hHeap)
	
	Dim hr As HRESULT = CreateInstance( _
		hHeap, _
		@CLSID_CLIENTREQUEST, _
		@IID_IClientRequest, _
		@pContext->pIRequest _
	)
	If FAILED(hr) Then
		DestroyClientContext(pContext)
		Return NULL
	End If
	
	hr = CreateInstance( _
		hHeap, _
		@CLSID_NETWORKSTREAM, _
		@IID_INetworkStream, _
		@pContext->pINetworkStream _
	)
	If FAILED(hr) Then
		DestroyClientContext(pContext)
		Return NULL
	End If
	
	hr = CreateInstance( _
		hHeap, _
		@CLSID_HTTPREADER, _
		@IID_IHttpReader, _
		@pContext->pIHttpReader _
	)
	If FAILED(hr) Then
		DestroyClientContext(pContext)
		Return NULL
	End If
	
	hr = CreateInstance( _
		hHeap, _
		@CLSID_SERVERRESPONSE, _
		@IID_IServerResponse, _
		@pContext->pIResponse _
	)
	If FAILED(hr) Then
		DestroyClientContext(pContext)
		Return NULL
	End If
	
	hr = CreateInstance( _
		hHeap, _
		@CLSID_REQUESTEDFILE, _
		@IID_IRequestedFile, _
		@pContext->pIRequestedFile _
	)
	If FAILED(hr) Then
		DestroyClientContext(pContext)
		Return NULL
	End If
	
	hr = CreateInstance( _
		hHeap, _
		@CLSID_WEBSITE, _
		@IID_IWebSite, _
		@pContext->pIWebSite _
	)
	If FAILED(hr) Then
		DestroyClientContext(pContext)
		Return NULL
	End If
	
	Return pContext
	
End Function

Sub DestroyClientContext( _
		ByVal this As ClientContext Ptr _
	)
	
	UnInitializeClientContext(this)
	
	' HeapFree( _
		' this->hThreadContextHeap, _
		' HEAP_NO_SERIALIZE, _
		' this _
	' )
	HeapDestroy(this->hHeap)
	
End Sub

Function ClientContextQueryInterface( _
		ByVal this As ClientContext Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientContext, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ClientContextAddRef(this)
	
	Return S_OK
	
End Function

Function ClientContextAddRef( _
		ByVal this As ClientContext Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function ClientContextRelease( _
		ByVal this As ClientContext Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyClientContext(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function ClientContextGetRemoteAddress( _
		ByVal this As ClientContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR_IN Ptr _
	)As HRESULT
	
	*pRemoteAddress = this->RemoteAddress
	
	Return S_OK
	
End Function

Function ClientContextSetRemoteAddress( _
		ByVal this As ClientContext Ptr, _
		ByVal RemoteAddress As SOCKADDR_IN _
	)As HRESULT
	
	this->RemoteAddress = RemoteAddress
	
	Return S_OK
	
End Function

Function ClientContextGetRemoteAddressLength( _
		ByVal this As ClientContext Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	
	Return S_OK
	
End Function

Function ClientContextSetRemoteAddressLength( _
		ByVal this As ClientContext Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	
	Return S_OK
	
End Function

Function ClientContextGetThreadId( _
		ByVal this As ClientContext Ptr, _
		ByVal pThreadId As DWORD Ptr _
	)As HRESULT
	
	*pThreadId = this->ThreadId
	
	Return S_OK
	
End Function

Function ClientContextSetThreadId( _
		ByVal this As ClientContext Ptr, _
		ByVal ThreadId As DWORD _
	)As HRESULT
	
	this->ThreadId = ThreadId
	
	Return S_OK
	
End Function

Function ClientContextGetThreadHandle( _
		ByVal this As ClientContext Ptr, _
		ByVal pThreadHandle As HANDLE Ptr _
	)As HRESULT
	
	*pThreadHandle = this->hThread
	
	Return S_OK
	
End Function

Function ClientContextSetThreadHandle( _
		ByVal this As ClientContext Ptr, _
		ByVal ThreadHandle As HANDLE _
	)As HRESULT
	
	If this->hThread <> NULL Then
		CloseHandle(this->hThread)
	End If
	
	this->hThread = ThreadHandle
	
	Return S_OK
	
End Function

Function ClientContextGetExecutableDirectory( _
		ByVal this As ClientContext Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	*ppExecutableDirectory = this->pExeDir
	
	Return S_OK
	
End Function

Function ClientContextSetExecutableDirectory( _
		ByVal this As ClientContext Ptr, _
		ByVal pExecutableDirectory As WString Ptr _
	)As HRESULT
	
	this->pExeDir = pExecutableDirectory
	
	Return S_OK
	
End Function

Function ClientContextGetWebSiteContainer( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIWebSiteContainer As IWebSiteContainer Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteContainer_AddRef(this->pIWebSites)
	End If
	
	*ppIWebSiteContainer = this->pIWebSites
	
	Return S_OK
	
End Function

Function ClientContextSetWebSiteContainer( _
		ByVal this As ClientContext Ptr, _
		ByVal pIWebSiteContainer As IWebSiteContainer Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteContainer_Release(this->pIWebSites)
	End If
	
	If pIWebSiteContainer <> NULL Then
		IWebSiteContainer_AddRef(pIWebSiteContainer)
	End If
	
	this->pIWebSites = pIWebSiteContainer
	
	Return S_OK
	
End Function

Function ClientContextGetNetworkStream( _
		ByVal this As ClientContext Ptr, _
		ByVal ppINetworkStream As INetworkStream Ptr Ptr _
	)As HRESULT
	
	If this->pINetworkStream <> NULL Then
		INetworkStream_AddRef(this->pINetworkStream)
	End If
	
	*ppINetworkStream = this->pINetworkStream
	
	Return S_OK
	
End Function

Function ClientContextSetNetworkStream( _
		ByVal this As ClientContext Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr _
	)As HRESULT
	
	If this->pINetworkStream <> NULL Then
		INetworkStream_Release(this->pINetworkStream)
	End If
	
	If pINetworkStream <> NULL Then
		INetworkStream_AddRef(pINetworkStream)
	End If
	
	this->pINetworkStream = pINetworkStream
	
	Return S_OK
	
End Function

Function ClientContextGetFrequency( _
		ByVal this As ClientContext Ptr, _
		ByVal pFrequency As LARGE_INTEGER Ptr _
	)As HRESULT
	
	pFrequency->QuadPart = this->Frequency.QuadPart
	
	Return S_OK
	
End Function

Function ClientContextSetFrequency( _
		ByVal this As ClientContext Ptr, _
		ByVal Frequency As LARGE_INTEGER _
	)As HRESULT
	
	this->Frequency.QuadPart = Frequency.QuadPart
	
	Return S_OK
	
End Function

Function ClientContextGetStartTicks( _
		ByVal this As ClientContext Ptr, _
		ByVal pStartTicks As LARGE_INTEGER Ptr _
	)As HRESULT
	
	pStartTicks->QuadPart = this->StartTicks.QuadPart
	
	Return S_OK
	
End Function

Function ClientContextSetStartTicks( _
		ByVal this As ClientContext Ptr, _
		ByVal StartTicks As LARGE_INTEGER _
	)As HRESULT
	
	this->StartTicks.QuadPart = StartTicks.QuadPart
	
	Return S_OK
	
End Function

Function ClientContextGetClientRequest( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function ClientContextSetClientRequest( _
		ByVal this As ClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If pIRequest <> NULL Then
		IClientRequest_AddRef(pIRequest)
	End If
	
	this->pIRequest = pIRequest
	
	Return S_OK
	
End Function

Function ClientContextGetServerResponse( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIResponse As IServerResponse Ptr Ptr _
	)As HRESULT
	
	If this->pIResponse <> NULL Then
		IServerResponse_AddRef(this->pIResponse)
	End If
	
	*ppIResponse = this->pIResponse
	
	Return S_OK
	
End Function

Function ClientContextSetServerResponse( _
		ByVal this As ClientContext Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)As HRESULT
	
	If this->pIResponse <> NULL Then
		IServerResponse_Release(this->pIResponse)
	End If
	
	If pIResponse <> NULL Then
		IClientRequest_AddRef(pIResponse)
	End If
	
	this->pIResponse = pIResponse
	
	Return S_OK
	
End Function

Function ClientContextGetHttpReader( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppIHttpReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function ClientContextSetHttpReader( _
		ByVal this As ClientContext Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pIHttpReader <> NULL Then
		IHttpReader_AddRef(pIHttpReader)
	End If
	
	this->pIHttpReader = pIHttpReader
	
	Return S_OK
	
End Function

Function ClientContextGetRequestedFile( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	
	If this->pIRequestedFile <> NULL Then
		IRequestedFile_AddRef(this->pIRequestedFile)
	End If
	
	*ppIRequestedFile = this->pIRequestedFile
	
	Return S_OK
	
End Function

Function ClientContextSetRequestedFile( _
		ByVal this As ClientContext Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As HRESULT
	
	If this->pIRequestedFile <> NULL Then
		IRequestedFile_Release(this->pIRequestedFile)
	End If
	
	If pIRequestedFile <> NULL Then
		IRequestedFile_AddRef(pIRequestedFile)
	End If
	
	this->pIRequestedFile = pIRequestedFile
	
	Return S_OK
	
End Function

Function ClientContextGetWebSite( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSite <> NULL Then
		IWebSite_AddRef(this->pIWebSite)
	End If
	
	*ppIWebSite = this->pIWebSite
	
	Return S_OK
	
End Function

Function ClientContextSetWebSite( _
		ByVal this As ClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	If this->pIWebSite <> NULL Then
		IWebSite_Release(this->pIWebSite)
	End If
	
	If pIWebSite <> NULL Then
		IWebSite_AddRef(pIWebSite)
	End If
	
	this->pIWebSite = pIWebSite
	
	Return S_OK
	
End Function
