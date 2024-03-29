#include once "WebServer.bi"
#include once "AcceptConnectionAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HttpReader.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "TaskExecutor.bi"
#include once "WebSiteCollection.bi"
#include once "WebUtils.bi"

Extern GlobalWebServerVirtualTable As Const IWebServerVirtualTable

Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Const SocketListCapacity As Integer = 10

Type WebServer
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IWebServerVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	SocketList(0 To SocketListCapacity - 1) As SocketNode
	SocketListLength As Integer
	ListenAddress As HeapBSTR
	ListenPort As HeapBSTR
End Type

Private Function CreateAcceptConnectionTask( _
		ByVal this As WebServer Ptr, _
		ByVal ServerSocket As SOCKET, _
		ByVal ppTask As IAcceptConnectionAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim pTask As IAcceptConnectionAsyncIoTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateAcceptConnectionAsyncTask( _
		this->pIMemoryAllocator, _
		@IID_IAcceptConnectionAsyncIoTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		*ppTask = NULL
		Return hrCreateTask
	End If
	
	IAcceptConnectionAsyncIoTask_SetListenSocket(pTask, ServerSocket)
	IAcceptConnectionAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSites)
	
	Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
	Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
		pIPool, _
		Cast(HANDLE, ServerSocket), _
		pTask _
	)
	If FAILED(hrBind) Then
		IAcceptConnectionAsyncIoTask_Release(pTask)
		*ppTask = NULL
		Return hrBind
	End If
	
	*ppTask = pTask
	Return S_OK
	
End Function

Private Function CreateServerSocketSink( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim hrCreateSocket As HRESULT = CreateSocketAndListenW( _
		this->ListenAddress, _
		this->ListenPort, _
		@this->SocketList(0), _
		SocketListCapacity, _
		@this->SocketListLength _
	)
	
	Scope
		Dim vtAddressMessage As VARIANT = Any
		vtAddressMessage.vt = VT_BSTR
		vtAddressMessage.bstrVal = this->ListenAddress
		LogWriteEntry( _
			LogEntryType.Information, _
			WStr(!"Listen address"), _
			@vtAddressMessage _
		)
		
		Dim vtPortMessage As VARIANT = Any
		vtPortMessage.vt = VT_BSTR
		vtPortMessage.bstrVal = this->ListenPort
		LogWriteEntry( _
			LogEntryType.Information, _
			WStr(!"Listen port"), _
			@vtPortMessage _
		)
	End Scope
	
	HeapSysFreeString(this->ListenAddress)
	this->ListenAddress = NULL
	
	HeapSysFreeString(this->ListenPort)
	this->ListenPort = NULL
	
	If FAILED(hrCreateSocket) Then
		Dim vtErrorMessage As VARIANT = Any
		vtErrorMessage.vt = VT_ERROR
		vtErrorMessage.scode = hrCreateSocket
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"Can not open and listend socket, error code"), _
			@vtErrorMessage _
		)
		Return hrCreateSocket
	End If
	
	Return S_OK
	
End Function

Private Sub InitializeWebServer( _
		ByVal this As WebServer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_WEBSERVER), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalWebServerVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	' Do not need AddRef pIWebSites
	this->pIWebSites = pIWebSites
	this->ListenAddress = NULL
	this->ListenPort = NULL
	
End Sub

Private Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	HeapSysFreeString(this->ListenAddress)
	HeapSysFreeString(this->ListenPort)
	
	If this->pIWebSites Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
End Sub

Private Sub WebServerCreated( _
		ByVal this As WebServer Ptr _
	)
	
End Sub

Private Sub WebServerDestroyed( _
		ByVal this As WebServer Ptr _
	)
	
End Sub

