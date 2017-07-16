#ifndef unicode
#define unicode
#endif

#include once "Http.bi"
#include once "windows.bi"

Function GetHttpMethod(ByVal s As WString Ptr)As HttpMethods
	If lstrcmp(s, HttpMethodGet) = 0 Then
		Return HttpMethods.HttpGet
	End If
	
	If lstrcmp(s, HttpMethodHead) = 0 Then
		Return HttpMethods.HttpHead
	End If
	
	If lstrcmp(s, HttpMethodPut) = 0 Then
		Return HttpMethods.HttpPut
	End If
	
	If lstrcmp(s, HttpMethodConnect) = 0 Then
		Return HttpMethods.HttpConnect
	End If
	
	If lstrcmp(s, HttpMethodDelete) = 0 Then
		Return HttpMethods.HttpDelete
	End If
	
	If lstrcmp(s, HttpMethodOptions) = 0 Then
		Return HttpMethods.HttpOptions
	End If
	
	If lstrcmp(s, HttpMethodTrace) = 0 Then
		Return HttpMethods.HttpTrace
	End If
	
	Return HttpMethods.None
End Function

Function GetHttpMethodName(ByVal Buffer As WString Ptr, ByVal HttpMethod As HttpMethods)As Integer
	Select Case HttpMethod
		Case HttpGet
			lstrcpy(Buffer, @HttpMethodGet)
			Return HttpMethodGetLength
			
		Case HttpHead
			lstrcpy(Buffer, @HttpMethodHead)
			Return HttpMethodHeadLength
			
		Case HttpPut
			lstrcpy(Buffer, @HttpMethodPut)
			Return HttpMethodPutLength
			
		Case HttpPatch
			lstrcpy(Buffer, @HttpMethodPatch)
			Return HttpMethodPatchLength
			
		Case HttpDelete
			lstrcpy(Buffer, @HttpMethodDelete)
			Return HttpMethodDeleteLength
			
		Case HttpPost
			lstrcpy(Buffer, @HttpMethodPost)
			Return HttpMethodPostLength
			
		Case HttpOptions
			lstrcpy(Buffer, @HttpMethodOptions)
			Return HttpMethodOptionsLength
			
		Case HttpTrace
			lstrcpy(Buffer, @HttpMethodTrace)
			Return HttpMethodTraceLength
			
		Case HttpConnect
			lstrcpy(Buffer, @HttpMethodConnect)
			Return HttpMethodConnectLength
			
		Case HttpCopy
			lstrcpy(Buffer, @HttpMethodCopy)
			Return HttpMethodCopyLength
			
		Case HttpMove
			lstrcpy(Buffer, @HttpMethodMove)
			Return HttpMethodMoveLength
			
		Case HttpPropfind
			lstrcpy(Buffer, @HttpMethodPropfind)
			Return HttpMethodPropfindLength
			
	End Select
	
	Return 0
End Function

