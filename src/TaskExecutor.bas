#include once "TaskExecutor.bi"
#include once "Logger.bi"

Function StartExecuteTask( _
		ByVal pTask As IAsyncIoTask Ptr _
	)As HRESULT
	
	Dim pIResult As IAsyncResult Ptr = Any
	Dim hrBeginExecute As HRESULT = IAsyncIoTask_BeginExecute( _
		pTask, _
		@pIResult _
	)
	If FAILED(hrBeginExecute) Then
		Dim vtErrorCode As VARIANT = Any
		vtErrorCode.vt = VT_ERROR
		vtErrorCode.scode = hrBeginExecute
		
		Dim TaskId As AsyncIoTaskIDs = Any
		IAsyncIoTask_GetTaskId(pTask, @TaskId)
		
		Dim p As WString Ptr = Any
		Select Case TaskId
			
			Case AsyncIoTaskIDs.AcceptConnection
				p = @WStr("AcceptConnectionTask.BeginExecute Error")
				
			Case AsyncIoTaskIDs.ReadRequest
				p = @WStr("ReadRequestTask.BeginExecute Error")
				
			Case AsyncIoTaskIDs.WriteError
				p = @WStr("WriteErrorTask.BeginExecute Error")
				
			Case Else ' AsyncIoTaskIDs.WriteResponse
				p = @WStr("WriteResponseTask.BeginExecute Error")
				
		End Select
		
		LogWriteEntry( _
			LogEntryType.Error, _
			p, _
			@vtErrorCode _
		)
		
		Return hrBeginExecute
	End If
	
	Return S_OK
	
End Function
