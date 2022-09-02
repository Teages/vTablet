package main

func main() {
	go initAdbServices()
	go initWebServices()
	initTray()
}
