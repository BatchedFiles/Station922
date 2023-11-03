#include once "ClientUri.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "Http.bi"

Extern GlobalClientUriVirtualTable As Const IClientUriVirtualTable

Const CompareResultEqual As Long = 0
Const MAX_URL_LENGTH As Integer = 1500

Type _ClientUri
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IClientUriVirtualTable Ptr
	ReferenceCounter As UInteger
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

Private Function DecodeUri( _
		ByVal pBuffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pUri As Const WString Const Ptr, _
		ByVal UriLength As Integer _
	)As Integer
	
	' TODO ��������� �������������� ������������� �������
	
	Dim DecodedBytesUtf8Length As Integer = 0
	
	Dim DecodedBytesUtf8 As ZString * (MAX_URL_LENGTH + 1) = Any
	
	Dim iAcc As UInteger = 0
	Dim iHex As UInteger = 0
	For i As Integer = 0 To UriLength - 1
		
		Dim c As WCHAR = pUri[i]
		
		If iHex Then
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
			
			' �������������
			iHex += 1
			iAcc *= 16
			
			Select Case c
				
				Case Characters.DigitZero, Characters.DigitOne, Characters.DigitTwo, Characters.DigitThree, Characters.DigitFour, Characters.DigitFive, Characters.DigitSix, Characters.DigitSeven, Characters.DigitEight, Characters.DigitNine
					iAcc += c - Characters.DigitZero
					
				Case &h41, &h42, &h43, &h44, &h45, &h46
					' ���� ABCDEF
					iAcc += c - &h37 ' 55
					
				Case &h61, &h62, &h63, &h64, &h65, &h66
					' ���� abcdef
					iAcc += c - &h57 ' 87
					
			End Select
			
			If iHex = 3 Then
				c = iAcc
				iAcc = 0
				iHex = 0
			End if
		End if
		
		' hex code coming?
		If c = Characters.PercentSign Then
			iHex = 1
			iAcc = 0
		End if
		
		If iHex = 0 Then
			DecodedBytesUtf8[DecodedBytesUtf8Length] = c
			DecodedBytesUtf8Length += 1
		End If
		
	Next
	
	DecodedBytesUtf8[DecodedBytesUtf8Length] = Characters.NullChar
	
	Const dwFlags As DWORD = 0
	Dim DecodedLength As Long = MultiByteToWideChar( _
		CP_UTF8, _
		dwFlags, _
		@DecodedBytesUtf8, _
		DecodedBytesUtf8Length, _
		pBuffer, _
		BufferLength _
	)
	
	pBuffer[DecodedLength] = Characters.NullChar
	
	Return DecodedLength
	
End Function

