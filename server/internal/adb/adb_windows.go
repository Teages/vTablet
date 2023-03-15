package adb

import (
	"embed"

	"github.com/Teages/go-vfile"
)

var (
	//go:embed windows/*
	adbFiles embed.FS
	adbPath  = func() string {
		vfile.JoinPart("libs/adb", "windows", adbFiles)
		return vfile.GetPath("libs/adb/adb")
	}()
)
