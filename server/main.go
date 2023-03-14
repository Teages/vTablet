package main

func main() {
	go initWebServices(23052)
	initTray(func() {
		// onExit
	})
}
