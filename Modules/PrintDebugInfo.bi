#ifndef PRINTDEBUGINFO_BI
#define PRINTDEBUGINFO_BI

#include "HttpReader.bi"

Declare Sub PrintRequestedBytes( _
	ByVal pIHttpReader As IHttpReader Ptr _
)

Declare Sub PrintResponseString( _
	ByVal wResponse As WString Ptr, _
	ByVal StatusCode As Integer _
)

#ifdef PERFORMANCE_TESTING

Declare Sub PrintRequestElapsedTimes( _
	ByVal pFrequency As PLARGE_INTEGER, _
	ByVal pTicks As PLARGE_INTEGER _
)

Declare Sub PrintThreadSuspendedElapsedTimes( _
	ByVal pFrequency As PLARGE_INTEGER, _
	ByVal pTicks As PLARGE_INTEGER _
)

#endif

#endif
