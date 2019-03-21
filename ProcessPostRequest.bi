#ifndef PROCESSPOSTREQUEST_BI
#define PROCESSPOSTREQUEST_BI

#include "IClientRequest.bi"
#include "INetworkStream.bi"
#include "IWebSite.bi"
#include "WebResponse.bi"

Declare Function ProcessPostRequest( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pResponse As WebResponse Ptr, _
	ByVal pINetworkStream As INetworkStream Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal pIClientReader As IHttpReader Ptr, _
	ByVal pIRequestedFile As IRequestedFile Ptr _
)As Boolean

#endif
