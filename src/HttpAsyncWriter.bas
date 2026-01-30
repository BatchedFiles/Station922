#include once "HttpAsyncWriter.bi"
#include once "AsyncResult.bi"
#include once "IFileAsyncStream.bi"
#include once "WebUtils.bi"

Extern GlobalHttpWriterVirtualTable As Const IHttpAsyncWriterVirtualTable

Const String100Continue = Str(!"HTTP/1.1 100 Continue\r\n\r\n")

Enum WriterTasks
	WritePreloadedBytesToNetwork
	ReadFileStream
	WriteNetworkData
	Write100Continue
	WritePreloadedBytesToFile
	ReadNetworkStream
	WriteFileData
End Enum

Type HeadersBodyBuffer
	Buf(1) As BaseStreamBuffer
End Type

Type HttpWriter
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpAsyncWriterVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseAsyncStream Ptr
	StreamBuffer As HeadersBodyBuffer
	pIBuffer As IAttributedAsyncStream Ptr
	pIResponse As IServerResponse Ptr
	CurrentTask As WriterTasks
	Headers As ZString Ptr
	HeadersOffset As LongInt
	HeadersLength As LongInt
	HeadersEndIndex As LongInt
	BodyOffset As LongInt
	BodyEndIndex As LongInt
	StreamBufferLength As Integer
	Write100ContinueOffset As Integer
	HeadersSended As Boolean
	BodySended As Boolean
	SendOnlyHeaders As Boolean
	KeepAlive As Boolean
	NeedWrite100Continue As Boolean
End Type

Private Sub InitializeHttpWriter( _
		ByVal self As HttpWriter Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_HTTPWRITER), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalHttpWriterVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pIStream = NULL
	self->pIBuffer = NULL
	self->pIResponse = NULL
	self->BodyOffset = 0
	self->KeepAlive = True
	self->NeedWrite100Continue = False

End Sub

Private Sub UnInitializeHttpWriter( _
		ByVal self As HttpWriter Ptr _
	)

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	If self->pIBuffer Then
		IAttributedAsyncStream_Release(self->pIBuffer)
	End If

	If self->pIResponse Then
		IServerResponse_Release(self->pIResponse)
	End If

End Sub

