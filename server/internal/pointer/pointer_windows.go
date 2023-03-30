package pointer

import (
	"github.com/Teages/go-vdigi"
	"github.com/Teages/vTablet/internal/logger"
)

var (
	digiDevice                = vdigi.CreatePointerForMainScreen()
	screenWidth, screenHeight = getScreenSize()
)

func getScreenSize() (int32, int32) {
	logger.Log("d")
	screen, _ := vdigi.GetScreens().GetScreen(0)
	width := screen.Width
	height := screen.Height
	logger.Log("Screen: (%d, %d)", width, height)
	// register updater

	// win.SetWinEventHook(win.WM_SETTINGCHANGE, win.WM_SETTINGCHANGE, 0, func(hWinEventHook win.HWINEVENTHOOK, event uint32, hwnd win.HWND, idObject int32, idChild int32, idEventThread uint32, dwmsEventTime uint32) uintptr {
	// 	return 0
	// }, 0, 0, 0|2)

	return int32(width), int32(height)
}

func UpdatePointer(rawX, rawY int32, pressure uint32) error {
	x := rawX * screenWidth / 32767
	y := rawY * screenHeight / 32767
	return digiDevice.Update(x, y, pressure)
}

func Destroy() {
	digiDevice.Destroy()
}
