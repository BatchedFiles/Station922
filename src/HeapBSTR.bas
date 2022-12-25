#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"

Extern GlobalInternalPermanentStringVirtualTable As Const IStringVirtualTable
Extern GlobalInternalStringVirtualTable As Const IStringVirtualTable

Const ReservedCharactersLength As Integer = 16

Declare Function __builtin_alloca cdecl Alias "__builtin_alloca"(ByVal size As UInteger)As Any Ptr
Declare Function __builtin_alloca_with_align cdecl Alias "__builtin_alloca_with_align"(ByVal size As UInteger, ByVal alignment As UInteger)As Any Ptr

#define alloca(size) __builtin_alloca (size)

Type _InternalHeapBSTR
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IStringVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	#ifdef __FB_64BIT__
		Padding As DWORD
	#endif
	cbBytes As DWORD
	wszNullChar(0 To ReservedCharactersLength - 1) As OLECHAR
End Type

Function FindStringW( _
		ByVal pSource As WString Ptr, _
		ByVal SourceLength As Integer, _
		ByVal pSubstring As WString Ptr, _
		ByVal SubstringLength As Integer _
	)As WString Ptr
	
	Dim BytesCount As Integer = SubstringLength * SizeOf(WString)
	
	For i As Integer = 0 To SourceLength - SubstringLength
		Dim pDestination As WString Ptr = @pSource[i]
		Dim Finded As Long = memcmp( _
			pDestination, _
			pSubstring, _
			BytesCount _
		)
		If Finded = 0 Then
			Return pDestination
		End If
	Next
	
	Return NULL
	
End Function

Sub StringToUpper( _
		ByVal pBuffer As WString Ptr, _
		ByVal pSource As WString Ptr, _
		ByVal SourceLength As Integer _
	)
	
	For i As Integer = 0 To SourceLength
		Dim Character As Integer = pSource[i]
		
		Dim UpperCharacter As Integer = Any
		Select Case Character
			
			Case &h0061 To &h007A
				UpperCharacter = Character - &h0020
				
			Case Else
				UpperCharacter = Character
				
		End Select
		
		pBuffer[i] = UpperCharacter
	Next
	
End Sub

Function FindStringIW( _
		ByVal pSource As WString Ptr, _
		ByVal SourceLength As Integer, _
		ByVal pSubstring As WString Ptr, _
		ByVal SubstringLength As Integer _
	)As WString Ptr
	
	Dim pSourceUpper As WString Ptr = alloca(SourceLength)
	StringToUpper( _
		pSourceUpper, _
		pSource, _
		SourceLength _
	)
	
	Dim pSubstringUpper As WString Ptr = alloca(SubstringLength)
	StringToUpper( _
		pSubstringUpper, _
		pSubstring, _
		SubstringLength _
	)
	
	Dim pFindUpper As WString Ptr = FindStringW( _
		pSourceUpper, _
		SourceLength, _
		pSubstringUpper, _
		SubstringLength _
	)
	
	If pFindUpper Then
		Dim Index As Integer = pFindUpper - pSourceUpper
		Dim pFind As WString Ptr = @pSource[Index]
		Return pFind
	End If
	
	Return NULL
	
End Function

Sub InitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT, _
		ByVal Permanent As Boolean _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HEAPBSTR), _
			Len(InternalHeapBSTR.IdString) _
		)
	#endif
	
	If Permanent Then
		this->lpVtbl = @GlobalInternalPermanentStringVirtualTable
		this->ReferenceCounter = CUInt(-1)
	Else
		this->lpVtbl = @GlobalInternalStringVirtualTable
		this->ReferenceCounter = 0
	End If
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	Dim cbBytes As DWORD = Length * SizeOf(OLECHAR)
	this->cbBytes = cbBytes
	
	If Length Then
		CopyMemory( _
			@this->wszNullChar(0), _
			pwsz, _
			cbBytes _
		)
	End If
	
	this->wszNullChar(Length) = 0
	
End Sub

Sub UnInitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
End Sub

Function CreateHeapString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = Any
	If pwsz Then
		pszlen = lstrlenW(pwsz)
	Else
		pszlen = 0
	End If
	
	Return CreateHeapStringLen(pIMemoryAllocator, pwsz, pszlen)
	
End Function

Function CreateHeapStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim this As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		False _
	)
	If this = NULL Then
		Return NULL
	End If
	
	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(this, @pHeapBstr)
	
	Dim ps As IString Ptr = CPtr(IString Ptr, @this->lpVtbl)
	IString_AddRef(ps)
	
	Return pHeapBstr
	
End Function

Function CreatePermanentHeapString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = Any
	If pwsz = NULL Then
		pszlen = 0
	Else
		pszlen = lstrlenW(pwsz)
	End If
	
	Return CreatePermanentHeapStringLen(pIMemoryAllocator, pwsz, pszlen)
	
End Function

Function CreatePermanentHeapStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim this As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		True _
	)
	If this = NULL Then
		Return NULL
	End If
	
	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(this, @pHeapBstr)
	
	Dim ps As IString Ptr = CPtr(IString Ptr, @this->lpVtbl)
	IString_AddRef(ps)
	
	Return pHeapBstr
	
