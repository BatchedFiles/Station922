#ifndef CONTAINEROF_BI
#define CONTAINEROF_BI

#ifndef ContainerOf
#define ContainerOf(pObject, ObjectName, FieldName) CPtr(ObjectName Ptr, (CInt(pObject) - OffsetOf(ObjectName, FieldName)))
#endif

#endif
