#ifndef URI_BI
#define URI_BI

Type URI
	' Максимальная длина Url
	Const MaxUrlLength As Integer = 4096 - 1
	
	' Запрошенный клиентом адрес
	Dim Url As WString Ptr
	' Путь, указанный клиентом (без строки запроса и раскодированный)
	Dim Path As WString * (MaxUrlLength + 1)
	' Строка запроса
	Dim QueryString As WString Ptr
	
	' Инициализация объекта запроса в начальное значение
	Declare Sub Initialize( _
	)
	
	' Расшифровываем интернет-кодировку в юникод-строку
	Declare Sub PathDecode( _
		ByVal Buffer As WString Ptr _
	)
	
End Type

#endif
