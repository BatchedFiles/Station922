#ifndef unicode
#define unicode
#endif

#include once "Mime.bi"
#include once "windows.bi"

' Html документы
Const ExtensionHtm = ".htm"
Const ExtensionHtml = ".html"
Const ExtensionXhtml = ".xhtml"
Const ExtensionCss = ".css"

' Плоский текст
Const ExtensionTxt = ".txt"
Const ExtensionHeaders = ".headers"

' XML
Const ExtensionXml = ".xml"
Const ExtensionXsl = ".xsl"
Const ExtensionXslt = ".xslt"
Const ExtensionRss = ".rss"
Const ExtensionAtom = ".atom"

' Изображения
Const ExtensionPng = ".png"
Const ExtensionGif = ".gif"
Const ExtensionIco = ".ico"
Const ExtensionJpg = ".jpg"
Const ExtensionJpe = ".jpe"
Const ExtensionJpeg = ".jpeg"
Const ExtensionTif = ".tif"
Const ExtensionTiff = ".tiff"
Const ExtensionSvg = ".svg"

' Скрипты
Const ExtensionJs = ".js"

' Архивы
Const ExtensionZip = ".zip"
Const Extension7z = ".7z"
Const ExtensionRar = ".rar"
Const ExtensionGz = ".gz"
Const ExtensionTgz = ".tgz"

' Программы и документы
Const ExtensionRtf = ".rtf"
Const ExtensionPdf = ".pdf"
Const ExtensionOdt = ".odt"
Const ExtensionOtt = ".ott"
Const ExtensionOdg = ".odg"
Const ExtensionOtg = ".otg"
Const ExtensionOdp = ".odp"
Const ExtensionOtp = ".otp"
Const ExtensionOds = ".ods"
Const ExtensionOts = ".ots"
Const ExtensionOdc = ".odc"
Const ExtensionOtc = ".otc"
Const ExtensionOdi = ".odi"
Const ExtensionOti = ".oti"
Const ExtensionOdf = ".odf"
Const ExtensionOtf = ".otf"
Const ExtensionOdm = ".odm"
Const ExtensionOth = ".oth"

' Аудио и видео
Const ExtensionMpg = ".mpg"
Const ExtensionMpeg = ".mpeg"
Const ExtensionOgv = ".ogv"
Const ExtensionMp4 = ".mp4"
Const ExtensionWebm = ".webm"
Const ExtensionSwf = ".swf"
Const ExtensionRam = ".ram"

' Двоичные файлы
Const ExtensionBin = ".bin"
Const ExtensionExe = ".exe"
Const ExtensionDll = ".dll"
Const ExtensionDeb = ".deb"
Const ExtensionDmg = ".dmg"
Const ExtensionEot = ".eot"
Const ExtensionIso = ".iso"
Const ExtensionImg = ".img"
Const ExtensionMsi = ".msi"
Const ExtensionMsp = ".msp"
Const ExtensionMsm = ".msm"

' Сертификаты
Const ExtensionCrt = ".crt"
Const ExtensionCer = ".cer"

' Исходники
Const ExtensionBas = ".bas"
Const ExtensionBi = ".bi"
Const ExtensionVb = ".vb"
Const ExtensionRc = ".rc"
Const ExtensionAsm = ".asm"
Const ExtensionIni = ".ini"

