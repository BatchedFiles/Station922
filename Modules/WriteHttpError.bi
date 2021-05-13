#ifndef WRITEHTTPERROR_BI
#define WRITEHTTPERROR_BI

#include once "IClientContext.bi"
#include once "IWebSite.bi"

Declare Sub WriteHttpCreated( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpUpdated( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteMovedPermanently( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpBadRequest( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpPathNotValid( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpHostNotFound( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpSiteNotFound( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpNeedAuthenticate( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpBadAuthenticateParam( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpNeedBasicAuthenticate( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpEmptyPassword( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpBadUserNamePassword( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpForbidden( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpFileNotFound( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpMethodNotAllowed( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpFileGone( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpLengthRequired( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpRequestEntityTooLarge( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpRequestUrlTooLarge( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpRequestHeaderFieldsTooLarge( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpInternalServerError( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpFileNotAvailable( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpCannotCreateChildProcess( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpCannotCreatePipe( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpNotImplemented( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpContentTypeEmpty( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpContentEncodingNotEmpty( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpBadGateway( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpNotEnoughMemory( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpCannotCreateThread( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpGatewayTimeout( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

Declare Sub WriteHttpVersionNotSupported( _
	ByVal pIContext As IClientContext Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)

#endif
