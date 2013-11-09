package fs

import (
    "bazil.org/fuse"
    "bazil.org/fuse/fs"
    "errors"
)


type FS struct {
    root *fs.Tree
}

func NewFS() *FS {
    return &FS{&fs.Tree{}}
}

func (f *FS) Root() (fs.Node, fuse.Error) {
    return f.root.Root()
}

func (f *FS) CreateDevice(name string, isSensor, isAffector bool) (*Device, error) {
    _, err := f.LookupDevice(name)
    if err == nil {
        // already exist
        return nil, errors.New("device already exist")
    }
    device := NewDevice(isSensor, isAffector)
    fuseDevice := newFuseDevice(device)
    f.root.Add(name, fuseDevice)
    return device, nil
}

func (f *FS) LookupDevice(name string) (*Device, error) {
    node, err := f.root.Lookup(name, nil)
    if err != nil {
        // FIXME: proper error
        return nil, errors.New("no such device")
    }
    fuseDevice, ok := node.(*FuseDevice)
    if !ok {
        return nil, errors.New("not a device")
    }
    return fuseDevice.device, nil
}
