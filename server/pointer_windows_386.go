package main

import (
	_ "embed"
	"syscall"

	"github.com/Teages/go-vfile"
)

var (
	//go:embed libs/windows/vdigi_386.dll
	vdigiDllFile []byte
	vdigiDll, _  = syscall.LoadDLL(func() string {
		vfile.Join("vdigi_386.dll", vdigiDllFile)
		return vfile.GetPath("vdigi_386.dll")
	}())
)
