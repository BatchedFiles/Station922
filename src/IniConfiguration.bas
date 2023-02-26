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
Const MaxWorkerThreadsKeyString = WStr("WorkerThreads")
Const MaxCachedClientMemoryContextKeyString = WStr("MemoryPoolCapacity")

Const WebSitesIniFileString = WStr("WebSites.ini")
Const HostKeyString = WStr("Host")
Const VirtualPathKeyString = WStr("VirtualPath")
Const PhisycalDirKeyString = WStr("PhisycalDir")
Const IsMovedKeyString = WStr("IsMoved")
Const CanonicalUrlKeyString = WStr("CanonicalUrl")
Const TextFileCharsetKeyString = WStr("TextFileCharset")
Const UtfBomFileOffsetKeyString = WStr("UtfBomFileOffset")
Const ListenAddressKeyString = WStr("ListenAddress")
Const ListenPortKeyString = WStr("ListenPort")
Const UseSslKeyString = WStr("UseSsl")
Const ConnectBindAddressKeyString = WStr("ConnectBindAddress")
Const ConnectBindPortKeyString = WStr("ConnectBindPort")
Const MethodsKeyString = WStr("Methods")
Const ReservedFileBytesKeyString = WStr("ReservedFileBytes")

Const DefaultTextFileCharset = WStr("utf-8")
Const DefaultVirtualPath = WStr("/")
Const DefaultListenAddress = WStr("localhost")
Const DefaultHttpPort = WStr("80")
Const DefaultHttpsPort = WStr("443")
Const ConnectBindDefaultPort = WStr("0")
Const DefaultCachedClientMemoryContextMaximum As INT_ = 1

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
End Type

Sub InitializeWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebServerIniFileName As WString Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr _
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
	
End Sub

Sub UnInitializeWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
	If this->pWebSitesIniFileName Then
		IMalloc_Free(this->pIMemoryAllocator, this->pWebSitesIniFileName)
	End If
	
	If this->pWebServerIniFileName Then
		IMalloc_Free(this->pIMemoryAllocator, this->pWebServerIniFileName)
	End If
	
End Sub

Sub WebServerIniConfigurationCreated( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
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
			
			Dim ExeFileName As WString * (MAX_PATH + 1) = Any
			Dim ExeFileNameLength As DWORD = GetModuleFileNameW( _
				0, _
				@ExeFileName, _
				MAX_PATH _
			)
			If ExeFileNameLength = 0 Then
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
				End Scope
				
				InitializeWebServerIniConfiguration( _
					this, _
					pIMemoryAllocator, _
					pWebServerIniFileName, _
					pWebSitesIniFileName _
				)
				WebServerIniConfigurationCreated(this)
				
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
			
			IMalloc_Free(pIMemoryAllocator, pWebSitesIniFileName)
		End If
		
		IMalloc_Free(pIMemoryAllocator, pWebServerIniFileName)
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub WebServerIniConfigurationDestroyed( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
End Sub

Sub DestroyWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServerIniConfiguration(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	WebServerIniConfigurationDestroyed(this)
	
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

Function GetWebSiteHost( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrWebSite As HeapBSTR Ptr _
	)As HRESULT
	
	Dim WebSiteName As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@HostKeyString, _
		NULL, _
		@WebSiteName, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrWebSite = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrWebSite As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@WebSiteName, _
		ValueLength _
	)
	If bstrWebSite = NULL Then
		*pbstrWebSite = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrWebSite = bstrWebSite
	
	Return S_OK
	
End Function

Function GetWebSiteVirtualPath( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	Dim VirtualPath As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@VirtualPathKeyString, _
		@DefaultVirtualPath, _
		@VirtualPath, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrVirtualPath = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrVirtualPath As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@VirtualPath, _
		ValueLength _
	)
	If bstrVirtualPath = NULL Then
		*pbstrVirtualPath = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrVirtualPath = bstrVirtualPath
	
	Return S_OK
	
End Function

Function GetWebSitePhisycalDir( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrPhisycalDir As HeapBSTR Ptr _
	)As HRESULT
	
	Dim PhisycalDir As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@PhisycalDirKeyString, _
		NULL, _
		@PhisycalDir, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrPhisycalDir = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrPhisycalDir As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@PhisycalDir, _
		ValueLength _
	)
	If bstrPhisycalDir = NULL Then
		*pbstrPhisycalDir = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrPhisycalDir = bstrPhisycalDir
	
	Return S_OK
	
End Function

Function GetWebSiteCanonicalUrl( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrCanonicalUrl As HeapBSTR Ptr _
	)As HRESULT
	
	Dim CanonicalUrl As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@CanonicalUrlKeyString, _
		NULL, _
		@CanonicalUrl, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrCanonicalUrl = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrCanonicalUrl As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@CanonicalUrl, _
		ValueLength _
	)
	If bstrCanonicalUrl = NULL Then
		*pbstrCanonicalUrl = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrCanonicalUrl = bstrCanonicalUrl
	
	Return S_OK
	
