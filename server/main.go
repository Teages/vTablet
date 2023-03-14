package main

import "github.com/Teages/vTablet/internal/pointer"

func main() {
	go initWebServices(23052)
	initTray(func() {
		// onExit
		pointer.Destroy()
	})
}
