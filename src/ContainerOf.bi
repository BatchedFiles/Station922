#ifndef CONTAINEROF_BI
#define CONTAINEROF_BI

#ifndef ContainerOf
#define ContainerOf(pInterface, ClassName, FieldName) CPtr(ClassName Ptr, (CInt(pInterface) - OFFSETOF(ClassName, FieldName)))
#endif

#endif
