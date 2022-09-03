package main

import (
	"embed"
	"flag"

	"github.com/Teages/go-vfile"
	adb "github.com/zach-klippenstein/goadb"
)

var (
	//go:embed libs/windows/adb/*
	adbFiles embed.FS
	adbPath  = func() string {
		vfile.JoinPart("libs/adb", "libs/windows/adb", adbFiles)
		return vfile.GetPath("libs/adb/adb")
	}()
	adbClient = func() *adb.Adb {
		a, _ := adb.NewWithConfig(adb.ServerConfig{
			Port: *flag.Int("p", adb.AdbPort, ""),
		})
		a.StartServer()
		return a
	}()
)

func adbWatch(f func(adb.DeviceStateChangedEvent)) {
	go func() {
		for {
			w := adbClient.NewDeviceWatcher()
			for event := range w.C() {
				// console.Log("\t[%s]%+v\n", time.Now(), event)
				f(event)
			}
		}
	}()
}

func adbAutoConnect(c func(string)) {
	adbWatch(func(event adb.DeviceStateChangedEvent) {
		if event.NewState == adb.StateOnline {
			console.Log(event.Serial)
			c(event.Serial)
		}
	})
}

func adbExec(args ...string) {
	cmd(adbPath, args...)
}

func initAdbServices() {
	// restartAdbServices()
	adbClient.StartServer()
	adbAutoConnect(func(serial string) {
		adbExec("-s", serial, "reverse tcp:23052 tcp:23052")
		adbExec("-s", serial, "shell am start -a android.intent.action.VIEW -d http://vtablet.teages.xyz?server=localhost:23052")
	})
}

func restartAdbServices() {
	adbClient.KillServer()
	adbClient.StartServer()
}
