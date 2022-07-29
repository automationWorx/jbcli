FROM golang:latest

RUN go install github.com/charmbracelet/gum@latest
RUN apt-get update && apt-get install vim -y

COPY jbcli.sh .

RUN chmod 755 jbcli.sh