End Function

Function GetWebSiteTextFileCharset( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrTextFileCharset As HeapBSTR Ptr _
	)As HRESULT
	
	Dim TextFileCharset As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@TextFileCharsetKeyString, _
		@DefaultTextFileCharset, _
		@TextFileCharset, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrTextFileCharset = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrTextFileCharset As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@TextFileCharset, _
		ValueLength _
	)
	If bstrTextFileCharset = NULL Then
		*pbstrTextFileCharset = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrTextFileCharset = bstrTextFileCharset
	
	Return S_OK
	
End Function

Function GetWebSiteListenAddress( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrListenAddress As HeapBSTR Ptr _
	)As HRESULT
	
	Dim ListenAddress As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@ListenAddressKeyString, _
		@DefaultListenAddress, _
		@ListenAddress, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrListenAddress = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrListenAddress As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@ListenAddress, _
		ValueLength _
	)
	If bstrListenAddress = NULL Then
		*pbstrListenAddress = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrListenAddress = bstrListenAddress
	
	Return S_OK
	
End Function

Function GetWebSiteListenPort( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal pbstrListenPort As HeapBSTR Ptr _
	)As HRESULT
	
	Dim ListenPort As WString * (MAX_PATH + 1) = Any
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		lpwszHost, _
		@ListenPortKeyString, _
		@DefaultHttpPort, _
		@ListenPort, _
		Cast(DWORD, MAX_PATH), _
		pWebSitesIniFileName _
	)
	If ValueLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		*pbstrListenPort = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim bstrListenPort As HeapBSTR = CreatePermanentHeapStringLen( _
		pIMemoryAllocator, _
		@ListenPort, _
		ValueLength _
	)
	If bstrListenPort = NULL Then
		*pbstrListenPort = NULL
		Return E_OUTOFMEMORY
	End If
	
	*pbstrListenPort = bstrListenPort
	
	Return S_OK
	
End Function

Function GetWebSiteIsMoved( _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr _
	)As Boolean
	
	Dim IsMoved As INT_ = GetPrivateProfileIntW( _
		lpwszHost, _
		@IsMovedKeyString, _
		0, _
		pWebSitesIniFileName _
	)
	
	If IsMoved Then
		Return True
	End If
	
	Return False
	
End Function

Function GetWebSiteUtfBomFileOffset( _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr _
	)As Integer
	
	Dim UtfBomFileOffset As INT_ = GetPrivateProfileIntW( _
		lpwszHost, _
		@UtfBomFileOffsetKeyString, _
		0, _
		pWebSitesIniFileName _
	)
	
	Return CInt(UtfBomFileOffset)
	
End Function

