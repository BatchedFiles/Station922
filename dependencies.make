Classes\ArrayStringWriter.bas: Classes\ArrayStringWriter.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi Headers\StringConstants.bi
Classes\ArrayStringWriter.bi: Interfaces\IArrayStringWriter.bi

Classes\AsyncResult.bas: Classes\AsyncResult.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\AsyncResult.bi: Interfaces\IMutableAsyncResult.bi

Classes\ClientContext.bas: Classes\ClientContext.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi
Classes\ClientContext.bi: Interfaces\IClientContext.bi

Classes\ClientRequest.bas: Classes\ClientRequest.bi Interfaces\IStringable.bi Headers\CharacterConstants.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi Headers\HttpConst.bi Modules\WebUtils.bi
Classes\ClientRequest.bi: Interfaces\IClientRequest.bi

Classes\Configuration.bas: Classes\Configuration.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\Configuration.bi: Interfaces\IConfiguration.bi

Classes\HeapBSTR.bas: Classes\HeapBSTR.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\HeapBSTR.bi: Interfaces\IHeapBSTR.bi

Classes\HttpGetProcessor.bas: Classes\HttpGetProcessor.bi Classes\ArrayStringWriter.bi Classes\AsyncResult.bi Headers\ContainerOf.bi Headers\CharacterConstants.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Headers\HttpConst.bi Classes\Mime.bi Classes\SafeHandle.bi Headers\StringConstants.bi Modules\WebUtils.bi
Classes\HttpGetProcessor.bi: Interfaces\IRequestProcessor.bi

Classes\HttpReader.bas: Classes\HttpReader.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi Modules\FindNewLineIndex.bi Headers\StringConstants.bi
Classes\HttpReader.bi: Interfaces\IHttpReader.bi

Classes\Mime.bas: Classes\Mime.bi
Classes\Mime.bi:

Classes\Monitor.bas: Classes\Monitor.bi
Classes\Monitor.bi:

Classes\NetworkStream.bas: Classes\NetworkStream.bi Classes\AsyncResult.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Modules\Network.bi
Classes\NetworkStream.bi: Interfaces\INetworkStream.bi

Classes\PrivateHeapMemoryAllocator.bas: Classes\PrivateHeapMemoryAllocator.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\PrivateHeapMemoryAllocator.bi: Interfaces\IPrivateHeapMemoryAllocator.bi

Classes\PrivateHeapMemoryAllocatorClassFactory.bas: Classes\PrivateHeapMemoryAllocatorClassFactory.bi Classes\ObjectsCounter.bi
Classes\PrivateHeapMemoryAllocatorClassFactory.bi:

Classes\RequestedFile.bas: Classes\RequestedFile.bi Headers\ContainerOf.bi Headers\HttpConst.bi Modules\PrintDebugInfo.bi
Classes\RequestedFile.bi: Interfaces\IRequestedFile.bi Interfaces\ISendable.bi

Classes\SafeHandle.bas: Classes\SafeHandle.bi
Classes\SafeHandle.bi:

Classes\ServerResponse.bas: Classes\ServerResponse.bi Classes\ArrayStringWriter.bi Headers\CharacterConstants.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Headers\HttpConst.bi Interfaces\IStringable.bi Modules\PrintDebugInfo.bi Resources.RH Headers\StringConstants.bi Modules\WebUtils.bi
Classes\ServerResponse.bi: Interfaces\IServerResponse.bi

Classes\ServerState.bas: Classes\ServerState.bi Modules\WebUtils.bi
Classes\ServerState.bi: Interfaces\IBaseStream.bi Interfaces\IClientRequest.bi Interfaces\IServerResponse.bi Interfaces\IServerState.bi Interfaces\IWebSite.bi

Classes\Station922Uri.bas: Classes\Station922Uri.bi Headers\CharacterConstants.bi
Classes\Station922Uri.bi:

Classes\StopWatcher.bas: Classes\StopWatcher.bi
Classes\StopWatcher.bi:

Classes\WebServer.bas: Classes\WebServer.bi Classes\ClientContext.bi Classes\ClientRequest.bi Classes\Configuration.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Headers\IniConst.bi Modules\Network.bi Modules\NetworkServer.bi Classes\NetworkStream.bi Classes\ServerResponse.bi Classes\WebSiteContainer.bi Modules\WorkerThread.bi Modules\WriteHttpError.bi
Classes\WebServer.bi: Interfaces\IRunnable.bi

Classes\WebSite.bas: Classes\WebSite.bi Headers\CharacterConstants.bi Headers\ContainerOf.bi Interfaces\IMutableWebSite.bi Modules\PrintDebugInfo.bi Classes\RequestedFile.bi
Classes\WebSite.bi: Interfaces\IMutableWebSite.bi

Classes\WebSiteContainer.bas: Classes\WebSiteContainer.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Headers\HttpConst.bi Interfaces\IConfiguration.bi Interfaces\IMutableWebSite.bi Headers\IniConst.bi Modules\PrintDebugInfo.bi Headers\StringConstants.bi
Classes\WebSiteContainer.bi: Interfaces\IWebSiteContainer.bi

Headers\CharacterConstants.bi:
Headers\ContainerOf.bi:
Headers\HttpConst.bi:
Headers\IniConst.bi:
Headers\StringConstants.bi:

