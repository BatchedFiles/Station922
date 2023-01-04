#include once "IniConfiguration.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HttpGetProcessor.bi"
#include once "HttpOptionsProcessor.bi"
#include once "HttpPutProcessor.bi"
#include once "HttpProcessorCollection.bi"
#include once "HttpTraceProcessor.bi"
#include once "WebSite.bi"
#include once "WebSiteCollection.bi"

Extern GlobalWebServerIniConfigurationVirtualTable As Const IWebServerConfigurationVirtualTable

Const EmptyString = WStr("")
Const WebServerIniFileString = WStr("WebServer.ini")
Const WebServerSectionString = WStr("WebServer")
Const ListenAddressKeyString = WStr("ListenAddress")
Const PortKeyString = WStr("Port")
Const ConnectBindAddressKeyString = WStr("ConnectBindAddress")
Const ConnectBindPortKeyString = WStr("ConnectBindPort")
Const MaxWorkerThreadsKeyString = WStr("MaxWorkerThreads")
Const MaxCachedClientMemoryContextKeyString = WStr("MaxCachedClientMemoryContext")

Const WebSitesIniFileString = WStr("WebSites.ini")
Const VirtualPathKeyString = WStr("VirtualPath")
Const PhisycalDirKeyString = WStr("PhisycalDir")
Const IsMovedKeyString = WStr("IsMoved")
Const MovedUrlKeyString = WStr("MovedUrl")
Const TextFileCharsetKeyString = WStr("TextFileCharset")

Const DefaultAddressString = WStr("localhost")
Const DefaultHttpPort As INT_ = 80
Const ConnectBindDefaultPort As INT_ = 0
Const DefaultCachedClientMemoryContextMaximum As INT_ = 1

Const UsersIniFileString = WStr("users.config")
Const AdministratorsSectionString = WStr("admins")

Const MaxSectionsLength As Integer = 32000 - 1
Const CompareResultEqual As Long = 0

' Const ListenAddressLengthMaximum As Integer = 255
' Const ListenPortLengthMaximum As Integer = 15

Type _WebServerIniConfiguration
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWebServerConfigurationVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pWebServerIniFileName As WString Ptr
	pWebSitesIniFileName As WString Ptr
	pUsersIniFileName As WString Ptr
End Type

