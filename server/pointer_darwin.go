package main

import (
	"github.com/go-vgo/robotgo"
)

func updatePointer(x, y int64, pressure uint32) {
	robotgo.MoveMouse(x, y)
	if pressure > 0 {
		robotgo.MouseToggle(`down`, `left`)
	} else {
		robotgo.MouseToggle(`up`, `left`)
	}
}
