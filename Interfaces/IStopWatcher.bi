#ifndef ISTOPWATCHER_BI
#define ISTOPWATCHER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IStopWatcher As IStopWatcher_

Type LPISTOPWATCHER As IStopWatcher Ptr

Extern IID_IStopWatcher Alias "IID_IStopWatcher" As Const IID

Type IStopWatcherVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IStopWatcher Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IStopWatcher Ptr _
	)As ULONG
	
	GetFrequency As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pFrequency As LongInt Ptr _
	)As HRESULT
	
	GetTicks As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pTicks As LongInt Ptr _
	)As HRESULT
	
	GetElapsedTicks As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pElapsedTicks As LongInt Ptr _
	)As HRESULT
	
	GetElapsedMilliseconds As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pElapsedMilliseconds As LongInt Ptr _
	)As HRESULT
	
	IsRunning As Function( _
		ByVal this As IStopWatcher Ptr, _
		ByVal pIsRunning As Boolean Ptr _
	)As HRESULT
	
	StartWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
	StopWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
	ResetWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
	RestartWatch As Function( _
		ByVal this As IStopWatcher Ptr _
	)As HRESULT
	
End Type

Type IStopWatcher_
	lpVtbl As IStopWatcherVirtualTable Ptr
End Type

#define IStopWatcher_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IStopWatcher_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IStopWatcher_Release(this) (this)->lpVtbl->Release(this)
#define IStopWatcher_GetFrequency(this, pFrequency) (this)->lpVtbl->GetFrequency(this, pFrequency)
#define IStopWatcher_GetTicks(this, pTicks) (this)->lpVtbl->GetTicks(this, pTicks)
#define IStopWatcher_GetElapsedTicks(this, pElapsedTicks) (this)->lpVtbl->GetElapsedTicks(this, pElapsedTicks)
#define IStopWatcher_GetElapsedMilliseconds(this, pElapsedMilliseconds) (this)->lpVtbl->GetElapsedMilliseconds(this, pElapsedMilliseconds)
#define IStopWatcher_IsRunning(this, pIsRunning) (this)->lpVtbl->IsRunning(this, pIsRunning)
#define IStopWatcher_StartWatch(this) (this)->lpVtbl->StartWatch(this)
#define IStopWatcher_StopWatch(this) (this)->lpVtbl->StopWatch(this)
#define IStopWatcher_ResetWatch(this) (this)->lpVtbl->ResetWatch(this)
#define IStopWatcher_RestartWatch(this) (this)->lpVtbl->RestartWatch(this)

#endif
	' GetFrequency — количество тиков (операций) в секунду
	' GetTicks — количество операций с начала запуска операционной системы
	' GetElapsedTicks — количество измеренных операций (от Start до Stop)
	' GetElapsedMilliseconds — количество измеренных миллисекунд
'		long nanosecPerTick = (1000L*1000L*1000L) / frequency;
	' IsRunning — запущено ли измерение времени
	' Start — запусает измерение времени
	' Stop — останавливает измерение времени
	' Reset — останавливает измерение времени и обнуляет измеренное время
	' Restart — Останавливает измерение интервала времени, обнуляет затраченное время и начинает измерение затраченного времени
	
	' private const long TicksPerMillisecond = 10000;
' private const long TicksPerSecond = TicksPerMillisecond * 1000;
' //
' // We now have the elapsed number of ticks, along with the
' // number of ticks-per-second. We use these values
' // to convert to the number of elapsed microseconds.
' // To guard against loss-of-precision, we convert
' // to microseconds *before* dividing by ticks-per-second.
' //

' ElapsedMicroseconds.QuadPart *= 1000000;
' ElapsedMicroseconds.QuadPart /= Frequency.QuadPart;