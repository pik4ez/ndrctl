package main

import (
    "github.com/pik4ez/ndrctl/relay"
    "time"
    "flag"
)

func main() {
    flag.Parse()
    rel := relay.NewRelay("workdir", "relay@localhost", "123")
    rel.Publish(5858)
    rel.Start()
    time.Sleep(time.Second * 300)
}
