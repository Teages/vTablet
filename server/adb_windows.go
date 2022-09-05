package main

import (
	"embed"

	"github.com/Teages/go-vfile"
)

var (
	//go:embed libs/windows/adb/*
	adbFiles embed.FS
	adbPath  = func() string {
		vfile.JoinPart("libs/adb", "libs/windows/adb", adbFiles)
		return vfile.GetPath("libs/adb/adb")
	}()
)
