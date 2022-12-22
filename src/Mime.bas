#include once "Mime.bi"
#include once "windows.bi"
#include once "win\shlwapi.bi"

Const ParamSeparator = WStr(";")
Const ContentCharsetUtf8 = WStr("charset=utf-8")
Const ContentCharsetUtf16LE = WStr("charset=utf-16")
Const ContentCharsetUtf16BE = WStr("charset=utf-16")

Const ExtensionZip = WStr(".zip")
Const Extension7z = WStr(".7z")
Const ExtensionRar = WStr(".rar")
Const ExtensionGz = WStr(".gz")
Const ExtensionTgz = WStr(".tgz")
Const ExtensionBin = WStr(".bin")
Const ExtensionExe = WStr(".exe")
Const ExtensionDll = WStr(".dll")
Const ExtensionDeb = WStr(".deb")
Const ExtensionDmg = WStr(".dmg")
Const ExtensionEot = WStr(".eot")
Const ExtensionIso = WStr(".iso")
Const ExtensionImg = WStr(".img")
Const ExtensionMsi = WStr(".msi")
Const ExtensionMsp = WStr(".msp")
Const ExtensionMsm = WStr(".msm")
Const ExtensionCrt = WStr(".crt")
Const ExtensionCer = WStr(".cer")
Const ExtensionRtf = WStr(".rtf")
Const ExtensionPdf = WStr(".pdf")
Const ExtensionOdt = WStr(".odt")
Const ExtensionOtt = WStr(".ott")
Const ExtensionOdg = WStr(".odg")
Const ExtensionOtg = WStr(".otg")
Const ExtensionOdp = WStr(".odp")
Const ExtensionOtp = WStr(".otp")
Const ExtensionOds = WStr(".ods")
Const ExtensionOts = WStr(".ots")
Const ExtensionOdc = WStr(".odc")
Const ExtensionOtc = WStr(".otc")
Const ExtensionOdi = WStr(".odi")
Const ExtensionOti = WStr(".oti")
Const ExtensionOdf = WStr(".odf")
Const ExtensionOtf = WStr(".otf")
Const ExtensionOdm = WStr(".odm")
Const ExtensionOth = WStr(".oth")

Const ExtensionAvi = WStr(".avi")
Const ExtensionMpg = WStr(".mpg")
Const ExtensionMpeg = WStr(".mpeg")
Const ExtensionMkv = WStr(".mkv")
Const ExtensionOgv = WStr(".ogv")
Const ExtensionMp4 = WStr(".mp4")
Const ExtensionWebm = WStr(".webm")
Const ExtensionSwf = WStr(".swf")
Const ExtensionRam = WStr(".ram")
Const ExtensionMp3 = WStr(".mp3")
Const ExtensionWmv = WStr(".wmv")

Const ExtensionPng = WStr(".png")
Const ExtensionGif = WStr(".gif")
Const ExtensionIco = WStr(".ico")
Const ExtensionJpg = WStr(".jpg")
Const ExtensionJpe = WStr(".jpe")
Const ExtensionJpeg = WStr(".jpeg")
Const ExtensionTif = WStr(".tif")
Const ExtensionTiff = WStr(".tiff")
Const ExtensionSvg = WStr(".svg")

Const ExtensionHtm = WStr(".htm")
Const ExtensionHtml = WStr(".html")
Const ExtensionXhtml = WStr(".xhtml")
Const ExtensionCss = WStr(".css")
Const ExtensionTxt = WStr(".txt")
Const ExtensionXml = WStr(".xml")
Const ExtensionXsl = WStr(".xsl")
Const ExtensionXslt = WStr(".xslt")
Const ExtensionRss = WStr(".rss")
Const ExtensionAtom = WStr(".atom")
Const ExtensionJs = WStr(".js")
Const ExtensionWasm = WStr(".wasm")

Const ContentTypesAnyAny = WStr("*/*")

