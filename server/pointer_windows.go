package main

import (
	"github.com/Teages/go-vdigi"
	"github.com/lxn/win"
)

var (
	digiDevice                   = vdigi.CreatePointer()
	screenOffsetX, screenOffsetY = getScreenOffset()
	screenWidth, screenHeight    = getScreenSize()
)

func getScreenOffset() (int32, int32) {
	return 0 - win.GetSystemMetrics(win.SM_XVIRTUALSCREEN), 0 - win.GetSystemMetrics(win.SM_YVIRTUALSCREEN)
}

func getScreenSize() (int32, int32) {
	width := win.GetSystemMetrics(win.SM_CXVIRTUALSCREEN)
	height := win.GetSystemMetrics(win.SM_CYVIRTUALSCREEN)
	console.Log("Screen: (%d, %d)", width, height)
	// register updater

	win.SetWinEventHook(win.WM_SETTINGCHANGE, win.WM_SETTINGCHANGE, 0, func(hWinEventHook win.HWINEVENTHOOK, event uint32, hwnd win.HWND, idObject int32, idChild int32, idEventThread uint32, dwmsEventTime uint32) uintptr {
		return 0
	}, 0, 0, 0|2)

	return width, height
}

func updatePointer(rawX, rawY int32, pressure uint32) error {
	x := rawX + screenOffsetX
	y := rawY + screenOffsetY
	return digiDevice.Update(x, y, pressure)
}
