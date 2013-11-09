package relay

import (
    "github.com/goerlang/node"
    "github.com/goerlang/etf"
    "github.com/pik4ez/ndrctl/hwfs/fs"
)


// device proc
type deviceProc struct {
    node.GenServerImpl
    device *fs.Device
}

func newDeviceProc(device *fs.Device) *deviceProc {
    return &deviceProc{device: device}
}

// gen_server behavior
func (d *deviceProc) Init(args ...interface{}) {
    println("handling init")
    d.Node.Register(etf.Atom(args[0].(string)), d.Self)
    // initialization done before spawn
}

// sensor update data
// msg must be single binary
func (d *deviceProc) HandleCast(msg *etf.Term) {
    println("handling cast")
    if buf, ok := (*msg).([]byte); ok {
        d.device.Sense(buf)
    }
    // silent drop for invalid casts
}

// affecter data request
// msg must be atom `req`
func (d *deviceProc) HandleCall(msg *etf.Term, from *etf.Tuple) *etf.Term {
    println("handling call")
    if atom, ok := (*msg).(etf.Atom); !ok {
        t := etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
        return &t
    } else {
        if string(atom) != "req" {
            t := etf.Term(etf.Tuple{etf.Atom("error"), etf.Atom("badarg")})
            return &t
        }
        buf := d.device.Affect()
        if buf == nil {
            t := etf.Term(etf.Tuple{etf.Atom("ok"), etf.Atom("nil")})
            return &t
        } else {
            t := etf.Term(etf.Tuple{etf.Atom("ok"), buf})
            return &t
        }
    }
}

func (d *deviceProc) HandleInfo(msg *etf.Term) {
    println("handling info")
}

func (d *deviceProc) Terminate(reason interface{}) {
    println("handling terminate")
}

