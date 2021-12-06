#include once "ClientUri.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"

Extern GlobalClientUriVirtualTable As Const IClientUriVirtualTable

Const MaxUrlLength As Integer = 2048 - 1

Type _ClientUri
	lpVtbl As Const IClientUriVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	Uri As HeapBSTR
	Scheme As HeapBSTR
	UserName As HeapBSTR
	Password As HeapBSTR
	Host As HeapBSTR
	Port As HeapBSTR
	Path As HeapBSTR
	Query As HeapBSTR
	Fragment As HeapBSTR
End Type

Function DecodeUri( _
		ByVal pBuffer As WString Ptr, _
		ByVal pUri As Const WString Const Ptr, _
		ByVal UriLength As Integer _
	)As Integer
	
	' TODO Исправить раскодирование неправильного запроса
	' Расшифровываем url-кодировку %XY
	Dim iAcc As UInteger = 0
	Dim iHex As UInteger = 0
	
	Dim DecodedBytesUtf8Length As Integer = 0
	
	Dim DecodedBytesUtf8 As ZString * (MaxUrlLength + 1) = Any
	
	For i As Integer = 0 To UriLength - 1
		
		Dim c As wchar_t = pUri[i]
		
		If iHex <> 0 Then
			' 0 = 30 = 48 = 0
			' 1 = 31 = 49 = 1
			' 2 = 32 = 50 = 2
			' 3 = 33 = 51 = 3
			' 4 = 34 = 52 = 4
			' 5 = 35 = 53 = 5
			' 6 = 36 = 54 = 6
			' 7 = 37 = 55 = 7
			' 8 = 38 = 56 = 8
			' 9 = 39 = 57 = 9
			' A = 41 = 65 = 10
			' B = 42 = 66 = 11
			' C = 43 = 67 = 12
			' D = 44 = 68 = 13
			' E = 45 = 69 = 14
			' F = 46 = 70 = 15
			
			iHex += 1 ' раскодировать
			iAcc *= 16
			
			Select Case c
				
				Case Characters.DigitZero, Characters.DigitOne, Characters.DigitTwo, Characters.DigitThree, Characters.DigitFour, Characters.DigitFive, Characters.DigitSix, Characters.DigitSeven, Characters.DigitEight, Characters.DigitNine
					iAcc += c - Characters.DigitZero
					
				Case &h41, &h42, &h43, &h44, &h45, &h46 ' Коды ABCDEF
					iAcc += c - &h37 ' 55
					
				Case &h61, &h62, &h63, &h64, &h65, &h66 ' Коды abcdef
					iAcc += c - &h57 ' 87
					
			End Select
			
			If iHex = 3 Then
				c = iAcc
				iAcc = 0
				iHex = 0
			End if
		End if
		
		If c = Characters.PercentSign Then ' hex code coming?
			iHex = 1
			iAcc = 0
		End if
		
		If iHex = 0 Then
			DecodedBytesUtf8[DecodedBytesUtf8Length] = c
			DecodedBytesUtf8Length += 1
		End If
		
	Next
	
	' Завершающий ноль
	DecodedBytesUtf8[DecodedBytesUtf8Length] = 0
	
	Const dwFlags As DWORD = 0
	Dim DecodedLength As Integer = MultiByteToWideChar( _
		CP_UTF8, _
		dwFlags, _
		@DecodedBytesUtf8, _
		DecodedBytesUtf8Length, _
		pBuffer, _
		MaxUrlLength _
	)
	
	Return DecodedLength
	
End Function

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
				
			' Case Characters.Asterisk
				' Нельзя звёздочку
				' Return E_FAIL
				
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
	this->Scheme = NULL
	this->UserName = NULL
	this->Password = NULL
	this->Host = NULL
	this->Port = NULL
	this->Path = NULL
	this->Query = NULL
	this->Fragment = NULL
	
End Sub

