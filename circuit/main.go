package main

import (
    "github.com/pik4ez/ndrctl/relay"
    "os"
    "flag"
    "io/ioutil"
)

var baseDir = flag.String("basedir", "/run/ndrctl", "directory, when new fs;s are born")
var name = flag.String("name", "circuit@localhost", "node name")
var cookieFile = flag.String("cookie-file", "", "path to erlang's cookie file")
var port = flag.Int("port", 5858, "change default port")

func main() {
    flag.Parse()
    // read cookie
    cf, err := os.Open(*cookieFile)
    if err != nil {
        panic(err)
    }
    cookie, err := ioutil.ReadAll(cf)
    if err != nil {
        panic(err)
    }
    if _, err := os.Stat(*baseDir); os.IsNotExist(err) {
        err = os.MkdirAll(*baseDir, os.ModeDir | 0777)
        if err != nil {
            panic(err)
        }
    } else {
        panic(err)
    }
    rel := relay.NewRelay(*baseDir, *name, string(cookie))
    rel.Publish(5858)
    shutdown := rel.Start()
    <-shutdown
}
