package main

import "github.com/lxn/win"

var (
	// sum, _        = vdigiDll.FindProc("sum")
	_setupDigi, _  = vdigiDll.FindProc("setupDigi")
	_updateDigi, _ = vdigiDll.FindProc("updateDigi")
	// destroyDigi, _   = vdigiDll.FindProc("destroyDigi")
	_digiDevice, _, _              = _setupDigi.Call()
	_screenOffsetX, _screenOffsetY = func() (int64, int64) {
		return 0 - int64(win.GetSystemMetrics(win.SM_XVIRTUALSCREEN)), int64(0 - win.GetSystemMetrics(win.SM_YVIRTUALSCREEN))
	}()
)

func updatePointer(rawX, rawY int64, pressure uint32) uintptr {
	console.Log("%d, %d, %d", rawX, rawY, pressure)
	x := rawX + _screenOffsetX
	y := rawY + _screenOffsetY
	result, _, _ := _updateDigi.Call(_digiDevice, uintptr(x), uintptr(y), uintptr(pressure))
	// result, _, _ := _updateDigi.Call(_digiDevice, uintptr(0), uintptr(0), uintptr(0))
	return result
}
