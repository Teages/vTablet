package main

import (
	"github.com/Teages/go-vfile"
	_ "github.com/Teages/vTablet/internal/adb"
)

func main() {
	go initWebServices(23052)
	initTray(func() {
		// onExit
		vfile.Close()
	})
}
