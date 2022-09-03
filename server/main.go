package main

import "github.com/Teages/go-vfile"

func main() {
	go initAdbServices()
	go initWebServices()
	initTray(func() {
		// onExit
		console.Log("Cleaning")
		vfile.Close()
	})
}
