package main

import (
	"fmt"
	"time"
)

var (
	console = initConsole()
)

type Console struct {
	logPath string
}

func initConsole() Console {
	return Console{
		logPath: "log/" + time.Now().Format("2006-01-02 15:04:05"),
	}
}

func (c Console) Msg(format string, a ...any) {
	fmt.Printf(format+"\n", a...)
	// TODO: log to file
}

func (c Console) Log(format string, a ...any) {
	c.Msg("[LOG]  "+format, a...)
}

func (c Console) Warn(format string, a ...any) {
	c.Msg("[WARN] "+format, a...)
}

func (c Console) Error(format string, a ...any) {
	c.Msg("[ERR]  "+format, a...)
}

func (c Console) Catch(err error) bool {
	if err != nil {
		c.Error(err.Error())
		return true
	}
	return false
}
