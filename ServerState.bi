#ifndef SERVERSTATE_BI
#define SERVERSTATE_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "Http.bi"
#include once "ReadHeadersResult.bi"
#include once "WebSite.bi"

Type ServerState_ As ServerState

' Интерфейс
Type IServerState
	Dim GetRequestHeader As Function( _
		ByVal objState As ServerState_ Ptr, _
		ByVal Value As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal HeaderIndex As HttpRequestHeaderIndices _
	)As Integer
	
	Dim GetHttpMethod As Function( _
		ByVal objState As ServerState_ Ptr _
	)As HttpMethods
	
	Dim GetHttpVersion As Function( _
		ByVal objState As ServerState_ Ptr _
	)As HttpVersions
	
	Dim SetStatusCode As Sub( _
		ByVal objState As ServerState_ Ptr, _
		ByVal Code As Integer _
	)
	
	Dim SetStatusDescription As Sub( _
		ByVal objState As ServerState_ Ptr, _
		ByVal Description As WString Ptr _
	)
	
	Dim SetResponseHeader As Sub( _
		ByVal objState As ServerState_ Ptr, _
		ByVal HeaderIndex As HttpResponseHeaderIndices, _
		ByVal Value As WString Ptr _
	)
	
	Dim GetSafeString As Function( _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal strSafe As WString Ptr _
	)As Integer
	
	Dim WriteData As Function( _
		ByVal objState As ServerState_ Ptr, _
		ByVal Buffer As Any Ptr, _
		ByVal BytesCount As Integer _
	)As Boolean
	
	Dim ReadData As Function( _
		ByVal objState As ServerState_ Ptr, _
		ByVal Buffer As Any Ptr, _
		ByVal BufferLength As Integer, _
		ByVal ReadedBytesCount As Integer Ptr _
	)As Boolean
	
End Type

' Объект сервера
Type ServerState
	Dim VirtualTable As IServerState Ptr
	Dim ClientSocket As Socket
	Dim state As ReadHeadersResult Ptr
	Dim www As WebSite Ptr
	
	' Буфер памяти для сохранения клиентского ответа
	Dim hMapFile As Handle
	Dim ClientBuffer As Any Ptr
	Dim BufferLength As Integer
End Type

#endif
