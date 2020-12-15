package main

import (
	"net/http"
	"time"

	"github.com/etherlabsio/healthcheck"
	"github.com/etherlabsio/healthcheck/checkers"
)

func health() http.Handler {
	return healthcheck.Handler(

		healthcheck.WithTimeout(5*time.Second),

		healthcheck.WithChecker("heartbeat", checkers.Heartbeat("/")),
		healthcheck.WithObserver(
			"diskspace", checkers.DiskSpace(diskPath, 5),
		),
	)
}
