package hwfs

import (
    "bazil.org/fuse"
)


type Device struct {
    // fan/collect side
    isSensor, isAffector bool
    inputPipe chan []byte
    outputPipe chan chan []byte
    clock chan struct{}

    // input for this tick
    input []byte

    // fuse side
    readReqs chan *readReq
    writeReqs chan *writeReq

    readQueue []*readReq
    writeQueue []*writeReq
}

func NewDevice(isSensor, isAffector bool) *Device {
    d := &Device{isSensor, isAffector, nil, nil, make(chan struct{}), nil,
        make(chan *readReq), make(chan *writeReq),
        make([]*readReq, 0), make([]*writeReq, 0)}

    if isSensor {
        d.inputPipe = make(chan []byte)
    }
    if isAffector {
        d.outputPipe = make(chan chan []byte)
    }
    go d.loop()
    return d
}

func (d *Device) loop() {
    for {
        select {
        // fan/collect side updates
        case inputReq := <-d.inputPipe:
            // if we have queued read requests
            if len(d.readQueue) > 0 {
                var req *readReq
                d.readQueue, req = popReadQ(d.readQueue)
                *req <- readResp{inputReq, nil}
            } else {
                // no one waits for input, save it for a tick
                d.input = inputReq
            }
        case outputReq := <-d.outputPipe:
            // return affector's data or nil
            if len(d.writeQueue) > 0 {
                var req *writeReq
                d.writeQueue, req = popWriteQ(d.writeQueue)
                outputReq<- req.output
                req.response<- nil
            } else {
                outputReq <- nil
            }
        case <-d.clock:
            // invalidate unread (stale) input
            d.input = nil

        // fuse requests
        case readReq := <-d.readReqs:
            // if it is not a sensor, return error
            if !d.isSensor {
                *readReq <- readResp{nil, fuse.EPERM}
                continue
            }
            // if we have unread input, read it
            if d.input != nil {
                *readReq <- readResp{d.input, nil}
                d.input = nil
            } else {
                // otherwise, queue read
                d.readQueue = append(d.readQueue, readReq)
            }
        case writeReq := <-d.writeReqs:
            // if it is not a affector, return error
            if !d.isAffector {
                writeReq.response <- fuse.EPERM
                continue
            }
            // always queue writes to next tick sync
            d.writeQueue = append(d.writeQueue, writeReq)
        }
    }
}

func (d *Device) Sense(input []byte) {
    d.inputPipe <- input
}

func (d *Device) Affect() []byte {
    ch := make(chan []byte)
    d.outputPipe <- ch
    return <-ch
}

func (d *Device) Tick() {
    d.clock <- struct{}{}
}


type readResp struct {
    input []byte
    err fuse.Error
}

type readReq chan readResp

func newReadReq() *readReq {
    r := readReq(make(chan readResp))
    return &r
}


type writeReq struct {
    output []byte
    response chan fuse.Error
}

func newWriteReq(input []byte) *writeReq {
    return &writeReq{input, make(chan fuse.Error)}
}


func popReadQ(q []*readReq) ([]*readReq, *readReq) {
    if len(q) == 0 {
        return q, nil
    }
    rq := q[0]
    copy(q, q[1:])
    q = q[:len(q) - 1]
    return q, rq
}

func popWriteQ(q []*writeReq) ([]*writeReq, *writeReq) {
    if len(q) == 0 {
        return q, nil
    }
    rq := q[0]
    copy(q, q[1:])
    q = q[:len(q) - 1]
    return q, rq
}