Sub UnInitializeClientUri( _
		ByVal this As ClientUri Ptr _
	)
	
	HeapSysFreeString(this->Fragment)
	HeapSysFreeString(this->Query)
	HeapSysFreeString(this->Path)
	HeapSysFreeString(this->Port)
	HeapSysFreeString(this->Host)
	HeapSysFreeString(this->Password)
	HeapSysFreeString(this->UserName)
	HeapSysFreeString(this->Scheme)
	HeapSysFreeString(this->Uri)
	
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
		ByVal bstrUri As HeapBSTR _
	)As HRESULT
	
	Dim UriLength As Integer = SysStringLen(bstrUri)
	
	If UriLength > MaxUrlLength Then
		Return CLIENTURI_E_URITOOLARGE
	End If
	
	Dim wszDecodedUri As WString * (MaxUrlLength + 1) = Any
	Dim DecodedUriLength As Integer = DecodeUri( _
		@wszDecodedUri, _
		bstrUri, _
		UriLength _
	)
	
	Dim pScheme As WString Ptr = Any
	Dim SchemeLength As Integer = Any
	
	Dim pUserName As WString Ptr = Any
	Dim UserNameLength As Integer = Any
	
	Dim pPassword As WString Ptr = Any
	Dim PasswordLength As Integer = Any
	
	Dim pHost As WString Ptr = Any
	Dim HostLength As Integer = Any
	
	Dim pPort As WString Ptr = Any
	Dim PortLength As Integer = Any
	
	Dim pPath As WString Ptr = Any
	Dim PathLength As Integer = Any
	
	Dim pQuery As WString Ptr = Any
	Dim QueryLength As Integer = Any
	
	Dim pFragment As WString Ptr = Any
	Dim FragmentLength As Integer = Any
	
	Dim pFirstChar As WString Ptr = @wszDecodedUri
	Dim FirstChar As Integer = pFirstChar[0]
	If FirstChar = Characters.Solidus Then
		pScheme = NULL
		SchemeLength = 0
		
		pUserName = NULL
		UserNameLength = 0
		
		pPassword = NULL
		PasswordLength = 0
		
		pHost = NULL
		HostLength = 0
		
		pPort = NULL
		PortLength = 0
		
		pPath = pFirstChar
		
		Dim pQuestionMark As WString Ptr = StrChrW( _
			pFirstChar, _
			Characters.QuestionMark _
		)
		If pQuestionMark = NULL Then
			pQuery = NULL
			QueryLength = 0
			
			Dim pNumberSign As WString Ptr = StrChrW( _
				pFirstChar, _
				Characters.NumberSign _
			)
			If pNumberSign = NULL Then
				PathLength = DecodedUriLength
				pFragment = NULL
				FragmentLength = 0
			Else
				PathLength = pNumberSign - pFirstChar
				pFragment = @pNumberSign[1]
				Dim pNullChar As WString Ptr = @pFirstChar[DecodedUriLength]
				FragmentLength = pNullChar - pNumberSign
			End If
		Else
			PathLength = pQuestionMark - pFirstChar
			Dim pNumberSign As WString Ptr = StrChrW( _
				pQuestionMark, _
				Characters.NumberSign _
			)
			If pNumberSign = NULL Then
				pFragment = NULL
				FragmentLength = 0
				pQuery = @pQuestionMark[1]
				
				Dim pNullChar As WString Ptr = @pFirstChar[DecodedUriLength]
				QueryLength = pNullChar - pQuestionMark - 1
			Else
				pQuery = @pQuestionMark[1]
				QueryLength = pNumberSign - pQuestionMark - 1
				pFragment = @pNumberSign[1]
				
				Dim pNullChar As WString Ptr = @pFirstChar[DecodedUriLength]
				FragmentLength = pNullChar - pNumberSign - 1
			End If
		End If
	Else
		Return CLIENTURI_E_PATHNOTFOUND
		
		' Dim pSolidusChar As WString Ptr = StrChrW( _
		' 	pFirstChar, _
		' 	Characters.Solidus _
		' )
		' If pSolidusChar = NULL Then
		' 	Return STATION922URI_E_PATHNOTFOUND
		' Else
			' PathLength = pQuestionMark - pFirstChar
			' this->Query = HeapSysAllocString( _
			' 	this->pIMemoryAllocator, _
			' 	pQuestionMark + 1 _
			' )
			Scope
				pScheme = NULL
				SchemeLength = 0
				
				pUserName = NULL
				UserNameLength = 0
				
				pPassword = NULL
				PasswordLength = 0
				
				pHost = NULL
				HostLength = 0
				
				pPort = NULL
				PortLength = 0
				
				pPath = NULL
				PathLength = 0
				
				pQuery = NULL
				QueryLength = 0
				
				pFragment = NULL
				FragmentLength = 0
			End Scope
		' End If
		
	End If
	
	Dim hrContainsBadChar As HRESULT = ContainsBadCharSequence( _
		pPath, _
		PathLength _
	)
	If FAILED(hrContainsBadChar) Then
		Return CLIENTURI_E_CONTAINSBADCHAR
	End If
	
	HeapSysAddRefString(bstrUri)
	this->Uri = bstrUri
	this->Scheme = HeapSysAllocStringLen(this->pIMemoryAllocator, pScheme, SchemeLength)
	this->UserName = HeapSysAllocStringLen(this->pIMemoryAllocator, pUserName, UserNameLength)
	this->Password = HeapSysAllocStringLen(this->pIMemoryAllocator, pPassword, PasswordLength)
	this->Host = HeapSysAllocStringLen(this->pIMemoryAllocator, pHost, HostLength)
	this->Port = HeapSysAllocStringLen(this->pIMemoryAllocator, pPort, PortLength)
	this->Path = HeapSysAllocStringLen(this->pIMemoryAllocator, pPath, PathLength)
	this->Query = HeapSysAllocStringLen(this->pIMemoryAllocator, pQuery, QueryLength)
	this->Fragment = HeapSysAllocStringLen(this->pIMemoryAllocator, pFragment, FragmentLength)
	
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
		ByVal bstrUri As HeapBSTR _
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
