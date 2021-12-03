#include once "ClientUri.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"

Type _ClientUri
	lpVtbl As Const IClientUriVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
End Type