Interfaces\IArrayStringWriter.bi: Interfaces\ITextWriter.bi
Interfaces\IAsyncResult.bi:
Interfaces\IBaseStream.bi: Interfaces\IAsyncResult.bi
Interfaces\IClientContext.bi: Interfaces\IClientRequest.bi Interfaces\IHttpReader.bi Interfaces\INetworkStream.bi Interfaces\IRequestedFile.bi Interfaces\IRequestProcessor.bi Interfaces\IServerResponse.bi
Interfaces\IClientRequest.bi: Modules\Http.bi Interfaces\IHttpReader.bi Classes\Station922Uri.bi
Interfaces\IClientUri.bi:
Interfaces\IConfiguration.bi:
Interfaces\IFileStream.bi: Interfaces\IBaseStream.bi
Interfaces\IHeapBSTR.bi:
Interfaces\IHttpReader.bi: Interfaces\IBaseStream.bi Interfaces\ITextReader.bi
Interfaces\IMutableAsyncResult.bi: Interfaces\IAsyncResult.bi
Interfaces\IMutableWebSite.bi: Interfaces\IWebSite.bi
Interfaces\INetworkStream.bi: Interfaces\IBaseStream.bi
Interfaces\IPauseable.bi: Interfaces\IRunnable.bi
Interfaces\IPrivateHeapMemoryAllocator.bi:
Interfaces\IPrivateHeapMemoryAllocatorClassFactory.bi:
Interfaces\IRequestedFile.bi: Modules\Http.bi
Interfaces\IRequestProcessor.bi: Interfaces\IAsyncResult.bi Interfaces\IClientRequest.bi Interfaces\INetworkStream.bi Interfaces\IServerResponse.bi Interfaces\IWebSite.bi
Interfaces\IRunnable.bi:
Interfaces\ISendable.bi: Interfaces\INetworkStream.bi
Interfaces\IServerResponse.bi: Modules\Http.bi Classes\Mime.bi
Interfaces\IServerState.bi: Modules\Http.bi
Interfaces\IStopWatcher.bi:
Interfaces\IStreamReader.bi: Interfaces\ITextReader.bi
Interfaces\IStreamWriter.bi: Interfaces\ITextWriter.bi
Interfaces\IStringable.bi:
Interfaces\ITextReader.bi:
Interfaces\ITextWriter.bi:
Interfaces\IWebSite.bi: Interfaces\IRequestedFile.bi
Interfaces\IWebSiteContainer.bi: Interfaces\IWebSite.bi

Modules\ConsoleColors.bas: Modules\ConsoleColors.bi
Modules\ConsoleColors.bi:

Modules\ConsoleMain.bas: Modules\ConsoleMain.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Classes\WebServer.bi
Modules\ConsoleMain.bi:

Modules\CreateInstance.bas: Modules\CreateInstance.bi Classes\ArrayStringWriter.bi Classes\AsyncResult.bi Classes\ClientContext.bi Classes\ClientRequest.bi Classes\Configuration.bi Classes\HttpGetProcessor.bi Classes\HttpReader.bi Classes\NetworkStream.bi Classes\PrivateHeapMemoryAllocator.bi Classes\RequestedFile.bi Classes\ServerResponse.bi Classes\WebServer.bi Classes\WebSite.bi Classes\WebSiteContainer.bi
Modules\CreateInstance.bi:

Modules\EntryPoint.bas: Modules\EntryPoint.bi Modules\Http.bi Modules\WindowsServiceMain.bi Modules\ConsoleMain.bi
Modules\EntryPoint.bi:

Modules\FindNewLineIndex.bas: Modules\FindNewLineIndex.bi Headers\StringConstants.bi
Modules\FindNewLineIndex.bi:

Modules\Guids.bas: Modules\Guids.bi
Modules\Guids.bi:

Modules\Http.bas: Modules\Http.bi
Modules\Http.bi:

Modules\Network.bas: Modules\Network.bi
Modules\Network.bi:

Modules\NetworkClient.bas: Modules\NetworkClient.bi
Modules\NetworkClient.bi: Modules\Network.bi

Modules\NetworkServer.bas: Modules\NetworkServer.bi
Modules\NetworkServer.bi: Modules\Network.bi

Modules\PrintDebugInfo.bas: Modules\PrintDebugInfo.bi Modules\ConsoleColors.bi Headers\StringConstants.bi
Modules\PrintDebugInfo.bi: Classes\HttpReader.bi Modules\Http.bi

Modules\WebUtils.bas: Modules\WebUtils.bi Headers\CharacterConstants.bi Modules\CreateInstance.bi Headers\HttpConst.bi Classes\Configuration.bi Headers\IniConst.bi Interfaces\IStringable.bi Modules\PrintDebugInfo.bi Headers\StringConstants.bi Classes\Station922Uri.bi Modules\WriteHttpError.bi
Modules\WebUtils.bi: Interfaces\IClientRequest.bi Interfaces\IServerResponse.bi Interfaces\ITextWriter.bi Interfaces\IWebSite.bi Classes\Mime.bi

Modules\WindowsServiceMain.bas: Modules\WindowsServiceMain.bi Modules\CreateInstance.bi Classes\WebServer.bi
Modules\WindowsServiceMain.bi: 

Modules\WorkerThread.bas: Modules\WorkerThread.bi Classes\AsyncResult.bi Modules\CreateInstance.bi Classes\HttpGetProcessor.bi Interfaces\IClientContext.bi Interfaces\IRequestProcessor.bi Modules\PrintDebugInfo.bi Classes\RequestedFile.bi Modules\WriteHttpError.bi
Modules\WorkerThread.bi: Interfaces\IWebSiteContainer.bi

Modules\WriteHttpError.bas: Modules\WriteHttpError.bi Classes\ArrayStringWriter.bi Modules\CreateInstance.bi Headers\HttpConst.bi Modules\WebUtils.bi
Modules\WriteHttpError.bi: Interfaces\IBaseStream.bi Interfaces\IClientRequest.bi Interfaces\IServerResponse.bi Interfaces\IWebSite.bi

Resources.RC: Resources.RH
Resources.RH:

test\test.bas: test\test.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi
test\test.bi:
