#ifndef LOGGER_BI
#define LOGGER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Enum LogEntryType
	Debug
	Information
	Warning
	Error
	Critical
End Enum

Declare Sub LogWriteEntry( _
	ByVal Reason As LogEntryType, _
	ByVal pwszText As WString Ptr, _
	ByVal pvtData As VARIANT Ptr _
)

#endif