Const ContentTypesApplicationAny = WStr("application/*")
Const ContentTypesApplicationOctetStream = WStr("application/octet-stream")
Const ContentTypesApplicationXml = WStr("application/xml")
Const ContentTypesApplicationXmlXslt = WStr("application/xml+xslt")
Const ContentTypesApplicationXhtml = WStr("application/xhtml+xml")
Const ContentTypesApplicationAtom = WStr("application/atom+xml")
Const ContentTypesApplicationRssXml = WStr("application/rss+xml")
Const ContentTypesApplicationJavascript = WStr("application/javascript")
Const ContentTypesApplicationXJavascript = WStr("application/x-javascript")
Const ContentTypesApplicationJson = WStr("application/json")
Const ContentTypesApplicationSoapxml = WStr("application/soap+xml")
Const ContentTypesApplicationXmldtd = WStr("application/xml-dtd")
Const ContentTypesApplication7z = WStr("application/x-7z-compressed")
Const ContentTypesApplicationRar = WStr("application/x-rar-compressed")
Const ContentTypesApplicationZip = WStr("application/zip")
Const ContentTypesApplicationGzip = WStr("application/x-gzip")
Const ContentTypesApplicationXCompressed = WStr("application/x-compressed")
Const ContentTypesApplicationRtf = WStr("application/rtf")
Const ContentTypesApplicationPdf = WStr("application/pdf")
Const ContentTypesApplicationOpenDocumentText = WStr("application/vnd.oasis.opendocument.text")
Const ContentTypesApplicationOpenDocumentTextTemplate = WStr("application/vnd.oasis.opendocument.text-template")
Const ContentTypesApplicationOpenDocumentGraphics = WStr("application/vnd.oasis.opendocument.graphics")
Const ContentTypesApplicationOpenDocumentGraphicsTemplate = WStr("application/vnd.oasis.opendocument.graphics-template")
Const ContentTypesApplicationOpenDocumentPresentation = WStr("application/vnd.oasis.opendocument.presentation")
Const ContentTypesApplicationOpenDocumentPresentationTemplate = WStr("application/vnd.oasis.opendocument.presentation-template")
Const ContentTypesApplicationOpenDocumentSpreadsheet = WStr("application/vnd.oasis.opendocument.spreadsheet")
Const ContentTypesApplicationOpenDocumentSpreadsheetTemplate = WStr("application/vnd.oasis.opendocument.spreadsheet-template")
Const ContentTypesApplicationOpenDocumentChart = WStr("application/vnd.oasis.opendocument.chart")
Const ContentTypesApplicationOpenDocumentChartTemplate = WStr("application/vnd.oasis.opendocument.chart-template")
Const ContentTypesApplicationOpenDocumentImage = WStr("application/vnd.oasis.opendocument.image")
Const ContentTypesApplicationOpenDocumentImageTemplate = WStr("application/vnd.oasis.opendocument.image-template")
Const ContentTypesApplicationOpenDocumentFormula = WStr("application/vnd.oasis.opendocument.formula")
Const ContentTypesApplicationOpenDocumentFormulaTemplate = WStr("application/vnd.oasis.opendocument.formula-template")
Const ContentTypesApplicationOpenDocumentMaster = WStr("application/vnd.oasis.opendocument.text-master")
Const ContentTypesApplicationOpenDocumentWeb = WStr("application/vnd.oasis.opendocument.text-web")
Const ContentTypesApplicationVndmsexcel = WStr("application/vnd.ms-excel")
Const ContentTypesApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet = WStr("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
Const ContentTypesApplicationVndmspowerpoint = WStr("application/vnd.ms-powerpoint")
Const ContentTypesApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation = WStr("application/vnd.openxmlformats-officedocument.presentationml.presentation")
Const ContentTypesApplicationMsword = WStr("application/msword")
Const ContentTypesApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument = WStr("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
Const ContentTypesApplicationFontwoff = WStr("application/font-woff")
Const ContentTypesApplicationXfontttf = WStr("application/x-font-ttf")
Const ContentTypesApplicationXwwwformurlencoded = WStr("application/x-www-form-urlencoded")
Const ContentTypesApplicationXbittorrent = WStr("application/x-bittorrent")
Const ContentTypesApplicationOgg = WStr("application/ogg")
Const ContentTypesApplicationFlash = WStr("application/x-shockwave-flash")
Const ContentTypesApplicationCertx509 = WStr("application/x-x509-ca-cert")
Const ContentTypesApplicationWasm = WStr("application/wasm")

Const ContentTypesAudioAny = WStr("audio/*")
Const ContentTypesAudioBasic = WStr("audio/basic")
Const ContentTypesAudioL24 = WStr("audio/L24")
Const ContentTypesAudioMp4 = WStr("audio/mp4")
Const ContentTypesAudioAac = WStr("audio/aac")
Const ContentTypesAudioMpeg = WStr("audio/mpeg")
Const ContentTypesAudioOgg = WStr("audio/ogg")
Const ContentTypesAudioVorbis = WStr("audio/vorbis")
Const ContentTypesAudioXmswma = WStr("audio/x-ms-wma")
Const ContentTypesAudioXmswax = WStr("audio/x-ms-wax")
Const ContentTypesAudioRealaudio = WStr("audio/vnd.rn-realaudio")
Const ContentTypesAudioVndwave = WStr("audio/vnd.wave")
Const ContentTypesAudioWebm = WStr("audio/webm")

Const ContentTypesImageAny = WStr("image/*")
Const ContentTypesImageGif = WStr("image/gif")
Const ContentTypesImageJpeg = WStr("image/jpeg")
Const ContentTypesImagePJpeg = WStr("image/pjpeg")
Const ContentTypesImagePng = WStr("image/png")
Const ContentTypesImageSvg = WStr("image/svg+xml")
Const ContentTypesImageTiff = WStr("image/tiff")
' Const ContentTypesImageIco = WStr("image/vnd.microsoft.icon")
Const ContentTypesImageIco = WStr("image/x-icon")
Const ContentTypesImageWbmp = WStr("image/vnd.wap.wbmp")
Const ContentTypesImageWebp = WStr("image/webp")

Const ContentTypesMessageAny = WStr("message/*")
Const ContentTypesMessageHttp = WStr("message/http")
Const ContentTypesMessageImdnxml = WStr("message/imdn+xml")
Const ContentTypesMessagePartial = WStr("message/partial")
Const ContentTypesMessageRfc822 = WStr("message/rfc822")

Const ContentTypesMultipartAny = WStr("multipart/*")
Const ContentTypesMultipartMixed = WStr("multipart/mixed")
Const ContentTypesMultipartAlternative = WStr("multipart/alternative")
Const ContentTypesMultipartRelated = WStr("multipart/related")
Const ContentTypesMultipartFormdata = WStr("multipart/form-data")
Const ContentTypesMultipartSigned = WStr("multipart/signed")
Const ContentTypesMultipartEncrypted = WStr("multipart/encrypted")

Const ContentTypesTextAny = WStr("text/*")
Const ContentTypesTextCmd = WStr("text/cmd")
Const ContentTypesTextCss = WStr("text/css")
Const ContentTypesTextCsv = WStr("text/csv")
Const ContentTypesTextHtml = WStr("text/html")
Const ContentTypesTextPlain = WStr("text/plain")
Const ContentTypesTextPhp = WStr("text/php")
Const ContentTypesTextXml = WStr("text/xml")

Const ContentTypesVideoAny = WStr("video/*")
Const ContentTypesVideoMpeg = WStr("video/mpeg")
Const ContentTypesVideoOgg = WStr("video/ogg")
Const ContentTypesVideoMp4 = WStr("video/mp4")
Const ContentTypesVideoQuicktime = WStr("video/quicktime")
Const ContentTypesVideoWebm = WStr("video/webm")
Const ContentTypesVideoXMatroska = WStr("video/x-matroska")
Const ContentTypesVideoXMsvideo = WStr("video/x-msvideo")
Const ContentTypesVideoXmswmv = WStr("video/x-ms-wmv")
Const ContentTypesVideoXflv = WStr("video/x-flv")
Const ContentTypesVideo3gpp = WStr("video/3gpp")
Const ContentTypesVideo3gpp2 = WStr("video/3gpp2")

Const CompareResultEqual As Long = 0

Sub GetContentTypeOfMimeType( _
		ByVal ContentType As WString Ptr, _
		ByVal mt As MimeType Ptr _
	)
	
	Select Case mt->ContentType
		
		Case ContentTypes.AnyAny
			lstrcpyW(ContentType, @ContentTypesAnyAny)
		
		Case ContentTypes.ImageAny
			lstrcpyW(ContentType, @ContentTypesImageAny)
			
		Case ContentTypes.ImageGif
			lstrcpyW(ContentType, @ContentTypesImageGif)
			
		Case ContentTypes.ImageJpeg
			lstrcpyW(ContentType, @ContentTypesImageJpeg)
			
		Case ContentTypes.ImagePjpeg
			lstrcpyW(ContentType, @ContentTypesImagePJpeg)
			
		Case ContentTypes.ImagePng
			lstrcpyW(ContentType, @ContentTypesImagePng)
			
		Case ContentTypes.ImageSvg
			lstrcpyW(ContentType, @ContentTypesImageSvg)
			
		Case ContentTypes.ImageTiff
			lstrcpyW(ContentType, @ContentTypesImageTiff)
			
		Case ContentTypes.ImageIco
			lstrcpyW(ContentType, @ContentTypesImageIco)
			
		Case ContentTypes.ImageWbmp
			lstrcpyW(ContentType, @ContentTypesImageWbmp)
			
		Case ContentTypes.ImageWebp
			lstrcpyW(ContentType, @ContentTypesImageWebp)
			
		Case ContentTypes.TextAny
			lstrcpyW(ContentType, @ContentTypesTextAny)
			
		Case ContentTypes.TextCmd
			lstrcpyW(ContentType, @ContentTypesTextCmd)
			
		Case ContentTypes.TextCss
			lstrcpyW(ContentType, @ContentTypesTextCss)
			
		Case ContentTypes.TextCsv
			lstrcpyW(ContentType, @ContentTypesTextCsv)
			
		Case ContentTypes.TextHtml
			lstrcpyW(ContentType, @ContentTypesTextHtml)
			
		Case ContentTypes.TextPlain
			lstrcpyW(ContentType, @ContentTypesTextPlain)
			
		Case ContentTypes.TextPhp
			lstrcpyW(ContentType, @ContentTypesTextPhp)
			
		Case ContentTypes.TextXml
			lstrcpyW(ContentType, @ContentTypesTextXml)
			
		Case ContentTypes.ApplicationAny
			lstrcpyW(ContentType, @ContentTypesApplicationAny)
			
		Case ContentTypes.ApplicationXml
			lstrcpyW(ContentType, @ContentTypesApplicationXml)
			
		Case ContentTypes.ApplicationXmlXslt
			lstrcpyW(ContentType, @ContentTypesApplicationXmlXslt)
			
		Case ContentTypes.ApplicationXhtml
			lstrcpyW(ContentType, @ContentTypesApplicationXhtml)
			
		Case ContentTypes.ApplicationAtom
			lstrcpyW(ContentType, @ContentTypesApplicationAtom)
			
		Case ContentTypes.ApplicationRssXml
			lstrcpyW(ContentType, @ContentTypesApplicationRssXml)
			
		Case ContentTypes.ApplicationJavascript
			lstrcpyW(ContentType, @ContentTypesApplicationJavascript)
			
		Case ContentTypes.ApplicationXJavascript
			lstrcpyW(ContentType, @ContentTypesApplicationXJavascript)
			
		Case ContentTypes.ApplicationJson
			lstrcpyW(ContentType, @ContentTypesApplicationJson)
			
		Case ContentTypes.ApplicationSoapxml
			lstrcpyW(ContentType, @ContentTypesApplicationSoapxml)
			
		Case ContentTypes.ApplicationXmldtd
			lstrcpyW(ContentType, @ContentTypesApplicationXmldtd)
			
		Case ContentTypes.Application7z
			lstrcpyW(ContentType, @ContentTypesApplication7z)
			
		Case ContentTypes.ApplicationRar
			lstrcpyW(ContentType, @ContentTypesApplicationRar)
			
		Case ContentTypes.ApplicationZip
			lstrcpyW(ContentType, @ContentTypesApplicationZip)
			
		Case ContentTypes.ApplicationGzip
			lstrcpyW(ContentType, @ContentTypesApplicationGzip)
			
		Case ContentTypes.ApplicationXCompressed
			lstrcpyW(ContentType, @ContentTypesApplicationXCompressed)
			
		Case ContentTypes.ApplicationRtf
			lstrcpyW(ContentType, @ContentTypesApplicationRtf)
			
		Case ContentTypes.ApplicationPdf
			lstrcpyW(ContentType, @ContentTypesApplicationPdf)
			
		Case ContentTypes.ApplicationOpenDocumentText
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentText)
			
		Case ContentTypes.ApplicationOpenDocumentTextTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentTextTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentGraphics
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentGraphics)
			
		Case ContentTypes.ApplicationOpenDocumentGraphicsTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentGraphicsTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentPresentation
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentPresentation)
			
		Case ContentTypes.ApplicationOpenDocumentPresentationTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentPresentationTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentSpreadsheet
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentSpreadsheet)
			
		Case ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentSpreadsheetTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentChart
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentChart)
			
		Case ContentTypes.ApplicationOpenDocumentChartTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentChartTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentImage
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentImage)
			
		Case ContentTypes.ApplicationOpenDocumentImageTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentImageTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentFormula
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentFormula)
			
		Case ContentTypes.ApplicationOpenDocumentFormulaTemplate
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentFormulaTemplate)
			
		Case ContentTypes.ApplicationOpenDocumentMaster
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentMaster)
			
		Case ContentTypes.ApplicationOpenDocumentWeb
			lstrcpyW(ContentType, @ContentTypesApplicationOpenDocumentWeb)
			
		Case ContentTypes.ApplicationVndmsexcel
			lstrcpyW(ContentType, @ContentTypesApplicationVndmsexcel)
			
		Case ContentTypes.ApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet
			lstrcpyW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet)
			
		Case ContentTypes.ApplicationVndmspowerpoint
			lstrcpyW(ContentType, @ContentTypesApplicationVndmspowerpoint)
			
		Case ContentTypes.ApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation
			lstrcpyW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation)
			
		Case ContentTypes.ApplicationMsword
			lstrcpyW(ContentType, @ContentTypesApplicationMsword)
			
		Case ContentTypes.ApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument
			lstrcpyW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument)
			
		Case ContentTypes.ApplicationFontwoff
			lstrcpyW(ContentType, @ContentTypesApplicationFontwoff)
			
		Case ContentTypes.ApplicationXfontttf
			lstrcpyW(ContentType, @ContentTypesApplicationXfontttf)
			
		Case ContentTypes.ApplicationXwwwformurlencoded
			lstrcpyW(ContentType, @ContentTypesApplicationXwwwformurlencoded)
			
		Case ContentTypes.ApplicationOctetStream
			lstrcpyW(ContentType, @ContentTypesApplicationOctetStream)
			
		Case ContentTypes.ApplicationXbittorrent
			lstrcpyW(ContentType, @ContentTypesApplicationXbittorrent)
			
		Case ContentTypes.ApplicationOgg
			lstrcpyW(ContentType, @ContentTypesApplicationOgg)
			
		Case ContentTypes.ApplicationFlash
			lstrcpyW(ContentType, @ContentTypesApplicationFlash)
			
		Case ContentTypes.ApplicationCertx509
			lstrcpyW(ContentType, @ContentTypesApplicationCertx509)
			
		Case ContentTypes.ApplicationWasm
			lstrcpyW(ContentType, @ContentTypesApplicationWasm)
			
		Case ContentTypes.AudioAny
			lstrcpyW(ContentType, @ContentTypesAudioAny)
			
		Case ContentTypes.AudioBasic
			lstrcpyW(ContentType, @ContentTypesAudioBasic)
			
		Case ContentTypes.AudioL24
			lstrcpyW(ContentType, @ContentTypesAudioL24)
			
		Case ContentTypes.AudioMp4
			lstrcpyW(ContentType, @ContentTypesAudioMp4)
			
		Case ContentTypes.AudioAac
			lstrcpyW(ContentType, @ContentTypesAudioAac)
			
		Case ContentTypes.AudioMpeg
			lstrcpyW(ContentType, @ContentTypesAudioMpeg)
			
		Case ContentTypes.AudioOgg
			lstrcpyW(ContentType, @ContentTypesAudioOgg)
			
		Case ContentTypes.AudioVorbis
			lstrcpyW(ContentType, @ContentTypesAudioVorbis)
			
		Case ContentTypes.AudioXmswma
			lstrcpyW(ContentType, @ContentTypesAudioXmswma)
			
		Case ContentTypes.AudioXmswax
			lstrcpyW(ContentType, @ContentTypesAudioXmswax)
			
		Case ContentTypes.AudioRealaudio
			lstrcpyW(ContentType, @ContentTypesAudioRealaudio)
			
		Case ContentTypes.AudioVndwave
			lstrcpyW(ContentType, @ContentTypesAudioVndwave)
			
		Case ContentTypes.AudioWebm
			lstrcpyW(ContentType, @ContentTypesAudioWebm)
			
		Case ContentTypes.MessageAny
			lstrcpyW(ContentType, @ContentTypesMessageAny)
			
		Case ContentTypes.MessageHttp
			lstrcpyW(ContentType, @ContentTypesMessageHttp)
			
		Case ContentTypes.MessageImdnxml
			lstrcpyW(ContentType, @ContentTypesMessageImdnxml)
			
		Case ContentTypes.MessagePartial
			lstrcpyW(ContentType, @ContentTypesMessagePartial)
			
		Case ContentTypes.MessageRfc822
			lstrcpyW(ContentType, @ContentTypesMessageRfc822)
			
		Case ContentTypes.VideoAny
			lstrcpyW(ContentType, @ContentTypesVideoAny)
			
		Case ContentTypes.VideoMpeg
			lstrcpyW(ContentType, @ContentTypesVideoMpeg)
			
		Case ContentTypes.VideoOgg
			lstrcpyW(ContentType, @ContentTypesVideoOgg)
			
		Case ContentTypes.VideoMp4
			lstrcpyW(ContentType, @ContentTypesVideoMp4)
			
		Case ContentTypes.VideoQuicktime
			lstrcpyW(ContentType, @ContentTypesVideoQuicktime)
			
		Case ContentTypes.VideoWebm
			lstrcpyW(ContentType, @ContentTypesVideoWebm)
			
		Case ContentTypes.VideoXmswmv
			lstrcpyW(ContentType, @ContentTypesVideoXmswmv)
			
		Case ContentTypes.VideoXflv
			lstrcpyW(ContentType, @ContentTypesVideoXflv)
			
		Case ContentTypes.VideoXMatroska
			lstrcpyW(ContentType, @ContentTypesVideoXMatroska)
			
		Case ContentTypes.VideoXMsvideo
			lstrcpyW(ContentType, @ContentTypesVideoXMsvideo)
			
		Case ContentTypes.Video3gpp
			lstrcpyW(ContentType, @ContentTypesVideo3gpp)
			
		Case ContentTypes.Video3gpp2
			lstrcpyW(ContentType, @ContentTypesVideo3gpp2)
			
		Case ContentTypes.MultipartAny
			lstrcpyW(ContentType, @ContentTypesMultipartAny)
			
		Case ContentTypes.MultipartMixed
			lstrcpyW(ContentType, @ContentTypesMultipartMixed)
			
		Case ContentTypes.MultipartAlternative
			lstrcpyW(ContentType, @ContentTypesMultipartAlternative)
			
		Case ContentTypes.MultipartRelated
			lstrcpyW(ContentType, @ContentTypesMultipartRelated)
			
		Case ContentTypes.MultipartFormdata
			lstrcpyW(ContentType, @ContentTypesMultipartFormdata)
			
		Case ContentTypes.MultipartSigned
			lstrcpyW(ContentType, @ContentTypesMultipartSigned)
			
		Case ContentTypes.MultipartEncrypted
			lstrcpyW(ContentType, @ContentTypesMultipartEncrypted)
			
		Case Else
			lstrcpyW(ContentType, @ContentTypesApplicationOctetStream)
			
	End Select
	
	Select Case mt->Charset
		
		Case DocumentCharsets.Utf8
			lstrcatW(ContentType, @ParamSeparator)
			lstrcatW(ContentType, @ContentCharsetUtf8)
			
		Case DocumentCharsets.Utf16LE
			lstrcatW(ContentType, @ParamSeparator)
			lstrcatW(ContentType, @ContentCharsetUtf16LE)
			
		Case DocumentCharsets.Utf16BE
			lstrcatW(ContentType, @ParamSeparator)
			lstrcatW(ContentType, @ContentCharsetUtf16BE)
			
	End Select
	
