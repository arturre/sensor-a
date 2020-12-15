package main

import (
	"github.com/gorilla/mux"
)

// Function to create http handler
func Router(projectName, buildTime, commit, release string) *mux.Router {
	r := mux.NewRouter()

	r.HandleFunc("/metadata", metadata(projectName, buildTime, commit, release)).Methods("GET")
	r.Handle("/health", health())
	r.HandleFunc("/parse/{reportUrl}", Parse()).Methods("GET")

	return r
}
