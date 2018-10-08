#include "FileStream.bi"

Common Shared GlobalFileStreamVirtualTable As IFileStreamVirtualTable

Function FileStreamCanRead( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	Return S_OK
End Function

Function FileStreamCanSeek( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	Return S_OK
End Function

Function FileStreamCanWrite( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	Return S_OK
End Function

Function FileStreamCloseStream( _
		ByVal this As FileStream Ptr _
	)As HRESULT
	
	Return S_OK
End Function

Function FileStreamFlush( _
		ByVal this As FileStream Ptr _
	)As HRESULT
	
	Return S_OK
End Function

' TODO
Function FileStreamGetLength( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As LongInt Ptr _
	)As HRESULT
	
	*pResult = 0
	Return S_OK
End Function

Function FileStreamOpenStream( _
		ByVal this As FileStream Ptr _
	)As HRESULT
	
	Return S_OK
End Function

' TODO
Function FileStreamPosition( _
		ByVal this As FileStream Ptr, _
		ByVal pResult As LongInt Ptr _
	)As HRESULT
	
	*pResult = 0
	Return S_OK
End Function

' TODO
Function FileStreamRead( _
		ByVal this As FileStream Ptr, _
		ByVal buffer As UByte Ptr, _
		ByVal offset As Integer, _
		ByVal Count As Integer, _
		ByVal pReadedBytes As LongInt Ptr _
	)As HRESULT
	
	Return S_OK
End Function

' TODO
Function FileStreamSeek( _
		ByVal this As FileStream Ptr, _
		ByVal offset As LongInt, _
		ByVal origin As SeekOrigin _
	)As HRESULT
	
	Return S_OK
End Function

' TODO
Function FileStreamSetLength( _
		ByVal this As FileStream Ptr, _
		ByVal length As LongInt _
	)As HRESULT
	
	Return S_OK
End Function

' TODO
Function FileStreamWrite( _
		ByVal this As FileStream Ptr, _
		ByVal buffer As UByte Ptr, _
		ByVal offset As Integer, _
		ByVal Count As Integer, _
		ByVal pWritedBytes As Integer Ptr _
	)As HRESULT
	
	Return S_OK
End Function

Sub InitializeFileStream( _
		ByVal pFileStream As FileStream Ptr, _
		ByVal hFile As HANDLE _
	)
	pFileStream->pVirtualTable = @GlobalFileStreamVirtualTable
	pFileStream->ReferenceCounter = 1
	pFileStream->hFile = hFile
End Sub