package main

import (
	"log"
	"net/http"
)

var (
	ProjectName = "unset"
	BuildTime   = "unset"
	Commit      = "unset"
	Release     = "unset"

	diskPath = "/tmp"
)

func main() {

	log.Printf("Starting the service ...")

	// Create http handler and pass in enviroment variables from Makefile
	r := Router(ProjectName, BuildTime, Commit, Release)
	log.Print("The service is up and running.")

	// Start a web server on local port 8000
	log.Fatal(http.ListenAndServe(":8000", r))
}
