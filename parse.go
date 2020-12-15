package main

import (
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/arturre/sensorreader/pkg/sensorreader"
	"github.com/gorilla/mux"
)

func Parse() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		Url := vars["reportUrl"]
		//create temporary file
		tmpFile, err := ioutil.TempFile(diskPath, "sensor_reader")
		if err != nil {
			log.Fatal(err)
		}
		defer os.Remove(tmpFile.Name())
		//download file
		err = DownloadUrl(tmpFile.Name(), Url)
		if err != nil {
			log.Printf("Could not download file: %v", err)
			http.Error(w, http.StatusText(http.StatusServiceUnavailable), http.StatusServiceUnavailable)
			return
		}
		//create MAIN Object
		RoomInWorks := sensorreader.New()
		RoomInWorks.Process(tmpFile.Name())
		body := RoomInWorks.PrintReport()
		w.Header().Set("Content-Type", "application/json")
		w.Write(body)
	}
}

// DownloadUrl downloads file
func DownloadUrl(filepath string, url string) error {
	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Create the file
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Write the body to file
	_, err = io.Copy(out, resp.Body)
	return err
}
