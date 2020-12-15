# VARIABLES
PACKAGE="github.com/arturre/sensor-reader"
APP?="sensor-reader"
RELEASE?=0.1
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
GOOS?=linux
GOARCH?=amd64

default: usage

clean: ## Trash binary files
	@echo "--> cleaning..."
	@go clean || (echo "Unable to clean project" && exit 1)
	@rm -rf $(GOPATH)/bin/$(APP) 2> /dev/null
	@echo "Clean OK"

test: ## Run all tests
	@echo "--> testing..."
	@go test -v $(PACKAGE)/...

build: clean ## Build app
	@go mod download
	CGO_ENABLED=0 GOOS=${GOS} GOARCH=${GOARCH} go build \
	-ldflags "-s -w -X main.Release=${RELEASE} \
	-X main.Commit=${COMMIT} -X main.BuildTime=${BUILD_TIME} \
	-X main.ProjectName=${APP}" \
	-o ${APP}

install: clean ## Compile sources and build binary
	@echo "--> installing..."
	@go install $(PACKAGE) || (echo "Compilation error" && exit 1)
	@echo "Install OK"

run: install ## Run  app
	@echo "--> running application..."
	@$(GOPATH)/bin/$(APP)

usage: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
