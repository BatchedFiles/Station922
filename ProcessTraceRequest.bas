#include once "ProcessTraceRequest.bi"
#include once "Mime.bi"

Function ProcessTraceRequest( _
		ByVal state As ReadHeadersResult Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal hOutput As Handle _
	)As Boolean
	
	' Собрать все заголовки запроса и сформировать из них тело ответа
	
	state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderContentType) = ContentTypeToString(ContentTypes.MessageHttp)
	
	Dim ContentLength As Integer = state->ClientReader.Start - 2
	
	' Заголовки
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	If send(ClientSocket, @SendBuffer, state->AllResponseHeadersToBytes(@SendBuffer, ContentLength, hOutput), 0) = SOCKET_ERROR Then
		Return False
	End If
	
	' Тело
	If send(ClientSocket, @state->ClientReader.Buffer, ContentLength, 0) = SOCKET_ERROR Then
		Return False
	End If
	
	Return True
End Function
