#ifndef MIME_BI
#define MIME_BI

#include once "IString.bi"

Const MaxContentTypeLength As Integer = 256 - 1

Enum ContentTypes
	AnyAny
	
	ApplicationAny
	Application7z
	ApplicationAtom
	ApplicationCertx509
	ApplicationFlash
	ApplicationFontwoff
	ApplicationGzip
	ApplicationJavascript
	ApplicationJson
	ApplicationMsword
	ApplicationOctetStream
	ApplicationOgg
	ApplicationOpenDocumentChart
	ApplicationOpenDocumentChartTemplate
	ApplicationOpenDocumentFormula
	ApplicationOpenDocumentFormulaTemplate
	ApplicationOpenDocumentGraphics
	ApplicationOpenDocumentGraphicsTemplate
	ApplicationOpenDocumentImage
	ApplicationOpenDocumentImageTemplate
	ApplicationOpenDocumentMaster
	ApplicationOpenDocumentPresentation
	ApplicationOpenDocumentPresentationTemplate
	ApplicationOpenDocumentSpreadsheet
	ApplicationOpenDocumentSpreadsheetTemplate
	ApplicationOpenDocumentText
	ApplicationOpenDocumentTextTemplate
	ApplicationOpenDocumentWeb
	ApplicationPdf
	ApplicationRar
	ApplicationRssXml
	ApplicationRtf
	ApplicationSoapxml
	ApplicationVndmsexcel
	ApplicationVndmspowerpoint
	ApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet
	ApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation
	ApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument
	ApplicationXbittorrent
	ApplicationXCompressed
	ApplicationXfontttf
	ApplicationXhtml
	ApplicationXJavascript
	ApplicationXml
	ApplicationXmldtd
	ApplicationXmlXslt
	ApplicationXwwwformurlencoded
	ApplicationWasm
	ApplicationZip
	
	AudioAny
	AudioAac
	AudioBasic
	AudioL24
	AudioMp4
	AudioMpeg
	AudioOgg
	AudioRealaudio
	AudioVndwave
	AudioVorbis
	AudioWebm
	AudioXmswma
	AudioXmswax
	
	ImageAny
	ImageGif
	ImageIco
	ImageJpeg
	ImagePjpeg
	ImagePng
	ImageSvg
	ImageTiff
	ImageWbmp
	ImageWebp
	
	MessageAny
	MessageHttp
	MessageImdnxml
	MessagePartial
	MessageRfc822
	
	MultipartAny
	MultipartAlternative
	MultipartEncrypted
	MultipartFormdata
	MultipartMixed
	MultipartRelated
	MultipartSigned
	
	TextAny
	TextCmd
	TextCss
	TextCsv
	TextHtml
	TextPlain
	TextPhp
	TextXml
	
	VideoAny
	Video3gpp
	Video3gpp2
	VideoQuicktime
	VideoMp4
	VideoMpeg
	VideoOgg
	VideoXMatroska
	VideoXMsvideo
	VideoXflv
	VideoWebm
	VideoXmswmv
	
End Enum

Enum DefaultMimeIfNotFound
	UseNone
	UseApplicationOctetStream
End Enum

Type MimeType
	ContentType As ContentTypes
	CharsetWeakPtr As HeapBSTR
	IsTextFormat As Boolean
End Type

Declare Sub GetContentTypeOfMimeType( _
	ByVal ContentType As WString Ptr, _
	ByVal mt As MimeType Ptr _
)

Declare Function GetMimeOfFileExtension( _
	ByVal mt As MimeType Ptr, _
	ByVal FileExtension As WString Ptr, _
	ByVal DefaultMime As DefaultMimeIfNotFound _
)As Boolean

#endif
