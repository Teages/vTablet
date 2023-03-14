package main

import (
	"os"
	"os/exec"
	"strings"
	"syscall"

	"github.com/Teages/vTablet/internal/logger"
)

func selfPath() string {
	exePath, _ := os.Executable()
	return exePath
}

func cmd(path string, args ...string) {
	exePath := strings.TrimSpace(path)
	arg := `/c ` + exePath + " " + strings.Join(args, " ")
	e := exec.Command("cmd", arg)
	e.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	logger.Log("Running: %s %s", exePath, arg)
	e.Stdout = os.Stdout
	e.Stderr = os.Stderr
	err := e.Run()
	logger.Catch(err)
}