End Function

Sub HeapBSTRCreated( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
End Sub

Function GetAllocatedValueBstrBytes( _
		ByVal Characters As UINT _
	)As Integer
	
	Dim cbValueBstrHeader As Integer = SizeOf(InternalHeapBSTR) - (ReservedCharactersLength) * SizeOf(OLECHAR)
	Dim cbValueBstrData As Integer = (Characters + 1) * SizeOf(OLECHAR)
	Dim cbBytes As Integer = cbValueBstrHeader + cbValueBstrData
	
	Return cbBytes
	
End Function

Function CreateHeapZStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal psz As Const ZString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim cbBytes As Integer = GetAllocatedValueBstrBytes(Length)
	
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		cbBytes _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR( _
		this, _
		pIMemoryAllocator, _
		NULL, _
		0, _
		False _
	)
	
	If Length Then
		Const dwFlags As DWORD = 0
		MultiByteToWideChar( _
			CP_ACP, _
			dwFlags, _
			psz, _
			Length, _
			@this->wszNullChar(0), _
			Length _
		)
	End If
	
	this->cbBytes = Length * SizeOf(OLECHAR)
	this->wszNullChar(Length) = 0
	
	HeapBSTRCreated(this)
	
	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(this, @pHeapBstr)
	
	Dim ps As IString Ptr = CPtr(IString Ptr, @this->lpVtbl)
	IString_AddRef(ps)
	
	Return pHeapBstr
	
End Function

Function CreateInternalHeapBSTR( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT, _
		ByVal Permanent As Boolean _
	)As InternalHeapBSTR Ptr
	
	Dim cbBytes As Integer = GetAllocatedValueBstrBytes(Length)
	
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		cbBytes _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR( _
		this, _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		Permanent _
	)
	
	HeapBSTRCreated(this)
	
	Return this
	
End Function

Sub HeapBSTRDestroyed( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
End Sub

Sub DestroyInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeInternalHeapBSTR(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HeapBSTRDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HeapSysAddRefString( _
		ByVal bstrString As HeapBSTR _
	)As HRESULT
	
	If bstrString Then
		Dim this As InternalHeapBSTR Ptr = ContainerOf(bstrString, InternalHeapBSTR, wszNullChar(0))
		Dim ps As IString Ptr = CPtr(IString Ptr, @this->lpVtbl)
		IString_AddRef(ps)
	End If
	
	Return S_OK
	
End Function

Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _ 
	)
	
	If bstrString Then
		Dim this As InternalHeapBSTR Ptr = ContainerOf(bstrString, InternalHeapBSTR, wszNullChar(0))
		Dim ps As IString Ptr = CPtr(IString Ptr, @this->lpVtbl)
		IString_Release(ps)
	End If
	
End Sub

Function PermanentHeapBSTRAddRef( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function PermanentHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function PermanentHeapBSTRQueryInterface( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IString, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	PermanentHeapBSTRAddRef(this)
	
	Return S_OK
	
End Function

Function InternalHeapBSTRAddRef( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function InternalHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyInternalHeapBSTR(this)
	
	Return 0
	
End Function

Function InternalHeapBSTRQueryInterface( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IString, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	InternalHeapBSTRAddRef(this)
	
	Return S_OK
	
End Function

Function InternalHeapBSTRGetHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT
	
	*pcHeapBSTR = @this->wszNullChar(0)
	
	Return S_OK
	
End Function


Function IPermanentStringQueryInterface( _
		ByVal this As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return PermanentHeapBSTRQueryInterface(ContainerOf(this, InternalHeapBSTR, lpVtbl), riid, ppvObject)
End Function

Function IPermanentStringAddRef( _
		ByVal this As IString Ptr _
	)As ULONG
	Return PermanentHeapBSTRAddRef(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Function IPermanentStringRelease( _
		ByVal this As IString Ptr _
	)As ULONG
	Return PermanentHeapBSTRRelease(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Function IStringQueryInterface( _
		ByVal this As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return InternalHeapBSTRQueryInterface(ContainerOf(this, InternalHeapBSTR, lpVtbl), riid, ppvObject)
End Function

Function IStringAddRef( _
		ByVal this As IString Ptr _
	)As ULONG
	Return InternalHeapBSTRAddRef(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Function IStringRelease( _
		ByVal this As IString Ptr _
	)As ULONG
	Return InternalHeapBSTRRelease(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Function IStringGetHeapBSTR( _
		ByVal this As IString Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT
	Return InternalHeapBSTRGetHeapBSTR(ContainerOf(this, InternalHeapBSTR, lpVtbl), pcHeapBSTR)
End Function

Dim GlobalInternalPermanentStringVirtualTable As Const IStringVirtualTable = Type( _
	@IPermanentStringQueryInterface, _
	@IPermanentStringAddRef, _
	@IPermanentStringRelease, _
	@IStringGetHeapBSTR _
)

Dim GlobalInternalStringVirtualTable As Const IStringVirtualTable = Type( _
	@IStringQueryInterface, _
	@IStringAddRef, _
	@IStringRelease, _
	@IStringGetHeapBSTR _
)
