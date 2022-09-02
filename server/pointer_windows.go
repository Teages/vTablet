package main

import (
	"github.com/lxn/win"
)

var (
	// sum, _        = vdigiDll.FindProc("sum")
	// destroyDigi, _   = vdigiDll.FindProc("destroyDigi")
	_setupDigi, _                  = vdigiDll.FindProc("setupDigi")
	_updateDigi, _                 = vdigiDll.FindProc("updateDigi")
	_digiDevice, _, _              = _setupDigi.Call()
	_screenOffsetX, _screenOffsetY = getScreenOffset()
	screenWidth, screenHeight      = getScreenSize()
)

func getScreenOffset() (int64, int64) {
	return 0 - int64(win.GetSystemMetrics(win.SM_XVIRTUALSCREEN)), int64(0 - win.GetSystemMetrics(win.SM_YVIRTUALSCREEN))
}

func getScreenSize() (int64, int64) {
	width := win.GetSystemMetrics(win.SM_CXVIRTUALSCREEN)
	height := win.GetSystemMetrics(win.SM_CYVIRTUALSCREEN)
	console.Log("Screen: (%d, %d)", width, height)
	// register updater

	win.SetWinEventHook(win.WM_SETTINGCHANGE, win.WM_SETTINGCHANGE, 0, func(hWinEventHook win.HWINEVENTHOOK, event uint32, hwnd win.HWND, idObject int32, idChild int32, idEventThread uint32, dwmsEventTime uint32) uintptr {
		return 0
	}, 0, 0, 0|2)

	return int64(width), int64(height)
}

func updatePointer(rawX, rawY int64, pressure uint32) uintptr {
	// console.Log("%d, %d, %d", rawX, rawY, pressure)
	if rawX < 0 {
		rawX = 0
	}
	if rawY < 0 {
		rawY = 0
	}
	x := rawX + _screenOffsetX
	y := rawY + _screenOffsetY
	// console.Log("%d, %d, %d", x, y, pressure)
	result, _, _ := _updateDigi.Call(_digiDevice, uintptr(x), uintptr(y), uintptr(pressure))
	return result
}