Function GetWebSite( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pWebSitesIniFileName As WString Ptr, _
		ByVal lpwszHost As WString Ptr, _
		ByVal HostLength As Integer, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Dim pIWebSite As IWebSite Ptr = Any
	
	Scope
		Dim hrCreateWebSite As HRESULT = CreateWebSite( _
			pIMemoryAllocator, _
			@IID_IWebSite, _
			@pIWebSite _
		)
		If FAILED(hrCreateWebSite) Then
			*ppIWebSite = NULL
			Return hrCreateWebSite
		End If
	End Scope
	
	Scope
		Dim bstrWebSite As HeapBSTR = Any
		Dim hrHost As HRESULT = GetWebSiteHost( _
			pIMemoryAllocator, _
			pWebSitesIniFileName, _
			lpwszHost, _
			@bstrWebSite _
		)
		If FAILED(hrHost) Then
			IWebSite_Release(pIWebSite)
			Return hrHost
		End If
		
		IWebSite_SetHostName(pIWebSite, bstrWebSite)
		HeapSysFreeString(bstrWebSite)
	End Scope
	
	Scope
		Dim bstrVirtualPath As HeapBSTR = Any
		Dim hrVirtualPath As HRESULT = GetWebSiteVirtualPath( _
			pIMemoryAllocator, _
			pWebSitesIniFileName, _
			lpwszHost, _
			@bstrVirtualPath _
		)
		If FAILED(hrVirtualPath) Then
			IWebSite_Release(pIWebSite)
			Return hrVirtualPath
		End If
		
		IWebSite_SetVirtualPath(pIWebSite, bstrVirtualPath)
		HeapSysFreeString(bstrVirtualPath)
	End Scope
	
	Scope
		Dim bstrPhisycalDir As HeapBSTR = Any
		Dim hrPhisycalDir As HRESULT = GetWebSitePhisycalDir( _
			pIMemoryAllocator, _
			pWebSitesIniFileName, _
			lpwszHost, _
			@bstrPhisycalDir _
		)
		If FAILED(hrPhisycalDir) Then
			IWebSite_Release(pIWebSite)
			Return hrPhisycalDir
		End If
		
		IWebSite_SetSitePhysicalDirectory(pIWebSite, bstrPhisycalDir)
		HeapSysFreeString(bstrPhisycalDir)
	End Scope
	
	Scope
		Dim bstrCanonicalUrl As HeapBSTR = Any
		Dim hrCanonicalUrl As HRESULT = GetWebSiteCanonicalUrl( _
			pIMemoryAllocator, _
			pWebSitesIniFileName, _
			lpwszHost, _
			@bstrCanonicalUrl _
		)
		If FAILED(hrCanonicalUrl) Then
			IWebSite_Release(pIWebSite)
			Return hrCanonicalUrl
		End If
		
		IWebSite_SetMovedUrl(pIWebSite, bstrCanonicalUrl)
		HeapSysFreeString(bstrCanonicalUrl)
	End Scope
	
	Scope
		Dim bstrCharset As HeapBSTR = Any
		Dim hrCharset As HRESULT = GetWebSiteTextFileCharset( _
			pIMemoryAllocator, _
			pWebSitesIniFileName, _
			lpwszHost, _
			@bstrCharset _
		)
		If FAILED(hrCharset) Then
			IWebSite_Release(pIWebSite)
			Return hrCharset
		End If
		
		IWebSite_SetTextFileEncoding(pIWebSite, bstrCharset)
		HeapSysFreeString(bstrCharset)
	End Scope
	
	Scope
		Dim IsMoved As Boolean = GetWebSiteIsMoved( _
			pWebSitesIniFileName, _
			lpwszHost _
		)
		IWebSite_SetIsMoved(pIWebSite, IsMoved)
	End Scope
	
	Scope
		Dim Offset As Integer = GetWebSiteUtfBomFileOffset( _
			pWebSitesIniFileName, _
			lpwszHost _
		)
		IWebSite_SetUtfBomFileOffset(pIWebSite, Offset)
	End Scope
	
	*ppIWebSite = pIWebSite
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetWebSites( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pWebSites As Integer Ptr, _
		ByVal ppIWebSites As IWebSite Ptr Ptr _
	)As HRESULT
	
	Dim AllSections As WString Ptr = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		(MaxSectionsLength + 1) * SizeOf(WString) _
	)
	If AllSections = NULL Then
		*pWebSites = 0
		ZeroMemory(*ppIWebSites, MaxWebSites * SizeOf(IWebSite Ptr))
		Return E_OUTOFMEMORY
	End If
	
	Scope
		Dim DefaultValue As WString * 4 = Any
		ZeroMemory(@DefaultValue, 4 * SizeOf(WString))
		
		Dim SectionsLength As DWORD = GetPrivateProfileStringW( _
			NULL, _
			NULL, _
			@DefaultValue, _
			AllSections, _
			Cast(DWORD, MaxSectionsLength), _
			this->pWebSitesIniFileName _
		)
		If SectionsLength = 0 Then
			Dim dwError As DWORD = GetLastError()
			*pWebSites = 0
			ZeroMemory(*ppIWebSites, MaxWebSites * SizeOf(IWebSite Ptr))
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End Scope
	
	Dim lpwszHost As WString Ptr = AllSections
	Dim HostLength As Integer = CInt(lstrlenW(lpwszHost))
	Dim WebSiteCount As Integer = 0
	
	Do While HostLength
		
		Dim pIWebSite As IWebSite Ptr = Any
		Dim hrGetWebSite As HRESULT = GetWebSite( _
			this->pIMemoryAllocator, _
			this->pWebSitesIniFileName, _
			lpwszHost, _
			HostLength, _
			@pIWebSite _
		)
		If FAILED(hrGetWebSite) Then
			Return hrGetWebSite
		End If
		
		ppIWebSites[WebSiteCount] = pIWebSite
		
		WebSiteCount += 1
		lpwszHost = @lpwszHost[HostLength + 1]
		HostLength = CInt(lstrlenW(lpwszHost))
		
	Loop
	
	IMalloc_Free( _
		this->pIMemoryAllocator, _
		AllSections _
	)
	
	*pWebSites = WebSiteCount
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetHttpProcessors( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pHttpProcessors As Integer Ptr, _
		ByVal ppIHttpProcessors As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	
	/'
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
	'/
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

Function IWebServerConfigurationGetWebSites( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pWebSites As Integer Ptr, _
		ByVal ppIWebSites As IWebSite Ptr Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetWebSites(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pWebSites, ppIWebSites)
End Function

Function IWebServerConfigurationGetHttpProcessors( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pHttpProcessors As Integer Ptr, _
		ByVal ppIHttpProcessors As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetHttpProcessors(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pHttpProcessors, ppIHttpProcessors)
End Function

Dim GlobalWebServerIniConfigurationVirtualTable As Const IWebServerConfigurationVirtualTable = Type( _
	@IWebServerConfigurationQueryInterface, _
	@IWebServerConfigurationAddRef, _
	@IWebServerConfigurationRelease, _
	@IWebServerConfigurationGetWorkerThreadsCount, _
	@IWebServerConfigurationGetCachedClientMemoryContextCount, _
	@IWebServerConfigurationGetWebSites, _
	@IWebServerConfigurationGetHttpProcessors _
)
