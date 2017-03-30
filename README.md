
# FreeBASICWebServer #

Very small web server for Windows written in FreeBASIC. Is able to process the methods CONNECT, GET, HEAD, PUT, DELETE, TRACE and OPTIONS.

## Compile ##

### Simple version ###

fbc.exe -mt -x "webserver.exe" WebServer.bas Network.bas ThreadProc.bas ReadHeadersResult.bas WebUtils.bas ProcessRequests.bas base64-decode.bas Mime.bas Http.bas WebSite.bas HeapOnArray.bas

### WebServer as Windows Service ###

fbc.exe -mt -x "webserver.exe" -d service=true WebServer.bas Network.bas ThreadProc.bas ReadHeadersResult.bas WebUtils.bas ProcessRequests.bas base64-decode.bas Mime.bas Http.bas WebSite.bas HeapOnArray.bas

