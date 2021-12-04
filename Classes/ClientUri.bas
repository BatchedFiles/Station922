#include once "ClientUri.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"

Extern GlobalClientUriVirtualTable As Const IClientUriVirtualTable

Type _ClientUri
	lpVtbl As Const IClientUriVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	Uri As HeapBSTR
	UserName As HeapBSTR
	Password As HeapBSTR
	Host As HeapBSTR
	Port As HeapBSTR
	Scheme As HeapBSTR
	Path As HeapBSTR
	Query As HeapBSTR
	Fragment As HeapBSTR
End Type

Function ContainsBadCharSequence( _
		ByVal Buffer As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	' TODO Звёздочка в пути допустима при методе OPTIONS
	
	If Length = 0 Then
		Return E_FAIL
	End If
	
	If Buffer[Length - 1] = Characters.FullStop Then
		Return E_FAIL
	End If
	
	For i As Integer = 0 To Length - 1
		
		Dim c As wchar_t = Buffer[i]
		
		Select Case c
			
			Case Is < Characters.WhiteSpace
				Return E_FAIL
				
			Case Characters.QuotationMark
				' Кавычки нельзя
				Return E_FAIL
				
			'Case Characters.DollarSign
				' Нельзя доллар, потому что могут открыть $MFT
				'Return E_FAIL
				
			'Case Characters.PercentSign
				' TODO Уточнить, почему нельзя использовать знак процента
				'Return E_FAIL
				
			'Case Characters.Ampersand
				' Объединение команд в одну
				'Return E_FAIL
				
			Case Characters.Asterisk
				' Нельзя звёздочку
				Return E_FAIL
				
			Case Characters.FullStop
				' Разрешены .. потому что могут встретиться в имени файла
				' Запрещены /.. потому что могут привести к смене каталога
				Dim NextChar As wchar_t = Buffer[i + 1]
				
				If NextChar = Characters.FullStop Then
					
					If i > 0 Then
						Dim PrevChar As wchar_t = Buffer[i - 1]
						
						If PrevChar = Characters.Solidus Then
							Return E_FAIL
						End If
						
					End If
					
				End If
				
			'Case Characters.Semicolon
				' Разделитель путей
				'Return E_FAIL
				
			Case Characters.LessThanSign
				' Защита от перенаправлений ввода-вывода
				Return E_FAIL
				
			Case Characters.GreaterThanSign
				' Защита от перенаправлений ввода-вывода
				Return E_FAIL
				
			Case Characters.QuestionMark
				' Подстановочный знак
				Return E_FAIL
				
			Case Characters.VerticalLine
				' Символ конвейера
				Return E_FAIL
				
		End Select
		
	Next
	
	Return S_OK
	
End Function

Sub InitializeClientUri( _
		ByVal this As ClientUri Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalClientUriVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->Uri = NULL
	this->UserName = NULL
	this->Password = NULL
	this->Host = NULL
	this->Port = NULL
	this->Scheme = NULL
	this->Path = NULL
	this->Query = NULL
	this->Fragment = NULL
	
End Sub

Sub UnInitializeClientUri( _
		ByVal this As ClientUri Ptr _
	)
	
	HeapSysFreeString(this->Uri)
	HeapSysFreeString(this->UserName)
	HeapSysFreeString(this->Password)
	HeapSysFreeString(this->Host)
	HeapSysFreeString(this->Port)
	HeapSysFreeString(this->Scheme)
	HeapSysFreeString(this->Path)
	HeapSysFreeString(this->Query)
	HeapSysFreeString(this->Fragment)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateClientUri( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ClientUri Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ClientUri)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ClientUri creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As ClientUri Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ClientUri) _
	)
	
	If this <> NULL Then
		
		InitializeClientUri( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("ClientUri created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyClientUri( _
		ByVal this As ClientUri Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ClientUri destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeClientUri(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ClientUri destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ClientUriQueryInterface( _
		ByVal this As ClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientUri, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ClientUriAddRef(this)
	
	Return S_OK
	
End Function

Function ClientUriAddRef( _
		ByVal this As ClientUri Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function ClientUriRelease( _
		ByVal this As ClientUri Ptr _
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
	
	DestroyClientUri(this)
	
	Return 0
	
End Function

Function ClientUriUriFromString( _
		ByVal this As ClientUri Ptr, _
		ByVal bstrUri As BSTR _
	)As HRESULT
	
	Const MaxUrlLength As Integer = 2048
	
	Dim ClientURILength As Integer = SysStringLen(bstrUri)
	
	If ClientURILength > MaxUrlLength Then
		Return STATION922URI_E_URITOOLARGE
	End If
	
	this->Uri = HeapSysAllocStringLen( _
		this->pIMemoryAllocator, _
		bstrUri, _
		ClientURILength _
	)
	
	Dim pFirstChar As WString Ptr = this->Uri
	
	If pFirstChar[0] = Characters.Solidus Then
		Dim PathLength As Integer = Any
		Dim pQuestionMark As WString Ptr = StrChrW( _
			pFirstChar, _
			Characters.QuestionMark _
		)
		If pQuestionMark = NULL Then
			PathLength = ClientURILength
		Else
			PathLength = pQuestionMark - pFirstChar
			this->Query = HeapSysAllocString( _
				this->pIMemoryAllocator, _
				pQuestionMark + 1 _
			)
		End If
		
		this->Path = HeapSysAllocStringLen( _
			this->pIMemoryAllocator, _
			pFirstChar, _
			PathLength _
		)
		
		/'
		' TODO Раскодировка пути
		If StrChrW(@this->ClientURI.Path, PercentSign) = 0 Then
			PathLength = ClientURILength
		Else
			Dim DecodedPath As WString * (Station922Uri.MaxUrlLength + 1) = Any
			PathLength = Station922UriPathDecode(@this->ClientURI, @DecodedPath)
			lstrcpyW(@this->ClientURI.Path, @DecodedPath)
		End If
		'/
		
		Dim hrContainsBadChar As HRESULT = ContainsBadCharSequence( _
			this->Path, _
			PathLength _
		)
		If FAILED(hrContainsBadChar) Then
			Return STATION922URI_E_BADPATH
		End If
		
	Else
		
	End If
	
	Return S_OK
	
End Function

Function ClientUriGetOriginalString( _
		ByVal this As ClientUri Ptr, _
		ByVal ppOriginalString As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Uri)
	
	*ppOriginalString = this->Uri
	
	Return S_OK
	
End Function

Function ClientUriGetUserName( _
		ByVal this As ClientUri Ptr, _
		ByVal ppUserName As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->UserName)
	
	*ppUserName = this->UserName
	
	Return S_OK
	
End Function

Function ClientUriGetPassword( _
		ByVal this As ClientUri Ptr, _
		ByVal ppPassword As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Password)
	
	*ppPassword = this->Password
	
	Return S_OK
	
End Function

Function ClientUriGetHost( _
		ByVal this As ClientUri Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Host)
	
	*ppHost = this->Host
	
	Return S_OK
	
End Function

Function ClientUriGetPort( _
		ByVal this As ClientUri Ptr, _
		ByVal ppPort As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Port)
	
	*ppPort = this->Port
	
	Return S_OK
	
End Function

Function ClientUriGetScheme( _
		ByVal this As ClientUri Ptr, _
		ByVal ppScheme As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Scheme)
	
	*ppScheme = this->Scheme
	
	Return S_OK
	
End Function

Function ClientUriGetPath( _
		ByVal this As ClientUri Ptr, _
		ByVal ppPath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Path)
	
	*ppPath = this->Path
	
	Return S_OK
	
End Function

Function ClientUriGetQuery( _
		ByVal this As ClientUri Ptr, _
		ByVal ppQuery As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Query)
	
	*ppQuery = this->Query
	
	Return S_OK
	
End Function

Function ClientUriGetFragment( _
		ByVal this As ClientUri Ptr, _
		ByVal ppFragment As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Fragment)
	
	*ppFragment = this->Fragment
	
	Return S_OK
	
End Function


Function IClientUriQueryInterface( _
		ByVal this As IClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ClientUriQueryInterface(ContainerOf(this, ClientUri, lpVtbl), riid, ppvObject)
End Function

Function IClientUriAddRef( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	Return ClientUriAddRef(ContainerOf(this, ClientUri, lpVtbl))
End Function

Function IClientUriRelease( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	Return ClientUriRelease(ContainerOf(this, ClientUri, lpVtbl))
End Function

Function IClientUriUriFromString( _
		ByVal this As IClientUri Ptr, _
		ByVal bstrUri As BSTR _
	)As HRESULT
	Return ClientUriUriFromString(ContainerOf(this, ClientUri, lpVtbl), bstrUri)
End Function

Function IClientUriGetOriginalString( _
		ByVal this As IClientUri Ptr, _
		ByVal ppOriginalString As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetOriginalString(ContainerOf(this, ClientUri, lpVtbl), ppOriginalString)
End Function

Function IClientUriGetUserName( _
		ByVal this As IClientUri Ptr, _
		ByVal ppUserName As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetUserName(ContainerOf(this, ClientUri, lpVtbl), ppUserName)
End Function

Function IClientUriGetPassword( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPassword As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetPassword(ContainerOf(this, ClientUri, lpVtbl), ppPassword)
End Function

Function IClientUriGetHost( _
		ByVal this As IClientUri Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetHost(ContainerOf(this, ClientUri, lpVtbl), ppHost)
End Function

Function IClientUriGetPort( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPort As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetPort(ContainerOf(this, ClientUri, lpVtbl), ppPort)
End Function

Function IClientUriGetScheme( _
		ByVal this As IClientUri Ptr, _
		ByVal ppScheme As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetScheme(ContainerOf(this, ClientUri, lpVtbl), ppScheme)
End Function

Function IClientUriGetPath( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPath As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetPath(ContainerOf(this, ClientUri, lpVtbl), ppPath)
End Function

Function IClientUriGetQuery( _
		ByVal this As IClientUri Ptr, _
		ByVal ppQuery As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetQuery(ContainerOf(this, ClientUri, lpVtbl), ppQuery)
End Function

Function IClientUriGetFragment( _
		ByVal this As IClientUri Ptr, _
		ByVal ppFragment As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetFragment(ContainerOf(this, ClientUri, lpVtbl), ppFragment)
End Function

Dim GlobalClientUriVirtualTable As Const IClientUriVirtualTable = Type( _
	@IClientUriQueryInterface, _
	@IClientUriAddRef, _
	@IClientUriRelease, _
	@IClientUriUriFromString, _
	@IClientUriGetOriginalString, _
	@IClientUriGetUserName, _
	@IClientUriGetPassword, _
	@IClientUriGetHost, _
	@IClientUriGetPort, _
	@IClientUriGetScheme, _
	@IClientUriGetPath, _
	@IClientUriGetQuery, _
	@IClientUriGetFragment _
)
