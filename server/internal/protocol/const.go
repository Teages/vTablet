package protocol

type EventType uint16

const (
	EvSyn EventType = 0x0000
	// EvKey EventType = 0x0001
	// EvRel EventType = 0x0002
	EvAbs EventType = 0x0003
)

type Syn uint16

const (
	SynReport Syn = 0x0000
	// SynConfig   Syn = 0x0001
	// SynMtReport Syn = 0x0002
	// SynDropped  Syn = 0x0003

	SynPing Syn = 0xffff
)

// type Rel uint16

// const (
// 	RelX           Rel = 0x00
// 	RelY           Rel = 0x01
// 	RelDIAL        Rel = 0x07
// 	RelWHEEL       Rel = 0x08
// 	RelMISC        Rel = 0x09
// 	RelRESERVED    Rel = 0x0a
// 	RelWHEELHIRES  Rel = 0x0b
// 	RelHWHEELHIRES Rel = 0x0c
// )

type Abs uint16

const (
	AbsX        Abs = 0x00
	AbsY        Abs = 0x01
	AbsPressure Abs = 0x18
	AbsTiltX    Abs = 0x1a
	AbsTiltY    Abs = 0x1b
)
