#ifndef HTTPCONST_BI
#define HTTPCONST_BI

Const BytesString = "bytes"
Const CloseString = "Close"
Const GzipString = "gzip"
Const DeflateString = "deflate"
Const HeadersExtensionString = ".headers"
Const FileGoneExtension = ".410"
Const QuoteString = """"
Const BasicAuthorization = "Basic"
Const WebSocketGuidString = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

Const DefaultVirtualPath = "/"

' Максимальный размер полученного от клиента тела запроса
' TODO Вынести в конфигурацию ограничение на максимальный размер тела запроса
Const MaxRequestBodyContentLength As LongInt = 20 * 1024 * 1024

#endif
