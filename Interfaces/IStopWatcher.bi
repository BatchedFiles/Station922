#ifndef ISTOPWATCHER_BI
#define ISTOPWATCHER_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"

Type IStopWatcher As IStopWatcher_

Type LPISTOPWATCHER As IStopWatcher Ptr

Extern IID_IStopWatcher Alias "IID_IStopWatcher" As Const IID

Type IStopWatcherVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim GetFrequency As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pFrequency As LongInt Ptr _
	)As HRESULT
	
	Dim GetElapsedTicks As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pElapsedTicks As LongInt Ptr _
	)As HRESULT
	
	Dim GetElapsedMilliseconds As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pElapsedMilliseconds As LongInt Ptr _
	)As HRESULT
	
	Dim GetTicks As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pTicks As LongInt Ptr _
	)As HRESULT
	
	Dim IsRunning As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pIsRunning As Boolean Ptr _
	)As HRESULT
	
	Dim StartWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
	Dim StopWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
	Dim ResetWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
	Dim RestartWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
End Type

Type IStopWatcher_
	Dim pVirtualTable As IStopWatcherVirtualTable Ptr
End Type

#define IStopWatcher_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IStopWatcher_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IStopWatcher_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IStopWatcher_GetFrequency(this, pFrequency) (this)->pVirtualTable->GetFrequency(this, pFrequency)
#define IStopWatcher_GetElapsedTicks(this, pElapsedTicks) (this)->pVirtualTable->GetElapsedTicks(this, pElapsedTicks)
#define IStopWatcher_GetElapsedMilliseconds(this, pElapsedMilliseconds) (this)->pVirtualTable->GetElapsedMilliseconds(this, pElapsedMilliseconds)
#define IStopWatcher_GetTicks(this, pTicks) (this)->pVirtualTable->GetTicks(this, pTicks)
#define IStopWatcher_IsRunning(this, pIsRunning) (this)->pVirtualTable->IsRunning(this, pIsRunning)
#define IStopWatcher_StartWatch(this) (this)->pVirtualTable->StartWatch(this)
#define IStopWatcher_StopWatch(this) (this)->pVirtualTable->StopWatch(this)
#define IStopWatcher_ResetWatch(this) (this)->pVirtualTable->ResetWatch(this)
#define IStopWatcher_RestartWatch(this) (this)->pVirtualTable->RestartWatch(this)

#endif
'		long nanosecPerTick = (1000L*1000L*1000L) / frequency;
	 ' — измеренное количество тактов
	' GetTicks — получает текущее число тактов
	' IsRunning — запущено ли измерение времени
	' Start — запусает измерение времени
	' Stop — останавливает измерение времени
	' Reset — останавливает измерение времени и обнуляет измеренное время
	' Restart — Останавливает измерение интервала времени, обнуляет затраченное время и начинает измерение затраченного времени
	
	' private const long TicksPerMillisecond = 10000;
' private const long TicksPerSecond = TicksPerMillisecond * 1000;