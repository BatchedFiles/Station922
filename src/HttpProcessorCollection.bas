#include once "HttpProcessorCollection.bi"
#include once "HeapBSTR.bi"

Extern GlobalHttpProcessorCollectionVirtualTable As Const IHttpProcessorCollectionVirtualTable

Const HttpProcessorCollectionCapacity As Integer = 20
Const CompareResultEqual As Long = 0

Type HttpProcessorCollectionKeyValuePair
	Key As WString * 16
	KeyLength As Integer
	Value As IHttpAsyncProcessor Ptr
	Padding1 As Integer
	Padding2 As Integer
End Type

Type HttpProcessorCollection
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpProcessorCollectionVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	AllMethods As HeapBSTR
	CollectionLength As Integer
	Padding1 As Integer
	#ifndef __FB_64BIT__
		Padding2 As Integer
		Padding3 As Integer
	#endif
	Collection(HttpProcessorCollectionCapacity - 1) As HttpProcessorCollectionKeyValuePair
End Type

Private Sub InitializeHttpProcessorCollection( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_HTTPPROCESSORCOLLECTION), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalHttpProcessorCollectionVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->AllMethods = NULL
	this->pIMemoryAllocator = pIMemoryAllocator
	this->CollectionLength = 0

End Sub

Private Sub UnInitializeHttpProcessorCollection( _
		ByVal this As HttpProcessorCollection Ptr _
	)

	HeapSysFreeString(this->AllMethods)

	For i As Integer = 0 To this->CollectionLength - 1
		IHttpAsyncProcessor_Release(this->Collection(i).Value)
	Next

End Sub

Private Sub HttpProcessorCollectionCreated( _
		ByVal this As HttpProcessorCollection Ptr _
	)

End Sub

Private Sub HttpProcessorCollectionDestroyed( _
		ByVal this As HttpProcessorCollection Ptr _
	)

End Sub

Private Sub DestroyHttpProcessorCollection( _
		ByVal this As HttpProcessorCollection Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeHttpProcessorCollection(this)

	IMalloc_Free(pIMemoryAllocator, this)

	HttpProcessorCollectionDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function HttpProcessorCollectionAddRef( _
		ByVal this As HttpProcessorCollection Ptr _
	)As ULONG

	Return 1

End Function

Private Function HttpProcessorCollectionRelease( _
		ByVal this As HttpProcessorCollection Ptr _
	)As ULONG

	Return 0

End Function

Private Function HttpProcessorCollectionQueryInterface( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHttpProcessorCollection, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	HttpProcessorCollectionAddRef(this)

	Return S_OK

End Function

Public Function CreateHttpProcessorCollection( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As HttpProcessorCollection Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpProcessorCollection) _
	)
	If this Then
		InitializeHttpProcessorCollection(this, pIMemoryAllocator)
		HttpProcessorCollectionCreated(this)

		Dim hrQueryInterface As HRESULT = HttpProcessorCollectionQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpProcessorCollection(this)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function HttpProcessorCollectionItem( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT

	For i As Integer = 0 To this->CollectionLength - 1

		Dim CompareResult As Long = lstrcmpW(pKey, @this->Collection(i).Key)
		If CompareResult = CompareResultEqual Then

			IHttpAsyncProcessor_AddRef(this->Collection(i).Value)
			*ppIProcessor = this->Collection(i).Value

			Return S_OK
		End If

	Next

	*ppIProcessor = NULL

	Return E_FAIL

End Function

Private Function HttpProcessorCollectionCount( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT

	*pCount = this->CollectionLength

	Return S_OK

End Function

Private Function HttpProcessorCollectionGetAllMethods( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(this->AllMethods)
	*ppMethods = this->AllMethods

	Return S_OK

End Function

Private Function HttpProcessorCollectionAdd( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpAsyncProcessor Ptr _
	)As HRESULT

	If this->CollectionLength > HttpProcessorCollectionCapacity Then
		Return E_OUTOFMEMORY
	End If

	Dim Length As Integer = lstrlenW(pKey)

	lstrcpyW(@this->Collection(this->CollectionLength).Key, pKey)
	this->Collection(this->CollectionLength).KeyLength = Length
	IHttpAsyncProcessor_AddRef(pIProcessor)
	this->Collection(this->CollectionLength).Value = pIProcessor

	this->CollectionLength += 1

	Return S_OK

End Function

Private Function HttpProcessorCollectionItemWeakPtr( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT

	For i As Integer = 0 To this->CollectionLength - 1

		Dim pCollectionKey As WString Ptr = @this->Collection(i).Key
		Dim CompareResult As Long = lstrcmpW(pKey, pCollectionKey)
		If CompareResult = CompareResultEqual Then

			*ppIProcessor = this->Collection(i).Value

			Return S_OK
		End If

	Next

	*ppIProcessor = NULL

	Return E_FAIL

End Function

Private Function HttpProcessorCollectionSetAllMethods( _
		ByVal this As HttpProcessorCollection Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT

	LET_HEAPSYSSTRING(this->AllMethods, pMethods)

	Return S_OK

End Function


Private Function IHttpProcessorCollectionQueryInterface( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpProcessorCollectionQueryInterface(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), riid, ppvObject)
End Function

Private Function IHttpProcessorCollectionAddRef( _
		ByVal this As IHttpProcessorCollection Ptr _
	)As ULONG
	Return HttpProcessorCollectionAddRef(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl))
End Function

Private Function IHttpProcessorCollectionRelease( _
		ByVal this As IHttpProcessorCollection Ptr _
	)As ULONG
	Return HttpProcessorCollectionRelease(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl))
End Function

' Private Function IHttpProcessorCollection_NewEnum( _
		' ByVal this As IHttpProcessorCollection Ptr, _
		' ByVal ppIEnum As IEnumHttpProcessor Ptr Ptr _
	' )As HRESULT
	' Return HttpProcessorCollection_NewEnum(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), ppIEnum)
' End Function

Private Function IHttpProcessorCollectionItem( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	Return HttpProcessorCollectionItem(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), pKey, ppIProcessor)
End Function

Private Function IHttpProcessorCollectionCount( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	Return HttpProcessorCollectionCount(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), pCount)
End Function

Private Function IHttpProcessorCollectionGetAllMethods( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT
	Return HttpProcessorCollectionGetAllMethods(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), ppMethods)
End Function

Private Function IHttpProcessorCollectionAdd( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpAsyncProcessor Ptr _
	)As HRESULT
	Return HttpProcessorCollectionAdd(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), pKey, pIProcessor)
End Function

Private Function IHttpProcessorCollectionItemWeakPtr( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	Return HttpProcessorCollectionItemWeakPtr(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), pKey, ppIProcessor)
End Function

Private Function IHttpProcessorCollectionSetAllMethods( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT
	Return HttpProcessorCollectionSetAllMethods(CONTAINING_RECORD(this, HttpProcessorCollection, lpVtbl), pMethods)
End Function

Dim GlobalHttpProcessorCollectionVirtualTable As Const IHttpProcessorCollectionVirtualTable = Type( _
	@IHttpProcessorCollectionQueryInterface, _
	@IHttpProcessorCollectionAddRef, _
	@IHttpProcessorCollectionRelease, _
	NULL, _ /' @IWebSiteCollection_NewEnum, _ '/
	@IHttpProcessorCollectionItem, _
	@IHttpProcessorCollectionCount, _
	@IHttpProcessorCollectionGetAllMethods, _
	@IHttpProcessorCollectionAdd, _
	@IHttpProcessorCollectionItemWeakPtr, _
	@IHttpProcessorCollectionSetAllMethods _
)
