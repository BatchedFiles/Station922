#ifndef INTERFACEHELPER_BI
#define INTERFACEHELPER_BI

#MACRO SAFE_LET(lhs, rhs)
	(rhs)->lpVtbl->AddRef(rhs)
	lhs = rhs
#ENDMACRO

#MACRO SAFE_RELEASE(lhs)
	(lhs)->lpVtbl->Release(lhs)
	lhs = 0
#ENDMACRO

#endif