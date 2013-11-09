package fs

import (
    "bazil.org/fuse"
    "bazil.org/fuse/fs"
)


type FuseDevice struct {
    device *Device
}

func newFuseDevice(d *Device) *FuseDevice {
    return &FuseDevice{d}
}

// base file interface
func (f *FuseDevice) Attr() fuse.Attr {
    // FIXME: correct attrs
    return fuse.Attr{Inode: 1, Mode: 0444}
}

// io
func (f *FuseDevice) Read(fReq *fuse.ReadRequest, fResp *fuse.ReadResponse,
    i fs.Intr) fuse.Error {
    println("read request, bufsize: ", cap(fResp.Data), fReq.Size)
    req := newReadReq()
    f.device.readReqs<- req
    resp := <-*req
    if resp.err != nil {
        fResp.Data = fResp.Data[:0]
    } else {
        n := copy(fResp.Data[:fReq.Size], resp.input)
        fResp.Data = fResp.Data[:n]
        println("return on read: ", fResp.Data, resp.err)
    }
    return resp.err
}

func (f *FuseDevice) Write(fReq *fuse.WriteRequest, fResp *fuse.WriteResponse,
    i fs.Intr) fuse.Error {
    println("write request, datasize: ", len(fReq.Data))
    req := newWriteReq(fReq.Data)
    f.device.writeReqs <- req
    err := <-(*req).response
    if err == nil {
        fResp.Size = len(fReq.Data)
    }
    println("return on write: ", err)
    return err
}
