package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func metadata(projectName, buildTime, commit, release string) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		info := struct {
			ProjectName string `json:"projectName"`
			BuildTime   string `json:"buildTime"`
			Commit      string `json:"commit"`
			Release     string `json:"release"`
		}{
			projectName, buildTime, commit, release,
		}

		body, err := json.Marshal(info)
		if err != nil {
			log.Printf("Could not encode info data: %v", err)
			http.Error(w, http.StatusText(http.StatusServiceUnavailable), http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Write(body)
	}
}
