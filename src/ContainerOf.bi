#ifndef CONTAINEROF_BI
#define CONTAINEROF_BI

#ifndef ContainerOf
#define ContainerOf(pObject, ObjectName, FieldName) CPtr(ObjectName Ptr, (CInt(pObject) - OFFSETOF(ObjectName, FieldName)))
#endif

#endif
