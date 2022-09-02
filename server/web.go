package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
		// origin := strings.ToLower(r.Header.Get("Origin"))
		// allows := "http://localhost:23052\n" + "http://localhost:62448\n" + "https://vtablet.teages.xyz\n" + "http://coolaf.com"
		// console.Log("Connect from: " + origin)
		// return strings.Contains(allows, origin)
	},
}

var (
	clientCount = 0
)

func initWebServices() {
	flag.Parse()
	http.HandleFunc("/digi", digiWS)
	http.HandleFunc("/server", serverData)
	http.HandleFunc("/", home)

	addr := flag.String("addr", "0.0.0.0:23052", "http service address")
	log.Fatal(http.ListenAndServe(*addr, nil))

}

func resolve(msg []byte) []byte {
	_, err := strconv.ParseInt(string(msg), 10, 64)
	if err != nil {
		data := strings.Split(string(msg), ",")
		if len(data) < 3 {
			return nil
		}
		x, _ := strconv.ParseInt(data[0], 10, 64)
		y, _ := strconv.ParseInt(data[1], 10, 64)
		p, _ := strconv.ParseInt(data[2], 10, 64)
		updatePointer(x*int64(screenWidth)/32767, y*int64(screenHeight)/32767, uint32(p*2048/8192))
	} else {
		return msg
	}

	return nil
}

func digiWS(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if console.Catch(err) {
		return
	}

	clientCount++
	updateConnectState(clientCount)
	defer func() {
		clientCount--
		updateConnectState(clientCount)
		c.Close()
	}()

	for {
		t, message, err := c.ReadMessage()
		if console.Catch(err) {
			break
		}

		// console.Log("recv: %s", message)
		r := resolve(message)
		if r != nil {
			c.WriteMessage(t, r)
		}

		if console.Catch(err) {
			break
		}

	}
}

// Server Data
func serverData(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/server" {
		http.Error(w, "Not found", http.StatusNotFound)
		return
	}
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	w.Header().Add("Access-Control-Allow-Origin", "*")
	fmt.Fprintf(w, `{"screen": {"width": %d,"height": %d}}`, screenWidth, screenHeight)
}

// HOME
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.Error(w, "Not found", http.StatusNotFound)
		return
	}
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	http.Redirect(w, r, "https://vtablet.teages.xyz", http.StatusFound)
}
