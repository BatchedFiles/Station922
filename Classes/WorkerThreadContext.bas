#include "WorkerThreadContext.bi"
#include "CreateInstance.bi"

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID
Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID
Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID

Dim Shared GlobalWorkerThreadContextVirtualTable As IWorkerThreadContextVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@WorkerThreadContextQueryInterface, _
		@WorkerThreadContextAddRef, _
		@WorkerThreadContextRelease _
	), _
	@WorkerThreadContextGetRemoteAddress, _
	@WorkerThreadContextSetRemoteAddress, _
	@WorkerThreadContextGetRemoteAddressLength, _
	@WorkerThreadContextSetRemoteAddressLength, _
	@WorkerThreadContextGetThreadId, _
	@WorkerThreadContextSetThreadId, _
	@WorkerThreadContextGetThreadHandle, _
	@WorkerThreadContextSetThreadHandle, _
	@WorkerThreadContextGetExecutableDirectory, _
	@WorkerThreadContextSetExecutableDirectory, _
	@WorkerThreadContextGetWebSiteContainer, _
	@WorkerThreadContextSetWebSiteContainer, _
	@WorkerThreadContextGetNetworkStream, _
	@WorkerThreadContextSetNetworkStream, _
	@WorkerThreadContextGetThreadContextHeap, _
	@WorkerThreadContextSetThreadContextHeap, _
	@WorkerThreadContextGetFrequency, _
	@WorkerThreadContextSetFrequency, _
	@WorkerThreadContextGetStartTicks, _
	@WorkerThreadContextSetStartTicks, _
	@WorkerThreadContextGetClientRequest, _
	@WorkerThreadContextSetClientRequest _
)

Sub InitializeWorkerThreadContext( _
		ByVal this As WorkerThreadContext Ptr _
	)
	
	this->pVirtualTable = @GlobalWorkerThreadContextVirtualTable
	this->ReferenceCounter = 0
	
	ZeroMemory(@this->RemoteAddress, SizeOf(SOCKADDR_IN))
	this->RemoteAddressLength = 0
	
	this->ThreadId = 0
	this->hThread = NULL
	this->pExeDir = NULL
	
	this->pIWebSites = NULL
	this->pINetworkStream = NULL
	this->pIRequest = NULL
	
	this->hThreadContextHeap = NULL
	
	this->Frequency.QuadPart = 0
	this->StartTicks.QuadPart = 0
	
End Sub

Sub UnInitializeWorkerThreadContext( _
		ByVal this As WorkerThreadContext Ptr _
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
	
End Sub

Function CreateWorkerThreadContext( _
	)As WorkerThreadContext Ptr
	
	Dim pContext As WorkerThreadContext Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(WorkerThreadContext) _
	)
	
	If pContext = NULL Then
		Return NULL
	End If
	
	InitializeWorkerThreadContext(pContext)
	
	Dim hr As HRESULT = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_CLIENTREQUEST, _
		@IID_IClientRequest, _
		@pContext->pIRequest _
	)
	If FAILED(hr) Then
		DestroyWorkerThreadContext(pContext)
		Return NULL
	End If
	
	hr = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_NETWORKSTREAM, _
		@IID_INetworkStream, _
		@pContext->pINetworkStream _
	)
	If FAILED(hr) Then
		DestroyWorkerThreadContext(pContext)
		Return NULL
	End If
	
	Return pContext
	
End Function

Sub DestroyWorkerThreadContext( _
		ByVal this As WorkerThreadContext Ptr _
	)
	
	UnInitializeWorkerThreadContext(this)
	
	HeapFree(GetProcessHeap(), 0, this)
	
End Sub

Function WorkerThreadContextQueryInterface( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWorkerThreadContext, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WorkerThreadContextAddRef(this)
	
	Return S_OK
	
End Function

Function WorkerThreadContextAddRef( _
		ByVal this As WorkerThreadContext Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function WorkerThreadContextRelease( _
		ByVal this As WorkerThreadContext Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyWorkerThreadContext(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function WorkerThreadContextGetRemoteAddress( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR_IN Ptr _
	)As HRESULT
	
	*pRemoteAddress = this->RemoteAddress
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetRemoteAddress( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal RemoteAddress As SOCKADDR_IN _
	)As HRESULT
	
	this->RemoteAddress = RemoteAddress
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetRemoteAddressLength( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetRemoteAddressLength( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetThreadId( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pThreadId As DWORD Ptr _
	)As HRESULT
	
	*pThreadId = this->ThreadId
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetThreadId( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ThreadId As DWORD _
	)As HRESULT
	
	this->ThreadId = ThreadId
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetThreadHandle( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pThreadHandle As HANDLE Ptr _
	)As HRESULT
	
	*pThreadHandle = this->hThread
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetThreadHandle( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ThreadHandle As HANDLE _
	)As HRESULT
	
	If this->hThread <> NULL Then
		CloseHandle(this->hThread)
	End If
	
	this->hThread = ThreadHandle
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetExecutableDirectory( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	*ppExecutableDirectory = this->pExeDir
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetExecutableDirectory( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pExecutableDirectory As WString Ptr _
	)As HRESULT
	
	this->pExeDir = pExecutableDirectory
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetWebSiteContainer( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ppIWebSiteContainer As IWebSiteContainer Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteContainer_AddRef(this->pIWebSites)
	End If
	
	*ppIWebSiteContainer = this->pIWebSites
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetWebSiteContainer( _
		ByVal this As WorkerThreadContext Ptr, _
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

Function WorkerThreadContextGetNetworkStream( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ppINetworkStream As INetworkStream Ptr Ptr _
	)As HRESULT
	
	If this->pINetworkStream <> NULL Then
		INetworkStream_AddRef(this->pINetworkStream)
	End If
	
	*ppINetworkStream = this->pINetworkStream
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetNetworkStream( _
		ByVal this As WorkerThreadContext Ptr, _
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

Function WorkerThreadContextGetThreadContextHeap( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pThreadContextHeap As HANDLE Ptr _
	)As HRESULT
	
	*pThreadContextHeap = this->hThreadContextHeap
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetThreadContextHeap( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ThreadContextHeap As HANDLE _
	)As HRESULT
	
	this->hThreadContextHeap = ThreadContextHeap
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetFrequency( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pFrequency As LARGE_INTEGER Ptr _
	)As HRESULT
	
	pFrequency->QuadPart = this->Frequency.QuadPart
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetFrequency( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal Frequency As LARGE_INTEGER _
	)As HRESULT
	
	this->Frequency.QuadPart = Frequency.QuadPart
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetStartTicks( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal pStartTicks As LARGE_INTEGER Ptr _
	)As HRESULT
	
	pStartTicks->QuadPart = this->StartTicks.QuadPart
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetStartTicks( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal StartTicks As LARGE_INTEGER _
	)As HRESULT
	
	this->StartTicks.QuadPart = StartTicks.QuadPart
	
	Return S_OK
	
End Function

Function WorkerThreadContextGetClientRequest( _
		ByVal this As WorkerThreadContext Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function WorkerThreadContextSetClientRequest( _
		ByVal this As WorkerThreadContext Ptr, _
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
