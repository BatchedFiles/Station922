#include once "ProcessOptionsRequest.bi"

Function ProcessOptionsRequest( _
		ByVal state As ReadHeadersResult Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal hOutput As Handle _
	)As Boolean
	' Нет содержимого
	state->ServerResponse.StatusCode = 204
	
	' Если звёздочка, то ко всему серверу
	If lstrcmp(state->ClientRequest.ClientURI.Url, "*") = 0 Then
		state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethods
	Else
		' К конкретному ресурсу
		' Проверка на CGI
		If NeedCGIProcessing(state->ClientRequest.ClientUri.Path) Then
			state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsForScript
		Else
			' Проверка на dll-cgi
			If NeedDLLProcessing(state->ClientRequest.ClientUri.Path) Then
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsForScript
			Else
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsForFile
			End If
		End If
	End If
	
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	If send(ClientSocket, @SendBuffer, state->AllResponseHeadersToBytes(@SendBuffer, 0, hOutput), 0) = SOCKET_ERROR Then
		Return False
	End If
	
	Return True
End Function
