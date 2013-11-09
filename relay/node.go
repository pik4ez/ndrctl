package relay

import (
    "errors"
    "github.com/goerlang/node"
    "github.com/goerlang/etf"
    "github.com/pik4ez/ndrctl/hwfs"
    "path/filepath"
)

type Relay struct {
    basedir string
    node *node.Node
    fss map[string]*hwfs.FS
}

func NewRelay(basedir, name, cookie string) *Relay {
    return &Relay{basedir, node.NewNode(name, cookie), make(map[string]*hwfs.FS)}
}

func (r *Relay) Publish(port int) error {
    return r.node.Publish(port)
}

func (r *Relay) Start() {
    err := r.node.RpcProvide("relay", "register_fs", r.rpcCreateFS)
    if err != nil {
        panic(err)
    }
    err = r.node.RpcProvide("relay", "register_device", r.rpcCreateDevice)
    if err != nil {
        panic(err)
    }
}

func (r *Relay) createFS(name string) error {
    if _, ok := r.fss[name]; ok {
        return errors.New("fs already exists")
    }
    fsDir := filepath.Join(r.basedir, name)
    myfs := hwfs.NewFS()
    err := myfs.MountAndServe(fsDir)
    if err != nil {
        return err
    }
    r.fss[name] = myfs
    return nil
}

func (r *Relay) createDevice(fsName, deviceName string,
    isSensor, isAffector bool) (etf.Atom, error) {
    fs, ok := r.fss[fsName]
    if !ok {
        return etf.Atom(""), errors.New("no such fs")
    }
    device, err := hwfs.CreateDevice(deviceName, isSensor, isAffector)
    if err != nil {
        return etf.Atom(""), err
    }
    dp := newDeviceProc(device)
    fullName := deviceName + "@" + fsName
    r.node.Spawn(dp, fullName)
    return etf.Atom(fullName), nil
}

// rpc funcs for erlang nodes
// args must be in form `[Name:string]` 
// returns either `ok` or `{error, Reason}`
func (r *Relay) rpcCreateFS(terms etf.List) etf.Term {
    if len(terms) != 1 {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarith")})
    }
    t := terms[0]
    if _, ok := t.(string); !ok {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
    }
    name := t.(string)
    err := r.createFS(name)
    if err != nil {
        println("cannot create fs: ", err)
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("failed-to-create-fs")})
    }
    return etf.Term(etf.Atom("ok"))
}

// args must be in form `[FSName:string, DevName:string, isSensor/optional, 
//    isAffector/optional]
// return `{ok, Pid}` or `{error, Reason}`
func (r *Relay) rpcCreateDevice(terms etf.List) etf.Term {
    if len(terms) != 3 {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarith")})
    }
    tFSName := terms[0]
    if _, ok := tFSName.(string); !ok {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
    }
    fsName := tFSName.(string)
    tDeviceName := terms[1]
    if _, ok := tDeviceName.(string); !ok {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
    }
    deviceName := tDeviceName.(string)
    if _, ok := terms[2].(etf.List); !ok {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
    }
    isSensor, isAffector, err := parseCreateFlags(terms[2].(etf.List))
    if err != nil {
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
    }
    fullName, err := r.createDevice(fsName, deviceName, isSensor, isAffector)
    if err != nil {
        println("failed to create device: ", err)
        return etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("failed-to-create-device")})
    }
    return etf.Term(etf.Tuple{etf.Atom("ok"), fullName})
}

func parseCreateFlags(terms etf.List) (isSensor, isAffector bool, err error) {
    for _, t := range terms {
        if value, ok := t.(etf.Atom); ok {
            switch string(value) {
            case "is_sensor":
                isSensor = true
            case "is_affector":
                isAffector = true
            default:
                return false, false, errors.New("invalid tag")
            }
        }
    }
    return
}
