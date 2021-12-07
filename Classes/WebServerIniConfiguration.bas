#include once "WebServerIniConfiguration.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "CreateInstance.bi"
#include once "ContainerOf.bi"
#include once "IMutableWebSite.bi"
#include once "IMutableWebSiteCollection.bi"
#include once "Logger.bi"
#include once "StringConstants.bi"

Extern GlobalWebServerIniConfigurationVirtualTable As Const IWebServerConfigurationVirtualTable

Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID
Extern CLSID_WEBSITECOLLECTION Alias "CLSID_WEBSITECOLLECTION" As Const CLSID

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

Const DefaultAddressString = WStr("localhost")
Const DefaultHttpPort As INT_ = 80
Const ConnectBindDefaultPort As INT_ = 0
Const DefaultCachedClientMemoryContextMaximum As INT_ = 1

Const UsersIniFileString = WStr("users.config")
Const AdministratorsSectionString = WStr("admins")

Const MaxSectionsLength As Integer = 32000 - 1

' Const ListenAddressLengthMaximum As Integer = 255
' Const ListenPortLengthMaximum As Integer = 15

Type _WebServerIniConfiguration
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWebServerConfigurationVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	WebServerIniFileName As WString * (MAX_PATH + 1)
	WebSitesIniFileName As WString * (MAX_PATH + 1)
	UsersIniFileName As WString * (MAX_PATH + 1)
End Type

