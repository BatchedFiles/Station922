#include once "Mime.bi"
#include once "windows.bi"
#include once "win\shlwapi.bi"

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
Const ExtensionWasm = WStr(".wasm")

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
Const ExtensionBmp = WStr(".bmp")
Const ExtensionWebp = WStr(".webp")

Const ExtensionHtm = WStr(".htm")
Const ExtensionHtml = WStr(".html")
Const ExtensionXhtml = WStr(".xhtml")
Const ExtensionCss = WStr(".css")
Const ExtensionCsv = WStr(".csv")
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
Const ContentTypesImageBmp = WStr("image/bmp")

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

Type MimeTypeNode
	Extension As WString Ptr
	MimeString As WString Ptr
	ContentType As ContentTypes
	Format As MimeFormats
End Type

Dim Shared MimeTypeNodesVector(0 To ...) As MimeTypeNode = { _
	Type<MimeTypeNode>(@ExtensionHtm,  @ContentTypesTextHtml, ContentTypes.TextHtml, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionCss,  @ContentTypesTextCss, ContentTypes.TextCss, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionPng,  @ContentTypesImagePng, ContentTypes.ImagePng, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionGif,  @ContentTypesImageGif, ContentTypes.ImageGif, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionJpg,  @ContentTypesImageJpeg, ContentTypes.ImageJpeg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionWebp, @ContentTypesImageWebp, ContentTypes.ImageWebp, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionIco,  @ContentTypesImageIco, ContentTypes.ImageIco, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionXhtml, @ContentTypesApplicationXhtml, ContentTypes.ApplicationXhtml, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionXml,  @ContentTypesApplicationXml, ContentTypes.ApplicationXml, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionXsl,  @ContentTypesApplicationXmlXslt, ContentTypes.ApplicationXmlXslt, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionXslt, @ContentTypesApplicationXmlXslt, ContentTypes.ApplicationXmlXslt, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionTxt,  @ContentTypesTextPlain, ContentTypes.TextPlain, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionRss,  @ContentTypesApplicationRssXml, ContentTypes.ApplicationRssXml, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionJs,   @ContentTypesApplicationJavascript, ContentTypes.ApplicationJavascript, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionZip,  @ContentTypesApplicationZip, ContentTypes.ApplicationZip, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionHtml, @ContentTypesTextHtml, ContentTypes.TextHtml, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionSvg,  @ContentTypesImageSvg, ContentTypes.ImageSvg, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionBmp,  @ContentTypesImageBmp, ContentTypes.ImageBmp, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionJpe,  @ContentTypesImageJpeg, ContentTypes.ImageJpeg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionJpeg, @ContentTypesImageJpeg, ContentTypes.ImageJpeg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionTif,  @ContentTypesImageTiff, ContentTypes.ImageTiff, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionTiff, @ContentTypesImageTiff, ContentTypes.ImageTiff, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionAtom, @ContentTypesApplicationAtom, ContentTypes.ApplicationAtom, MimeFormats.Text), _
	Type<MimeTypeNode>(@ExtensionCsv,  @ContentTypesTextCsv, ContentTypes.TextCsv, MimeFormats.Text), _
	Type<MimeTypeNode>(@Extension7z,   @ContentTypesApplication7z, ContentTypes.Application7z, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionRar,  @ContentTypesApplicationRar, ContentTypes.ApplicationRar, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionGz,   @ContentTypesApplicationGzip, ContentTypes.ApplicationGzip, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionTgz,  @ContentTypesApplicationXCompressed, ContentTypes.ApplicationXCompressed, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionRtf,  @ContentTypesApplicationRtf, ContentTypes.ApplicationRtf, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMp3,  @ContentTypesAudioMpeg, ContentTypes.AudioMpeg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMpg,  @ContentTypesVideoMpeg, ContentTypes.VideoMpeg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMpeg, @ContentTypesVideoMpeg, ContentTypes.VideoMpeg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionAvi,  @ContentTypesVideoXMsvideo, ContentTypes.VideoXMsvideo, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOgv,  @ContentTypesVideoOgg, ContentTypes.VideoOgg, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMp4,  @ContentTypesVideoMp4, ContentTypes.VideoMp4, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionWebm, @ContentTypesVideoWebm, ContentTypes.VideoWebm, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionWasm, @ContentTypesApplicationWasm, ContentTypes.ApplicationWasm, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionWmv,  @ContentTypesVideoXmswmv, ContentTypes.VideoXmswmv, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionBin,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionExe,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionDll,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionDeb,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionDmg,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionEot,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionIso,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionImg,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMsi,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMsp,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionMsm,  @ContentTypesApplicationOctetStream, ContentTypes.ApplicationOctetStream, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionSwf,  @ContentTypesApplicationFlash, ContentTypes.ApplicationFlash, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionRam,  @ContentTypesAudioRealaudio, ContentTypes.AudioRealaudio, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionCrt,  @ContentTypesApplicationCertx509, ContentTypes.ApplicationCertx509, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionCer,  @ContentTypesApplicationCertx509, ContentTypes.ApplicationCertx509, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionPdf,  @ContentTypesApplicationPdf, ContentTypes.ApplicationPdf, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdt,  @ContentTypesApplicationOpenDocumentText, ContentTypes.ApplicationOpenDocumentText, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOtt,  @ContentTypesApplicationOpenDocumentTextTemplate, ContentTypes.ApplicationOpenDocumentTextTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdg,  @ContentTypesApplicationOpenDocumentGraphics, ContentTypes.ApplicationOpenDocumentGraphics, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOtg,  @ContentTypesApplicationOpenDocumentGraphicsTemplate, ContentTypes.ApplicationOpenDocumentGraphicsTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdp,  @ContentTypesApplicationOpenDocumentPresentation, ContentTypes.ApplicationOpenDocumentPresentation, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOtp,  @ContentTypesApplicationOpenDocumentPresentationTemplate, ContentTypes.ApplicationOpenDocumentPresentationTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOds,  @ContentTypesApplicationOpenDocumentSpreadsheet, ContentTypes.ApplicationOpenDocumentSpreadsheet, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOts,  @ContentTypesApplicationOpenDocumentSpreadsheetTemplate, ContentTypes.ApplicationOpenDocumentSpreadsheetTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdc,  @ContentTypesApplicationOpenDocumentChart, ContentTypes.ApplicationOpenDocumentChart, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOtc,  @ContentTypesApplicationOpenDocumentChartTemplate, ContentTypes.ApplicationOpenDocumentChartTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdi,  @ContentTypesApplicationOpenDocumentImage, ContentTypes.ApplicationOpenDocumentImage, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOti,  @ContentTypesApplicationOpenDocumentImageTemplate, ContentTypes.ApplicationOpenDocumentImageTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdf,  @ContentTypesApplicationOpenDocumentFormula, ContentTypes.ApplicationOpenDocumentFormula, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOtf,  @ContentTypesApplicationOpenDocumentFormulaTemplate, ContentTypes.ApplicationOpenDocumentFormulaTemplate, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOdm,  @ContentTypesApplicationOpenDocumentMaster, ContentTypes.ApplicationOpenDocumentMaster, MimeFormats.Binary), _
	Type<MimeTypeNode>(@ExtensionOth,  @ContentTypesApplicationOpenDocumentWeb, ContentTypes.ApplicationOpenDocumentWeb, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesAnyAny, ContentTypes.AnyAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesImageAny, ContentTypes.ImageAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesTextAny, ContentTypes.TextAny, MimeFormats.Text), _
	Type<MimeTypeNode>(NULL,           @ContentTypesApplicationAny, ContentTypes.ApplicationAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesAudioAny, ContentTypes.AudioAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMessageAny, ContentTypes.MessageAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMessageHttp, ContentTypes.MessageHttp, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesVideoAny, ContentTypes.VideoAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartAny, ContentTypes.MultipartAny, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartMixed, ContentTypes.MultipartMixed, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartAlternative, ContentTypes.MultipartAlternative, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartRelated, ContentTypes.MultipartRelated, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartFormdata, ContentTypes.MultipartFormdata, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartSigned, ContentTypes.MultipartSigned, MimeFormats.Binary), _
	Type<MimeTypeNode>(NULL,           @ContentTypesMultipartEncrypted, ContentTypes.MultipartEncrypted, MimeFormats.Binary) _
}

