package main

import "github.com/Teages/go-vfile"

func main() {
	go initAdbServices()
	go initWebServices(23052)
	initTray(func() {
		// onExit
		console.Log("Cleaning")
		vfile.Close()
	})
}