Function GetKnownRequestHeaderIndex(ByVal Header As WString Ptr)As Integer
	If lstrcmpi(Header, HeaderAcceptString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderAccept
	End If
	If lstrcmpi(Header, HeaderAcceptCharsetString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderAcceptCharset
	End If
	If lstrcmpi(Header, HeaderAcceptEncodingString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderAcceptEncoding
	End If
	If lstrcmpi(Header, HeaderAcceptLanguageString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderAcceptLanguage
	End If
	If lstrcmpi(Header, HeaderAuthorizationString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderAuthorization
	End If
	If lstrcmpi(Header, HeaderCacheControlString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderCacheControl
	End If
	If lstrcmpi(Header, HeaderConnectionString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderConnection
	End If
	If lstrcmpi(Header, HeaderContentEncodingString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderContentEncoding
	End If
	If lstrcmpi(Header, HeaderContentLanguageString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderContentLanguage
	End If
	If lstrcmpi(Header, HeaderContentLengthString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderContentLength
	End If
	If lstrcmpi(Header, HeaderContentMd5String) = 0 Then
		Return HttpRequestHeaderIndices.HeaderContentMd5
	End If
	If lstrcmpi(Header, HeaderContentRangeString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderContentRange
	End If
	If lstrcmpi(Header, HeaderContentTypeString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderContentType
	End If
	If lstrcmpi(Header, HeaderCookieString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderCookie
	End If
	If lstrcmpi(Header, HeaderExpectString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderExpect
	End If
	If lstrcmpi(Header, HeaderFromString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderFrom
	End If
	If lstrcmpi(Header, HeaderHostString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderHost
	End If
	If lstrcmpi(Header, HeaderIfMatchString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderIfMatch
	End If
	If lstrcmpi(Header, HeaderIfModifiedSinceString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderIfModifiedSince
	End If
	If lstrcmpi(Header, HeaderIfNoneMatchString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderIfNoneMatch
	End If
	If lstrcmpi(Header, HeaderIfRangeString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderIfRange
	End If
	If lstrcmpi(Header, HeaderIfUnmodifiedSinceString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderIfUnmodifiedSince
	End If
	If lstrcmpi(Header, HeaderKeepAliveString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderKeepAlive
	End If
	If lstrcmpi(Header, HeaderMaxForwardsString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderMaxForwards
	End If
	If lstrcmpi(Header, HeaderPragmaString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderPragma
	End If
	If lstrcmpi(Header, HeaderProxyAuthorizationString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderProxyAuthorization
	End If
	If lstrcmpi(Header, HeaderRangeString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderRange
	End If
	If lstrcmpi(Header, HeaderRefererString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderReferer
	End If
	If lstrcmpi(Header, HeaderTeString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderTe
	End If
	If lstrcmpi(Header, HeaderTrailerString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderTrailer
	End If
	If lstrcmpi(Header, HeaderTransferEncodingString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderTransferEncoding
	End If
	If lstrcmpi(Header, HeaderUpgradeString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderUpgrade
	End If
	If lstrcmpi(Header, HeaderTransferEncodingString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderTransferEncoding
	End If
	If lstrcmpi(Header, HeaderUserAgentString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderUserAgent
	End If
	If lstrcmpi(Header, HeaderViaString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderVia
	End If
	If lstrcmpi(Header, HeaderWarningString) = 0 Then
		Return HttpRequestHeaderIndices.HeaderWarning
	End If
	Return -1
End Function

Function GetKnownResponseHeaderIndex(ByVal Header As WString Ptr)As Integer
	If lstrcmpi(Header, @HeaderAcceptRangesString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderAcceptRanges
	End If
	If lstrcmpi(Header, @HeaderAgeString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderAge
	End If
	If lstrcmpi(Header, @HeaderAllowString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderAllow
	End If
	If lstrcmpi(Header, @HeaderCacheControlString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderCacheControl
	End If
	If lstrcmpi(Header, @HeaderConnectionString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderConnection
	End If
	If lstrcmpi(Header, @HeaderContentEncodingString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentEncoding
	End If
	If lstrcmpi(Header, @HeaderContentLanguageString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentLanguage
	End If
	If lstrcmpi(Header, @HeaderContentLengthString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentLength
	End If
	If lstrcmpi(Header, @HeaderContentLocationString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentLocation
	End If
	If lstrcmpi(Header, @HeaderContentMd5String) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentMd5
	End If
	If lstrcmpi(Header, @HeaderContentRangeString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentRange
	End If
	If lstrcmpi(Header, @HeaderContentTypeString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderContentType
	End If
	If lstrcmpi(Header, @HeaderDateString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderDate
	End If
	If lstrcmpi(Header, @HeaderETagString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderETag
	End If
	If lstrcmpi(Header, @HeaderExpiresString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderExpires
	End If
	If lstrcmpi(Header, @HeaderKeepAliveString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderKeepAlive
	End If
	If lstrcmpi(Header, @HeaderLastModifiedString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderLastModified
	End If
	If lstrcmpi(Header, @HeaderLocationString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderLocation
	End If
	If lstrcmpi(Header, @HeaderPragmaString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderPragma
	End If
	If lstrcmpi(Header, @HeaderProxyAuthenticateString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderProxyAuthenticate
	End If
	If lstrcmpi(Header, @HeaderRetryAfterString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderRetryAfter
	End If
	If lstrcmpi(Header, @HeaderServerString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderServer
	End If
	If lstrcmpi(Header, @HeaderSetCookieString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderSetCookie
	End If
	If lstrcmpi(Header, @HeaderTrailerString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderTrailer
	End If
	If lstrcmpi(Header, @HeaderTransferEncodingString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderTransferEncoding
	End If
	If lstrcmpi(Header, @HeaderUpgradeString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderUpgrade
	End If
	If lstrcmpi(Header, @HeaderVaryString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderVary
	End If
	If lstrcmpi(Header, @HeaderViaString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderVia
	End If
	If lstrcmpi(Header, @HeaderWarningString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderWarning
	End If
	If lstrcmpi(Header, @HeaderWWWAuthenticateString) = 0 Then
		Return HttpResponseHeaderIndices.HeaderWwwAuthenticate
	End If
	Return -1
End Function

Function GetKnownResponseHeaderName(ByVal Buffer As WString Ptr, ByVal HeaderIndex As HttpResponseHeaderIndices)As Integer
	Select Case HeaderIndex
		
		Case HttpResponseHeaderIndices.HeaderAcceptRanges
			lstrcpy(Buffer, @HeaderAcceptRangesString)
			Return HeaderAcceptRangesStringLength
			
		Case HttpResponseHeaderIndices.HeaderAge
			lstrcpy(Buffer, @HeaderAgeString)
			Return HeaderAgeStringLength
			
		Case HttpResponseHeaderIndices.HeaderAllow
			lstrcpy(Buffer, @HeaderAllowString)
			Return HeaderAllowStringLength
			
		Case HttpResponseHeaderIndices.HeaderCacheControl
			lstrcpy(Buffer, @HeaderCacheControlString)
			Return HeaderCacheControlStringLength
			
		Case HttpResponseHeaderIndices.HeaderConnection
			lstrcpy(Buffer, @HeaderConnectionString)
			Return HeaderConnectionStringLength
			
		Case HttpResponseHeaderIndices.HeaderContentEncoding
			lstrcpy(Buffer, @HeaderContentEncodingString)
			Return HeaderContentEncodingStringLength
			
		Case HttpResponseHeaderIndices.HeaderContentLength
			lstrcpy(Buffer, @HeaderContentLengthString)
			Return HeaderContentLengthStringLength
			
		Case HttpResponseHeaderIndices.HeaderContentLanguage
			lstrcpy(Buffer, @HeaderContentLanguageString)
			Return HeaderContentLanguageStringLength
			
		Case HttpResponseHeaderIndices.HeaderContentLocation
			lstrcpy(Buffer, @HeaderContentLocationString)
			Return HeaderContentLocationStringLength
			
		Case HttpResponseHeaderIndices.HeaderContentMd5
			lstrcpy(Buffer, @HeaderContentMd5String)
			Return HeaderContentMd5StringLength
			
		Case HttpResponseHeaderIndices.HeaderContentRange
			lstrcpy(Buffer, @HeaderContentRangeString)
			Return HeaderContentRangeStringLength
			
		Case HttpResponseHeaderIndices.HeaderContentType
			lstrcpy(Buffer, @HeaderContentTypeString)
			Return HeaderContentTypeStringLength
			
		Case HttpResponseHeaderIndices.HeaderDate
			lstrcpy(Buffer, @HeaderDateString)
			Return HeaderDateStringLength
			
		Case HttpResponseHeaderIndices.HeaderEtag
			lstrcpy(Buffer, @HeaderETagString)
			Return HeaderETagStringLength
			
		Case HttpResponseHeaderIndices.HeaderExpires
			lstrcpy(Buffer, @HeaderExpiresString)
			Return HeaderExpiresStringLength
			
		Case HttpResponseHeaderIndices.HeaderKeepAlive
			lstrcpy(Buffer, @HeaderKeepAliveString)
			Return HeaderKeepAliveStringLength
			
		Case HttpResponseHeaderIndices.HeaderLastModified
			lstrcpy(Buffer, @HeaderLastModifiedString)
			Return HeaderLastModifiedStringLength
			
		Case HttpResponseHeaderIndices.HeaderLocation
			lstrcpy(Buffer, @HeaderLocationString)
			Return HeaderLocationStringLength
			
		Case HttpResponseHeaderIndices.HeaderPragma
			lstrcpy(Buffer, @HeaderPragmaString)
			Return HeaderPragmaStringLength
			
		Case HttpResponseHeaderIndices.HeaderProxyAuthenticate
			lstrcpy(Buffer, @HeaderProxyAuthenticateString)
			Return HeaderProxyAuthenticateStringLength
			
		Case HttpResponseHeaderIndices.HeaderRetryAfter
			lstrcpy(Buffer, @HeaderRetryAfterString)
			Return HeaderRetryAfterStringLength
			
		Case HttpResponseHeaderIndices.HeaderServer
			lstrcpy(Buffer, @HeaderServerString)
			Return HeaderServerStringLength
			
		Case HttpResponseHeaderIndices.HeaderSetCookie
			lstrcpy(Buffer, @HeaderSetCookieString)
			Return HeaderSetCookieStringLength
			
		Case HttpResponseHeaderIndices.HeaderTrailer
			lstrcpy(Buffer, @HeaderTrailerString)
			Return HeaderTrailerStringLength
			
		Case HttpResponseHeaderIndices.HeaderTransferEncoding
			lstrcpy(Buffer, @HeaderTransferEncodingString)
			Return HeaderTransferEncodingStringLength
			
		Case HttpResponseHeaderIndices.HeaderUpgrade
			lstrcpy(Buffer, @HeaderUpgradeString)
			Return HeaderUpgradeStringLength
			
		Case HttpResponseHeaderIndices.HeaderVary
			lstrcpy(Buffer, @HeaderVaryString)
			Return HeaderVaryStringLength
			
		Case HttpResponseHeaderIndices.HeaderVia
			lstrcpy(Buffer, @HeaderViaString)
			Return HeaderViaStringLength
			
		Case HttpResponseHeaderIndices.HeaderWarning
			lstrcpy(Buffer, @HeaderWarningString)
			Return HeaderWarningStringLength
			
		Case HttpResponseHeaderIndices.HeaderWwwAuthenticate
			lstrcpy(Buffer, @HeaderWWWAuthenticateString)
			Return HeaderWWWAuthenticateStringLength
			
	End Select
	
	Return 0
End Function

Function GetStatusDescription(ByVal Buffer As WString Ptr, ByVal StatusCode As Integer)As Integer
	Select Case StatusCode
		Case 100
			lstrcpy(Buffer, @HttpStatusCodeString100)
		Case 101
			lstrcpy(Buffer, @HttpStatusCodeString101)
		Case 102
			lstrcpy(Buffer, @HttpStatusCodeString102)
		Case 200
			lstrcpy(Buffer, @HttpStatusCodeString200)
		Case 201
			lstrcpy(Buffer, @HttpStatusCodeString201)
		Case 202
			lstrcpy(Buffer, @HttpStatusCodeString202)
		Case 203
			lstrcpy(Buffer, @HttpStatusCodeString203)
		Case 204
			lstrcpy(Buffer, @HttpStatusCodeString204)
		Case 205
			lstrcpy(Buffer, @HttpStatusCodeString205)
		Case 206
			lstrcpy(Buffer, @HttpStatusCodeString206)
		Case 207
			lstrcpy(Buffer, @HttpStatusCodeString207)
		Case 226
			lstrcpy(Buffer, @HttpStatusCodeString226)
		Case 300
			lstrcpy(Buffer, @HttpStatusCodeString300)
		Case 301
			lstrcpy(Buffer, @HttpStatusCodeString301)
		Case 302
			lstrcpy(Buffer, @HttpStatusCodeString302)
		Case 303
			lstrcpy(Buffer, @HttpStatusCodeString303)
		Case 304
			lstrcpy(Buffer, @HttpStatusCodeString304)
		Case 305
			lstrcpy(Buffer, @HttpStatusCodeString305)
		Case 307
			lstrcpy(Buffer, @HttpStatusCodeString307)
		Case 400
			lstrcpy(Buffer, @HttpStatusCodeString400)
		Case 401
			lstrcpy(Buffer, @HttpStatusCodeString401)
		Case 402
			lstrcpy(Buffer, @HttpStatusCodeString402)
		Case 403
			lstrcpy(Buffer, @HttpStatusCodeString403)
		Case 404
			lstrcpy(Buffer, @HttpStatusCodeString404)
		Case 405
			lstrcpy(Buffer, @HttpStatusCodeString405)
		Case 406
			lstrcpy(Buffer, @HttpStatusCodeString406)
		Case 407
			lstrcpy(Buffer, @HttpStatusCodeString407)
		Case 408
			lstrcpy(Buffer, @HttpStatusCodeString408)
		Case 409
			lstrcpy(Buffer, @HttpStatusCodeString409)
		Case 410
			lstrcpy(Buffer, @HttpStatusCodeString410)
		Case 411
			lstrcpy(Buffer, @HttpStatusCodeString411)
		Case 412
			lstrcpy(Buffer, @HttpStatusCodeString412)
		Case 413
			lstrcpy(Buffer, @HttpStatusCodeString413)
		Case 414
			lstrcpy(Buffer, @HttpStatusCodeString414)
		Case 415
			lstrcpy(Buffer, @HttpStatusCodeString415)
		Case 416
			lstrcpy(Buffer, @HttpStatusCodeString416)
		Case 417
			lstrcpy(Buffer, @HttpStatusCodeString417)
		Case 418
			lstrcpy(Buffer, @HttpStatusCodeString418)
		REM Case 422
			REM lstrcpy(Buffer, @HttpStatusCodeString422)
		REM Case 423
			REM lstrcpy(Buffer, @HttpStatusCodeString423)
		REM Case 424
			REM lstrcpy(Buffer, @HttpStatusCodeString424)
		REM Case 425
			REM lstrcpy(Buffer, @HttpStatusCodeString425)
		Case 426
			lstrcpy(Buffer, @HttpStatusCodeString426)
		Case 428
			lstrcpy(Buffer, @HttpStatusCodeString428)
		Case 429
			lstrcpy(Buffer, @HttpStatusCodeString429)
		Case 431
			lstrcpy(Buffer, @HttpStatusCodeString431)
		REM Case 449
			REM lstrcpy(Buffer, @HttpStatusCodeString449)
		Case 451
			lstrcpy(Buffer, @HttpStatusCodeString451)
		Case 500
			lstrcpy(Buffer, @HttpStatusCodeString500)
		Case 501
			lstrcpy(Buffer, @HttpStatusCodeString501)
		Case 502
			lstrcpy(Buffer, @HttpStatusCodeString502)
		Case 503
			lstrcpy(Buffer, @HttpStatusCodeString503)
		Case 504
			lstrcpy(Buffer, @HttpStatusCodeString504)
		Case 505
			lstrcpy(Buffer, @HttpStatusCodeString505)
		Case 506
			lstrcpy(Buffer, @HttpStatusCodeString506)
		Case 507
			lstrcpy(Buffer, @HttpStatusCodeString507)
		Case 508
			lstrcpy(Buffer, @HttpStatusCodeString508)
		Case 509
			lstrcpy(Buffer, @HttpStatusCodeString509)
		Case 510
			lstrcpy(Buffer, @HttpStatusCodeString510)
		Case 511
			lstrcpy(Buffer, @HttpStatusCodeString511)
		Case Else
			lstrcpy(Buffer, @HttpStatusCodeString200)
	End Select
	
	Return 0
End Function