Private Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	WebServerDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function WebServerAddRef( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Private Function WebServerRelease( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyWebServer(this)
	
	Return 0
	
End Function

Private Function WebServerQueryInterface( _
		ByVal this As WebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebServer, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebServerAddRef(this)
	
	Return S_OK
	
End Function

Public Function CreateWebServer( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As WebServer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebServer) _
	)
	
	If this Then
		Dim pIWebSites As IWebSiteCollection Ptr = Any
		Dim hrCreateCollection As HRESULT = CreateWebSiteCollection( _
			pIMemoryAllocator, _
			@IID_IWebSiteCollection, _
			@pIWebSites _
		)
		
		If SUCCEEDED(hrCreateCollection) Then
			
			InitializeWebServer( _
				this, _
				pIMemoryAllocator, _
				pIWebSites _
			)
			
			WebServerCreated(this)
			
			Dim hrQueryInterface As HRESULT = WebServerQueryInterface( _
				this, _
				riid, _
				ppv _
			)
			If FAILED(hrQueryInterface) Then
				DestroyWebServer(this)
			End If
			
			Return hrQueryInterface
		End If
		
		IMalloc_Free( _
			pIMemoryAllocator, _
			this _
		)
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function WebServerAddWebSite( _
		ByVal this As WebServer Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	Dim hrAdd As HRESULT = IWebSiteCollection_Add( _
		this->pIWebSites, _
		pKey, _
		Port, _
		pIWebSite _
	)
	If FAILED(hrAdd) Then
		Return hrAdd
	End If
	
	Return S_OK
	
End Function

Private Function WebServerAddDefaultWebSite( _
		ByVal this As WebServer Ptr, _
		ByVal pIDefaultWebSite As IWebSite Ptr _
	)As HRESULT
	
	Dim hrAdd As HRESULT = IWebSiteCollection_SetDefaultWebSite( _
		this->pIWebSites, _
		pIDefaultWebSite _
	)
	If FAILED(hrAdd) Then
		Return hrAdd
	End If
	
	Return S_OK
	
End Function

Private Function WebServerSetEndPoint( _
		ByVal this As WebServer Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ListenAddress, ListenAddress)
	LET_HEAPSYSSTRING(this->ListenPort, ListenPort)
	
	Return S_OK
	
End Function

Private Function WebServerRun( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim hrSocket As HRESULT = CreateServerSocketSink(this)
	If FAILED(hrSocket) Then
		Return hrSocket
	End If
	
	For i As Integer = 0 To this->SocketListLength - 1
		
		Dim pTask As IAcceptConnectionAsyncIoTask Ptr = Any
		Dim hrCreate As HRESULT = CreateAcceptConnectionTask( _
			this, _
			this->SocketList(i).ClientSocket, _
			@pTask _
		)
		If FAILED(hrCreate) Then
			Return hrCreate
		End If
		
		Dim hrBeginExecute As HRESULT = StartExecuteTask( _
			CPtr(IAsyncIoTask Ptr, pTask) _
		)
		If FAILED(hrBeginExecute) Then
			Return hrBeginExecute
		End If
		
		' ������ �� �� ��������� ������� ������ �� ������
		' ������� ������ �������� � ���� ������� ����� ������� EndExecute
		
	Next
	
	Dim vtErrorMessage As VARIANT = Any
	vtErrorMessage.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Information, _
		WStr(!"WebServer create succeeded\r\n"), _
		@vtErrorMessage _
	)
	
	Return S_OK
	
End Function

Private Function WebServerStop( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	For i As Integer = 0 To this->SocketListLength - 1
		closesocket(this->SocketList(i).ClientSocket)
	Next
	
	Return S_OK
	
End Function


Private Function IWebServerQueryInterface( _
		ByVal this As IWebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WebServerQueryInterface(ContainerOf(this, WebServer, lpVtbl), riid, ppv)
End Function

Private Function IWebServerAddRef( _
		ByVal this As IWebServer Ptr _
	)As ULONG
	Return WebServerAddRef(ContainerOf(this, WebServer, lpVtbl))
End Function

Private Function IWebServerRelease( _
		ByVal this As IWebServer Ptr _
	)As ULONG
	Return WebServerRelease(ContainerOf(this, WebServer, lpVtbl))
End Function

Private Function IWebServerAddWebSite( _
		ByVal this As IWebServer Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebServerAddWebSite(ContainerOf(this, WebServer, lpVtbl), pKey, Port, pIWebSite)
End Function

Private Function IWebServerAddDefaultWebSite( _
		ByVal this As IWebServer Ptr, _
		ByVal pIDefaultWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebServerAddDefaultWebSite(ContainerOf(this, WebServer, lpVtbl), pIDefaultWebSite)
End Function

Private Function IWebServerSetEndPoint( _
		ByVal this As IWebServer Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	Return WebServerSetEndPoint(ContainerOf(this, WebServer, lpVtbl), ListenAddress, ListenPort)
End Function

Private Function IWebServerRun( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	Return WebServerRun(ContainerOf(this, WebServer, lpVtbl))
End Function

Private Function IWebServerStop( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	Return WebServerStop(ContainerOf(this, WebServer, lpVtbl))
End Function

Dim GlobalWebServerVirtualTable As Const IWebServerVirtualTable = Type( _
	@IWebServerQueryInterface, _
	@IWebServerAddRef, _
	@IWebServerRelease, _
	@IWebServerAddWebSite, _
	@IWebServerAddDefaultWebSite, _
	@IWebServerSetEndPoint, _
	@IWebServerRun, _
	@IWebServerStop _
)
