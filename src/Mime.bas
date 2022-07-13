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
		
		Case DocumentCharsets.Utf8BOM
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
	
	If lstrcmpiW(ext, @ExtensionHtm) = 0 Then
		mt->ContentType = ContentTypes.TextHtml
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionXhtml) = 0 Then
		mt->ContentType = ContentTypes.ApplicationXhtml
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionCss) = 0 Then
		mt->ContentType = ContentTypes.TextCss
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionPng) = 0 Then
		mt->ContentType = ContentTypes.ImagePng
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionGif) = 0 Then
		mt->ContentType = ContentTypes.ImageGif
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionJpg) = 0 Then
		mt->ContentType = ContentTypes.ImageJpeg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionIco) = 0 Then
		mt->ContentType = ContentTypes.ImageIco
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionXml) = 0 Then
		mt->ContentType = ContentTypes.ApplicationXml
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionXsl) = 0 Then
		mt->ContentType = ContentTypes.ApplicationXmlXslt
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionXslt) = 0 Then
		mt->ContentType = ContentTypes.ApplicationXmlXslt
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionTxt) = 0 Then
		mt->ContentType = ContentTypes.TextPlain
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionRss) = 0 Then
		mt->ContentType = ContentTypes.ApplicationRssXml
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionJs) = 0 Then
		mt->ContentType = ContentTypes.ApplicationJavascript
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionZip) = 0 Then
		mt->ContentType = ContentTypes.ApplicationZip
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionHtml) = 0 Then
		mt->ContentType = ContentTypes.TextHtml
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionSvg) = 0 Then
		mt->ContentType = ContentTypes.ImageSvg
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionJpe) = 0 Then
		mt->ContentType = ContentTypes.ImageJpeg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionJpeg) = 0 Then
		mt->ContentType = ContentTypes.ImageJpeg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionTif) = 0 Then
		mt->ContentType = ContentTypes.ImageTiff
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionTiff) = 0 Then
		mt->ContentType = ContentTypes.ImageTiff
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionAtom) = 0 Then
		mt->ContentType = ContentTypes.ApplicationAtom
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @Extension7z) = 0 Then
		mt->ContentType = ContentTypes.Application7z
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionRar) = 0 Then
		mt->ContentType = ContentTypes.ApplicationRar
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionGz) = 0 Then
		mt->ContentType = ContentTypes.ApplicationGzip
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionTgz) = 0 Then
		mt->ContentType = ContentTypes.ApplicationXCompressed
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionRtf) = 0 Then
		mt->ContentType = ContentTypes.ApplicationRtf
		mt->IsTextFormat = True
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMp3) = 0 Then
		mt->ContentType = ContentTypes.AudioMpeg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMpg) = 0 Then
		mt->ContentType = ContentTypes.VideoMpeg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMpeg) = 0 Then
		mt->ContentType = ContentTypes.VideoMpeg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMkv) = 0 Then
		mt->ContentType = ContentTypes.VideoXMatroska
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionAvi) = 0 Then
		mt->ContentType = ContentTypes.VideoXMsvideo
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOgv) = 0 Then
		mt->ContentType = ContentTypes.VideoOgg
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMp4) = 0 Then
		mt->ContentType = ContentTypes.VideoMp4
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionWebm) = 0 Then
		mt->ContentType = ContentTypes.VideoWebm
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionWmv) = 0 Then
		mt->ContentType = ContentTypes.VideoXmswmv
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionBin) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionExe) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionDll) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionDeb) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionDmg) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionEot) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionIso) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionImg) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMsi) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMsp) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionMsm) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionSwf) = 0 Then
		mt->ContentType = ContentTypes.ApplicationFlash
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionRam) = 0 Then
		mt->ContentType = ContentTypes.AudioRealaudio
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionCrt) = 0 Then
		mt->ContentType = ContentTypes.ApplicationCertx509
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionCer) = 0 Then
		mt->ContentType = ContentTypes.ApplicationCertx509
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionPdf) = 0 Then
		mt->ContentType = ContentTypes.ApplicationPdf
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdt) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentText
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOtt) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentTextTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdg) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphics
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOtg) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphicsTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdp) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentation
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOtp) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentationTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOds) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheet
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOts) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdc) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentChart
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOtc) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentChartTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdi) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentImage
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOti) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentImageTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdf) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentFormula
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOtf) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentFormulaTemplate
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOdm) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentMaster
		Return True
	End If
	
	If lstrcmpiW(ext, @ExtensionOth) = 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentWeb
		Return True
	End If
	
	Return False
