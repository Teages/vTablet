package main

import (
	"fmt"
	"log"
	"os/exec"
	"runtime"

	"github.com/Teages/go-autostart"
	"github.com/Teages/vTablet/internal/adb"
	"github.com/Teages/vTablet/internal/logger"
	. "github.com/Teages/vTablet/internal/tools"
	"github.com/getlantern/systray"
)

var (
	appName    = "vTablet"
	appVersion = "v3.0.0 (Preview 4)"
)

func initTray(onExit func()) {
	systray.Run(func() {
		systray.SetIcon(AppIconData_Disconnected)
		systray.SetTitle("vTablet")
		systray.SetTooltip("vTablet")

		mAbout := systray.AddMenuItem(fmt.Sprint(appName, " ", appVersion), "About")

		go func() {
			for {
				<-mAbout.ClickedCh
				openBrowser("https://github.com/Teages/vTablet")
			}
		}()

		systray.AddSeparator()

		// Start with OS
		aStartWithOS := &autostart.App{
			Name:        "vTablet",
			DisplayName: "Auto start vTablet services",
			Exec:        []string{GetSelfPath()},
		}
		mStartWithOS := systray.AddMenuItemCheckbox("Start with OS", "Start with OS", aStartWithOS.IsEnabled())
		go func() {
			for {
				<-mStartWithOS.ClickedCh
				if aStartWithOS.IsEnabled() {
					logger.Catch(aStartWithOS.Disable())
					mStartWithOS.Uncheck()
				} else {
					logger.Catch(aStartWithOS.Enable())
					mStartWithOS.Check()
				}
			}
		}()

		systray.AddSeparator()

		mAdb := systray.AddMenuItem("Restart ADB", "Restart ADB services")
		go func() {
			for {
				<-mAdb.ClickedCh
				adb.Restart()
			}
		}()

		mQuit := systray.AddMenuItem("Quit", "Quit the app")
		go func() {
			<-mQuit.ClickedCh
			systray.Quit()
		}()
	}, onExit)
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
func openBrowser(url string) {
	var err error

	switch runtime.GOOS {
	case "linux":
		err = exec.Command("xdg-open", url).Start()
	case "windows":
		err = exec.Command("rundll32", "url.dll,FileProtocolHandler", url).Start()
	case "darwin":
		err = exec.Command("open", url).Start()
	default:
		err = fmt.Errorf("unsupported platform")
	}
	if err != nil {
		log.Fatal(err)
	}

}
