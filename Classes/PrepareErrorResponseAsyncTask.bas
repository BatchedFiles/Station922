#include once "PrepareErrorResponseAsyncTask.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "ICloneable.bi"
#include once "Logger.bi"

Extern GlobalPrepareErrorResponseAsyncTaskVirtualTable As Const IPrepareErrorResponseAsyncTaskVirtualTable

Type _PrepareErrorResponseAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IPrepareErrorResponseAsyncTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSite As IWebSite Ptr
	RemoteAddress As SOCKADDR_STORAGE
	RemoteAddressLength As Integer
	pIStream As IBaseStream Ptr
	pIHttpReader As IHttpReader Ptr
	pIRequest As IClientRequest Ptr
End Type

Sub InitializePrepareErrorResponseAsyncTask( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("PrepareErrorResp"), 16)
	#endif
	this->lpVtbl = @GlobalPrepareErrorResponseAsyncTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSite = NULL
	ZeroMemory(@this->RemoteAddress, SizeOf(SOCKADDR_STORAGE))
	this->RemoteAddressLength = 0
	this->pIStream = NULL
	this->pIHttpReader = NULL
	this->pIRequest = NULL
	
End Sub

Sub UnInitializePrepareErrorResponseAsyncTask( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIWebSite <> NULL Then
		IWebSite_Release(this->pIWebSite)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreatePrepareErrorResponseAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As PrepareErrorResponseAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(PrepareErrorResponseAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"PrepareErrorResponseAsyncTask creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As PrepareErrorResponseAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(PrepareErrorResponseAsyncTask) _
	)
	
	If this <> NULL Then
		InitializePrepareErrorResponseAsyncTask( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("PrepareErrorResponseAsyncTask created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyPrepareErrorResponseAsyncTask( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("PrepareErrorResponseAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializePrepareErrorResponseAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("PrepareErrorResponseAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function PrepareErrorResponseAsyncTaskQueryInterface( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IPrepareErrorResponseAsyncTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncTask, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	PrepareErrorResponseAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskAddRef( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function PrepareErrorResponseAsyncTaskRelease( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyPrepareErrorResponseAsyncTask(this)
	
	Return 0
	
End Function

Function PrepareErrorResponseAsyncTaskBeginExecute( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Return E_FAIL
	
End Function

Function PrepareErrorResponseAsyncTaskEndExecute( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	Return E_FAIL
			
End Function

Function PrepareErrorResponseAsyncTaskGetClientRequest( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetClientRequest( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	If pIRequest <> NULL Then
		IClientRequest_AddRef(pIRequest)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	this->pIRequest = pIRequest
	
	Return S_OK
	
End Function


Function PrepareErrorResponseAsyncTaskGetWebSite( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSite <> NULL Then
		IWebSite_AddRef(this->pIWebSite)
	End If
	
	*ppIWebSite = this->pIWebSite
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetWebSite( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	If pIWebSite <> NULL Then
		IWebSite_AddRef(pIWebSite)
	End If
	
	If this->pIWebSite <> NULL Then
		IWebSite_Release(this->pIWebSite)
	End If
	
	this->pIWebSite = pIWebSite
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetRemoteAddress( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	CopyMemory(pRemoteAddress, @this->RemoteAddress, this->RemoteAddressLength)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetRemoteAddress( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetBaseStream( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetBaseStream( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream <> NULL Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetHttpReader( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetHttpReader( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader <> NULL Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	IClientRequest_SetTextReader( _
		this->pIRequest, _
		CPtr(ITextReader Ptr, this->pIHttpReader) _
	)
	
	Return S_OK
	
End Function


Function IPrepareErrorResponseAsyncTaskQueryInterface( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskQueryInterface(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), riid, ppv)
End Function

Function IPrepareErrorResponseAsyncTaskAddRef( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskAddRef(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl))
End Function

Function IPrepareErrorResponseAsyncTaskRelease( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskRelease(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl))
End Function

Function IPrepareErrorResponseAsyncTaskBeginExecute( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskBeginExecute(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pPool, ppIResult)
End Function

Function IPrepareErrorResponseAsyncTaskEndExecute( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskEndExecute(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pPool, pIResult, BytesTransferred, CompletionKey)
End Function

Function IPrepareErrorResponseAsyncTaskGetWebSite( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetWebSite(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppIWebSite)
End Function

Function IPrepareErrorResponseAsyncTaskSetWebSite( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetWebSite(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pIWebSite)
End Function

Function IPrepareErrorResponseAsyncTaskGetRemoteAddress( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetRemoteAddress(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pRemoteAddress, pRemoteAddressLength)
End Function

Function IPrepareErrorResponseAsyncTaskSetRemoteAddress( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetRemoteAddress(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), RemoteAddress, RemoteAddressLength)
End Function

Function IPrepareErrorResponseAsyncTaskGetBaseStream( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetBaseStream(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppStream)
End Function

Function IPrepareErrorResponseAsyncTaskSetBaseStream( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetBaseStream(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pStream)
End Function

Function IPrepareErrorResponseAsyncTaskGetHttpReader( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetHttpReader(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppReader)
End Function

Function IPrepareErrorResponseAsyncTaskSetHttpReader( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetHttpReader(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pReader)
End Function

Function IPrepareErrorResponseAsyncTaskGetClientRequest( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetClientRequest(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppIRequest)
End Function

Function IPrepareErrorResponseAsyncTaskSetClientRequest( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetClientRequest(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pIRequest)
End Function

Dim GlobalPrepareErrorResponseAsyncTaskVirtualTable As Const IPrepareErrorResponseAsyncTaskVirtualTable = Type( _
	@IPrepareErrorResponseAsyncTaskQueryInterface, _
	@IPrepareErrorResponseAsyncTaskAddRef, _
	@IPrepareErrorResponseAsyncTaskRelease, _
	@IPrepareErrorResponseAsyncTaskBeginExecute, _
	@IPrepareErrorResponseAsyncTaskEndExecute, _
	@IPrepareErrorResponseAsyncTaskGetWebSite, _
	@IPrepareErrorResponseAsyncTaskSetWebSite, _
	@IPrepareErrorResponseAsyncTaskGetRemoteAddress, _
	@IPrepareErrorResponseAsyncTaskSetRemoteAddress, _
	@IPrepareErrorResponseAsyncTaskGetBaseStream, _
	@IPrepareErrorResponseAsyncTaskSetBaseStream, _
	@IPrepareErrorResponseAsyncTaskGetHttpReader, _
	@IPrepareErrorResponseAsyncTaskSetHttpReader, _
	@IPrepareErrorResponseAsyncTaskGetClientRequest, _
	@IPrepareErrorResponseAsyncTaskSetClientRequest _
)
