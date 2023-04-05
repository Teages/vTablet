package pointer

import (
	"github.com/Teages/go-vdigi"
)

type Pointer struct {
	screenId int
	device   *vdigi.Pointer
}

func Create(screenUid string) Pointer {
	screenId, _ := vdigi.GetScreens().GetScreenIdByUid(screenUid)
	device, _ := vdigi.CreatePointerForScreen(screenId)
	return Pointer{screenId: screenId, device: device}
}

func (p Pointer) getScreenSize() (int32, int32) {
	screen, _ := vdigi.GetScreens().GetScreen(p.screenId)

	width := screen.Width
	height := screen.Height

	return int32(width), int32(height)
}

func (p Pointer) Update(rawX, rawY int32, pressure uint32) error {
	width, height := p.getScreenSize()
	x := rawX * width / 32767
	y := rawY * height / 32767
	return p.device.Update(x, y, pressure)
}

func (p Pointer) Destroy() {
	p.device.Destroy()
}