Sub InitializeWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("IniConfiguration"), 16)
	#endif
	this->lpVtbl = @GlobalWebServerIniConfigurationVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Sub UnInitializeWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateWebServerIniConfiguration( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WebServerIniConfiguration Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(WebServerIniConfiguration)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"WebServerIniConfiguration creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileNameW( _
		0, _
		@ExeFileName, _
		MAX_PATH _
	)
	If ExeFileNameLength = 0 Then
		Return NULL
	End If
	
	Dim this As WebServerIniConfiguration Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebServerIniConfiguration) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	Scope
		Dim ExecutableDirectory As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@ExecutableDirectory, @ExeFileName)
		PathRemoveFileSpecW(@ExecutableDirectory)
		
		PathCombineW(@this->WebServerIniFileName, @ExecutableDirectory, @WebServerIniFileString)
		PathCombineW(@this->WebSitesIniFileName, @ExecutableDirectory, @WebSitesIniFileString)
		PathCombineW(@this->UsersIniFileName, @ExecutableDirectory, @UsersIniFileString)
	End Scope
	
	InitializeWebServerIniConfiguration(this, pIMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebServerIniConfiguration created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyWebServerIniConfiguration( _
		ByVal this As WebServerIniConfiguration Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebServerIniConfiguration destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServerIniConfiguration(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebServerIniConfiguration destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WebServerIniConfigurationQueryInterface( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebServerConfiguration, riid) Then
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
	
	If this->ReferenceCounter = 0 Then
		
		DestroyWebServerIniConfiguration(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function WebServerIniConfigurationGetListenAddress( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal bstrListenAddress As BSTR Ptr _
	)As HRESULT
	
	Const BufferLength As DWORD = 255
	Dim buf As WString * (BufferLength + 1) = Any
	
	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
		@WebServerSectionString, _
		@ListenAddressKeyString, _
		@DefaultAddressString, _
		@buf, _
		Cast(DWORD, BufferLength), _
		@this->WebServerIniFileName _
	)
	
	*bstrListenAddress = SysAllocStringLen( _
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
		@this->WebServerIniFileName _
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
		@this->WebServerIniFileName _
	)
	
	*bstrConnectBindAddress = SysAllocStringLen( _
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
		@this->WebServerIniFileName _
	)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetWorkerThreadsCount( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pWorkerThreadsCount As Integer Ptr _
	)As HRESULT
	
	Dim si As SYSTEM_INFO
	GetSystemInfo(@si)
	
	Dim DefaultWorkerThreadsCount As INT_ = Cast(INT_, 2 * si.dwNumberOfProcessors)
	
	*pWorkerThreadsCount = GetPrivateProfileIntW( _
		@WebServerSectionString, _
		@MaxWorkerThreadsKeyString, _
		DefaultWorkerThreadsCount, _
		@this->WebServerIniFileName _
	)
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetCachedClientMemoryContextCount( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal pCachedClientMemoryContextCount As Integer Ptr _
	)As HRESULT
	
	*pCachedClientMemoryContextCount = GetPrivateProfileIntW( _
		@WebServerSectionString, _
		@MaxCachedClientMemoryContextKeyString, _
		DefaultCachedClientMemoryContextMaximum, _
		@this->WebServerIniFileName _
	)
	
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
		@this->UsersIniFileName _
	)
	If ValueLength = 0 Then
		*pIsPasswordValid = False
		Return S_FALSE
	End If
	
	If lstrlenW(@PasswordBuffer) = 0 Then
		*pIsPasswordValid = False
		Return S_FALSE
	End If
	
	If lstrcmpW(@PasswordBuffer, pPassword) <> 0 Then
		*pIsPasswordValid = False
		Return S_FALSE
	End If
	
	Return S_OK
	
End Function

Function WebServerIniConfigurationGetWebSiteCollection( _
		ByVal this As WebServerIniConfiguration Ptr, _
		ByVal ppIWebSiteCollection As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	*ppIWebSiteCollection = NULL
	
	Dim pIWebSiteCollection As IMutableWebSiteCollection Ptr = Any
	Scope
		Dim hr As HRESULT = CreateInstance( _
			this->pIMemoryAllocator, _
			@CLSID_WEBSITECOLLECTION, _
			@IID_IMutableWebSiteCollection, _
			@pIWebSiteCollection _
		)
		If FAILED(hr) Then
			Return E_OUTOFMEMORY
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
			@this->WebSitesIniFileName _
		)
		If SectionsLength = 0 Then
			Dim dwError As DWORD = GetLastError()
			IMutableWebSiteCollection_Release(pIWebSiteCollection)
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End Scope
	
	Dim lpwszHost As WString Ptr = @AllSections
	Dim HostLength As Integer = lstrlenW(lpwszHost)
	
	Do While HostLength > 0
		
		Dim WebSiteName As WString * (MAX_PATH + 1) = Any
		lstrcpyW(WebSiteName, lpwszHost)
		
		For i As Integer = 0 To HostLength - 1
			
			Dim character As Integer = WebSiteName[i]
			
			Select Case character
				
				Case Characters.LeftCurlyBracket
					WebSiteName[i] = Characters.LeftSquareBracket
					
				Case Characters.RightCurlyBracket
					WebSiteName[i] = Characters.RightSquareBracket
					
			End Select
		Next
		
		Dim pIWebSite As IMutableWebSite Ptr = Any
		Dim hr2 As HRESULT = CreateInstance( _
			this->pIMemoryAllocator, _
			@CLSID_WEBSITE, _
			@IID_IMutableWebSite, _
			@pIWebSite _
		)
		If FAILED(hr2) Then
			IMutableWebSiteCollection_Release(pIWebSiteCollection)
			Return E_OUTOFMEMORY
		End If
		
		IMutableWebSite_SetHostName(pIWebSite, WebSiteName)
		
		Scope
			Dim PhisycalDir As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@PhisycalDirKeyString, _
				@EmptyString, _
				@PhisycalDir, _
				Cast(DWORD, MAX_PATH), _
				@this->WebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IMutableWebSite_Release(pIWebSite)
				IMutableWebSiteCollection_Release(pIWebSiteCollection)
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			IMutableWebSite_SetSitePhysicalDirectory(pIWebSite, @PhisycalDir)
		End Scope
		
		Scope
			Dim VirtualPath As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@VirtualPathKeyString, _
				@EmptyString, _
				@VirtualPath, _
				Cast(DWORD, MAX_PATH), _
				@this->WebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IMutableWebSite_Release(pIWebSite)
				IMutableWebSiteCollection_Release(pIWebSiteCollection)
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			IMutableWebSite_SetVirtualPath(pIWebSite, @VirtualPath)
		End Scope
		
		Scope
			Dim MovedUrl As WString * (MAX_PATH + 1) = Any
			Dim ValueLength As DWORD = GetPrivateProfileStringW( _
				lpwszHost, _
				@MovedUrlKeyString, _
				@EmptyString, _
				@MovedUrl, _
				Cast(DWORD, MAX_PATH), _
				@this->WebSitesIniFileName _
			)
			If ValueLength = 0 Then
				Dim dwError As DWORD = GetLastError()
				IMutableWebSite_Release(pIWebSite)
				IMutableWebSiteCollection_Release(pIWebSiteCollection)
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			IMutableWebSite_SetMovedUrl(pIWebSite, @MovedUrl)
		End Scope
		
		Scope
			Dim IsMoved As INT_ = GetPrivateProfileIntW( _
				lpwszHost, _
				@IsMovedKeyString, _
				0, _
				@this->WebSitesIniFileName _
			)
			If IsMoved = 0 Then
				IMutableWebSite_SetIsMoved(pIWebSite, False)
			Else
				IMutableWebSite_SetIsMoved(pIWebSite, True)
			End If
		End Scope
		
		Scope
			Dim pIWebSite2 As IWebSite Ptr = Any
			Dim hr3 As HRESULT = IMutableWebSite_QueryInterface( _
				pIWebSite, _
				@IID_IWebSite, _
				@pIWebSite2 _
			)
			If FAILED(hr3) Then
				IMutableWebSite_Release(pIWebSite)
				IMutableWebSiteCollection_Release(pIWebSiteCollection)
				Return hr3
			End If
			
			IMutableWebSiteCollection_Add(pIWebSiteCollection, WebSiteName, pIWebSite2)
			
			IWebSite_Release(pIWebSite2)
		End Scope
		
		IMutableWebSite_Release(pIWebSite)
		
		lpwszHost = @lpwszHost[HostLength + 1]
		HostLength = lstrlenW(lpwszHost)
		
	Loop
	
	Scope
		Dim pIWebSiteCollection2 As IWebSiteCollection Ptr = Any
		Dim hr4 As HRESULT = IMutableWebSiteCollection_QueryInterface( _
			pIWebSiteCollection, _
			@IID_IWebSiteCollection, _
			@pIWebSiteCollection2 _
		)
		If FAILED(hr4) Then
			IMutableWebSiteCollection_Release(pIWebSiteCollection)
			Return hr4
		End If
		
		*ppIWebSiteCollection = pIWebSiteCollection2
		
	End Scope
	
	IMutableWebSiteCollection_Release(pIWebSiteCollection)
	
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
		ByVal bstrListenAddress As BSTR Ptr _
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
		ByVal pWorkerThreadsCount As Integer Ptr _
	)As HRESULT
	Return WebServerIniConfigurationGetWorkerThreadsCount(ContainerOf(this, WebServerIniConfiguration, lpVtbl), pWorkerThreadsCount)
End Function

Function IWebServerConfigurationGetCachedClientMemoryContextCount( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pCachedClientMemoryContextCount As Integer Ptr _
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
	@IWebServerConfigurationGetWebSiteCollection _
)
