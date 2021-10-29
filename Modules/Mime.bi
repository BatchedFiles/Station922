#ifndef MIME_BI
#define MIME_BI

' Размер буфера для записи в него типа документа
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

Enum DocumentCharsets
	ASCII
	Utf8BOM
	Utf16LE
	Utf16BE
End Enum

Type _MimeType
	ContentType As ContentTypes
	IsTextFormat As Boolean
	Charset As DocumentCharsets
End Type

Type MimeType As _MimeType

Type LPMimeType As MimeType Ptr

Declare Sub GetContentTypeOfMimeType( _
	ByVal ContentType As WString Ptr, _
	ByVal mt As MimeType Ptr _
)

Declare Function GetMimeOfFileExtension( _
	ByVal mt As MimeType Ptr, _
	ByVal FileExtension As WString Ptr _
)As Boolean

Declare Function GetMimeOfStringContentType( _
	ByVal mt As MimeType Ptr, _
	ByVal ContentType As WString Ptr _
)As Boolean

#endif
