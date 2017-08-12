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
	Dim GetRequestHeader As Function(ByVal objState As ServerState_ Ptr, ByVal Value As WString Ptr, ByVal BufferLength As Integer, ByVal HeaderIndex As HttpRequestHeaderIndices)As Integer
	Dim GetHttpMethod As Function(ByVal objState As ServerState_ Ptr)As HttpMethods
	Dim GetHttpVersion As Function(ByVal objState As ServerState_ Ptr)As HttpVersions
	
	Dim SetStatusCode As Sub(ByVal objState As ServerState_ Ptr, ByVal Code As Integer)
	Dim SetStatusDescription As Sub(ByVal objState As ServerState_ Ptr, ByVal Description As WString Ptr)
	Dim SetResponseHeader As Sub(ByVal objState As ServerState_ Ptr, ByVal HeaderIndex As HttpResponseHeaderIndices, ByVal Value As WString Ptr)
	
	Dim WriteData As Function(ByVal objState As ServerState_ Ptr, ByVal Buffer As Any Ptr, ByVal BytesCount As Integer)As Boolean
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
