package main

func main() {
	go initAdbServices()
	go initWebServices()
	initTray(func() {
		// onExit
	})
}
