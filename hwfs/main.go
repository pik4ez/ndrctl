package main

import (
    "os"
    "bazil.org/fuse"
    "bazil.org/fuse/fs"
    "time"
)

type Dir struct{}

func (Dir) Attr() fuse.Attr {
    return fuse.Attr{Inode: 1, Mode: os.ModeDir | 0555}
}

type File struct{}

func (File) Attr() fuse.Attr {
    return fuse.Attr{Mode: 0444}
}

func (File) ReadAll(fs.Intr) ([]byte, fuse.Error) {
    time.Sleep(time.Second)
    return []byte("hello world!"), nil
}

func (Dir) Lookup(name string, intr fs.Intr) (fs.Node, fuse.Error) {
    return File{}, nil
}

type FS struct{}

func (FS) Root() (fs.Node, fuse.Error) {
    return Dir{}, nil
}

var dirDirs = []fuse.Dirent{
    {Inode: 2, Name: "hello", Type: fuse.DT_File},
    {Inode: 3, Name: "hello2", Type: fuse.DT_File},
}

func (Dir) ReadDir(intr fs.Intr) ([]fuse.Dirent, fuse.Error) {
    return dirDirs, nil
}


func main() {
    conn, err := fuse.Mount("./workdir/testmount")
    if err != nil {
        panic(err)
    }

    fs.Serve(conn, FS{})
}
