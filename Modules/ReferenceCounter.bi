#ifndef REFERENCECOUNTER_BI
#define REFERENCECOUNTER_BI

#include once "windows.bi"

#ifdef __FB_64BIT__

Type _ReferenceCounter
	Counter As LONG64
	#ifndef WITHOUT_CRITICAL_SECTIONS
		crSection As CRITICAL_SECTION
	#endif
End Type

#else

Type _ReferenceCounter
	Counter As LONG
	#ifndef WITHOUT_CRITICAL_SECTIONS
		crSection As CRITICAL_SECTION
	#endif
End Type

#endif

Type ReferenceCounter As _ReferenceCounter

Type LPReferenceCounter As _ReferenceCounter Ptr

Declare Sub ReferenceCounterInitialize( _
	ByVal pCounter As ReferenceCounter Ptr _
)

Declare Sub ReferenceCounterUnInitialize( _
	ByVal pCounter As ReferenceCounter Ptr _
)

#ifdef __FB_64BIT__

Declare Function ReferenceCounterIncrement Alias "ReferenceCounterIncrement64"( _
	ByVal pCounter As ReferenceCounter Ptr _
)As LONG64

Declare Function ReferenceCounterDecrement Alias "ReferenceCounterDecrement64"( _
	ByVal pCounter As ReferenceCounter Ptr _
)As LONG64

Declare Function ReferenceCounterGetValue Alias "ReferenceCounterGetValue64"( _
	ByVal pCounter As ReferenceCounter Ptr _
)As LONG64

#else

Declare Function ReferenceCounterIncrement Alias "ReferenceCounterIncrement"( _
	ByVal pCounter As ReferenceCounter Ptr _
)As LONG

Declare Function ReferenceCounterDecrement Alias "ReferenceCounterDecrement"( _
	ByVal pCounter As ReferenceCounter Ptr _
)As LONG

Declare Function ReferenceCounterGetValue Alias "ReferenceCounterGetValue"( _
	ByVal pCounter As ReferenceCounter Ptr _
)As LONG

#endif

#endif
