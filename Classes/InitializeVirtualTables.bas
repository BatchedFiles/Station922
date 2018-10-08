#include "InitializeVirtualTables.bi"
#include "ArrayStringWriter.bi"
#include "ServerState.bi"
#include "NetworkStream.bi"
#include "FileStream.bi"
#include "StreamWriter.bi"
'#include "StreamReader.bi"
#include "Configuration.bi"

Common Shared GlobalArrayStringWriterVirtualTable As IArrayStringWriterVirtualTable
Common Shared GlobalServerStateVirtualTable As IServerStateVirtualTable
Common Shared GlobalNetworkStreamVirtualTable As INetworkStreamVirtualTable
Common Shared GlobalFileStreamVirtualTable As IFileStreamVirtualTable
Common Shared GlobalStreamWriterVirtualTable As IStreamWriterVirtualTable
' Common Shared GlobalStreamReaderVirtualTable As IStreamReaderVirtualTable
Common Shared GlobalConfigurationVirtualTable As IConfigurationVirtualTable

Sub InitializeVirtualTables()
	
	' ArrayStringWriter
	GlobalArrayStringWriterVirtualTable.VirtualTable.VirtualTable.QueryInterface = 0
	GlobalArrayStringWriterVirtualTable.VirtualTable.VirtualTable.Addref = 0
	GlobalArrayStringWriterVirtualTable.VirtualTable.VirtualTable.Release = 0
	GlobalArrayStringWriterVirtualTable.VirtualTable.CloseTextWriter = @ArrayStringWriterCloseTextWriter
	GlobalArrayStringWriterVirtualTable.VirtualTable.OpenTextWriter = @ArrayStringWriterCloseTextWriter
	GlobalArrayStringWriterVirtualTable.VirtualTable.Flush = @ArrayStringWriterCloseTextWriter
	GlobalArrayStringWriterVirtualTable.VirtualTable.GetCodePage = @ArrayStringWriterGetCodePage
	GlobalArrayStringWriterVirtualTable.VirtualTable.SetCodePage = @ArrayStringWriterSetCodePage
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteNewLine = @ArrayStringWriterWriteNewLine
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteStringLine = @ArrayStringWriterWriteStringLine
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteLengthStringLine = @ArrayStringWriterWriteLengthStringLine
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteString = @ArrayStringWriterWriteString
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteLengthString = @ArrayStringWriterWriteLengthString
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteChar = @ArrayStringWriterWriteChar
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteInt32 = @ArrayStringWriterWriteInt32
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteInt64 = @ArrayStringWriterWriteInt64
	GlobalArrayStringWriterVirtualTable.VirtualTable.WriteUInt64 = @ArrayStringWriterWriteUInt64
	
	' ServerState
	GlobalServerStateVirtualTable.VirtualTable.QueryInterface = 0
	GlobalServerStateVirtualTable.VirtualTable.Addref = 0
	GlobalServerStateVirtualTable.VirtualTable.Release = 0
	GlobalServerStateVirtualTable.GetRequestHeader = @ServerStateDllCgiGetRequestHeader
	GlobalServerStateVirtualTable.GetHttpMethod = @ServerStateDllCgiGetHttpMethod
	GlobalServerStateVirtualTable.GetHttpVersion = @ServerStateDllCgiGetHttpVersion
	GlobalServerStateVirtualTable.SetStatusCode = @ServerStateDllCgiSetStatusCode
	GlobalServerStateVirtualTable.SetStatusDescription = @ServerStateDllCgiSetStatusDescription
	GlobalServerStateVirtualTable.SetResponseHeader = @ServerStateDllCgiSetResponseHeader
	GlobalServerStateVirtualTable.WriteData = @ServerStateDllCgiWriteData
	GlobalServerStateVirtualTable.ReadData = @ServerStateDllCgiReadData
	GlobalServerStateVirtualTable.GetHtmlSafeString = @ServerStateDllCgiGetHtmlSafeString
	
	' NetworkStream
	GlobalNetworkStreamVirtualTable.VirtualTable.VirtualTable.QueryInterface = 0
	GlobalNetworkStreamVirtualTable.VirtualTable.VirtualTable.Addref = 0
	GlobalNetworkStreamVirtualTable.VirtualTable.VirtualTable.Release = 0
	GlobalNetworkStreamVirtualTable.VirtualTable.CanRead = @NetworkStreamCanRead
	GlobalNetworkStreamVirtualTable.VirtualTable.CanSeek = @NetworkStreamCanSeek
	GlobalNetworkStreamVirtualTable.VirtualTable.CanWrite = @NetworkStreamCanWrite
	GlobalNetworkStreamVirtualTable.VirtualTable.CloseStream = @NetworkStreamCloseStream
	GlobalNetworkStreamVirtualTable.VirtualTable.Flush = @NetworkStreamFlush
	GlobalNetworkStreamVirtualTable.VirtualTable.GetLength = @NetworkStreamGetLength
	GlobalNetworkStreamVirtualTable.VirtualTable.OpenStream = @NetworkStreamOpenStream
	GlobalNetworkStreamVirtualTable.VirtualTable.Position = @NetworkStreamPosition
	GlobalNetworkStreamVirtualTable.VirtualTable.Read = @NetworkStreamRead
	GlobalNetworkStreamVirtualTable.VirtualTable.Seek = @NetworkStreamSeek
	GlobalNetworkStreamVirtualTable.VirtualTable.SetLength = @NetworkStreamSetLength
	GlobalNetworkStreamVirtualTable.VirtualTable.Write = @NetworkStreamWrite
	
	' FileStream
	
	' Configuration
	GlobalConfigurationVirtualTable.VirtualTable.QueryInterface = 0
	GlobalConfigurationVirtualTable.VirtualTable.AddRef = 0
	GlobalConfigurationVirtualTable.VirtualTable.Release = 0
	GlobalConfigurationVirtualTable.GetStringValue = @ConfigurationGetStringValue
	GlobalConfigurationVirtualTable.GetIntegerValue = @ConfigurationGetIntegerValue
	GlobalConfigurationVirtualTable.GetAllSections = @ConfigurationGetAllSections
	GlobalConfigurationVirtualTable.GetAllKeys = @ConfigurationGetAllKeys
	GlobalConfigurationVirtualTable.SetStringValue = @ConfigurationSetStringValue
	
End Sub
