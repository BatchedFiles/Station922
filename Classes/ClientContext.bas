#include once "ClientContext.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"

Extern GlobalClientContextVirtualTable As Const IClientContextVirtualTable

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID
Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID
Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID
Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

Type _ClientContext
	lpVtbl As Const IClientContextVirtualTable Ptr
	crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	pINetworkStream As INetworkStream Ptr
	pIRequest As IClientRequest Ptr
	pIHttpReader As IHttpReader Ptr
	pIResponse As IServerResponse Ptr
	pIRequestedFile As IRequestedFile Ptr
	pIAsync As IAsyncResult Ptr
	pIProcessor As IRequestProcessor Ptr
	OperationCode As OperationCodes
	RemoteAddress As SOCKADDR_STORAGE
	RemoteAddressLength As Integer
End Type

Sub InitializeClientContext( _
		ByVal this As ClientContext Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)
	
	this->lpVtbl = @GlobalClientContextVirtualTable
	InitializeCriticalSectionAndSpinCount( _
		@this->crSection, _
		MAX_CRITICAL_SECTION_SPIN_COUNT _
	)
	this->ReferenceCounter = 0
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->pINetworkStream = pINetworkStream
	this->pIRequest = pIRequest
	this->pIResponse = pIResponse
	this->pIHttpReader = pIHttpReader
	this->pIRequestedFile = pIRequestedFile
	this->pIAsync = NULL
	this->pIProcessor = NULL
	
	ZeroMemory(@this->RemoteAddress, SizeOf(SOCKADDR_STORAGE))
	this->RemoteAddressLength = 0
	
End Sub

Sub UnInitializeClientContext( _
		ByVal this As ClientContext Ptr _
	)
	
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
	
	If this->pIAsync <> NULL Then
		IAsyncResult_Release(this->pIAsync)
	End If
	
	If this->pIProcessor <> NULL Then
		IRequestProcessor_Release(this->pIProcessor)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	DeleteCriticalSection(@this->crSection)
	
End Sub

Function CreateClientContext( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ClientContext Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ClientContext)
		ILogger_LogDebug(pILogger, WStr(!"ClientContext creating\t"), vtAllocatedBytes)
	End Scope
	#endif
	
	Dim pIHttpReader As IHttpReader Ptr = Any
	Dim hr2 As HRESULT = CreateInstance( _
		pILogger, _
		pIMemoryAllocator, _
		@CLSID_HTTPREADER, _
		@IID_IHttpReader, _
		@pIHttpReader _
	)
	If SUCCEEDED(hr2) Then
		Dim pIRequest As IClientRequest Ptr = Any
		Dim hr3 As HRESULT = CreateInstance( _
			pILogger, _
			pIMemoryAllocator, _
			@CLSID_CLIENTREQUEST, _
			@IID_IClientRequest, _
			@pIRequest _
		)
		If SUCCEEDED(hr3) Then
			Dim pIResponse As IServerResponse Ptr = Any
			Dim hr4 As HRESULT = CreateInstance( _
				pILogger, _
				pIMemoryAllocator, _
				@CLSID_SERVERRESPONSE, _
				@IID_IServerResponse, _
				@pIResponse _
			)
			If SUCCEEDED(hr4) Then
				Dim pINetworkStream As INetworkStream Ptr = Any
				Dim hr5 As HRESULT = CreateInstance( _
					pILogger, _
					pIMemoryAllocator, _
					@CLSID_NETWORKSTREAM, _
					@IID_INetworkStream, _
					@pINetworkStream _
				)
				If SUCCEEDED(hr5) Then
					Dim this As ClientContext Ptr = IMalloc_Alloc( _
						pIMemoryAllocator, _
						SizeOf(ClientContext) _
					)
					If this <> NULL Then
						InitializeClientContext( _
							this, _
							pILogger, _
							pIMemoryAllocator, _
							pINetworkStream, _
							pIRequest, _
							pIResponse, _
							pIHttpReader, _
							NULL _
						)
						
						#if __FB_DEBUG__
						Scope
							Dim vtEmpty As VARIANT = Any
							VariantInit(@vtEmpty)
							ILogger_LogDebug(pILogger, WStr("ClientContext created"), vtEmpty)
						End Scope
						#endif
						
						Return this
						
					End If
					
					INetworkStream_Release(pINetworkStream)
					
				End If
				
				IServerResponse_Release(pIResponse)
				
			End If
			
			IClientRequest_Release(pIRequest)
			
		End If
		
		IHttpReader_Release(pIHttpReader)
		
	End If
	
	Return NULL
	
End Function

Sub DestroyClientContext( _
		ByVal this As ClientContext Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		ILogger_LogDebug(this->pILogger, WStr("ClientContext destroying"), vtEmpty)
	End Scope
	#endif
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeClientContext(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		ILogger_LogDebug(pILogger, WStr("ClientContext destroyed"), vtEmpty)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
End Sub

Function ClientContextQueryInterface( _
		ByVal this As ClientContext Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientContext, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
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
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter += 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	Return this->ReferenceCounter
	
End Function

Function ClientContextRelease( _
		ByVal this As ClientContext Ptr _
	)As ULONG
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyClientContext(this)
	
	Return 0
	
End Function

Function ClientContextGetRemoteAddress( _
		ByVal this As ClientContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	CopyMemory(pRemoteAddress, @this->RemoteAddress, this->RemoteAddressLength)
	
	Return S_OK
	
End Function

Function ClientContextSetRemoteAddress( _
		ByVal this As ClientContext Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	Return S_OK
	
End Function

Function ClientContextGetMemoryAllocator( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIMemoryAllocator As IMalloc Ptr Ptr _
	)As HRESULT
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	*ppIMemoryAllocator = this->pIMemoryAllocator
	
	Return S_OK
	
End Function

' Function ClientContextSetMemoryAllocator( _
		' ByVal this As ClientContext Ptr, _
		' ByVal pIMemoryAllocator As IMalloc Ptr _
	' )As HRESULT
	
	' IMalloc_AddRef(pIMemoryAllocator)
	' this->pIMemoryAllocator = pIMemoryAllocator
	
	' Return S_OK
	
' End Function

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

' Function ClientContextGetFrequency( _
		' ByVal this As ClientContext Ptr, _
		' ByVal pFrequency As LARGE_INTEGER Ptr _
	' )As HRESULT
	
	' #ifdef PERFORMANCE_TESTING
		' pFrequency->QuadPart = this->Frequency.QuadPart
	' #endif
	
	' Return S_OK
	
' End Function

' Function ClientContextSetFrequency( _
		' ByVal this As ClientContext Ptr, _
		' ByVal Frequency As LARGE_INTEGER _
	' )As HRESULT
	
	' #ifdef PERFORMANCE_TESTING
		' this->Frequency.QuadPart = Frequency.QuadPart
	' #endif
	
	' Return S_OK
	
' End Function

' Function ClientContextGetStartTicks( _
		' ByVal this As ClientContext Ptr, _
		' ByVal pStartTicks As LARGE_INTEGER Ptr _
	' )As HRESULT
	
	' #ifdef PERFORMANCE_TESTING
		' pStartTicks->QuadPart = this->StartTicks.QuadPart
	' #endif
	
	' Return S_OK
	
' End Function

' Function ClientContextSetStartTicks( _
		' ByVal this As ClientContext Ptr, _
		' ByVal StartTicks As LARGE_INTEGER _
	' )As HRESULT
	
	' #ifdef PERFORMANCE_TESTING
		' this->StartTicks.QuadPart = StartTicks.QuadPart
	' #endif
	
	' Return S_OK
	
' End Function

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

Function ClientContextGetAsyncResult( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIAsync As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	If this->pIAsync <> NULL Then
		IAsyncResult_AddRef(this->pIAsync)
	End If
	
	*ppIAsync = this->pIAsync
	
	Return S_OK
	
End Function

Function ClientContextSetAsyncResult( _
		ByVal this As ClientContext Ptr, _
		ByVal pIAsync As IAsyncResult Ptr _
	)As HRESULT
	
	If this->pIAsync <> NULL Then
		IAsyncResult_Release(this->pIAsync)
	End If
	
	If pIAsync <> NULL Then
		IAsyncResult_AddRef(pIAsync)
	End If
	
	this->pIAsync = pIAsync
	
	Return S_OK
	
End Function

Function ClientContextGetRequestProcessor( _
		ByVal this As ClientContext Ptr, _
		ByVal ppIProcessor As IRequestProcessor Ptr Ptr _
	)As HRESULT
	
	If this->pIProcessor <> NULL Then
		IRequestProcessor_AddRef(this->pIProcessor)
	End If
	
	*ppIProcessor = this->pIProcessor
	
	Return S_OK
	
End Function

Function ClientContextSetRequestProcessor( _
		ByVal this As ClientContext Ptr, _
		ByVal pIProcessor As IRequestProcessor Ptr _
	)As HRESULT
	
	If this->pIProcessor <> NULL Then
		IRequestProcessor_Release(this->pIProcessor)
	End If
	
	If pIProcessor <> NULL Then
		IRequestProcessor_AddRef(pIProcessor)
	End If
	
	this->pIProcessor = pIProcessor
	
	Return S_OK
	
End Function

Function ClientContextGetOperationCode( _
		ByVal this As ClientContext Ptr, _
		ByVal pCode As OperationCodes Ptr _
	)As HRESULT
	
	*pCode = this->OperationCode
	
	Return S_OK
	
End Function

Function ClientContextSetOperationCode( _
		ByVal this As ClientContext Ptr, _
		ByVal Code As OperationCodes _
	)As HRESULT
	
	this->OperationCode = Code
	
	Return S_OK
	
End Function

Function ClientContextGetLogger( _
		ByVal this As ClientContext Ptr, _
		ByVal ppILogger As ILogger Ptr Ptr _
	)As HRESULT
	
	ILogger_AddRef(this->pILogger)
	*ppILogger = this->pILogger
	
	Return S_OK
	
End Function

Function IClientContextQueryInterface( _
		ByVal this As IClientContext Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ClientContextQueryInterface(ContainerOf(this, ClientContext, lpVtbl), riid, ppvObject)
End Function

Function IClientContextAddRef( _
		ByVal this As IClientContext Ptr _
	)As ULONG
	Return ClientContextAddRef(ContainerOf(this, ClientContext, lpVtbl))
End Function

Function IClientContextRelease( _
		ByVal this As IClientContext Ptr _
	)As ULONG
	Return ClientContextRelease(ContainerOf(this, ClientContext, lpVtbl))
End Function

Function IClientContextGetRemoteAddress( _
		ByVal this As IClientContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	Return ClientContextGetRemoteAddress(ContainerOf(this, ClientContext, lpVtbl), pRemoteAddress, pRemoteAddressLength)
End Function

Function IClientContextSetRemoteAddress( _
		ByVal this As IClientContext Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	Return ClientContextSetRemoteAddress(ContainerOf(this, ClientContext, lpVtbl), RemoteAddress, RemoteAddressLength)
End Function

Function IClientContextGetMemoryAllocator( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIMemoryAllocator As IMalloc Ptr Ptr _
	)As HRESULT
	Return ClientContextGetMemoryAllocator(ContainerOf(this, ClientContext, lpVtbl), ppIMemoryAllocator)
End Function

' Function IClientContextSetClientContextHeap( _
		' ByVal this As IClientContext Ptr, _
		' ByVal hHeap As HANDLE _
	' )As HRESULT
	' Return ClientContextSetClientContextHeap(ContainerOf(this, ClientContext, lpVtbl), hHeap)
' End Function

Function IClientContextGetNetworkStream( _
		ByVal this As IClientContext Ptr, _
		ByVal ppINetworkStream As INetworkStream Ptr Ptr _
	)As HRESULT
	Return ClientContextGetNetworkStream(ContainerOf(this, ClientContext, lpVtbl), ppINetworkStream)
End Function

Function IClientContextSetNetworkStream( _
		ByVal this As IClientContext Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr _
	)As HRESULT
	Return ClientContextSetNetworkStream(ContainerOf(this, ClientContext, lpVtbl), pINetworkStream)
End Function

' Function IClientContextGetFrequency( _
		' ByVal this As IClientContext Ptr, _
		' ByVal pFrequency As LARGE_INTEGER Ptr _
	' )As HRESULT
	' Return ClientContextGetFrequency(ContainerOf(this, ClientContext, lpVtbl), pFrequency)
' End Function

' Function IClientContextSetFrequency( _
		' ByVal this As IClientContext Ptr, _
		' ByVal Frequency As LARGE_INTEGER _
	' )As HRESULT
	' Return ClientContextSetFrequency(ContainerOf(this, ClientContext, lpVtbl), Frequency)
' End Function

' Function IClientContextGetStartTicks( _
		' ByVal this As IClientContext Ptr, _
		' ByVal pStartTicks As LARGE_INTEGER Ptr _
	' )As HRESULT
	' Return ClientContextGetStartTicks(ContainerOf(this, ClientContext, lpVtbl), pStartTicks)
' End Function

' Function IClientContextSetStartTicks( _
		' ByVal this As IClientContext Ptr, _
		' ByVal StartTicks As LARGE_INTEGER _
	' )As HRESULT
	' Return ClientContextSetStartTicks(ContainerOf(this, ClientContext, lpVtbl), StartTicks)
' End Function

Function IClientContextGetClientRequest( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return ClientContextGetClientRequest(ContainerOf(this, ClientContext, lpVtbl), ppIRequest)
End Function

Function IClientContextSetClientRequest( _
		ByVal this As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return ClientContextSetClientRequest(ContainerOf(this, ClientContext, lpVtbl), pIRequest)
End Function

Function IClientContextGetServerResponse( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIResponse As IServerResponse Ptr Ptr _
	)As HRESULT
	Return ClientContextGetServerResponse(ContainerOf(this, ClientContext, lpVtbl), ppIResponse)
End Function

Function IClientContextSetServerResponse( _
		ByVal this As IClientContext Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)As HRESULT
	Return ClientContextSetServerResponse(ContainerOf(this, ClientContext, lpVtbl), pIResponse)
End Function

Function IClientContextGetHttpReader( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return ClientContextGetHttpReader(ContainerOf(this, ClientContext, lpVtbl), ppIHttpReader)
End Function

Function IClientContextSetHttpReader( _
		ByVal this As IClientContext Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	Return ClientContextSetHttpReader(ContainerOf(this, ClientContext, lpVtbl), pIHttpReader)
End Function

Function IClientContextGetRequestedFile( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	Return ClientContextGetRequestedFile(ContainerOf(this, ClientContext, lpVtbl), ppIRequestedFile)
End Function

Function IClientContextSetRequestedFile( _
		ByVal this As IClientContext Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As HRESULT
	Return ClientContextSetRequestedFile(ContainerOf(this, ClientContext, lpVtbl), pIRequestedFile)
End Function

Function IClientContextGetAsyncResult( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIAsync As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return ClientContextGetAsyncResult(ContainerOf(this, ClientContext, lpVtbl), ppIAsync)
End Function
	
Function IClientContextSetAsyncResult( _
		ByVal this As IClientContext Ptr, _
		ByVal pIAsync As IAsyncResult Ptr _
	)As HRESULT
	Return ClientContextSetAsyncResult(ContainerOf(this, ClientContext, lpVtbl), pIAsync)
End Function

Function IClientContextGetRequestProcessor( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIProcessor As IRequestProcessor Ptr Ptr _
	)As HRESULT
	Return ClientContextGetRequestProcessor(ContainerOf(this, ClientContext, lpVtbl), ppIProcessor)
End Function
	
Function IClientContextSetRequestProcessor( _
		ByVal this As IClientContext Ptr, _
		ByVal pIProcessor As IRequestProcessor Ptr _
	)As HRESULT
	Return ClientContextSetRequestProcessor(ContainerOf(this, ClientContext, lpVtbl), pIProcessor)
End Function

Function IClientContextGetOperationCode( _
		ByVal this As IClientContext Ptr, _
		ByVal pCode As OperationCodes Ptr _
	)As HRESULT
	Return ClientContextGetOperationCode(ContainerOf(this, ClientContext, lpVtbl), pCode)
End Function
	
Function IClientContextSetOperationCode( _
		ByVal this As IClientContext Ptr, _
		ByVal Code As OperationCodes _
	)As HRESULT
	Return ClientContextSetOperationCode(ContainerOf(this, ClientContext, lpVtbl), Code)
End Function

Function IClientContextGetLogger( _
		ByVal this As IClientContext Ptr, _
		ByVal ppILogger As ILogger Ptr Ptr _
	)As HRESULT
	Return ClientContextGetLogger(ContainerOf(this, ClientContext, lpVtbl), ppILogger)
End Function

Dim GlobalClientContextVirtualTable As Const IClientContextVirtualTable = Type( _
	@IClientContextQueryInterface, _
	@IClientContextAddRef, _
	@IClientContextRelease, _
	@IClientContextGetRemoteAddress, _
	@IClientContextSetRemoteAddress, _
	@IClientContextGetMemoryAllocator, _
	@IClientContextGetNetworkStream, _
	@IClientContextSetNetworkStream, _
	NULL, _ /' @IClientContextGetFrequency, _ '/
	NULL, _ /' @IClientContextSetFrequency, _ '/
	NULL, _ /' @IClientContextGetStartTicks, _ '/
	NULL, _ /' @IClientContextSetStartTicks, _ '/
	@IClientContextGetClientRequest, _
	@IClientContextSetClientRequest, _
	@IClientContextGetServerResponse, _
	@IClientContextSetServerResponse, _
	@IClientContextGetHttpReader, _
	@IClientContextSetHttpReader, _
	@IClientContextGetRequestedFile, _
	@IClientContextSetRequestedFile, _
	@IClientContextGetAsyncResult, _
	@IClientContextSetAsyncResult, _
	@IClientContextGetRequestProcessor, _
	@IClientContextSetRequestProcessor, _
	@IClientContextGetOperationCode, _
	@IClientContextSetOperationCode, _
	@IClientContextGetLogger _
)
