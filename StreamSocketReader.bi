#ifndef STREAMSOCKETREADER_BI
#define STREAMSOCKETREADER_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"

Type StreamSocketReader
	' Максимальный размер буфера
	Const MaxBufferLength As Integer = 16 * 1024 - 1
	
	' Буфер заполнен
	Const BufferOverflowError As DWORD = 1
	' Ошибка сети
	Const SocketError As DWORD = 2
	' Клиент закрыл соединение
	Const ClientClosedSocketError As DWORD = 3
	
	' Клиентский сокет
	Dim ClientSocket As SOCKET
	' Буфер данных
	Dim Buffer As ZString * (MaxBufferLength + 1)
	' Количество данных в буфере
	Dim BufferLength As Integer
	' Индекс начала необработанных данные в буфере
	Dim Start As Integer
	
	' Инициализация
	Declare Sub Initialize( _
	)
	
	' Чтение данных из сокета и заполнение буфера строкой
	Declare Function ReadLine( _
		ByVal wLine As WString Ptr, _
		ByVal LineBufferLength As Integer, _
		ByVal pLineLength As Integer Ptr _
	)As Boolean
	
	' Удаляет обработанные данные из буфера
	Declare Sub Flush( _
	)
	
Private:
	
	' Поиск символов CrLf в буфере
	Declare Function FindCrLfA( _
		ByVal pFindedIndex As Integer Ptr _
	)As Boolean
	
End Type

#endif
