#include once "TaskExecutor.bi"
#include once "Logger.bi"

Public Sub ThreadPoolCallBack( _
		ByVal dwError As DWORD, _
		ByVal BytesTransferred As DWORD, _
		ByVal pOverlap As OVERLAPPED Ptr _
	)
	
	Dim hrFinishExecute As HRESULT = Any
	Dim pNextTask As IAsyncIoTask Ptr = Any
	Scope
		Dim pIResult As IAsyncResult Ptr = GetAsyncResultFromOverlappedWeakPtr(pOverlap)
		
		hrFinishExecute = FinishExecuteTaskSink( _
			BytesTransferred, _
			pIResult, _
			@pNextTask, _
			dwError _
		)
	End Scope
	
	If SUCCEEDED(hrFinishExecute) Then
		
		Select Case hrFinishExecute
			
			Case S_OK
				Dim hrStart As HRESULT = StartExecuteTask(pNextTask)
				If FAILED(hrStart) Then
					IAsyncIoTask_Release(pNextTask)
				End If
				
			Case S_FALSE
				
			Case ASYNCTASK_S_KEEPALIVE_FALSE
				
		End Select
	End If
	
End Sub

Public Function StartExecuteTask( _
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

Private Function FinishExecuteTaskSink( _
		ByVal BytesTransferred As DWORD, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr, _
		ByVal dwError As DWORD _
	)As HRESULT
	
	IAsyncResult_SetCompleted( _
		pIResult, _
		BytesTransferred, _
		True, _
		dwError _
	)
	
	Dim pTask As IAsyncIoTask Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pTask)
	
	Dim hrEndExecute As HRESULT = IAsyncIoTask_EndExecute( _
		pTask, _
		pIResult, _
		BytesTransferred, _
		ppNextTask _
	)
	If FAILED(hrEndExecute) Then
		Dim vtErrorCode As VARIANT = Any
		vtErrorCode.vt = VT_ERROR
		vtErrorCode.scode = hrEndExecute
		
		Dim TaskId As AsyncIoTaskIDs = Any
		IAsyncIoTask_GetTaskId(pTask, @TaskId)
		
		Dim p As WString Ptr = Any
		Select Case TaskId
			
			Case AsyncIoTaskIDs.AcceptConnection
				p = @WStr("AcceptConnectionTask.EndExecute Error")
				
			Case AsyncIoTaskIDs.ReadRequest
				p = @WStr("ReadRequestTask.EndExecute Error")
				
			Case AsyncIoTaskIDs.WriteError
				p = @WStr("WriteErrorTask.EndExecute Error")
				
			Case Else ' AsyncIoTaskIDs.WriteResponse
				p = @WStr("WriteResponseTask.EndExecute Error")
				
		End Select
		
		LogWriteEntry( _
			LogEntryType.Error, _
			p, _
			@vtErrorCode _
		)
	End If
	
	' Releasing the references to the task and futura
	' beecause we haven't done this before
	IAsyncResult_Release(pIResult)
	IAsyncIoTask_Release(pTask)
	
	Return hrEndExecute
	
End Function
