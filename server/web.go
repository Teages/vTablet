package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
		origin := strings.ToLower(r.Header.Get("Origin"))
		allows := "http://localhost:23052\n" + "http://localhost:62448\n" + "https://vtablet.teages.xyz\n" + "http://coolaf.com"
		console.Log("Connect from: " + origin)
		return strings.Contains(allows, origin)
	},
}

var (
	clientCount = 0
)

func initWebServices() {
	flag.Parse()
	http.HandleFunc("/digi", digiWS)
	http.HandleFunc("/server", serverData)
	http.HandleFunc("/settings", settings)
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
		updatePointer(x*int64(screenX)/32767, y*int64(screenY)/32767, uint32(p*2048/8192))
	} else {
		return msg
	}

	return nil
}

func digiWS(w http.ResponseWriter, r *http.Request) {
	console.Log("dddd")
	c, err := upgrader.Upgrade(w, r, nil)
	if console.Catch(err) {
		return
	}

	clientCount++
	defer func() {
		clientCount--
		c.Close()
	}()
	for {
		t, message, err := c.ReadMessage()
		if console.Catch(err) {
			break
		}

		console.Log("recv: %s", message)
		r := resolve(message)
		if r != nil {
			c.WriteMessage(t, r)
		}

		if console.Catch(err) {
			break
		}

	}
}

// Settings
func settings(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "*")
	if r.URL.Path != "/settings" {
		http.Error(w, "Not found", http.StatusNotFound)
		return
	}
	if r.Method == http.MethodGet {
		http.ServeFile(w, r, exeDir("settings.json"))
	} else if r.Method == http.MethodPost {
		body, err := io.ReadAll(r.Body)
		if console.Catch(err) {
			return
		}
		err = os.WriteFile(exeDir("settings.json"), body, 0644)
		console.Catch(err)
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
	fmt.Fprintf(w, `{"screen": {"width": %d,"height": %d}}`, screenX, screenY)
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
	http.ServeFile(w, r, exeDir("index.html"))
}
