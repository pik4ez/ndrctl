package fs

import (
    "bazil.org/fuse"
    "bazil.org/fuse/fs"
    "errors"
    "os"
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

// FIXME: device removing
func (f *FS) CreateDevice(name string, isSensor, isAffector bool) (*Device, error) {
    // FIXME: inode number management
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

func (f *FS) MountAndServe(dir string) error {
    if _, err := os.Stat(dir); os.IsNotExist(err) {
        err = os.MkdirAll(dir, os.ModeDir | 0777)
        if err != nil {
            return err
        }
    } else if err != nil {
        return err
    }
    conn, err := fuse.Mount(dir)
    if err != nil {
        println("mount failed", err.Error())
        return err
    }
    // FIXME: error handling there
    go fs.Serve(conn, f)
    return nil
}
