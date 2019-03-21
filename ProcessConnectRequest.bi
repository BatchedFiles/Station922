#ifndef PROCESSCONNECTREQUEST_BI
#define PROCESSCONNECTREQUEST_BI

#include "IClientRequest.bi"
#include "INetworkStream.bi"
#include "IWebSite.bi"
#include "WebResponse.bi"

Declare Function ProcessConnectRequest( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pResponse As WebResponse Ptr, _
	ByVal pINetworkStream As INetworkStream Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal pIClientReader As IHttpReader Ptr, _
	ByVal pIRequestedFile As IRequestedFile Ptr _
)As Boolean

#endif
