#ifndef WEBUTILS_BI
#define WEBUTILS_BI

#include once "IClientRequest.bi"
#include once "IBaseStream.bi"
#include once "IServerResponse.bi"
#include once "IWebSiteCollection.bi"

' ��������� ����� �������������� �������, ���������� ��� html
' ����������� ����� ������ ���� � 6 ��� ������� ������
' Declare Function GetHtmlSafeString( _
	' ByVal Buffer As WString Ptr, _
	' ByVal BufferLength As Integer, _
	' ByVal HtmlSafe As WString Ptr, _
	' ByVal pHtmlSafeLength As Integer Ptr _
' )As Boolean

' ��������� ����� ����� � �������� � http �������
Declare Sub GetHttpDate Overload( _
	ByVal Buffer As WString Ptr _
)

Declare Sub GetHttpDate Overload( _
	ByVal Buffer As WString Ptr, _
	ByVal dt As SYSTEMTIME Ptr _
)

' �������� ��������������
Declare Function HttpAuthUtil( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pStream As IBaseStream Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal ProxyAuthorization As Boolean _
)As Boolean

Declare Function SetResponseCompression( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal PathTranslated As WString Ptr, _
	ByVal pAcceptEncoding As Boolean Ptr _
)As Handle

Declare Sub AddResponseCacheHeaders( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pDateLastFileModified As FILETIME Ptr, _
	ByVal ETag As HeapBSTR _
)

Declare Function FindWebSite( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

#endif
