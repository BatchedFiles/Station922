#include once "WebSiteCollection.bi"
#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"

Extern GlobalWebSiteCollectionVirtualTable As Const IWebSiteCollectionVirtualTable

Type WebSiteNode
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	LeftNode As WebSiteNode Ptr
	RightNode As WebSiteNode Ptr
	HostName As HeapBSTR
	Port As HeapBSTR
	pIWebSite As IWebSite Ptr
End Type

Type WebSiteCollection
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IWebSiteCollectionVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pTree As WebSiteNode Ptr
	pDefaultWebSite As IWebSite Ptr
	WebSitesCount As Integer
End Type

Private Sub TreeAddNode( _
		ByVal pTree As WebSiteNode Ptr, _
		ByVal pNode As WebSiteNode Ptr _
	)
	
	Dim CompareResult As Long = lstrcmpiW( _
		pNode->HostName, _
		pTree->HostName _
	)
	
	Select Case CompareResult
		
		Case Is > 0
			If pTree->RightNode = NULL Then
				pTree->RightNode = pNode
			Else
				TreeAddNode(pTree->RightNode, pNode)
			End If
			
		Case Is < 0
			If pTree->LeftNode = NULL Then
				pTree->LeftNode = pNode
			Else
				TreeAddNode(pTree->LeftNode, pNode)
			End If
			
	End Select
	
End Sub

Private Function CompareHostWithPort( _
		ByVal Host As WString Ptr, _
		ByVal Port As WString Ptr, _
		ByVal HostToCompare As WString Ptr _
	)As Boolean
	
	Dim HostNameWithPort As WString * (MAX_PATH + 1) = Any
	lstrcpyW(@HostNameWithPort, Host)
	lstrcatW(@HostNameWithPort, WStr(":"))
	lstrcatW(@HostNameWithPort, Port)
	
	Dim CompareResultWithPort As Long = lstrcmpiW( _
		@HostNameWithPort, _
		HostToCompare _
	)
	
	If CompareResultWithPort = 0 Then
		Return True
	End If
	
	Return False
	
End Function

Private Function TreeFindNode( _
		ByVal pNode As WebSiteNode Ptr, _
		ByVal HostName As HeapBSTR _
	)As WebSiteNode Ptr
	
	Dim CompareResult As Long = lstrcmpiW( _
		HostName, _
		pNode->HostName _
	)
	
	Select Case CompareResult
		
		Case Is > 0
			Dim resCompareWithPort As Boolean = CompareHostWithPort( _
				pNode->HostName, _
				pNode->Port, _
				HostName _
			)
			
			If resCompareWithPort Then
				Return pNode
			End If
			
			If pNode->RightNode = NULL Then
				Return NULL
			End If
			
			Return TreeFindNode(pNode->RightNode, HostName)
			
		Case Is < 0
			Dim resCompareWithPort As Boolean = CompareHostWithPort( _
				pNode->HostName, _
				pNode->Port, _
				HostName _
			)
			
			If resCompareWithPort Then
				Return pNode
			End If
			
			If pNode->LeftNode = NULL Then
				Return NULL
			End If
			
			Return TreeFindNode(pNode->LeftNode, HostName)
			
		Case Else
			Return pNode
			
	End Select
	
End Function

Private Function CreateWebSiteNode( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal bstrHostName As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pValue As IWebSite Ptr _
	)As WebSiteNode Ptr
	
	Dim pNode As WebSiteNode Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSiteNode) _
	)
	If pNode = NULL Then
		Return NULL
	End If
	
	#if __FB_DEBUG__
		CopyMemory( _
			@pNode->RttiClassName(0), _
			@Str(RTTI_ID_WEBSITENODE), _
			UBound(pNode->RttiClassName) - LBound(pNode->RttiClassName) + 1 _
		)
	#endif
	HeapSysAddRefString(bstrHostName)
	pNode->HostName = bstrHostName
	HeapSysAddRefString(Port)
	pNode->Port = Port
	IWebSite_AddRef(pValue)
	pNode->pIWebSite = pValue
	pNode->LeftNode = NULL
	pNode->RightNode = NULL
	
	Return pNode
	
End Function

Private Sub InitializeWebSiteCollection( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_WEBSITECOLLECTION), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalWebSiteCollectionVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pTree = NULL
	this->WebSitesCount = 0
	
End Sub

Private Sub UnInitializeWebSiteCollection( _
		ByVal this As WebSiteCollection Ptr _
	)
	
End Sub

Private Sub WebSiteCollectionCreated( _
		ByVal this As WebSiteCollection Ptr _
	)
	
End Sub

Private Sub WebSiteCollectionDestroyed( _
		ByVal this As WebSiteCollection Ptr _
	)
	
End Sub