Private Sub DestroyHttpWriter( _
		ByVal self As HttpWriter Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeHttpWriter(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function HttpWriterAddRef( _
		ByVal self As HttpWriter Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function HttpWriterRelease( _
		ByVal self As HttpWriter Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyHttpWriter(self)

	Return 0

End Function

Private Function HttpWriterQueryInterface( _
		ByVal self As HttpWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHttpAsyncWriter, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	HttpWriterAddRef(self)

	Return S_OK

End Function

Public Function CreateHttpWriter( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As HttpWriter Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpWriter) _
	)

	If self Then
		InitializeHttpWriter(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = HttpWriterQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpWriter(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function HttpWriterGetBaseStream( _
		ByVal self As HttpWriter Ptr, _
		ByVal ppResult As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	If self->pIStream Then
		IBaseAsyncStream_AddRef(self->pIStream)
	End If

	*ppResult = self->pIStream

	Return S_OK

End Function

Private Function HttpWriterSetBaseStream( _
		ByVal self As HttpWriter Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	If pIStream Then
		IBaseAsyncStream_AddRef(pIStream)
	End If

	self->pIStream = pIStream

	Return S_OK

End Function

Private Function HttpWriterGetBuffer( _
		ByVal self As HttpWriter Ptr, _
		ByVal ppResult As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	If self->pIBuffer Then
		IAttributedAsyncStream_AddRef(self->pIBuffer)
	End If

	*ppResult = self->pIBuffer

	Return S_OK

End Function

Private Function HttpWriterSetBuffer( _
		ByVal self As HttpWriter Ptr, _
		ByVal pIBuffer As IAttributedAsyncStream Ptr _
	)As HRESULT

	If self->pIBuffer Then
		IAttributedAsyncStream_Release(self->pIBuffer)
	End If

	If pIBuffer Then
		IAttributedAsyncStream_AddRef(pIBuffer)
	End If

	self->pIBuffer = pIBuffer

	Return S_OK

End Function

Private Sub HttpWriterSinkResponse( _
		ByVal self As HttpWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)

	If self->pIResponse Then
		IServerResponse_Release(self->pIResponse)
	End If

	If pIResponse Then
		IServerResponse_AddRef(pIResponse)
	End If

	self->pIResponse = pIResponse

End Sub

Private Function HttpWriterPrepare( _
		ByVal self As HttpWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal fFileAccess As FileAccess _
	)As HRESULT

	HttpWriterSinkResponse(self, pIResponse)

	Scope
		self->HeadersOffset = 0
		self->HeadersSended = False

		Dim ResponseContentLength As LongInt = Any
		If fFileAccess = FileAccess.ReadAccess Then
			ResponseContentLength = ContentLength
		Else
			ResponseContentLength = 0
		End If

		Dim hrHeadersToString As HRESULT = IServerResponse_AllHeadersToZString( _
			pIResponse, _
			ResponseContentLength, _
			@self->Headers, _
			@self->HeadersLength _
		)
		If FAILED(hrHeadersToString) Then
			Return hrHeadersToString
		End If
	End Scope

	Scope
		IServerResponse_GetSendOnlyHeaders( _
			pIResponse, _
			@self->SendOnlyHeaders _
		)

		If self->SendOnlyHeaders Then
			self->BodySended = True
		Else
			self->BodySended = False
		End If
	End Scope

	Scope
		Dim ByteRangeLength As LongInt = Any
		IServerResponse_GetByteRange( _
			pIResponse, _
			@self->BodyOffset, _
			@ByteRangeLength _
		)

		Dim BodyContentLength As LongInt = Any
		If ByteRangeLength Then
			BodyContentLength = ByteRangeLength
		Else
			BodyContentLength = ContentLength
		End If

		self->HeadersEndIndex = self->HeadersLength
		self->BodyEndIndex = self->BodyOffset + BodyContentLength

		If BodyContentLength = 0 Then
			self->BodySended = True
		End If
	End Scope

	Select Case fFileAccess

		Case FileAccess.ReadAccess
			self->CurrentTask = WriterTasks.ReadFileStream

		Case FileAccess.CreateAccess, FileAccess.UpdateAccess
			If self->NeedWrite100Continue Then
				self->Write100ContinueOffset = 0
				self->StreamBufferLength = 1
				self->StreamBuffer.Buf(0).Buffer = @String100Continue
				self->StreamBuffer.Buf(0).Length = Len(String100Continue)
				self->CurrentTask = WriterTasks.Write100Continue
			Else
				self->CurrentTask = WriterTasks.WritePreloadedBytesToFile
			End If

		Case FileAccess.DeleteAccess
			self->CurrentTask = WriterTasks.ReadFileStream

	End Select

	Return S_OK

End Function

Private Function AllocBytes( _
		ByVal pIBuffer As IAttributedAsyncStream Ptr, _
		ByVal DesiredLength As LongInt, _
		ByVal pLength As UInteger Ptr, _
		ByVal ppBytes As Any Ptr Ptr _
	) As HRESULT

	Dim pFileStream As IFileAsyncStream Ptr = Any
	Dim hrQuery As HRESULT = IAttributedAsyncStream_QueryInterface( _
		pIBuffer, _
		@IID_IFileAsyncStream, _
		@pFileStream  _
	)
	If FAILED(hrQuery) Then
		Return hrQuery
	End If

	Dim Slice As BufferSlice = Any
	Dim hrAllocSlice As HRESULT = IFileAsyncStream_AllocSlice( _
		pFileStream, _
		DesiredLength, _
		@Slice _
	)

	IFileAsyncStream_Release(pFileStream)

	If FAILED(hrAllocSlice) Then
		Return E_OUTOFMEMORY
	End If

	*pLength = Slice.Length
	*ppBytes = Slice.pSlice

	Return S_OK

End Function

Private Function HttpWriterBeginWrite( _
		ByVal self As HttpWriter Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim cTask As WriterTasks = self->CurrentTask

	Select Case cTask

		Case WriterTasks.WritePreloadedBytesToNetwork
			'
		Case WriterTasks.ReadFileStream
			If self->BodySended Then
				If self->HeadersSended Then
					*ppIAsyncResult = NULL
					Return S_FALSE
				End If

				Dim pINewAsyncResult As IAsyncResult Ptr = Any
				Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
					self->pIMemoryAllocator, _
					@IID_IAsyncResult, _
					@pINewAsyncResult _
				)
				If FAILED(hrCreateAsyncResult) Then
					*ppIAsyncResult = NULL
					Return hrCreateAsyncResult
				End If

				IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

				*ppIAsyncResult = pINewAsyncResult

				Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
				Dim hrStatus As HRESULT = IThreadPool_PostPacket( _
					pIPool, _
					SizeOf(HttpWriter), _
					Cast(ULONG_PTR, StateObject), _
					pINewAsyncResult _
				)
				If FAILED(hrStatus) Then
					IAsyncResult_Release(pINewAsyncResult)
					*ppIAsyncResult = NULL
					Return hrStatus
				End If

			Else
				Dim DesiredSliceLength As LongInt = self->BodyEndIndex - self->BodyOffset

				Dim hrBeginGetSlice As HRESULT = IAttributedAsyncStream_BeginReadSlice( _
					self->pIBuffer, _
					self->BodyOffset, _
					DesiredSliceLength, _
					pcb, _
					StateObject, _
					ppIAsyncResult _
				)
				If FAILED(hrBeginGetSlice) Then
					*ppIAsyncResult = NULL
					Return hrBeginGetSlice
				End If

			End If

		Case WriterTasks.WriteNetworkData
			Dim hrBeginWrite As HRESULT = Any

			If self->KeepAlive Then
				hrBeginWrite = IBaseAsyncStream_BeginWriteGather( _
					self->pIStream, _
					@self->StreamBuffer.Buf(0), _
					self->StreamBufferLength, _
					pcb, _
					StateObject, _
					ppIAsyncResult _
				)
			Else
				hrBeginWrite = IBaseAsyncStream_BeginWriteGatherAndShutdown( _
					self->pIStream, _
					@self->StreamBuffer.Buf(0), _
					self->StreamBufferLength, _
					pcb, _
					StateObject, _
					ppIAsyncResult _
				)
			End If

			If FAILED(hrBeginWrite) Then
				Return hrBeginWrite
			End If

		Case WriterTasks.Write100Continue
			Dim hrBeginWrite As HRESULT = IBaseAsyncStream_BeginWriteGather( _
				self->pIStream, _
				@self->StreamBuffer.Buf(0), _
				self->StreamBufferLength, _
				pcb, _
				StateObject, _
				ppIAsyncResult _
			)
			If FAILED(hrBeginWrite) Then
				Return hrBeginWrite
			End If

		Case WriterTasks.WritePreloadedBytesToFile
			Dim PreloadedBytesLength As Integer = Any
			Dim pPreloadedBytes As UByte Ptr = Any
			IAttributedAsyncStream_GetPreloadedBytes( _
				self->pIBuffer, _
				@PreloadedBytesLength, _
				@pPreloadedBytes _
			)

			If PreloadedBytesLength Then
				Dim Slice As BufferSlice = Any
				With Slice
					.pSlice = pPreloadedBytes
					.Length = PreloadedBytesLength
				End With

				Dim pIFileAsyncStream As IFileAsyncStream Ptr = CPtr(IFileAsyncStream Ptr, self->pIBuffer)
				Dim hrBeginWrite As HRESULT = IFileAsyncStream_BeginWriteSlice( _
					pIFileAsyncStream, _
					@Slice, _
					self->BodyOffset, _
					pcb, _
					StateObject, _
					ppIAsyncResult _
				)

				If FAILED(hrBeginWrite) Then
					Return hrBeginWrite
				End If

			Else
				self->CurrentTask = WriterTasks.ReadNetworkStream

				Dim DesiredLength As LongInt = self->BodyEndIndex - self->BodyOffset

				Dim ReservedBytesLength As Integer = Any
				Dim pReservedBytes As UByte Ptr = Any
				Dim hrGetReservedBytes As HRESULT = AllocBytes( _
					self->pIBuffer, _
					DesiredLength , _
					@ReservedBytesLength, _
					@pReservedBytes  _
				)
				If FAILED(hrGetReservedBytes) Then
					*ppIAsyncResult = NULL
					Return hrGetReservedBytes
				End If

				' No need to specify the buffer length
				' as it will return to the EndRead function
				self->StreamBufferLength = 1
				self->StreamBuffer.Buf(0).Buffer = pReservedBytes

				Dim hrBeginRead As HRESULT = IBaseAsyncStream_BeginRead( _
					self->pIStream, _
					pReservedBytes, _
					ReservedBytesLength, _
					pcb, _
					StateObject, _
					ppIAsyncResult _
				)

				If FAILED(hrBeginRead) Then
					Return hrBeginRead
				End If

			End If

		Case WriterTasks.ReadNetworkStream
			Dim DesiredLength As LongInt = self->BodyEndIndex - self->BodyOffset

			Dim ReservedBytesLength As UInteger = Any
			Dim pReservedBytes As UByte Ptr = Any

			Dim hrGetReservedBytes As HRESULT = AllocBytes( _
				self->pIBuffer, _
				DesiredLength, _
				@ReservedBytesLength, _
				@pReservedBytes  _
			)
			If FAILED(hrGetReservedBytes) Then
				*ppIAsyncResult = NULL
				Return hrGetReservedBytes
			End If

			' No need to specify the buffer length
			' as it will return to the EndRead function
			self->StreamBufferLength = 1
			self->StreamBuffer.Buf(0).Buffer = pReservedBytes

			Dim hrBeginRead As HRESULT = IBaseAsyncStream_BeginRead( _
				self->pIStream, _
				pReservedBytes, _
				ReservedBytesLength, _
				pcb, _
				StateObject, _
				ppIAsyncResult _
			)
			If FAILED(hrBeginRead) Then
				Return hrBeginRead
			End If

		Case WriterTasks.WriteFileData
			Dim Slice As BufferSlice = Any
			With Slice
				.pSlice = self->StreamBuffer.Buf(0).Buffer
				.Length = self->StreamBuffer.Buf(0).Length
			End With

			Dim pIFileAsyncStream As IFileAsyncStream Ptr = CPtr(IFileAsyncStream Ptr, self->pIBuffer)
			Dim hrBeginWrite As HRESULT = IFileAsyncStream_BeginWriteSlice( _
				pIFileAsyncStream, _
				@Slice, _
				self->BodyOffset, _
				pcb, _
				StateObject, _
				ppIAsyncResult _
			)

			If FAILED(hrBeginWrite) Then
				Return hrBeginWrite
			End If

	End Select

	Return HTTPWRITER_S_IO_PENDING

End Function

Private Function HttpWriterEndWrite( _
		ByVal self As HttpWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

	Dim cTask As WriterTasks = self->CurrentTask

	Select Case cTask

		Case WriterTasks.WritePreloadedBytesToNetwork
			'
		Case WriterTasks.ReadFileStream
			If self->BodySended Then
				If self->HeadersSended Then
					Return S_FALSE
				End If

				self->StreamBufferLength = 1
				self->StreamBuffer.Buf(0).Buffer = @self->Headers[self->HeadersOffset]
				self->StreamBuffer.Buf(0).Length = self->HeadersLength - self->HeadersOffset
			Else

				Dim Slice As BufferSlice = Any
				Dim hrEndGetSlice As HRESULT = IAttributedAsyncStream_EndReadSlice( _
					self->pIBuffer, _
					pIAsyncResult, _
					@Slice _
				)
				If FAILED(hrEndGetSlice) Then
					Return hrEndGetSlice
				End If

				If self->HeadersSended Then
					self->StreamBufferLength = 1

					self->StreamBuffer.Buf(0).Buffer = Slice.pSlice
					self->StreamBuffer.Buf(0).Length = Slice.Length
				Else
					self->StreamBufferLength = 2

					self->StreamBuffer.Buf(0).Buffer = @self->Headers[self->HeadersOffset]
					self->StreamBuffer.Buf(0).Length = self->HeadersLength - self->HeadersOffset
					self->StreamBuffer.Buf(1).Buffer = Slice.pSlice
					self->StreamBuffer.Buf(1).Length = Slice.Length
				End If

			End If

			self->CurrentTask = WriterTasks.WriteNetworkData

		Case WriterTasks.WriteNetworkData
			Dim dwWritedBytes As DWORD = Any
			Dim hrEndWrite As HRESULT = IBaseAsyncStream_EndWrite( _
				self->pIStream, _
				pIAsyncResult, _
				@dwWritedBytes _
			)
			If FAILED(hrEndWrite) Then
				Return hrEndWrite
			End If

			If self->HeadersSended Then
				self->BodyOffset += CLngInt(dwWritedBytes)
			Else
				Dim HeadersSize As LongInt = self->HeadersLength - self->HeadersOffset
				Dim HeadersWritedBytes As LongInt = min(CLngInt(dwWritedBytes), HeadersSize)

				self->HeadersOffset += HeadersWritedBytes

				If self->HeadersOffset >= self->HeadersEndIndex Then
					self->HeadersSended = True
				End If

				Dim BodyWritedBytes As LongInt = CLngInt(dwWritedBytes) - HeadersWritedBytes
				self->BodyOffset += CLngInt(BodyWritedBytes)

			End If

			If self->BodyOffset >= self->BodyEndIndex Then
				self->BodySended = True
			End If

			If hrEndWrite = S_FALSE Then
				Return S_FALSE
			End If

			If self->BodySended Then
				Return S_OK
			End If

			self->CurrentTask = WriterTasks.ReadFileStream

		Case WriterTasks.Write100Continue
			Dim dwWritedBytes As DWORD = Any
			Dim hrEndWrite As HRESULT = IBaseAsyncStream_EndWrite( _
				self->pIStream, _
				pIAsyncResult, _
				@dwWritedBytes _
			)
			If FAILED(hrEndWrite) Then
				Return hrEndWrite
			End If

			If hrEndWrite = S_FALSE Then
				Return S_FALSE
			End If

			self->Write100ContinueOffset += CInt(dwWritedBytes)

			If self->Write100ContinueOffset >= Len(String100Continue) Then
				self->CurrentTask = WriterTasks.WritePreloadedBytesToFile
			Else
				self->StreamBufferLength = 1
				self->StreamBuffer.Buf(0).Buffer = @String100Continue + self->Write100ContinueOffset
				self->StreamBuffer.Buf(0).Length = Len(String100Continue) - self->Write100ContinueOffset
			End If

		Case WriterTasks.WritePreloadedBytesToFile
			Dim pIFileAsyncStream As IFileAsyncStream Ptr = CPtr(IFileAsyncStream Ptr, self->pIBuffer)
			Dim WritedBytes As DWORD = Any
			Dim hrEndGetSlice As HRESULT = IFileAsyncStream_EndWriteSlice( _
				pIFileAsyncStream, _
				pIAsyncResult, _
				@WritedBytes _
			)
			If FAILED(hrEndGetSlice) Then
				Return hrEndGetSlice
			End If

			self->BodyOffset += CLngInt(WritedBytes)

			Dim BodySended As Boolean = Any
			If self->BodyOffset >= self->BodyEndIndex Then
				BodySended = True
			Else
				BodySended = False
			End If

			If hrEndGetSlice = S_FALSE Then
				Return S_FALSE
			End If

			If BodySended Then
				self->StreamBufferLength = 1
				self->StreamBuffer.Buf(0).Buffer = @self->Headers[self->HeadersOffset]
				self->StreamBuffer.Buf(0).Length = self->HeadersLength - self->HeadersOffset

				self->CurrentTask = WriterTasks.WriteNetworkData
			Else
				Dim PreloadedBytesLength As Integer = Any
				Dim pPreloadedBytes As UByte Ptr = Any
				IAttributedAsyncStream_GetPreloadedBytes( _
					self->pIBuffer, _
					@PreloadedBytesLength, _
					@pPreloadedBytes _
				)

				Dim AllPreloadBytesWrited As Boolean = self->BodyOffset >= PreloadedBytesLength
				If AllPreloadBytesWrited Then
					self->CurrentTask = WriterTasks.ReadNetworkStream
				End If
			End If

		Case WriterTasks.ReadNetworkStream
			Dim ReadedBytes As DWORD = Any
			Dim hrEndRead As HRESULT = IBaseAsyncStream_EndRead( _
				self->pIStream, _
				pIAsyncResult, _
				@ReadedBytes _
			)
			If FAILED(hrEndRead) Then
				Return hrEndRead
			End If

			If hrEndRead = S_FALSE Then
				Return S_FALSE
			End If

			' The buffer pointer is already specified
			self->StreamBuffer.Buf(0).Length = ReadedBytes

			self->CurrentTask = WriterTasks.WriteFileData

		Case WriterTasks.WriteFileData
			Dim pIFileAsyncStream As IFileAsyncStream Ptr = CPtr(IFileAsyncStream Ptr, self->pIBuffer)
			Dim WritedBytes As DWORD = Any
			Dim hrEndGetSlice As HRESULT = IFileAsyncStream_EndWriteSlice( _
				pIFileAsyncStream, _
				pIAsyncResult, _
				@WritedBytes _
			)
			If FAILED(hrEndGetSlice) Then
				Return hrEndGetSlice
			End If

			self->BodyOffset += CLngInt(WritedBytes)

			' Dim Diff As Integer = self->StreamBuffer.Buf(0).Length - WritedBytes
			' If Diff Then
			' 	' Write the remaining bytes
			' 	self->StreamBuffer.Buf(0).Length = Diff
			' Else
				If hrEndGetSlice = S_FALSE Then
					Return S_FALSE
				End If

				Dim BodySended As Boolean = Any
				If self->BodyOffset >= self->BodyEndIndex Then
					BodySended = True
				Else
					BodySended = False
				End If

				If BodySended Then
					self->StreamBufferLength = 1
					self->StreamBuffer.Buf(0).Buffer = @self->Headers[self->HeadersOffset]
					self->StreamBuffer.Buf(0).Length = self->HeadersLength - self->HeadersOffset

					self->CurrentTask = WriterTasks.WriteNetworkData
				Else
					self->CurrentTask = WriterTasks.ReadNetworkStream
				End If
			' End If

	End Select

	Return HTTPWRITER_S_IO_PENDING

End Function

Private Function HttpWriterSetKeepAlive( _
		ByVal self As HttpWriter Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT

	self->KeepAlive = KeepAlive

	Return S_OK

End Function

Private Function HttpWriterSetNeedWrite100Continue( _
		ByVal self As HttpWriter Ptr, _
		ByVal NeedWrite100Continue As Boolean _
	)As HRESULT

	self->NeedWrite100Continue = NeedWrite100Continue

	Return S_OK

End Function


Private Function IHttpAsyncWriterQueryInterface( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpWriterQueryInterface(CONTAINING_RECORD(self, HttpWriter, lpVtbl), riid, ppvObject)
End Function

Private Function IHttpAsyncWriterAddRef( _
		ByVal self As IHttpAsyncWriter Ptr _
	)As ULONG
	Return HttpWriterAddRef(CONTAINING_RECORD(self, HttpWriter, lpVtbl))
End Function

Private Function IHttpAsyncWriterRelease( _
		ByVal self As IHttpAsyncWriter Ptr _
	)As ULONG
	Return HttpWriterRelease(CONTAINING_RECORD(self, HttpWriter, lpVtbl))
End Function

Private Function IHttpAsyncWriterGetBaseStream( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal ppResult As IBaseAsyncStream Ptr Ptr _
	)As HRESULT
	Return HttpWriterGetBaseStream(CONTAINING_RECORD(self, HttpWriter, lpVtbl), ppResult)
End Function

Private Function IHttpAsyncWriterSetBaseStream( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return HttpWriterSetBaseStream(CONTAINING_RECORD(self, HttpWriter, lpVtbl), pIStream)
End Function

Private Function IHttpAsyncWriterGetBuffer( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal ppResult As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT
	Return HttpWriterGetBuffer(CONTAINING_RECORD(self, HttpWriter, lpVtbl), ppResult)
End Function

Private Function IHttpAsyncWriterSetBuffer( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal pIBuffer As IAttributedAsyncStream Ptr _
	)As HRESULT
	Return HttpWriterSetBuffer(CONTAINING_RECORD(self, HttpWriter, lpVtbl), pIBuffer)
End Function

Private Function IHttpAsyncWriterPrepare( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal fFileAccess As FileAccess _
	)As HRESULT
	Return HttpWriterPrepare(CONTAINING_RECORD(self, HttpWriter, lpVtbl), pIResponse, ContentLength, fFileAccess)
End Function

Private Function IHttpAsyncWriterBeginWrite( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpWriterBeginWrite(CONTAINING_RECORD(self, HttpWriter, lpVtbl), pcb, StateObject, ppIAsyncResult)
End Function

Private Function IHttpAsyncWriterEndWrite( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpWriterEndWrite(CONTAINING_RECORD(self, HttpWriter, lpVtbl), pIAsyncResult)
End Function

Private Function IHttpAsyncWriterSetKeepAlive( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	Return HttpWriterSetKeepAlive(CONTAINING_RECORD(self, HttpWriter, lpVtbl), KeepAlive)
End Function

Private Function IHttpAsyncWriterSetNeedWrite100Continue( _
		ByVal self As IHttpAsyncWriter Ptr, _
		ByVal NeedWrite100Continue As Boolean _
	)As HRESULT
	Return HttpWriterSetNeedWrite100Continue(CONTAINING_RECORD(self, HttpWriter, lpVtbl), NeedWrite100Continue)
End Function

Dim GlobalHttpWriterVirtualTable As Const IHttpAsyncWriterVirtualTable = Type( _
	@IHttpAsyncWriterQueryInterface, _
	@IHttpAsyncWriterAddRef, _
	@IHttpAsyncWriterRelease, _
	@IHttpAsyncWriterGetBaseStream, _
	@IHttpAsyncWriterSetBaseStream, _
	@IHttpAsyncWriterGetBuffer, _
	@IHttpAsyncWriterSetBuffer, _
	@IHttpAsyncWriterPrepare, _
	@IHttpAsyncWriterBeginWrite, _
	@IHttpAsyncWriterEndWrite, _
	@IHttpAsyncWriterSetKeepAlive, _
	@IHttpAsyncWriterSetNeedWrite100Continue _
)
