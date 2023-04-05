package main

import (
	"strconv"
	"strings"

	"github.com/Teages/vTablet/internal/logger"
	"github.com/Teages/vTablet/internal/pointer"
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

	recevedMsg := make([]byte, 512)
	recevedSize := 0
	var err error

	for {
		recevedSize, err = c.Read(recevedMsg)
		if logger.Catch(err) {
			break
		}

		r := func(msg []byte) []byte {
			// Ping: t int64
			_, err := strconv.ParseInt(string(msg), 10, 64)
			if err == nil {
				return msg
			}

			// Pointerevent: x, y int32, p uint32
			data := strings.Split(string(msg), ",")
			if len(data) == 3 {
				x, _ := strconv.ParseInt(data[0], 10, 32)
				y, _ := strconv.ParseInt(data[1], 10, 32)
				p, _ := strconv.ParseInt(data[2], 10, 32)
				pd.Update(int32(x), int32(y), uint32(p*2048/8192))
			}

			return nil
		}(recevedMsg[:recevedSize])

		if r != nil {
			_, err = c.Write(recevedMsg[:recevedSize])
		}
		if logger.Catch(err) {
			break
		}
	}
}