Private Function ContainsBadCharSequence( _
		ByVal Buffer As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
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
				' ������� ������
				Return E_FAIL
				
			'Case Characters.DollarSign
				' ������ ������, ������ ��� ����� ������� $MFT
				'Return E_FAIL
				
			'Case Characters.PercentSign
				' TODO ��������, ������ ������ ������������ ���� ��������
				'Return E_FAIL
				
			'Case Characters.Ampersand
				' ����������� ������ � ����
				'Return E_FAIL
				
			' Case Characters.Asterisk
				' ������ ��������
				' Return E_FAIL
				
			Case Characters.FullStop
				' ��������� .. ������ ��� ����� ����������� � ����� �����
				' ��������� /.. ������ ��� ����� �������� � ����� ��������
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
				' ����������� �����
				'Return E_FAIL
				
			Case Characters.LessThanSign, Characters.GreaterThanSign
				' ������ �� ��������������� �����-������
				Return E_FAIL
				
			Case Characters.QuestionMark
				' �������������� ����
				Return E_FAIL
				
			Case Characters.VerticalLine
				' ������ ���������
				Return E_FAIL
				
		End Select
		
	Next
	
	Return S_OK
	
End Function

Private Sub InitializeClientUri( _
		ByVal this As ClientUri Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_CLIENTURI), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
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

Private Sub UnInitializeClientUri( _
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
	
End Sub

Private Sub ClientUriCreated( _
		ByVal this As ClientUri Ptr _
	)
	
End Sub

Private Sub ClientUriDestroyed( _
		ByVal this As ClientUri Ptr _
	)
	
End Sub

Private Sub DestroyClientUri( _
		ByVal this As ClientUri Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeClientUri(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ClientUriDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function ClientUriAddRef( _
		ByVal this As ClientUri Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Private Function ClientUriRelease( _
		ByVal this As ClientUri Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyClientUri(this)
	
	Return 0
	
End Function

Private Function ClientUriQueryInterface( _
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

Public Function CreateClientUri( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As ClientUri Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ClientUri) _
	)
	
	If this Then
		InitializeClientUri(this, pIMemoryAllocator)
		ClientUriCreated(this)
		
		Dim hrQueryInterface As HRESULT = ClientUriQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyClientUri(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function ClientUriUriFromString( _
		ByVal this As ClientUri Ptr, _
		ByVal bstrUri As HeapBSTR _
	)As HRESULT
	
	Dim UriLength As Integer = SysStringLen(bstrUri)
	
	If UriLength > MAX_URL_LENGTH Then
		Return CLIENTURI_E_URITOOLARGE
	End If
	
	Dim pwszDecodedUri As WString Ptr = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		(MAX_URL_LENGTH + 1) * SizeOf(WString) _
	)
	If pwszDecodedUri = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Dim DecodedUriLength As Integer = DecodeUri( _
		pwszDecodedUri, _
		MAX_URL_LENGTH, _
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
	
	Dim pFirstChar As WString Ptr = pwszDecodedUri
	
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
		Dim CompareResult As Long = lstrcmpW(pFirstChar, WStr("*"))
		If CompareResult = 0 Then
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
			PathLength = 1
			
			pQuery = NULL
			QueryLength = 0
			
			pFragment = NULL
			FragmentLength = 0
		Else
			IMalloc_Free( _
				this->pIMemoryAllocator, _
				pwszDecodedUri _
			)
			Return CLIENTURI_E_PATHNOTFOUND
		End If
	End If
	
	Dim hrContainsBadChar As HRESULT = ContainsBadCharSequence( _
		pPath, _
		PathLength _
	)
	If FAILED(hrContainsBadChar) Then
		IMalloc_Free( _
			this->pIMemoryAllocator, _
			pwszDecodedUri _
		)
		Return CLIENTURI_E_CONTAINSBADCHAR
	End If
	
	HeapSysAddRefString(bstrUri)
	this->Uri = bstrUri
	
	Scope
		If SchemeLength Then
			this->Scheme = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pScheme, _
				SchemeLength _
			)
			If this->Scheme = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
		
		If UserNameLength Then
			this->UserName = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pUserName, _
				UserNameLength _
			)
			If this->UserName = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
		
		If PasswordLength Then
			this->Password = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pPassword, _
				PasswordLength _
			)
			If this->Password = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
		
		If HostLength Then
			this->Host = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pHost, _
				HostLength _
			)
			If this->Host = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
		
		If PortLength Then
			this->Port = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pPort, _
				PortLength _
			)
			If this->Port = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
	End Scope
	
	Scope
		If PathLength Then
			this->Path = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pPath, _
				PathLength _
			)
			If this->Path = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
		
		If QueryLength Then
			this->Query = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pQuery, _
				QueryLength _
			)
			If this->Query = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
		
		If FragmentLength Then
			this->Fragment = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pFragment, _
				FragmentLength _
			)
			If this->Fragment = NULL Then
				IMalloc_Free( _
					this->pIMemoryAllocator, _
					pwszDecodedUri _
				)
				Return E_OUTOFMEMORY
			End If
		End If
	End Scope
	
	IMalloc_Free( _
		this->pIMemoryAllocator, _
		pwszDecodedUri _
	)
	
	Return S_OK
	
End Function

Private Function ClientUriGetOriginalString( _
		ByVal this As ClientUri Ptr, _
		ByVal ppOriginalString As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Uri)
	
	*ppOriginalString = this->Uri
	
	Return S_OK
	