Function GetStringOfContentType(ByVal ContentType As ContentTypes)As WString Ptr
	
	Select Case ContentType
	
		Case ContentTypes.ImageGif
			Return @"image/gif"
			
		Case ContentTypes.ImageJpeg
			Return @"image/jpeg"
			
		Case ContentTypes.ImagePjpeg
			Return @"image/pjpeg"
			
		Case ContentTypes.ImagePng
			Return @"image/png"
			
		Case ContentTypes.ImageSvg
			Return @"image/svg+xml"
			
		Case ContentTypes.ImageTiff
			Return @"image/tiff"
			
		Case ContentTypes.ImageIco
			Return @"image/vnd.microsoft.icon"
			
		Case ContentTypes.ImageWbmp
			Return @"image/vnd.wap.wbmp"
			
		Case ContentTypes.ImageWebp
			Return @"image/webp"
			
		Case ContentTypes.TextCmd
			Return @"text/cmd"
			
		Case ContentTypes.TextCss
			Return @"text/css"
			
		Case ContentTypes.TextCsv
			Return @"text/csv"
			
		Case ContentTypes.TextHtml
			Return @"text/html"
			
		Case ContentTypes.TextPlain
			Return @"text/plain"
			
		Case ContentTypes.TextPhp
			Return @"text/php"
			
		Case ContentTypes.TextXml
			Return @"text/xml"
			
		Case ContentTypes.ApplicationXml
			Return @"application/xml"
			
		Case ContentTypes.ApplicationXmlXslt
			Return @"application/xml+xslt"
			
		Case ContentTypes.ApplicationXhtml
			Return @"application/xhtml+xml"
			
		Case ContentTypes.ApplicationAtom
			Return @"application/atom+xml"
			
		Case ContentTypes.ApplicationRssXml
			Return @"application/rss+xml"
			
		Case ContentTypes.ApplicationJavascript
			Return @"application/javascript"
			
		Case ContentTypes.ApplicationXJavascript
			Return @"application/x-javascript"
			
		Case ContentTypes.ApplicationJson
			Return @"application/json"
			
		Case ContentTypes.ApplicationSoapxml
			Return @"application/soap+xml"
			
		Case ContentTypes.ApplicationXmldtd
			Return @"application/xml-dtd"
			
		Case ContentTypes.Application7z
			Return @"application/x-7z-compressed"
			
		Case ContentTypes.ApplicationRar
			Return @"application/x-rar-compressed"
			
		Case ContentTypes.ApplicationZip
			Return @"application/zip"
			
		Case ContentTypes.ApplicationGzip
			Return @"application/x-gzip"
			
		Case ContentTypes.ApplicationXCompressed
			Return @"application/x-compressed"
			
		Case ContentTypes.ApplicationRtf
			Return @"application/rtf"
			
		Case ContentTypes.ApplicationPdf
			Return @"application/pdf"
			
		Case ContentTypes.ApplicationOpenDocumentText
			Return @"application/vnd.oasis.opendocument.text"
			
		Case ContentTypes.ApplicationOpenDocumentTextTemplate
			Return @"application/vnd.oasis.opendocument.text-template"
			
		Case ContentTypes.ApplicationOpenDocumentGraphics
			Return @"application/vnd.oasis.opendocument.graphics"
			
		Case ContentTypes.ApplicationOpenDocumentGraphicsTemplate
			Return @"application/vnd.oasis.opendocument.graphics-template"
			
		Case ContentTypes.ApplicationOpenDocumentPresentation
			Return @"application/vnd.oasis.opendocument.presentation"
			
		Case ContentTypes.ApplicationOpenDocumentPresentationTemplate
			Return @"application/vnd.oasis.opendocument.presentation-template"
			
		Case ContentTypes.ApplicationOpenDocumentSpreadsheet
			Return @"application/vnd.oasis.opendocument.spreadsheet"
			
		Case ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
			Return @"application/vnd.oasis.opendocument.spreadsheet-template"
			
		Case ContentTypes.ApplicationOpenDocumentChart
			Return @"application/vnd.oasis.opendocument.chart"
			
		Case ContentTypes.ApplicationOpenDocumentChartTemplate
			Return @"application/vnd.oasis.opendocument.chart-template"
			
		Case ContentTypes.ApplicationOpenDocumentImage
			Return @"application/vnd.oasis.opendocument.image"
			
		Case ContentTypes.ApplicationOpenDocumentImageTemplate
			Return @"application/vnd.oasis.opendocument.image-template"
			
		Case ContentTypes.ApplicationOpenDocumentFormula
			Return @"application/vnd.oasis.opendocument.formula"
			
		Case ContentTypes.ApplicationOpenDocumentFormulaTemplate
			Return @"application/vnd.oasis.opendocument.formula-template"
			
		Case ContentTypes.ApplicationOpenDocumentMaster
			Return @"application/vnd.oasis.opendocument.text-master"
			
		Case ContentTypes.ApplicationOpenDocumentWeb
			Return @"application/vnd.oasis.opendocument.text-web"
			
		Case ContentTypes.ApplicationVndmsexcel
			Return @"application/vnd.ms-excel"
			
		Case ContentTypes.ApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet
			Return @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
			
		Case ContentTypes.ApplicationVndmspowerpoint
			Return @"application/vnd.ms-powerpoint"
			
		Case ContentTypes.ApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation
			Return @"application/vnd.openxmlformats-officedocument.presentationml.presentation"
			
		Case ContentTypes.ApplicationMsword
			Return @"application/msword"
			
		Case ContentTypes.ApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument
			Return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document"
			
		Case ContentTypes.ApplicationFontwoff
			Return @"application/font-woff"
			
		Case ContentTypes.ApplicationXfontttf
			Return @"application/x-font-ttf"
			
		Case ContentTypes.AudioBasic
			Return @"audio/basic"
			
		Case ContentTypes.AudioL24
			Return @"audio/L24"
			
		Case ContentTypes.AudioMp4
			Return @"audio/mp4"
			
		Case ContentTypes.AudioAac
			Return @"audio/aac"
			
		Case ContentTypes.AudioMpeg
			Return @"audio/mpeg"
			
		Case ContentTypes.AudioOgg
			Return @"audio/ogg"
			
		Case ContentTypes.AudioVorbis
			Return @"audio/vorbis"
			
		Case ContentTypes.AudioXmswma
			Return @"audio/x-ms-wma"
			
		Case ContentTypes.AudioXmswax
			Return @"audio/x-ms-wax"
			
		Case ContentTypes.AudioRealaudio
			Return @"audio/vnd.rn-realaudio"
			
		Case ContentTypes.AudioVndwave
			Return @"audio/vnd.wave"
			
		Case ContentTypes.AudioWebm
			Return @"audio/webm"
			
		Case ContentTypes.MessageHttp
			Return @"message/http"
			
		Case ContentTypes.MessageImdnxml
			Return @"message/imdn+xml"
			
		Case ContentTypes.MessagePartial
			Return @"message/partial"
			
		Case ContentTypes.MessageRfc822
			Return @"message/rfc822"
			
		Case ContentTypes.VideoMpeg
			Return @"video/mpeg"
			
		Case ContentTypes.VideoOgg
			Return @"video/ogg"
			
		Case ContentTypes.VideoMp4
			Return @"video/mp4"
			
		Case ContentTypes.VideoQuicktime
			Return @"video/quicktime"
			
		Case ContentTypes.VideoWebm
			Return @"video/webm"
			
		Case ContentTypes.VideoXmswmv
			Return @"video/x-ms-wmv"
			
		Case ContentTypes.VideoXflv
			Return @"video/x-flv"
			
		Case ContentTypes.Video3gpp
			Return @"video/3gpp"
			
		Case ContentTypes.Video3gpp2
			Return @"video/3gpp2"
			
		Case ContentTypes.MultipartMixed
			Return @"multipart/mixed"
			
		Case ContentTypes.MultipartAlternative
			Return @"multipart/alternative"
			
		Case ContentTypes.MultipartRelated
			Return @"multipart/related"
			
		Case ContentTypes.MultipartFormdata
			Return @"multipart/form-data"
			
		Case ContentTypes.MultipartSigned
			Return @"multipart/signed"
			
		Case ContentTypes.MultipartEncrypted
			Return @"multipart/encrypted"
			
		Case ContentTypes.ApplicationXwwwformurlencoded
			Return @"application/x-www-form-urlencoded"
			
		Case ContentTypes.ApplicationOctetStream
			Return @"application/octet-stream"
			
		Case ContentTypes.ApplicationXbittorrent
			Return @"application/x-bittorrent"
			
		Case ContentTypes.ApplicationOgg
			Return @"application/ogg"
			
		Case ContentTypes.ApplicationFlash
			Return @"application/x-shockwave-flash"
			
		Case ContentTypes.ApplicationCertx509
			Return @"application/x-x509-ca-cert"
			
	End Select
	
	Return @"application/octet-stream"
