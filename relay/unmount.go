package relay

import (
    "os/exec"
)

func unmount(path string) error {
    cmd := exec.Command("/bin/fusermount", "-u", path)
    return cmd.Run()
}
