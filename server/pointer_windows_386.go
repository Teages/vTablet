package main

import (
	"syscall"
)

var (
	vdigiDll, _ = syscall.LoadDLL(libs("vdigi_386.dll"))
)
