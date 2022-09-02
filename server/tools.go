package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func selfPath() string {
	exePath, _ := os.Executable()
	return exePath
}

func exeDir(path string) string {
	exePath := selfPath()
	dir := filepath.Dir(exePath)
	return dir + "/" + path
}

func libs(path string) string {
	return exeDir("libs/" + path)
}

func cmd(path string, args ...string) {
	exePath := strings.TrimSpace(path)
	arg := `/c ` + exePath + " " + strings.Join(args, " ")
	e := exec.Command("cmd", arg)
	console.Log("Running: %s %s", exePath, arg)
	e.Stdout = os.Stdout
	e.Stderr = os.Stderr
	err := e.Run()
	console.Catch(err)
}
