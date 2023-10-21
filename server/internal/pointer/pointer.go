package pointer

import (
	"github.com/Teages/go-vdigi"
)

type AbsPointer struct {
	screenId int
	device   *vdigi.Pointer

	X        int32
	Y        int32
	Pressure uint32
	TiltX    int32
	TiltY    int32
}

func (p AbsPointer) getScreenSize() (int32, int32) {
	screen, _ := vdigi.GetScreens().GetScreen(p.screenId)

	width := screen.Width
	height := screen.Height

	return int32(width), int32(height)
}

func Create(screenUid string) AbsPointer {
	screenId, _ := vdigi.GetScreens().GetScreenIdByUid(screenUid)
	device, _ := vdigi.CreatePointerForScreen(screenId)
	return AbsPointer{screenId: screenId, device: device}
}

func (p AbsPointer) Update() error {
	width, height := p.getScreenSize()
	x := p.X * width / 32767
	y := p.Y * height / 32767
	tiltX := p.TiltX / 32767 / 90
	tiltY := p.TiltY / 32767 / 90
	pressure := p.Pressure
	return p.device.UpdateWithTilt(x, y, pressure, tiltX, tiltY)
}

func (p AbsPointer) Destroy() {
	p.device.Destroy()
}