End Sub

Function GetMimeOfFileExtension( _
		ByVal mt As MimeType Ptr, _
		ByVal ext As WString Ptr _
	)As Boolean
	
	mt->IsTextFormat = False
	mt->Charset = DocumentCharsets.ASCII
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionHtm)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.TextHtml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionXhtml)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationXhtml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionCss)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.TextCss
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionPng)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImagePng
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionGif)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageGif
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionJpg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageJpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionIco)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageIco
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionXml)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationXml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionXsl)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationXmlXslt
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionXslt)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationXmlXslt
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionTxt)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.TextPlain
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionRss)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationRssXml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionJs)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationJavascript
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionZip)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationZip
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionHtml)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.TextHtml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionSvg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageSvg
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionJpe)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageJpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionJpeg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageJpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionTif)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageTiff
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionTiff)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ImageTiff
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionAtom)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationAtom
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @Extension7z)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.Application7z
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionRar)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationRar
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionGz)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationGzip
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionTgz)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationXCompressed
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionRtf)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationRtf
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMp3)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.AudioMpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMpg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoMpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMpeg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoMpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMkv)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoXMatroska
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionAvi)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoXMsvideo
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOgv)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoOgg
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMp4)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoMp4
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionWebm)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoWebm
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionWmv)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.VideoXmswmv
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionBin)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionExe)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionDll)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionDeb)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionDmg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionEot)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionIso)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionImg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMsi)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMsp)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionMsm)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionSwf)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationFlash
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionRam)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.AudioRealaudio
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionCrt)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationCertx509
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionCer)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationCertx509
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionPdf)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationPdf
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdt)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentText
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOtt)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentTextTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphics
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOtg)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphicsTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdp)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentation
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOtp)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentationTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOds)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheet
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOts)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdc)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentChart
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOtc)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentChartTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdi)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentImage
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOti)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentImageTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdf)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentFormula
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOtf)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentFormulaTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOdm)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentMaster
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionOth)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentWeb
			Return True
		End If
	End Scope
	
	Scope
		Dim Compare As Long = lstrcmpiW(ext, @ExtensionWasm)
		If Compare = CompareResultEqual Then
			mt->ContentType = ContentTypes.ApplicationWasm
			Return True
		End If
	End Scope
	
	Return False
	
