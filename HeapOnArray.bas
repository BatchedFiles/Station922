#include once "HeapOnArray.bi"

Sub MyHeapCreate(ByVal hHeap As Any Ptr)
	For i As Integer = 0 To MyHeapSize - 1 Step SizeOf(HeapThreadParam)
		CPtr(HeapThreadParam Ptr, hHeap + i)->IsUsed = False
	Next
End Sub

Sub MyHeapDestroy(ByVal hHeap As Any Ptr)
	For i As Integer = 0 To MyHeapSize - 1 Step SizeOf(HeapThreadParam)
		If CPtr(HeapThreadParam Ptr, hHeap + i)->IsUsed Then
			WaitForSingleObject(CPtr(HeapThreadParam Ptr, hHeap + i)->Param.hThread, INFINITE)
		End If
	Next
End Sub

Function MyHeapAlloc(ByVal hHeap As Any Ptr)As ThreadParam Ptr
	For i As Integer = 0 To MyHeapSize - 1 Step SizeOf(HeapThreadParam)
		If CPtr(HeapThreadParam Ptr, hHeap + i)->IsUsed = False Then
			CPtr(HeapThreadParam Ptr, hHeap + i)->IsUsed = True
			Return @(CPtr(HeapThreadParam Ptr, hHeap + i)->Param)
		End If
	Next
	Return 0
End Function

Sub MyHeapFree(ByVal hMem As ThreadParam Ptr)
	CPtr(HeapThreadParam Ptr, hMem - SizeOf(Boolean))->IsUsed = False
End Sub