End Function

Function GetMimeOfStringContentType( _
		ByVal mt As MimeType Ptr, _
		ByVal ContentType As WString Ptr _
	)As Boolean
	
	mt->IsTextFormat = False
	
	If StrStrIW(ContentType, @ContentCharsetUtf8) <> 0 Then
		mt->Charset = DocumentCharsets.Utf8BOM
	Else
		If StrStrIW(ContentType, @ContentCharsetUtf16LE) <> 0 Then
			mt->Charset = DocumentCharsets.Utf16LE
		Else
			If StrStrIW(ContentType, @ContentCharsetUtf16BE) <> 0 Then
				mt->Charset = DocumentCharsets.Utf16BE
			Else
				mt->Charset = DocumentCharsets.ASCII
			End If
		End If
	End If
	
	If StrStrIW(ContentType, @ContentTypesAnyAny) <> 0 Then
		mt->ContentType = ContentTypes.AnyAny
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationAny) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationAny
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplication7z) <> 0 Then
		mt->ContentType = ContentTypes.Application7z
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationAtom) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationAtom
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationCertx509) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationCertx509
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationFlash) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationFlash
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationFontwoff) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationFontwoff
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationGzip) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationGzip
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationJavascript) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationJavascript
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationJson) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationJson
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationMsword) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationMsword
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOctetStream) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOctetStream
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOgg) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOgg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentChart) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentChart
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentChartTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentChartTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentFormula) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentFormula
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentFormulaTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentFormulaTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentGraphics) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphics
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentGraphicsTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentGraphicsTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentImage) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentImage
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentImageTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentImageTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentMaster) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentMaster
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentPresentation) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentation
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentPresentationTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentPresentationTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentSpreadsheet) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheet
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentSpreadsheetTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentText) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentText
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentTextTemplate) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentTextTemplate
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationOpenDocumentWeb) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationOpenDocumentWeb
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationPdf) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationPdf
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationRar) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationRar
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationRssXml) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationRssXml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationRtf) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationRtf
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationSoapxml) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationSoapxml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationVndmsexcel) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationVndmsexcel
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationVndmspowerpoint) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationVndmspowerpoint
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXbittorrent) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXbittorrent
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXCompressed) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXCompressed
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXfontttf) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXfontttf
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXhtml) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXhtml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXJavascript) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXJavascript
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXml) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXmldtd) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXmldtd
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXmlXslt) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXmlXslt
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationXwwwformurlencoded) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationXwwwformurlencoded
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesApplicationZip) <> 0 Then
		mt->ContentType = ContentTypes.ApplicationZip
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioAny) <> 0 Then
		mt->ContentType = ContentTypes.AudioAny
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioAac) <> 0 Then
		mt->ContentType = ContentTypes.AudioAac
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioBasic) <> 0 Then
		mt->ContentType = ContentTypes.AudioBasic
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioBasic) <> 0 Then
		mt->ContentType = ContentTypes.AudioBasic
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioL24) <> 0 Then
		mt->ContentType = ContentTypes.AudioL24
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioMp4) <> 0 Then
		mt->ContentType = ContentTypes.AudioMp4
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioMpeg) <> 0 Then
		mt->ContentType = ContentTypes.AudioMpeg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioOgg) <> 0 Then
		mt->ContentType = ContentTypes.AudioOgg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioRealaudio) <> 0 Then
		mt->ContentType = ContentTypes.AudioRealaudio
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioVndwave) <> 0 Then
		mt->ContentType = ContentTypes.AudioVndwave
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioVorbis) <> 0 Then
		mt->ContentType = ContentTypes.AudioVorbis
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioWebm) <> 0 Then
		mt->ContentType = ContentTypes.AudioWebm
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioXmswma) <> 0 Then
		mt->ContentType = ContentTypes.AudioXmswma
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesAudioXmswax) <> 0 Then
		mt->ContentType = ContentTypes.AudioXmswax
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageAny) <> 0 Then
		mt->ContentType = ContentTypes.ImageAny
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageGif) <> 0 Then
		mt->ContentType = ContentTypes.ImageGif
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageIco) <> 0 Then
		mt->ContentType = ContentTypes.ImageIco
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageJpeg) <> 0 Then
		mt->ContentType = ContentTypes.ImageJpeg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImagePJpeg) <> 0 Then
		mt->ContentType = ContentTypes.ImagePjpeg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImagePng) <> 0 Then
		mt->ContentType = ContentTypes.ImagePng
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageSvg) <> 0 Then
		mt->ContentType = ContentTypes.ImageSvg
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageTiff) <> 0 Then
		mt->ContentType = ContentTypes.ImageTiff
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageWbmp) <> 0 Then
		mt->ContentType = ContentTypes.ImageWbmp
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesImageWebp) <> 0 Then
		mt->ContentType = ContentTypes.ImageWebp
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMessageAny) <> 0 Then
		mt->ContentType = ContentTypes.MessageAny
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMessageHttp) <> 0 Then
		mt->ContentType = ContentTypes.MessageHttp
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMessageImdnxml) <> 0 Then
		mt->ContentType = ContentTypes.MessageImdnxml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMessagePartial) <> 0 Then
		mt->ContentType = ContentTypes.MessagePartial
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMessageRfc822) <> 0 Then
		mt->ContentType = ContentTypes.MessageRfc822
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartAny) <> 0 Then
		mt->ContentType = ContentTypes.MultipartAny
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartAlternative) <> 0 Then
		mt->ContentType = ContentTypes.MultipartAlternative
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartEncrypted) <> 0 Then
		mt->ContentType = ContentTypes.MultipartEncrypted
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartFormdata) <> 0 Then
		mt->ContentType = ContentTypes.MultipartFormdata
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartMixed) <> 0 Then
		mt->ContentType = ContentTypes.MultipartMixed
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartRelated) <> 0 Then
		mt->ContentType = ContentTypes.MultipartRelated
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesMultipartSigned) <> 0 Then
		mt->ContentType = ContentTypes.MultipartSigned
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextAny) <> 0 Then
		mt->ContentType = ContentTypes.TextAny
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextCmd) <> 0 Then
		mt->ContentType = ContentTypes.TextCmd
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextCss) <> 0 Then
		mt->ContentType = ContentTypes.TextCss
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextCsv) <> 0 Then
		mt->ContentType = ContentTypes.TextCsv
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextHtml) <> 0 Then
		mt->ContentType = ContentTypes.TextHtml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextPlain) <> 0 Then
		mt->ContentType = ContentTypes.TextPlain
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextPhp) <> 0 Then
		mt->ContentType = ContentTypes.TextPhp
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesTextXml) <> 0 Then
		mt->ContentType = ContentTypes.TextXml
		mt->IsTextFormat = True
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoAny) <> 0 Then
		mt->ContentType = ContentTypes.VideoAny
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideo3gpp) <> 0 Then
		mt->ContentType = ContentTypes.Video3gpp
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideo3gpp2) <> 0 Then
		mt->ContentType = ContentTypes.Video3gpp2
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoQuicktime) <> 0 Then
		mt->ContentType = ContentTypes.VideoQuicktime
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoMp4) <> 0 Then
		mt->ContentType = ContentTypes.VideoMp4
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoMpeg) <> 0 Then
		mt->ContentType = ContentTypes.VideoMpeg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoOgg) <> 0 Then
		mt->ContentType = ContentTypes.VideoOgg
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoXflv) <> 0 Then
		mt->ContentType = ContentTypes.VideoXflv
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoWebm) <> 0 Then
		mt->ContentType = ContentTypes.VideoWebm
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoXMatroska) <> 0 Then
		mt->ContentType = ContentTypes.VideoXMatroska
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoXMsvideo) <> 0 Then
		mt->ContentType = ContentTypes.VideoXMsvideo
		Return True
	End If
	
	If StrStrIW(ContentType, @ContentTypesVideoXmswmv) <> 0 Then
		mt->ContentType = ContentTypes.VideoXmswmv
		Return True
	End If
	
	Return False
	
End Function
