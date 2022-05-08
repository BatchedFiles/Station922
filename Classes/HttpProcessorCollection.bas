#include once "HttpProcessorCollection.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalMutableHttpProcessorCollectionVirtualTable As Const IMutableHttpProcessorCollectionVirtualTable

Const HttpProcessorCollectionCapacity As Integer = 20

Type HttpProcessorCollectionKeyValuePair
	Key As WString * 16
	KeyLength As Integer
	Value As IHttpAsyncProcessor Ptr
End Type

Type _HttpProcessorCollection
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IMutableHttpProcessorCollectionVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	CollectionLength As Integer
	Collection(HttpProcessorCollectionCapacity - 1) As HttpProcessorCollectionKeyValuePair
End Type

Sub InitializeHttpProcessorCollection( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("HttpProcessorCol"), 16)
	#endif
	this->lpVtbl = @GlobalMutableHttpProcessorCollectionVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->Collectionlength = 0
	
End Sub

Sub UnInitializeHttpProcessorCollection( _
		ByVal this As HttpProcessorCollection Ptr _
	)
	
	For i As Integer = 0 To this->Collectionlength - 1
		IHttpAsyncProcessor_Release(this->Collection(i).Value)
	Next
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateHttpProcessorCollection( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpProcessorCollection Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(HttpProcessorCollection)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HttpProcessorCollection creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As HttpProcessorCollection Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpProcessorCollection) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeHttpProcessorCollection(this, pIMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpProcessorCollection created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyHttpProcessorCollection( _
		ByVal this As HttpProcessorCollection Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpProcessorCollection destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpProcessorCollection(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpProcessorCollection destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HttpProcessorCollectionQueryInterface( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpProcessorCollection, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IMutableHttpProcessorCollection, riid) Then
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
	
	HttpProcessorCollectionAddRef(this)
	
	Return S_OK
	
End Function

Function HttpProcessorCollectionAddRef( _
		ByVal this As HttpProcessorCollection Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function HttpProcessorCollectionRelease( _
		ByVal this As HttpProcessorCollection Ptr _
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
	
	DestroyHttpProcessorCollection(this)
	
	Return 0
	
End Function

Function HttpProcessorCollectionItem( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	
	For i As Integer = 0 To this->CollectionLength - 1
		If lstrcmpW(pKey, @this->Collection(i).Key) = 0 Then
			IHttpAsyncProcessor_AddRef(this->Collection(i).Value)
			*ppIProcessor = this->Collection(i).Value
		End If
	Next
	
	*ppIProcessor = NULL
	
	Return E_FAIL
	
End Function

Function HttpProcessorCollectionCount( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	*pCount = this->CollectionLength
	
	Return S_OK
	
End Function

Function HttpProcessorCollectionGetAllMethods( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT
	
	*ppMethods = NULL
	
	Return S_OK
	
End Function

Function HttpProcessorCollectionAdd( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpAsyncProcessor Ptr _
	)As HRESULT
	
	If this->Collectionlength > HttpProcessorCollectionCapacity Then
		Return E_OUTOFMEMORY
	End If
	
	Dim Length As Integer = lstrlenW(pKey)
	
	lstrcpyW(@this->Collection(this->Collectionlength).Key, pKey)
	this->Collection(this->Collectionlength).KeyLength = Length
	IHttpAsyncProcessor_AddRef(pIProcessor)
	this->Collection(this->Collectionlength).Value = pIProcessor
	
	this->Collectionlength += 1
	
	Return S_OK
	
End Function


Function IMutableHttpProcessorCollectionQueryInterface( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpProcessorCollectionQueryInterface(ContainerOf(this, HttpProcessorCollection, lpVtbl), riid, ppvObject)
End Function

Function IMutableHttpProcessorCollectionAddRef( _
		ByVal this As IMutableHttpProcessorCollection Ptr _
	)As ULONG
	Return HttpProcessorCollectionAddRef(ContainerOf(this, HttpProcessorCollection, lpVtbl))
End Function

Function IMutableHttpProcessorCollectionRelease( _
		ByVal this As IMutableHttpProcessorCollection Ptr _
	)As ULONG
	Return HttpProcessorCollectionRelease(ContainerOf(this, HttpProcessorCollection, lpVtbl))
End Function

' Function IMutableHttpProcessorCollection_NewEnum( _
		' ByVal this As IMutableHttpProcessorCollection Ptr, _
		' ByVal ppIEnum As IEnumHttpProcessor Ptr Ptr _
	' )As HRESULT
	' Return HttpProcessorCollection_NewEnum(ContainerOf(this, HttpProcessorCollection, lpVtbl), ppIEnum)
' End Function

Function IMutableHttpProcessorCollectionItem( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	Return HttpProcessorCollectionItem(ContainerOf(this, HttpProcessorCollection, lpVtbl), pKey, ppIProcessor)
End Function

Function IMutableHttpProcessorCollectionCount( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	Return HttpProcessorCollectionCount(ContainerOf(this, HttpProcessorCollection, lpVtbl), pCount)
End Function

Function IMutableHttpProcessorCollectionGetAllMethods( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT
	Return HttpProcessorCollectionGetAllMethods(ContainerOf(this, HttpProcessorCollection, lpVtbl), ppMethods)
End Function

Function IMutableHttpProcessorCollectionAdd( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpAsyncProcessor Ptr _
	)As HRESULT
	Return HttpProcessorCollectionAdd(ContainerOf(this, HttpProcessorCollection, lpVtbl), pKey, pIProcessor)
End Function

Dim GlobalMutableHttpProcessorCollectionVirtualTable As Const IMutableHttpProcessorCollectionVirtualTable = Type( _
	@IMutableHttpProcessorCollectionQueryInterface, _
	@IMutableHttpProcessorCollectionAddRef, _
	@IMutableHttpProcessorCollectionRelease, _
	NULL, _ /' @IMutableWebSiteCollection_NewEnum, _ '/
	@IMutableHttpProcessorCollectionItem, _
	@IMutableHttpProcessorCollectionCount, _
	@IMutableHttpProcessorCollectionGetAllMethods, _
	@IMutableHttpProcessorCollectionAdd _
)