Private Sub DestroyWebSiteCollection( _
		ByVal this As WebSiteCollection Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebSiteCollection(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	WebSiteCollectionDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function WebSiteCollectionAddRef( _
		ByVal this As WebSiteCollection Ptr _
	)As ULONG
	
	Return 1
	
End Function

Private Function WebSiteCollectionRelease( _
		ByVal this As WebSiteCollection Ptr _
	)As ULONG
	
	Return 0
	
End Function

Private Function WebSiteCollectionQueryInterface( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebSiteCollection, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebSiteCollectionAddRef(this)
	
	Return S_OK
	
End Function

Public Function CreateWebSiteCollection( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As WebSiteCollection Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSiteCollection) _
	)
	
	If this Then
		InitializeWebSiteCollection(this, pIMemoryAllocator)
		WebSiteCollectionCreated(this)
		
		Dim hrQueryInterface As HRESULT = WebSiteCollectionQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyWebSiteCollection(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function WebSiteCollectionItem( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	*ppIWebSite = NULL
	
	Dim pNode As WebSiteNode Ptr = TreeFindNode(this->pTree, pKey)
	If pNode = NULL Then
		Return E_FAIL
	End If
	
	IWebSite_AddRef(pNode->pIWebSite)
	*ppIWebSite = pNode->pIWebSite
	
	Return S_OK
	
End Function

Private Function WebSiteCollectionCount( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	*pCount = this->WebSitesCount
	
	Return S_OK
	
End Function

Private Function WebSiteCollectionAdd( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	Dim pNode As WebSiteNode Ptr = CreateWebSiteNode( _
		this->pIMemoryAllocator, _
		pKey, _
		Port, _
		pIWebSite _
	)
	If pNode = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	If this->pTree = NULL Then
		this->pTree = pNode
	Else
		TreeAddNode(this->pTree, pNode)
	End If
	
	Return S_OK
	
End Function

Private Function WebSiteCollectionItemWeakPtr( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Dim pNode As WebSiteNode Ptr = TreeFindNode(this->pTree, pKey)
	If pNode = NULL Then
		*ppIWebSite = NULL
		Return E_FAIL
	End If
	
	*ppIWebSite = pNode->pIWebSite
	
	Return S_OK
	
End Function

Private Function WebSiteCollectionGetDefaultWebSite( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	*ppIWebSite = this->pDefaultWebSite
	
	Return S_OK
	
End Function

Private Function WebSiteCollectionSetDefaultWebSite( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	this->pDefaultWebSite = pIWebSite
	
	Return S_OK
	
End Function


Private Function IWebSiteCollectionQueryInterface( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionQueryInterface(ContainerOf(this, WebSiteCollection, lpVtbl), riid, ppvObject)
End Function

Private Function IWebSiteCollectionAddRef( _
		ByVal this As IWebSiteCollection Ptr _
	)As ULONG
	Return WebSiteCollectionAddRef(ContainerOf(this, WebSiteCollection, lpVtbl))
End Function

Private Function IWebSiteCollectionRelease( _
		ByVal this As IWebSiteCollection Ptr _
	)As ULONG
	Return WebSiteCollectionRelease(ContainerOf(this, WebSiteCollection, lpVtbl))
End Function

' Private Function IWebSiteCollection_NewEnum( _
		' ByVal this As IWebSiteCollection Ptr, _
		' ByVal ppIEnum As IEnumWebSite Ptr Ptr _
	' )As HRESULT
	' Return WebSiteCollection_NewEnum(ContainerOf(this, WebSiteCollection, lpVtbl), ppIEnum)
' End Function

Private Function IWebSiteCollectionItem( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal Host As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionItem(ContainerOf(this, WebSiteCollection, lpVtbl), Host, ppIWebSite)
End Function

Private Function IWebSiteCollectionCount( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	Return WebSiteCollectionCount(ContainerOf(this, WebSiteCollection, lpVtbl), pCount)
End Function

Private Function IWebSiteCollectionAdd( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebSiteCollectionAdd(ContainerOf(this, WebSiteCollection, lpVtbl), pKey, Port, pIWebSite)
End Function

Private Function IWebSiteCollectionItemWeakPtr( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal Host As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionItemWeakPtr(ContainerOf(this, WebSiteCollection, lpVtbl), Host, ppIWebSite)
End Function

Private Function IWebSiteCollectionGetDefaultWebSite( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionGetDefaultWebSite(ContainerOf(this, WebSiteCollection, lpVtbl), ppIWebSite)
End Function

Private Function IWebSiteCollectionSetDefaultWebSite( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebSiteCollectionSetDefaultWebSite(ContainerOf(this, WebSiteCollection, lpVtbl), pIWebSite)
End Function

Dim GlobalWebSiteCollectionVirtualTable As Const IWebSiteCollectionVirtualTable = Type( _
	@IWebSiteCollectionQueryInterface, _
	@IWebSiteCollectionAddRef, _
	@IWebSiteCollectionRelease, _
	NULL, _ /' @IWebSiteCollection_NewEnum, _ '/
	@IWebSiteCollectionItem, _
	@IWebSiteCollectionCount, _
	@IWebSiteCollectionAdd, _
	@IWebSiteCollectionItemWeakPtr, _
	@IWebSiteCollectionGetDefaultWebSite, _
	@IWebSiteCollectionSetDefaultWebSite _
)
