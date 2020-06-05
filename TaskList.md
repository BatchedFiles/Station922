# Задачи

## Иерархия классов

IUnknown
├───IAsyncResult
│
├───IBaseStream
│   ├───IFileStream
│   │   └───FileStream       [ ]
│   │
│   └───INetworkStream
│       └───NetworkStream
│
├───IClientContext
│   └───ClientContext
│
├───IClientRequest
│   └───ClientRequest
│
├───IClientUri
│   └───ClientUri            [ ]
│
├───IConfiguration
│   └───Configuration
│
├───IMutableWebSite
│   └───WebSite
│
├───IRequestedFile
│   └───RequestedFile
│
├───IRequestProcessor
│   ├───CgiProcessor         [ ]
│   ├───DllProcessor         [ ]
│   ├───HttpConnectProcessor [ ]
│   ├───HttpDeleteProcessor  [ ]
│   ├───HttpGetProcessor     [ ]
│   ├───HttpHeadProcessor    [ ]
│   ├───HttpOptionsProcessor [ ]
│   ├───HttpPostProcessor    [ ]
│   ├───HttpPutProcessor     [ ]
│   └───HttpTraceProcessor   [ ]
│
├───ISendable
│   └───RequestedFile        [ ]
│
├───IServerResponse
│   └───ServerResponse
│
├───IServerState
│   └───ServerState          [ ]
│
├───IStopWatcher
│   └───StopWatcher          [ ]
│
├───IStringable
│   ├───ClientRequest
│   └───ServerResponse
│
├───ITextReader
│   ├───IHttpReader
│   │   └───HttpReader
│   │
│   └───IStreamReader
│
├───ITextWriter
│   ├───IArrayStringWriter
│   │   └───ArrayStringWriter
│   │
│   └───IStreamWriter
│
└───IWebSite
    ├───WebSite
    │
    └───IWebSiteContainer
        └───WebSiteContainer

Mime                         [ ]
SafeHandle
Station922Uri                [ ]

## Создание объектов

Объекты создаёт функция CreateInstance.

## Предварительное объявление классов

Объявить в заголовочнике псевдоним, а в файле реализации сам тип с подчёркиванием слева.

* [x] Mime.bas
* [x] SafeHandle.bas
* [x] ServerState.bas
* [x] Station922Uri.bas

## Сделать

Эти задачи выполнить в любом порядке.

* [ ] Перенести на новую строку слишком длинные строки кода.
* [ ] Найти все магические числа и заменить на именованные константы.
* [ ] Улучшение производительности: хранение заголовков запроса и ответа в виде двоичного дерева.
* [ ] Собственный класс строк с хранением длины и переопределением операторов сравнения.
* [ ] Метод PATCH.
* [ ] Кеширование файлов.
* [ ] Согласование содержимого по заголовкам Accept, Accept-Charset, Accept-Encoding, Accept-Language.
* [ ] Локализовать текстовые описания ошибок.
* [ ] Разные интерфейсы IServerResponse для разных версий http‐протокола.
* [ ] Различать версию HTTP/1.0 и HTTP/1.1, отдавать соответствующие заголовки.
* [ ] Нераспознанные заголовки запроса.
* [ ] Объект безопасного владения объектами ядра.
* [ ] Журналирование запросов.
* [ ] Откатывать назад изменения буфера заголовоков ответа.
* [ ] Добавить возможность парольных ресурсов.
* [ ] Все коды ошибок WinAPI с описанием отправлять клиенту.
* [ ] Новый объект Uri, учитывающий Scheme, Authority, Path, Query, Fragment.
* [ ] Проверить функцию раскодировки URL, возможно, есть библиотечная.
* [ ] Убрать функцию загрузки виртуальной таблицы, загружать виртуальную таблицу статически.
* [ ] Новый интерфейс объекта сервера: функции приостановки, возобновления работы. Функция Run не должжна блокировать поток.
* [ ] Обработчики запросов — в свои отдельные классы.
* [ ] Передача на сервер через PUT очень больших файлов.
* [x] Исправить предупреждения о присвоении указателей разных типов на реальные функции виртуальных таблиц интерфейсов.
* [ ] Поддержка в запросе множественных байтовых диапазонов.
* [ ] Асинхронный трубопровод в CGI.
* [ ] Переименовать функции и структуры: юникодные должны быть с W на конце, неюникодные — с A.

## Рефракторинг

### Классы

* [ ] ArrayStringWriter.bas
* [ ] ClientRequest.bas
* [ ] Configuration.bas
* [ ] HttpReader.bas
* [ ] NetworkStream.bas
* [ ] RequestedFile.bas
* [ ] SafeHandle.bas
* [ ] ServerResponse.bas
* [ ] ServerState.bas
* [ ] WebServer.bas
* [ ] WebSite.bas
* [ ] WebSiteContainer.bas

### Интерфейсы

* [ ] IArrayStringWriter.bi
* [ ] IAsyncResult.bi
* [ ] IBaseStream.bi
* [ ] IClientRequest.bi
* [ ] IConfiguration.bi
* [ ] IFileStream.bi
* [ ] IHttpReader.bi
* [ ] INetworkStream.bi
* [ ] IRequestedFile.bi
* [ ] IRequestProcessor.bi
* [ ] IRunnable.bi
* [ ] ISendable.bi
* [ ] IServerResponse.bi
* [ ] IServerState.bi
* [ ] IStreamReader.bi
* [ ] IStreamWriter.bi
* [ ] IStringable.bi
* [ ] ITextReader.bi
* [ ] ITextWriter.bi
* [ ] IUri.bi
* [ ] IWebSite.bi
* [ ] IWebSiteContainer.bi

### Модули

* [ ] ConsoleColors.bas
* [ ] ConsoleMain.bas
* [ ] EntryPoint.bas
* [ ] FindNewLineIndex.bas
* [ ] Guids.bas
* [ ] Http.bas
* [ ] InitializeVirtualTables.bas
* [ ] Network.bas
* [ ] NetworkClient.bas
* [ ] NetworkServer.bas
* [ ] PrintDebugInfo.bas
* [ ] ThreadProc.bas
* [ ] WebUtils.bas
* [ ] WindowsServiceMain.bas
* [ ] WriteHttpError.bas
* [ ] URI.bas

## Выполнено

* [x] Обновить Read.Me про компиляцию и настройку службы.
* [x] Исправить перемотку видеофайлов.

