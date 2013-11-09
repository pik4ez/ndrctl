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
    req := newReadReq()
    f.device.readReqs<- req
    resp := <-*req
    if resp.err != nil {
        fResp.Data = fResp.Data[:0]
    } else {
        n := copy(fResp.Data, resp.input)
        fResp.Data = fResp.Data[:n]
    }
    return resp.err
}

func (f *FuseDevice) Write(fReq *fuse.WriteRequest, fResp *fuse.WriteResponse,
    i fs.Intr) fuse.Error {
    req := newWriteReq(fReq.Data)
    f.device.writeReqs <- req
    err := <-(*req).response
    return err
}
