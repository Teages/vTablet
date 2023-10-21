package main

import (
	"bytes"
	"encoding/binary"
	"strconv"

	"github.com/Teages/vTablet/internal/logger"
	"github.com/Teages/vTablet/internal/pointer"
	"github.com/Teages/vTablet/internal/protocol"
	"golang.org/x/net/websocket"
)

var (
	clientCount = 0
)

func pointerServices(screeUid string, c *websocket.Conn) {
	pd := pointer.Create(screeUid)

	clientCount++
	updateConnectState(clientCount)
	defer func() {
		clientCount--
		updateConnectState(clientCount)
		c.Close()
		pd.Destroy()
	}()

	receivedMsg := make([]byte, 512)
	receivedSize := 0
	var err error

	responser := func(msg string) error {
		_, err = c.Write([]byte(msg))
		if logger.Catch(err) {
			return err
		}
		return nil
	}

	for {
		receivedSize, err = c.Read(receivedMsg)
		if logger.Catch(err) {
			break
		}

		func(msg []byte) {
			handler := func(motionType uint16, motionCode uint16, motionValue int32) {
				motion := protocol.EventType(motionType)

				// syn
				if motion == protocol.EvSyn {
					code := protocol.Syn(motionCode)
					switch code {
					case protocol.SynReport:
						pd.Update()
					case protocol.SynPing:
						responser(strconv.Itoa(int(motionValue)))
					}
				}

				// abs
				if motion == protocol.EvAbs {
					code := protocol.Abs(motionCode)
					switch code {
					case protocol.AbsX:
						logger.Log("x %d", motionValue)
						pd.X = int32(motionValue)
					case protocol.AbsY:
						logger.Log("y %d", motionValue)
						pd.Y = int32(motionValue)
					case protocol.AbsPressure:
						logger.Log("pressure %d", motionValue)
						pd.Pressure = uint32(motionValue)
					case protocol.AbsTiltX:
						logger.Log("TiltX %d", motionValue)
						pd.TiltX = int32(motionValue)
					case protocol.AbsTiltY:
						logger.Log("TiltY %d", motionValue)
						pd.TiltY = int32(motionValue)
					default:
						logger.Error("Unknown abs code: %d", code)
					}
				}
			}

			// Pointer Event: type(4) motion(4) value(8), could be multiple
			for i := 0; i < len(msg); i += 8 {
				if i+8 > len(msg) {
					break
				}
				motionType := binary.BigEndian.Uint16(msg[i : i+2])
				motionCode := binary.BigEndian.Uint16(msg[i+2 : i+4])
				var motionValue int32
				binary.Read(bytes.NewReader(msg[i+4:i+8]), binary.BigEndian, &motionValue)
				handler(motionType, motionCode, motionValue)
			}
		}(receivedMsg[:receivedSize])

		if logger.Catch(err) {
			break
		}
	}
}

// utils
