FROM ubuntu AS builder
RUN export DEBIAN_FRONTEND="noninteractive" && apt update && apt upgrade -y && apt install -y golang

WORKDIR /workdir

COPY ./main.go .

RUN CGO_ENABLED=0 go build -o main main.go

CMD [ "/workdir/main" ]