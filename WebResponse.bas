#include "WebResponse.bi"

Sub InitializeWebResponse( _
		ByVal pWebResponse As WebResponse Ptr _
	)
	
	ZeroMemory(@pWebResponse->ResponseHeaders(0), HttpResponseHeadersMaximum * SizeOf(WString Ptr))
	
	pWebResponse->SendOnlyHeaders = False
	pWebResponse->StatusDescription = NULL
	pWebResponse->ResponseZipEnable = False
	pWebResponse->StartResponseHeadersPtr = @pWebResponse->ResponseHeaderBuffer
	pWebResponse->HttpVersion = HttpVersions.Http11
	pWebResponse->StatusCode = HttpStatusCodes.OK
	pWebResponse->Mime.ContentType = ContentTypes.Unknown
	
End Sub

Sub WebResponse.AddResponseHeader( _
		ByVal HeaderName As WString Ptr, _
		ByVal Value As WString Ptr _
	)
	' TODO Устранить переполнение буфера
	Dim HeaderIndex As HttpResponseHeaders = Any
	If GetKnownResponseHeader(HeaderName, @HeaderIndex) Then
		AddKnownResponseHeader(HeaderIndex, Value)
	End If
End Sub

Sub WebResponse.AddKnownResponseHeader( _
		ByVal Header As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)
	' TODO Избежать многократного добавления заголовка
	lstrcpy(StartResponseHeadersPtr, Value)
	ResponseHeaders(Header) = StartResponseHeadersPtr
	StartResponseHeadersPtr += lstrlen(Value) + 2
End Sub

Sub WebResponse.SetStatusDescription( _
		ByVal Description As WString Ptr _
	)
	lstrcpy(StartResponseHeadersPtr, Description)
	StatusDescription = StartResponseHeadersPtr
	StartResponseHeadersPtr += lstrlen(Description) + 2
End Sub