End Function

Function GetMimeTypeOfExtension(ByVal ext As WString Ptr)As MimeType
	Dim mt As MimeType = Any
	mt.IsTextFormat = False
	
	' Для ускорения работы сперва проверить самые распространённые расширения файлов
	
	If lstrcmpi(ext, @ExtensionHtm) = 0 Then
		mt.ContentType = ContentTypes.TextHtml
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionXhtml) = 0 Then
		mt.ContentType = ContentTypes.ApplicationXhtml
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionCss) = 0 Then
		mt.ContentType = ContentTypes.TextCss
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionPng) = 0 Then
		mt.ContentType = ContentTypes.ImagePng
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionGif) = 0 Then
		mt.ContentType = ContentTypes.ImageGif
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionJpg) = 0 Then
		mt.ContentType = ContentTypes.ImageJpeg
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionIco) = 0 Then
		mt.ContentType = ContentTypes.ImageIco
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionXml) = 0 Then
		mt.ContentType = ContentTypes.ApplicationXml
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionXsl) = 0 Then
		mt.ContentType = ContentTypes.ApplicationXmlXslt
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionXslt) = 0 Then
		mt.ContentType = ContentTypes.ApplicationXmlXslt
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionTxt) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionHeaders) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionRss) = 0 Then
		mt.ContentType = ContentTypes.ApplicationRssXml
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionJs) = 0 Then
		mt.ContentType = ContentTypes.ApplicationJavascript
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionZip) = 0 Then
		mt.ContentType = ContentTypes.ApplicationZip
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionHtml) = 0 Then
		mt.ContentType = ContentTypes.TextHtml
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionSvg) = 0 Then
		mt.ContentType = ContentTypes.ImageSvg
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionJpe) = 0 Then
		mt.ContentType = ContentTypes.ImageJpeg
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionJpeg) = 0 Then
		mt.ContentType = ContentTypes.ImageJpeg
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionTif) = 0 Then
		mt.ContentType = ContentTypes.ImageTiff
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionTiff) = 0 Then
		mt.ContentType = ContentTypes.ImageTiff
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionAtom) = 0 Then
		mt.ContentType = ContentTypes.ApplicationAtom
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @Extension7z) = 0 Then
		mt.ContentType = ContentTypes.Application7z
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionRar) = 0 Then
		mt.ContentType = ContentTypes.ApplicationRar
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionGz) = 0 Then
		mt.ContentType = ContentTypes.ApplicationGzip
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionTgz) = 0 Then
		mt.ContentType = ContentTypes.ApplicationXCompressed
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionRtf) = 0 Then
		mt.ContentType = ContentTypes.ApplicationRtf
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionMpg) = 0 Then
		mt.ContentType = ContentTypes.VideoMpeg
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionMpeg) = 0 Then
		mt.ContentType = ContentTypes.VideoMpeg
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOgv) = 0 Then
		mt.ContentType = ContentTypes.VideoOgg
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionMp4) = 0 Then
		mt.ContentType = ContentTypes.VideoMp4
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionWebm) = 0 Then
		mt.ContentType = ContentTypes.VideoWebm
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionBin) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionExe) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionDll) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionDeb) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionDmg) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionEot) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionIso) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionImg) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionMsi) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionMsp) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionMsm) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOctetStream
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionSwf) = 0 Then
		mt.ContentType = ContentTypes.ApplicationFlash
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionRam) = 0 Then
		mt.ContentType = ContentTypes.AudioRealaudio
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionCrt) = 0 Then
		mt.ContentType = ContentTypes.ApplicationCertx509
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionCer) = 0 Then
		mt.ContentType = ContentTypes.ApplicationCertx509
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionPdf) = 0 Then
		mt.ContentType = ContentTypes.ApplicationPdf
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdt) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentText
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOtt) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentTextTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdg) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentGraphics
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOtg) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentGraphicsTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdp) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentPresentation
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOtp) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentPresentationTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOds) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheet
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOts) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdc) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentChart
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOtc) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentChartTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdi) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentImage
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOti) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentImageTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdf) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentFormula
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOtf) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentFormulaTemplate
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOdm) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentMaster
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionOth) = 0 Then
		mt.ContentType = ContentTypes.ApplicationOpenDocumentWeb
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionBas) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionBi) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionVb) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionRc) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionAsm) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	If lstrcmpi(ext, @ExtensionIni) = 0 Then
		mt.ContentType = ContentTypes.TextPlain
		mt.IsTextFormat = True
		Return mt
	End If
	
	mt.ContentType = ContentTypes.None
	Return mt
End Function
