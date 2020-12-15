FROM golang:latest AS builder
ENV APP  sensor-reader
ADD . /app
WORKDIR /app
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -o /${APP} .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /${APP} ./
RUN chmod +x ./${APP}
ENTRYPOINT [ "./${APP}" ]
EXPOSE 8000