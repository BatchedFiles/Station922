#include once "HeapBSTR.bi"

Extern GlobalInternalPermanentStringVirtualTable As Const IStringVirtualTable
Extern GlobalInternalStringVirtualTable As Const IStringVirtualTable

Const ReservedCharactersLength As Integer = 16

Type InternalHeapBSTR
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
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

Public Function FindStringW( _
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

Private Sub StringToUpper( _
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

Public Function FindStringIW( _
		ByVal pSource As WString Ptr, _
		ByVal SourceLength As Integer, _
		ByVal pSubstring As WString Ptr, _
		ByVal SubstringLength As Integer _
	)As WString Ptr

	Const BufferCapacity As Integer = 400

	If SourceLength >= BufferCapacity Then
		Return NULL
	End If

	If SubstringLength >= BufferCapacity Then
		Return NULL
	End If

	Dim SourceUpper As WString * ((BufferCapacity + 1) * SizeOf(WString)) = Any
	StringToUpper( _
		@SourceUpper, _
		pSource, _
		SourceLength _
	)

	Dim pFindUpper As WString Ptr = Any

	Scope
		Dim SubstringUpper As WString * ((BufferCapacity + 1) * SizeOf(WString)) = Any
		StringToUpper( _
			@SubstringUpper, _
			pSubstring, _
			SubstringLength _
		)

		pFindUpper = FindStringW( _
			@SourceUpper, _
			SourceLength, _
			@SubstringUpper, _
			SubstringLength _
		)
	End Scope

	If pFindUpper Then
		Dim Index As Integer = pFindUpper - @SourceUpper
		Dim pFind As WString Ptr = @pSource[Index]
		Return pFind
	End If

	Return NULL

End Function

Private Sub InitializeInternalHeapBSTR( _
		ByVal self As InternalHeapBSTR Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT, _
		ByVal Permanent As Boolean _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_HEAPBSTR), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif

	If Permanent Then
		self->lpVtbl = @GlobalInternalPermanentStringVirtualTable
		self->ReferenceCounter = CUInt(-1)
	Else
		self->lpVtbl = @GlobalInternalStringVirtualTable
		self->ReferenceCounter = 0
	End If

	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator

	Dim cbBytes As DWORD = Length * SizeOf(OLECHAR)
	self->cbBytes = cbBytes

	If Length Then
		CopyMemory( _
			@self->wszNullChar(0), _
			pwsz, _
			cbBytes _
		)
	End If

	self->wszNullChar(Length) = 0

End Sub

Private Sub UnInitializeInternalHeapBSTR( _
		ByVal self As InternalHeapBSTR Ptr _
	)

End Sub

Private Function GetAllocatedValueBstrBytes( _
		ByVal Characters As UINT _
	)As Integer

	Dim cbValueBstrHeader As Integer = SizeOf(InternalHeapBSTR) - (ReservedCharactersLength) * SizeOf(OLECHAR)
	Dim cbValueBstrData As Integer = (Characters + 1) * SizeOf(OLECHAR)
	Dim cbBytes As Integer = cbValueBstrHeader + cbValueBstrData

	Return cbBytes

End Function

Private Sub HeapBSTRCreated( _
		ByVal self As InternalHeapBSTR Ptr _
	)

End Sub

Private Function InternalHeapBSTRGetHeapBSTR( _
		ByVal self As InternalHeapBSTR Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT

	*pcHeapBSTR = @self->wszNullChar(0)

	Return S_OK

End Function

Private Function CreateInternalHeapBSTR( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT, _
		ByVal Permanent As Boolean _
	)As InternalHeapBSTR Ptr

	Dim cbBytes As Integer = GetAllocatedValueBstrBytes(Length)

	Dim self As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		cbBytes _
	)
	If self = NULL Then
		Return NULL
	End If

	InitializeInternalHeapBSTR( _
		self, _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		Permanent _
	)

	HeapBSTRCreated(self)

	Return self

End Function

Public Function CreateHeapString( _
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

Public Function CreateHeapStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR

	Dim self As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		False _
	)
	If self = NULL Then
		Return NULL
	End If

	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(self, @pHeapBstr)

	Dim ps As IString Ptr = CPtr(IString Ptr, @self->lpVtbl)
	IString_AddRef(ps)

	Return pHeapBstr

End Function

Public Function CreatePermanentHeapString( _
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

Public Function CreatePermanentHeapStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR

	Dim self As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		True _
	)
	If self = NULL Then
		Return NULL
	End If

	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(self, @pHeapBstr)

	Dim ps As IString Ptr = CPtr(IString Ptr, @self->lpVtbl)
	IString_AddRef(ps)

	Return pHeapBstr

End Function

Public Function CreateHeapZStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal psz As Const ZString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR

	Dim cbBytes As Integer = GetAllocatedValueBstrBytes(Length)

	Dim self As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		cbBytes _
	)
	If self = NULL Then
		Return NULL
	End If

	InitializeInternalHeapBSTR( _
		self, _
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
			@self->wszNullChar(0), _
			Length _
		)
	End If

	self->cbBytes = Length * SizeOf(OLECHAR)
	self->wszNullChar(Length) = 0

	HeapBSTRCreated(self)

	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(self, @pHeapBstr)

	Dim ps As IString Ptr = CPtr(IString Ptr, @self->lpVtbl)
	IString_AddRef(ps)

	Return pHeapBstr

End Function

Private Sub HeapBSTRDestroyed( _
		ByVal self As InternalHeapBSTR Ptr _
	)

End Sub

Private Sub DestroyInternalHeapBSTR( _
		ByVal self As InternalHeapBSTR Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeInternalHeapBSTR(self)

	IMalloc_Free(pIMemoryAllocator, self)

	HeapBSTRDestroyed(self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Public Function HeapSysAddRefString( _
		ByVal bstrString As HeapBSTR _
	)As HRESULT

	If bstrString Then
		Dim self As InternalHeapBSTR Ptr = CONTAINING_RECORD(bstrString, InternalHeapBSTR, wszNullChar(0))
		Dim ps As IString Ptr = CPtr(IString Ptr, @self->lpVtbl)
		IString_AddRef(ps)
	End If

	Return S_OK

End Function

Public Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _
	)

	If bstrString Then
		Dim self As InternalHeapBSTR Ptr = CONTAINING_RECORD(bstrString, InternalHeapBSTR, wszNullChar(0))
		Dim ps As IString Ptr = CPtr(IString Ptr, @self->lpVtbl)
		IString_Release(ps)
	End If

End Sub

Private Function PermanentHeapBSTRAddRef( _
		ByVal self As InternalHeapBSTR Ptr _
	)As ULONG

	Return 1

End Function

Private Function PermanentHeapBSTRRelease( _
		ByVal self As InternalHeapBSTR Ptr _
	)As ULONG

	Return 0

End Function

Private Function PermanentHeapBSTRQueryInterface( _
		ByVal self As InternalHeapBSTR Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IString, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	PermanentHeapBSTRAddRef(self)

	Return S_OK

End Function

Private Function InternalHeapBSTRAddRef( _
		ByVal self As InternalHeapBSTR Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function InternalHeapBSTRRelease( _
		ByVal self As InternalHeapBSTR Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyInternalHeapBSTR(self)

	Return 0

End Function

Private Function InternalHeapBSTRQueryInterface( _
		ByVal self As InternalHeapBSTR Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IString, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	InternalHeapBSTRAddRef(self)

	Return S_OK

End Function


Private Function IPermanentStringQueryInterface( _
		ByVal self As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return PermanentHeapBSTRQueryInterface(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl), riid, ppvObject)
End Function

Private Function IPermanentStringAddRef( _
		ByVal self As IString Ptr _
	)As ULONG
	Return PermanentHeapBSTRAddRef(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl))
End Function

Private Function IPermanentStringRelease( _
		ByVal self As IString Ptr _
	)As ULONG
	Return PermanentHeapBSTRRelease(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl))
End Function

Private Function IStringQueryInterface( _
		ByVal self As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return InternalHeapBSTRQueryInterface(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl), riid, ppvObject)
End Function

Private Function IStringAddRef( _
		ByVal self As IString Ptr _
	)As ULONG
	Return InternalHeapBSTRAddRef(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl))
End Function

Private Function IStringRelease( _
		ByVal self As IString Ptr _
	)As ULONG
	Return InternalHeapBSTRRelease(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl))
End Function

Private Function IStringGetHeapBSTR( _
		ByVal self As IString Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT
	Return InternalHeapBSTRGetHeapBSTR(CONTAINING_RECORD(self, InternalHeapBSTR, lpVtbl), pcHeapBSTR)
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
