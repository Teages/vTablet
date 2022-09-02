package main

import "github.com/getlantern/systray"

func initTray() {
	systray.Run(onReady, onExit)
}

func onReady() {
	systray.SetIcon(AppIconData_Disconnected)
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

func updateConnectState(clientCount int) {
	if clientCount > 0 {
		onConnected()
	} else {
		onNoConnected()
	}
}

func onConnected() {
	systray.SetIcon(AppIconData_Connected)
}

func onNoConnected() {
	systray.SetIcon(AppIconData_Disconnected)
}