End Function

Function GetMimeOfStringContentType( _
		ByVal mt As MimeType Ptr, _
		ByVal ContentType As WString Ptr _
	)As Boolean
	
	mt->IsTextFormat = False
	
	Scope
		Dim pUtf8 As PCWSTR = StrStrIW(ContentType, @ContentCharsetUtf8)
		
		If pUtf8 Then
			mt->Charset = DocumentCharsets.Utf8
		Else
			Dim pUtf16LE As PCWSTR = StrStrIW(ContentType, @ContentCharsetUtf16LE)
			
			If pUtf16LE Then
				mt->Charset = DocumentCharsets.Utf16LE
			Else
				Dim pUtf16BE As PCWSTR = StrStrIW(ContentType, @ContentCharsetUtf16BE)
				
				If pUtf16BE Then
					mt->Charset = DocumentCharsets.Utf16BE
				Else
					mt->Charset = DocumentCharsets.ASCII
				End If
			End If
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAnyAny)
		If pFindString Then
			mt->ContentType = ContentTypes.AnyAny
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationAny)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationAny
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplication7z)
		If pFindString Then
			mt->ContentType = ContentTypes.Application7z
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationAtom)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationAtom
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationCertx509)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationCertx509
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationFlash)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationFlash
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationFontwoff)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationFontwoff
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationGzip)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationGzip
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationJavascript)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationJavascript
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationJson)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationJson
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationMsword)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationMsword
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOctetStream)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOgg)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOgg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentChart)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentChart
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentChartTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentChartTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentFormula)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentFormula
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentFormulaTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentFormulaTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentGraphics)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphics
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentGraphicsTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphicsTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentImage)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentImage
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentImageTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentImageTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentMaster)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentMaster
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentPresentation)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentation
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentPresentationTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentationTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentSpreadsheet)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheet
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentSpreadsheetTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentText)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentText
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentTextTemplate)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentTextTemplate
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentWeb)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationOpenDocumentWeb
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationPdf)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationPdf
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationRar)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationRar
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationRssXml)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationRssXml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationRtf)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationRtf
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationSoapxml)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationSoapxml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationVndmsexcel)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationVndmsexcel
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationVndmspowerpoint)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationVndmspowerpoint
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXbittorrent)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXbittorrent
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXCompressed)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXCompressed
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXfontttf)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXfontttf
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXhtml)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXhtml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXJavascript)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXJavascript
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXml)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXmldtd)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXmldtd
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXmlXslt)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXmlXslt
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationXwwwformurlencoded)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationXwwwformurlencoded
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationZip)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationZip
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesApplicationWasm)
		If pFindString Then
			mt->ContentType = ContentTypes.ApplicationWasm
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioAny)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioAny
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioAac)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioAac
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioBasic)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioBasic
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioBasic)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioBasic
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioL24)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioL24
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioMp4)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioMp4
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioMpeg)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioMpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioOgg)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioOgg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioRealaudio)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioRealaudio
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioVndwave)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioVndwave
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioVorbis)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioVorbis
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioWebm)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioWebm
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioXmswma)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioXmswma
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesAudioXmswax)
		If pFindString Then
			mt->ContentType = ContentTypes.AudioXmswax
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageAny)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageAny
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageGif)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageGif
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageIco)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageIco
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageJpeg)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageJpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImagePJpeg)
		If pFindString Then
			mt->ContentType = ContentTypes.ImagePjpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImagePng)
		If pFindString Then
			mt->ContentType = ContentTypes.ImagePng
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageSvg)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageSvg
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageTiff)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageTiff
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageWbmp)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageWbmp
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesImageWebp)
		If pFindString Then
			mt->ContentType = ContentTypes.ImageWebp
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMessageAny)
		If pFindString Then
			mt->ContentType = ContentTypes.MessageAny
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMessageHttp)
		If pFindString Then
			mt->ContentType = ContentTypes.MessageHttp
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMessageImdnxml)
		If pFindString Then
			mt->ContentType = ContentTypes.MessageImdnxml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMessagePartial)
		If pFindString Then
			mt->ContentType = ContentTypes.MessagePartial
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMessageRfc822)
		If pFindString Then
			mt->ContentType = ContentTypes.MessageRfc822
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartAny)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartAny
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartAlternative)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartAlternative
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartEncrypted)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartEncrypted
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartFormdata)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartFormdata
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartMixed)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartMixed
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartRelated)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartRelated
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesMultipartSigned)
		If pFindString Then
			mt->ContentType = ContentTypes.MultipartSigned
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextAny)
		If pFindString Then
			mt->ContentType = ContentTypes.TextAny
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextCmd)
		If pFindString Then
			mt->ContentType = ContentTypes.TextCmd
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextCss)
		If pFindString Then
			mt->ContentType = ContentTypes.TextCss
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextCsv)
		If pFindString Then
			mt->ContentType = ContentTypes.TextCsv
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextHtml)
		If pFindString Then
			mt->ContentType = ContentTypes.TextHtml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextPlain)
		If pFindString Then
			mt->ContentType = ContentTypes.TextPlain
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextPhp)
		If pFindString Then
			mt->ContentType = ContentTypes.TextPhp
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesTextXml)
		If pFindString Then
			mt->ContentType = ContentTypes.TextXml
			mt->IsTextFormat = True
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoAny)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoAny
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideo3gpp)
		If pFindString Then
			mt->ContentType = ContentTypes.Video3gpp
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideo3gpp2)
		If pFindString Then
			mt->ContentType = ContentTypes.Video3gpp2
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoQuicktime)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoQuicktime
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoMp4)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoMp4
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoMpeg)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoMpeg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoOgg)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoOgg
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoXflv)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoXflv
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoWebm)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoWebm
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoXMatroska)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoXMatroska
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoXMsvideo)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoXMsvideo
			Return True
		End If
	End Scope
	
	Scope
		Dim pFindString As PCWSTR = StrStrIW(ContentType, @ContentTypesVideoXmswmv)
		If pFindString Then
			mt->ContentType = ContentTypes.VideoXmswmv
			Return True
		End If
	End Scope
	
	Return False
	
End Function