Sub InitializeWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebServerIniFileName As WString Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal pUsersIniFileName As WString Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_INICONFIGURATION), _
			Len(WebServerIniConfiguration.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWebServerIniConfigurationVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pWebServerIniFileName = pWebServerIniFileName
	this->pWebSitesIniFileName = pWebSitesIniFileName
	this->pUsersIniFileName = pUsersIniFileName
	
End Sub

Sub UnInitializeWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
	If this->pUsersIniFileName Then
		IMalloc_Free(this->pIMemoryAllocator, this->pUsersIniFileName)
	End If
	If this->pWebSitesIniFileName Then
		IMalloc_Free(this->pIMemoryAllocator, this->pWebSitesIniFileName)
	End If
	If this->pWebServerIniFileName Then
		IMalloc_Free(this->pIMemoryAllocator, this->pWebServerIniFileName)
	End If
	
End Sub

Function CreateWebServerIniConfiguration( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pWebServerIniFileName As WString Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		(MAX_PATH + 1) * SizeOf(WString) _
	)
	
	If pWebServerIniFileName Then
		
		Dim pWebSitesIniFileName As WString Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			(MAX_PATH + 1) * SizeOf(WString) _
		)
		
		If pWebSitesIniFileName Then
			
			Dim pUsersIniFileName As WString Ptr = IMalloc_Alloc( _
				pIMemoryAllocator, _
				(MAX_PATH + 1) * SizeOf(WString) _
			)
			
			If pUsersIniFileName Then
				
				Dim ExeFileName As WString * (MAX_PATH + 1) = Any
				Dim ExeFileNameLength As DWORD = GetModuleFileNameW( _
					0, _
					@ExeFileName, _
					MAX_PATH _
				)
				If ExeFileNameLength = 0 Then
					IMalloc_Free(pIMemoryAllocator, pUsersIniFileName)
					IMalloc_Free(pIMemoryAllocator, pWebSitesIniFileName)
					IMalloc_Free(pIMemoryAllocator, pWebServerIniFileName)
					Return NULL
				End If
				
				Dim this As WebServerIniConfiguration Ptr = IMalloc_Alloc( _
					pIMemoryAllocator, _
					SizeOf(WebServerIniConfiguration) _
				)
				
				If this Then
					
					Scope
						Dim ExecutableDirectory As WString * (MAX_PATH + 1) = Any
						lstrcpyW(@ExecutableDirectory, @ExeFileName)
						PathRemoveFileSpecW(@ExecutableDirectory)
						
						PathCombineW(pWebServerIniFileName, @ExecutableDirectory, @WebServerIniFileString)
						PathCombineW(pWebSitesIniFileName, @ExecutableDirectory, @WebSitesIniFileString)
						PathCombineW(pUsersIniFileName, @ExecutableDirectory, @UsersIniFileString)
					End Scope
					
					InitializeWebServerIniConfiguration( _
						this, _
						pIMemoryAllocator, _
						pWebServerIniFileName, _
						pWebSitesIniFileName, _
						pUsersIniFileName _
					)
					
					Dim hrQueryInterface As HRESULT = WebServerIniConfigurationQueryInterface( _
						this, _
						riid, _
						ppv _
					)
					If FAILED(hrQueryInterface) Then
						DestroyWebServerIniConfiguration(this)
					End If
					
					Return hrQueryInterface
				End If
				
				IMalloc_Free(pIMemoryAllocator, pUsersIniFileName)
			End If
			
			IMalloc_Free(pIMemoryAllocator, pWebSitesIniFileName)
		End If
		
		IMalloc_Free(pIMemoryAllocator, pWebServerIniFileName)
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub DestroyWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServerIniConfiguration(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WebServerIniConfigurationQueryInterface( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IIniConfiguration, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebServerIniConfigurationAddRef(this)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationAddRef( _
		ByVal this As WebServerIniConfiguration Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function WebServerIniConfigurationRelease( _
		ByVal this As WebServerIniConfiguration Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyWebServerIniConfiguration(this)
	
	Return 0
	
End Function

Function WebServerIniConfigurationGetListenAddress( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal bstrListenAddress As HeapBSTR Ptr _
	)As HRESULT
	
	Const BufferLength As DWORD = 255
	Dim buf As WString * (BufferLength + 1) = Any
	
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		@WebServerSectionString, _
		@ListenAddressKeyString, _
		@DefaultAddressString, _
		@buf, _
		Cast(DWORD, BufferLength), _
		this->pWebServerIniFileName _
	)
	
	*bstrListenAddress = CreateHeapStringLen( _
		this->pIMemoryAllocator, _
		CPtr(OLECHAR Ptr, @buf), _
		Cast(UINT, ValueLength) _
	)
	If *bstrListenAddress = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetListenPort( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pListenPort As UINT Ptr _
	)As HRESULT
	
	*pListenPort = GetPrivateProfileIntW( _
		@WebServerSectionString, _
		@PortKeyString, _
		DefaultHttpPort, _
		this->pWebServerIniFileName _
	)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetConnectBindAddress( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal bstrConnectBindAddress As BSTR Ptr _
	)As HRESULT
	
	Const BufferLength As DWORD = 255
	Dim buf As WString * (BufferLength + 1) = Any
	
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		@WebServerSectionString, _
		@ConnectBindAddressKeyString, _
		@DefaultAddressString, _
		@buf, _
		Cast(DWORD, BufferLength), _
		this->pWebServerIniFileName _
	)
	
	*bstrConnectBindAddress = CreateHeapStringLen( _
		this->pIMemoryAllocator, _
		CPtr(OLECHAR Ptr, @buf), _
		Cast(UINT, ValueLength) _
	)
	If *bstrConnectBindAddress = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetConnectBindPort( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pConnectBindPort As UINT Ptr _
	)As HRESULT
	
	*pConnectBindPort = GetPrivateProfileIntW( _
		@WebServerSectionString, _
		@PortKeyString, _
		ConnectBindDefaultPort, _
		this->pWebServerIniFileName _
	)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetWorkerThreadsCount( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pWorkerThreadsCount As UInteger Ptr _
	)As HRESULT
	
	Dim si As SYSTEM_INFO = Any
	GetSystemInfo(@si)
	
	Dim DefaultWorkerThreadsCount As INT_ = Cast(INT_, 2 * si.dwNumberOfProcessors)
	
	Dim WorkerThreadsCount As UINT = GetPrivateProfileIntW( _
		@WebServerSectionString, _
		@MaxWorkerThreadsKeyString, _
		DefaultWorkerThreadsCount, _
		this->pWebServerIniFileName _
	)
	
	*pWorkerThreadsCount = CUInt(WorkerThreadsCount)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetCachedClientMemoryContextCount( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pCachedClientMemoryContextCount As UInteger Ptr _
	)As HRESULT
	
	Dim MemoryContextCount As UINT = GetPrivateProfileIntW( _
		@WebServerSectionString, _
		@MaxCachedClientMemoryContextKeyString, _
		DefaultCachedClientMemoryContextMaximum, _
		this->pWebServerIniFileName _
	)
	
	*pCachedClientMemoryContextCount = CUInt(MemoryContextCount)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetIsPasswordValid( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pUserName As WString Ptr, _
		ByVal pPassword As WString Ptr, _
		ByVal pIsPasswordValid As Boolean Ptr _
	)As HRESULT
	
	Const PasswordBufferLength As DWORD = 255
	Dim PasswordBuffer As WString * (PasswordBufferLength + 1) = Any
	
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		@AdministratorsSectionString, _
		pUserName, _
		@EmptyString, _
		@PasswordBuffer, _
		PasswordBufferLength, _
		this->pUsersIniFileName _
	)
	If ValueLength = 0 Then
		*pIsPasswordValid = False
		Return S_FALSE
	End If
	
	Dim PasswordLength As Long = lstrlenW(@PasswordBuffer)
	If PasswordLength = 0 Then
		*pIsPasswordValid = False
		Return S_FALSE
	End If
	
	Dim CompareResult As Long = lstrcmpW(@PasswordBuffer, pPassword)
	If CompareResult Then
		*pIsPasswordValid = False
		Return S_FALSE
	End If
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetWebSiteCollection( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal ppIWebSiteCollection As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	Dim pIWebSiteCollection As IWebSiteCollection Ptr = Any
	Scope
		Dim hr As HRESULT = CreateWebSiteCollection( _
			this->pIMemoryAllocator, _
			@IID_IWebSiteCollection, _
			@pIWebSiteCollection _
		)
		If FAILED(hr) Then
			*ppIWebSiteCollection = NULL
			Return hr
		End If
	End Scope
	
	Dim AllSections As WString * (MaxSectionsLength + 1) = Any
	Scope
		Dim DefaultValue As WString * 4 = Any
		ZeroMemory(@DefaultValue, 4 * SizeOf(WString))
		
		Dim SectionsLength As DWORD = GetPrivateProfileStringW( _
			NULL, _
			NULL, _
			@DefaultValue, _
			@AllSections, _
			Cast(DWORD, MaxSectionsLength), _
			this->pWebSitesIniFileName _
		)
		If SectionsLength = 0 Then
			Dim dwError As DWORD = GetLastError()
			IWebSiteCollection_Release(pIWebSiteCollection)
			*ppIWebSiteCollection = NULL
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End Scope
	
	Dim lpwszHost As WString Ptr = @AllSections
	Dim HostLength As Integer = CInt(lstrlenW(lpwszHost))
	
	Do While HostLength
		
		Dim bstrWebSite As HeapBSTR = Any
		Dim pIWebSite As IWebSite Ptr = Any
		Dim hr2 As HRESULT = CreateWebSite( _
			this->pIMemoryAllocator, _
			@IID_IWebSite, _
			@pIWebSite _
		)
		If FAILED(hr2) Then
			IWebSiteCollection_Release(pIWebSiteCollection)
			*ppIWebSiteCollection = NULL
			Return hr2
		End If
		
		Scope
			Dim WebSiteName As WString * (MAX_PATH + 1) = Any
			Dim cbBytes As UInteger = (HostLength + 1) * SizeOf(WString)
			CopyMemory(@WebSiteName, lpwszHost, cbBytes)
			
			For i As Integer = 0 To HostLength - 1
				
				Dim character As wchar_t = WebSiteName[i]
				
				Select Case character
					
					Case Characters.LeftCurlyBracket
						WebSiteName[i] = Characters.LeftSquareBracket
						
					Case Characters.RightCurlyBracket
						WebSiteName[i] = Characters.RightSquareBracket
						
				End Select
			Next
			
			bstrWebSite = CreatePermanentHeapStringLen( _
				this->pIMemoryAllocator, _
				@WebSiteName, _
				HostLength _
			)
			IWebSite_SetHostName(pIWebSite, bstrWebSite)
		End Scope
		
		Scope
			Dim PhisycalDir As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@PhisycalDirKeyString, _
				@EmptyString, _
				@PhisycalDir, _
				Cast(DWORD, MAX_PATH), _
				this->pWebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IWebSite_Release(pIWebSite)
				IWebSiteCollection_Release(pIWebSiteCollection)
				*ppIWebSiteCollection = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			Dim bstrPhisycalDir As HeapBSTR = CreatePermanentHeapStringLen( _
				this->pIMemoryAllocator, _
				@PhisycalDir, _
				ValueLength _
			)
			IWebSite_SetSitePhysicalDirectory(pIWebSite, bstrPhisycalDir)
			HeapSysFreeString(bstrPhisycalDir)
		End Scope
		
		Scope
			Dim VirtualPath As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@VirtualPathKeyString, _
				@EmptyString, _
				@VirtualPath, _
				Cast(DWORD, MAX_PATH), _
				this->pWebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IWebSite_Release(pIWebSite)
				IWebSiteCollection_Release(pIWebSiteCollection)
				*ppIWebSiteCollection = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			Dim bstrVirtualPath As HeapBSTR = CreatePermanentHeapStringLen( _
				this->pIMemoryAllocator, _
				@VirtualPath, _
				ValueLength _
			)
			IWebSite_SetVirtualPath(pIWebSite, bstrVirtualPath)
			HeapSysFreeString(bstrVirtualPath)
		End Scope
		
		Scope
			Dim MovedUrl As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@MovedUrlKeyString, _
				@EmptyString, _
				@MovedUrl, _
				Cast(DWORD, MAX_PATH), _
				this->pWebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IWebSite_Release(pIWebSite)
				IWebSiteCollection_Release(pIWebSiteCollection)
				*ppIWebSiteCollection = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			Dim bstrMovedUrl As HeapBSTR = CreatePermanentHeapStringLen( _
				this->pIMemoryAllocator, _
				@MovedUrl, _
				ValueLength _
			)
			IWebSite_SetMovedUrl(pIWebSite, bstrMovedUrl)
			HeapSysFreeString(bstrMovedUrl)
		End Scope
		
		Scope
			Dim IsMoved As INT_ = GetPrivateProfileIntW( _
				lpwszHost, _
				@IsMovedKeyString, _
				0, _
				this->pWebSitesIniFileName _
			)
			If IsMoved Then
				IWebSite_SetIsMoved(pIWebSite, True)
			Else
				IWebSite_SetIsMoved(pIWebSite, False)
			End If
		End Scope
		
		Scope
			Dim Charset As INT_ = GetPrivateProfileIntW( _
				lpwszHost, _
				@TextFileCharsetKeyString, _
				0, _
				this->pWebSitesIniFileName _
			)
			IWebSite_SetTextFileEncoding(pIWebSite, Charset)
		End Scope
		
		IWebSiteCollection_Add(pIWebSiteCollection, bstrWebSite, pIWebSite)
		IWebSite_Release(pIWebSite)
		HeapSysFreeString(bstrWebSite)
		
		lpwszHost = @lpwszHost[HostLength + 1]
		HostLength = CInt(lstrlenW(lpwszHost))
		
	Loop
	
	Scope
		Dim pIDefaultWebSite As IWebSite Ptr = Any
		Dim hr2 As HRESULT = CreateWebSite( _
			this->pIMemoryAllocator, _
			@IID_IWebSite, _
			@pIDefaultWebSite _
		)
		If FAILED(hr2) Then
			IWebSiteCollection_Release(pIWebSiteCollection)
			*ppIWebSiteCollection = NULL
			Return hr2
		End If
		
		Scope
			Dim ExeFileName As WString * (MAX_PATH + 1) = Any
			GetModuleFileNameW( _
				0, _
				@ExeFileName, _
				MAX_PATH _
			)
			
			Dim ExecutableDirectory As WString * (MAX_PATH + 1) = Any
			lstrcpyW(@ExecutableDirectory, @ExeFileName)
			PathRemoveFileSpecW(@ExecutableDirectory)
			
			Dim bstrPhisycalDir As HeapBSTR = CreatePermanentHeapString( _
				this->pIMemoryAllocator, _
				@ExecutableDirectory _
			)
			IWebSite_SetSitePhysicalDirectory(pIDefaultWebSite, bstrPhisycalDir)
			HeapSysFreeString(bstrPhisycalDir)
		End Scope
		
		Scope
			Const DefaultVirtualPath = WStr("/")
			Dim pVirtualPath As WString Ptr = @DefaultVirtualPath
			
			Dim bstrVirtualPath As HeapBSTR = CreatePermanentHeapStringLen( _
				this->pIMemoryAllocator, _
				pVirtualPath, _
				Len(DefaultVirtualPath) _
			)
			IWebSite_SetVirtualPath(pIDefaultWebSite, bstrVirtualPath)
			HeapSysFreeString(bstrVirtualPath)
		End Scope
		
		/'
		Scope
			Dim MovedUrl As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@MovedUrlKeyString, _
				@EmptyString, _
				@MovedUrl, _
				Cast(DWORD, MAX_PATH), _
				this->pWebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IWebSite_Release(pIWebSite)
				IWebSiteCollection_Release(pIWebSiteCollection)
				*ppIWebSiteCollection = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			Dim bstrMovedUrl As HeapBSTR = CreatePermanentHeapStringLen( _
				this->pIMemoryAllocator, _
				@MovedUrl, _
				ValueLength _
			)
			IWebSite_SetMovedUrl(pIDefaultWebSite, bstrMovedUrl)
			HeapSysFreeString(bstrMovedUrl)
		End Scope
		'/
		
		Scope
			IWebSite_SetIsMoved(pIDefaultWebSite, False)
		End Scope
		
		IWebSiteCollection_SetDefaultWebSite(pIWebSiteCollection, pIDefaultWebSite)
		IWebSite_Release(pIDefaultWebSite)
		
	End Scope
	
	*ppIWebSiteCollection = pIWebSiteCollection
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetHttpProcessorCollection( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal ppIHttpProcessorCollection As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	Dim pIProcessorCollection As IHttpProcessorCollection Ptr = Any
	Scope
		Dim hr As HRESULT = CreateHttpProcessorCollection( _
			this->pIMemoryAllocator, _
			@IID_IHttpProcessorCollection, _
			@pIProcessorCollection _
		)
		If FAILED(hr) Then
			*ppIHttpProcessorCollection = NULL
			Return hr
		End If
	End Scope
	
	Scope
		Dim pIHttpGetProcessor As IHttpAsyncProcessor Ptr = Any
		Dim hrCreateProcessor As HRESULT = CreateHttpGetProcessor( _
			this->pIMemoryAllocator, _
			@IID_IHttpGetAsyncProcessor, _
			@pIHttpGetProcessor _
		)
		If FAILED(hrCreateProcessor) Then
			IHttpProcessorCollection_Release(pIProcessorCollection)
			*ppIHttpProcessorCollection = NULL
			Return hrCreateProcessor
		End If
		
		IHttpProcessorCollection_Add( _
			pIProcessorCollection, _
			WStr("GET"), _
			pIHttpGetProcessor _
		)
		
		IHttpProcessorCollection_Add( _
			pIProcessorCollection, _
			WStr("HEAD"), _
			pIHttpGetProcessor _
		)
		
		IHttpAsyncProcessor_Release(pIHttpGetProcessor)
	End Scope
	
	Scope
		Dim pIHttpPutProcessor As IHttpAsyncProcessor Ptr = Any
		Dim hrCreateProcessor As HRESULT = CreateHttpPutProcessor( _
			this->pIMemoryAllocator, _
			@IID_IHttpPutAsyncProcessor, _
			@pIHttpPutProcessor _
		)
		If FAILED(hrCreateProcessor) Then
			IHttpProcessorCollection_Release(pIProcessorCollection)
			*ppIHttpProcessorCollection = NULL
			Return hrCreateProcessor
		End If
		
		IHttpProcessorCollection_Add( _
			pIProcessorCollection, _
			WStr("PUT"), _
			pIHttpPutProcessor _
		)
		
		IHttpAsyncProcessor_Release(pIHttpPutProcessor)
	End Scope
	
	Scope
		Dim pIHttpTraceProcessor As IHttpAsyncProcessor Ptr = Any
		Dim hrCreateProcessor As HRESULT = CreateHttpTraceProcessor( _
			this->pIMemoryAllocator, _
			@IID_IHttpTraceAsyncProcessor, _
			@pIHttpTraceProcessor _
		)
		If FAILED(hrCreateProcessor) Then
			IHttpProcessorCollection_Release(pIProcessorCollection)
			*ppIHttpProcessorCollection = NULL
			Return hrCreateProcessor
		End If
		
		IHttpProcessorCollection_Add( _
			pIProcessorCollection, _
			WStr("TRACE"), _
			pIHttpTraceProcessor _
		)
		
		IHttpAsyncProcessor_Release(pIHttpTraceProcessor)
	End Scope
	
	Scope
		Dim pIHttpOptionsProcessor As IHttpAsyncProcessor Ptr = Any
		Dim hrCreateProcessor As HRESULT = CreateHttpOptionsProcessor( _
			this->pIMemoryAllocator, _
			@IID_IHttpOptionsAsyncProcessor, _
			@pIHttpOptionsProcessor _
		)
		If FAILED(hrCreateProcessor) Then
			IHttpProcessorCollection_Release(pIProcessorCollection)
			*ppIHttpProcessorCollection = NULL
			Return hrCreateProcessor
		End If
		
		IHttpProcessorCollection_Add( _
			pIProcessorCollection, _
			WStr("OPTIONS"), _
			pIHttpOptionsProcessor _
		)
		
		IHttpAsyncProcessor_Release(pIHttpOptionsProcessor)
	End Scope
	
	Scope
		Const AllMethodsString = "GET, HEAD, OPTIONS, PUT, TRACE"
		Dim AllMethods As HeapBSTR = CreatePermanentHeapStringLen( _
			this->pIMemoryAllocator, _
			WStr(AllMethodsString), _
			Len(AllMethodsString) _
		)
		
		IHttpProcessorCollection_SetAllMethods( _
			pIProcessorCollection, _
			AllMethods _
		)
		
		HeapSysFreeString(AllMethods)
	End Scope

	*ppIHttpProcessorCollection = pIProcessorCollection
	
	Return S_OK
	
End Function


Function IWebServerConfigurationQueryInterface( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return WebServerIniConfigurationQueryInterface(ContainerOf(this, WebServerIniConfiguration, lpVtbl), riid, ppvObject)
End Function

Function IWebServerConfigurationAddRef( _
		ByVal this As IWebServerConfiguration Ptr _
	)As ULONG
	Return WebServerIniConfigurationAddRef(ContainerOf(this, WebServerIniConfiguration, lpVtbl))
End Function

Function IWebServerConfigurationRelease( _
		ByVal this As IWebServerConfiguration Ptr _
	)As ULONG
	Return WebServerIniConfigurationRelease(ContainerOf(this, WebServerIniConfiguration, lpVtbl))
End Function

Function IWebServerConfigurationGetListenAddress( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal bstrListenAddress As HeapBSTR Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetListenAddress(ContainerOf(this, WebServerIniConfiguration, lpVtbl), bstrListenAddress)
End Function

Function IWebServerConfigurationGetListenPort( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pListenPort As UINT Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetListenPort(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pListenPort)
End Function

Function IWebServerConfigurationGetConnectBindAddress( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal bstrConnectBindAddress As BSTR Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetConnectBindAddress(ContainerOf(this, WebServerIniConfiguration, lpVtbl), bstrConnectBindAddress)
End Function

Function IWebServerConfigurationGetConnectBindPort( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pConnectBindPort As UINT Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetConnectBindPort(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pConnectBindPort)
End Function

Function IWebServerConfigurationGetWorkerThreadsCount( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pWorkerThreadsCount As UInteger Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetWorkerThreadsCount(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pWorkerThreadsCount)
End Function

Function IWebServerConfigurationGetCachedClientMemoryContextCount( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pCachedClientMemoryContextCount As UInteger Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetCachedClientMemoryContextCount(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pCachedClientMemoryContextCount)
End Function

Function IWebServerConfigurationGetIsPasswordValid( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pUserName As WString Ptr, _
		ByVal pPassword As WString Ptr, _
		ByVal pIsPasswordValid As Boolean Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetIsPasswordValid(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pUserName, pPassword, pIsPasswordValid)
End Function

Function IWebServerConfigurationGetWebSiteCollection( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal ppIWebSiteCollection As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetWebSiteCollection(ContainerOf(this, WebServerIniConfiguration, lpVtbl), ppIWebSiteCollection)
End Function

Function IWebServerConfigurationGetHttpProcessorCollection( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal ppIHttpProcessorCollection As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetHttpProcessorCollection(ContainerOf(this, WebServerIniConfiguration, lpVtbl), ppIHttpProcessorCollection)
End Function

Dim GlobalWebServerIniConfigurationVirtualTable As Const IWebServerConfigurationVirtualTable = Type( _
	@IWebServerConfigurationQueryInterface, _
	@IWebServerConfigurationAddRef, _
	@IWebServerConfigurationRelease, _
	@IWebServerConfigurationGetListenAddress, _
	@IWebServerConfigurationGetListenPort, _
	@IWebServerConfigurationGetConnectBindAddress, _
	@IWebServerConfigurationGetConnectBindPort, _
	@IWebServerConfigurationGetWorkerThreadsCount, _
	@IWebServerConfigurationGetCachedClientMemoryContextCount, _
	@IWebServerConfigurationGetIsPasswordValid, _
	@IWebServerConfigurationGetWebSiteCollection, _
	@IWebServerConfigurationGetHttpProcessorCollection _
)
