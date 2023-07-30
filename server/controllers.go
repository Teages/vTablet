package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"

	"github.com/Teages/go-vdigi"
	"golang.org/x/net/websocket"
)

func initWebServices(port int) {
	flag.Parse()
	http.Handle("/digi", digiWS())
	http.HandleFunc("/", clientPage)
	http.HandleFunc("/connect", connecter)

	for i := 0; i < vdigi.GetScreens().GetScreenCount(); i++ {
		screen, _ := vdigi.GetScreens().GetScreen(i)
		http.Handle(fmt.Sprintf("/digi/%s", screen.Uid), connectFactory(screen.Uid))
	}

	addr := flag.String("addr", fmt.Sprintf("0.0.0.0:%d", port), "http service address")
	log.Fatal(http.ListenAndServe(*addr, nil))
}

type ScreenData struct {
	Uid    string `json:"uid"`
	Path   string `json:"path"`
	Width  int    `json:"width"`
	Height int    `json:"height"`
}

func connecter(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "https://vtablet.teages.xyz")
	w.WriteHeader(http.StatusOK)

	var ans []ScreenData
	for i := 0; i < vdigi.GetScreens().GetScreenCount(); i++ {
		screen, _ := vdigi.GetScreens().GetScreen(i)
		ans = append(ans, ScreenData{
			screen.Uid,
			fmt.Sprintf("/digi/%s", screen.Uid),
			screen.Width,
			screen.Height,
		})
	}
	json_str, _ := json.Marshal(ans)
	io.WriteString(w, string(json_str))
}

func connectFactory(screeUid string) websocket.Handler {
	return websocket.Handler(func(c *websocket.Conn) {
		origin := c.Config().Origin.Host
		allows := "http://localhost:23052\n" + "https://vtablet.teages.xyz\n"
		if !strings.Contains(allows, origin) {
			c.Close()
			return
		}
		pointerServices(screeUid, c)
	})
}

func clientPage(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, "https://vtablet.teages.xyz", http.StatusFound)
}

// old api, will remove
func digiWS() websocket.Handler {
	s, _ := vdigi.GetScreens().GetScreen(0)
	return connectFactory(s.Uid)
}
