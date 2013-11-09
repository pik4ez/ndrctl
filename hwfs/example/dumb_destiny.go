package main

import (
    "bazil.org/fuse"
    fsup "bazil.org/fuse/fs"
    "github.com/pik4ez/ndrctl/hwfs/fs"
    "strconv"
    "time"
)

type DumbDestiny struct {
    fss map[string]*fs.FS
}

func newDumbDestiny() *DumbDestiny {
    return &DumbDestiny{make(map[string]*fs.FS)}
}

func (d *DumbDestiny) CreateFS(mountpoint string) (*fs.FS, chan struct{}, error) {
    conn, err := fuse.Mount(mountpoint)
    if err != nil {
        return nil, nil, err
    }
    f := fs.NewFS()
    done := make(chan struct{})
    go func(done chan struct{}) {
        fsup.Serve(conn, f)
        done <- struct{}{}
    }(done)
    return f, done, nil
}

func dumbTickSensor(dev *fs.Device) {
    var id int
    for _ = range time.NewTicker(time.Second).C {
        id++
        str := strconv.Itoa(id)
        dev.Sense([]byte(str))
        if id == 5 {
            break
        }
    }
}

func dumbTickAffecter(dev *fs.Device) {
    for _ = range time.NewTicker(time.Second).C {
        buf := dev.Affect()
        if buf == nil {
            println("affecter got empty command")
        } else {
            println("affecter got command: ", string(buf))
        }
    }
}