Public Sub GetContentTypeOfMimeType( _
		ByVal pBuffer As WString Ptr, _
		ByVal mt As MimeType Ptr _
	)

	Dim Finded As Boolean = False

	For i As Integer = LBound(MimeTypeNodesVector) To UBound(MimeTypeNodesVector)
		If mt->ContentType = MimeTypeNodesVector(i).ContentType Then
			lstrcpyW(pBuffer, MimeTypeNodesVector(i).MimeString)
			Finded = True
			Exit For
		End If
	Next

	If Finded = False Then
		lstrcpyW(pBuffer, @ContentTypesApplicationOctetStream)
	End If

	Dim CharsetLength As Integer = SysStringLen(mt->CharsetWeakPtr)

	If CharsetLength Then
		Const CharsetWithSeparatorString = WStr(";charset=")
		lstrcatW(pBuffer, @CharsetWithSeparatorString)
		lstrcatW(pBuffer, mt->CharsetWeakPtr)
	End If

End Sub

Public Function GetMimeOfFileExtension( _
		ByVal mt As MimeType Ptr, _
		ByVal ext As WString Ptr, _
		ByVal DefaultMime As DefaultMimeIfNotFound _
	)As Boolean

	mt->CharsetWeakPtr = NULL

	For i As Integer = LBound(MimeTypeNodesVector) To UBound(MimeTypeNodesVector)
		Dim Compare As Long = lstrcmpiW(ext, MimeTypeNodesVector(i).Extension)
		If Compare = CompareResultEqual Then
			mt->ContentType = MimeTypeNodesVector(i).ContentType
			mt->Format = MimeTypeNodesVector(i).Format
			Return True
		End If
	Next

	Scope
		If DefaultMime = DefaultMimeIfNotFound.UseApplicationOctetStream Then
			mt->ContentType = ContentTypes.ApplicationOctetStream
			mt->Format = MimeFormats.Binary
			Return True
		End If
	End Scope

	Return False

End Function
