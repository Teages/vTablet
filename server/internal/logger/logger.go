package logger

import (
	"fmt"
	"time"
)

var (
	logPath = "log/" + time.Now().Format("2006-01-02 15:04:05")
)

func Msg(format string, a ...any) {
	fmt.Printf(format+"\n", a...)
	// TODO: log to file
}

func Log(format string, a ...any) {
	Msg("[LOG]  "+format, a...)
}

func Warn(format string, a ...any) {
	Msg("[WARN] "+format, a...)
}

func Error(format string, a ...any) {
	Msg("[ERR]  "+format, a...)
}

func Catch(err error) bool {
	if err != nil {
		Error(err.Error())
		return true
	}
	return false
}
