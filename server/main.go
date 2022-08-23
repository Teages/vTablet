package main

import (
	"github.com/getlantern/systray"
)

func main() {
	go initAdbServices()
	go initWebServices()
	systray.Run(onReady, onExit)
}

func onReady() {
	systray.SetIcon(AppIconData)
	systray.SetTitle("vTablet")
	systray.SetTooltip("vTablet")
	mAdb := systray.AddMenuItem("restart ADB", "Quit the app")
	go func() {
		for {
			<-mAdb.ClickedCh
			restartAdbServices()
		}
	}()

	mQuit := systray.AddMenuItem("Quit", "Quit the app")
	go func() {
		<-mQuit.ClickedCh
		systray.Quit()
	}()
}

func onExit() {
	// clean up here
}
