package tools

import (
	"os"
	"os/exec"
	"strings"
	"syscall"

	"github.com/Teages/vTablet/internal/logger"
)

func GetSelfPath() string {
	exePath, err := os.Executable()
	logger.Catch(err)
	return exePath
}

func RunCommand(path string, args ...string) {
	exePath := strings.TrimSpace(path)
	arg := `/c ` + exePath + " " + strings.Join(args, " ")
	e := exec.Command("cmd", arg)
	e.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	logger.Log("Running: %s %s", "cmd", arg)
	e.Stdout = os.Stdout
	e.Stderr = os.Stderr
	err := e.Run()
	logger.Catch(err)
}
