package main

import (
)


func main() {
    d := newDumbDestiny()
    fs, done, err := d.CreateFS("./workdir/testmount")
    if err != nil {
        panic(err)
    }
    dev, err := fs.CreateDevice("test1", true, true)
    if err != nil {
        panic(err)
    }
    go dumbTickSensor(dev)
    go dumbTickAffecter(dev)

    <-done
}