End Function

Private Function ClientUriGetUserName( _
		ByVal this As ClientUri Ptr, _
		ByVal ppUserName As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->UserName)
	
	*ppUserName = this->UserName
	
	Return S_OK
	
End Function

Private Function ClientUriGetPassword( _
		ByVal this As ClientUri Ptr, _
		ByVal ppPassword As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Password)
	
	*ppPassword = this->Password
	
	Return S_OK
	
End Function

Private Function ClientUriGetHost( _
		ByVal this As ClientUri Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Host)
	
	*ppHost = this->Host
	
	Return S_OK
	
End Function

Private Function ClientUriGetPort( _
		ByVal this As ClientUri Ptr, _
		ByVal ppPort As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Port)
	
	*ppPort = this->Port
	
	Return S_OK
	
End Function

Private Function ClientUriGetScheme( _
		ByVal this As ClientUri Ptr, _
		ByVal ppScheme As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Scheme)
	
	*ppScheme = this->Scheme
	
	Return S_OK
	
End Function

Private Function ClientUriGetPath( _
		ByVal this As ClientUri Ptr, _
		ByVal ppPath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Path)
	
	*ppPath = this->Path
	
	Return S_OK
	
End Function

Private Function ClientUriGetQuery( _
		ByVal this As ClientUri Ptr, _
		ByVal ppQuery As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Query)
	
	*ppQuery = this->Query
	
	Return S_OK
	
End Function

Private Function ClientUriGetFragment( _
		ByVal this As ClientUri Ptr, _
		ByVal ppFragment As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Fragment)
	
	*ppFragment = this->Fragment
	
	Return S_OK
	
End Function


Private Function IClientUriQueryInterface( _
		ByVal this As IClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ClientUriQueryInterface(ContainerOf(this, ClientUri, lpVtbl), riid, ppvObject)
End Function

Private Function IClientUriAddRef( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	Return ClientUriAddRef(ContainerOf(this, ClientUri, lpVtbl))
End Function

Private Function IClientUriRelease( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	Return ClientUriRelease(ContainerOf(this, ClientUri, lpVtbl))
End Function

Private Function IClientUriUriFromString( _
		ByVal this As IClientUri Ptr, _
		ByVal bstrUri As HeapBSTR _
	)As HRESULT
	Return ClientUriUriFromString(ContainerOf(this, ClientUri, lpVtbl), bstrUri)
End Function

Private Function IClientUriGetOriginalString( _
		ByVal this As IClientUri Ptr, _
		ByVal ppOriginalString As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetOriginalString(ContainerOf(this, ClientUri, lpVtbl), ppOriginalString)
End Function

Private Function IClientUriGetUserName( _
		ByVal this As IClientUri Ptr, _
		ByVal ppUserName As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetUserName(ContainerOf(this, ClientUri, lpVtbl), ppUserName)
End Function

Private Function IClientUriGetPassword( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPassword As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetPassword(ContainerOf(this, ClientUri, lpVtbl), ppPassword)
End Function

Private Function IClientUriGetHost( _
		ByVal this As IClientUri Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetHost(ContainerOf(this, ClientUri, lpVtbl), ppHost)
End Function

Private Function IClientUriGetPort( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPort As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetPort(ContainerOf(this, ClientUri, lpVtbl), ppPort)
End Function

Private Function IClientUriGetScheme( _
		ByVal this As IClientUri Ptr, _
		ByVal ppScheme As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetScheme(ContainerOf(this, ClientUri, lpVtbl), ppScheme)
End Function

Private Function IClientUriGetPath( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPath As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetPath(ContainerOf(this, ClientUri, lpVtbl), ppPath)
End Function

Private Function IClientUriGetQuery( _
		ByVal this As IClientUri Ptr, _
		ByVal ppQuery As HeapBSTR Ptr _
	)As HRESULT
	Return ClientUriGetQuery(ContainerOf(this, ClientUri, lpVtbl), ppQuery)
End Function

Private Function IClientUriGetFragment( _
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
