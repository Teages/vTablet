package main

import (
	"syscall"
)

var (
	vdigiDll, _ = syscall.LoadDLL(libs("vdigi_amd64.dll"))
)
