#!/usr/bin/env python3

from module.engine import Engine
from module.accel import Accel
import os

_p = "/home/tt4/tmp/ndrctl_moduletest/"

def test_if_engine_shows_status():
    # setup
    _f = "engine_status"
    full_path = "%s%s" % (_p, _f)
    with open(full_path, "w") as source:
        source.write("0.100 0.200 0.300")

    # test
    engine = Engine()
    engine._path = _p
    engine._file = _f
    status = engine.status()
    if status == (0.1, 0.2, 0.3):
        print(".")
    else:
        print("F")

    # teardown
    os.remove(full_path)

def test_if_engine_fires():
    # setup
    _f = "engine_fire"
    full_path = "%s%s" % (_p, _f)
    open(full_path, "w").close()

    # test
    engine = Engine()
    engine._path = _p
    engine._file = _f
    engine.fire(0.4, 0.5, 0.6)
    with open(full_path, "r") as source:
        written = source.read()
        if written == "0.400 0.500 0.600":
            print(".")
        else:
            print("F")

    os.remove(full_path)

def test_if_accel_shows_status():
    # setup
    _f = "accel_status"
    full_path = "%s%s" % (_p, _f)
    with open(full_path, "w") as source:
        source.write("0.100 0.200")

    # test
    accel = Accel()
    accel._path = _p
    accel._file = _f
    status = accel.status()
    if status == (0.1, 0.2):
        print(".")
    else:
        print("F")

    # teardown
    os.remove(full_path)
    pass

if __name__ == "__main__":
    test_if_engine_shows_status()
    test_if_engine_fires()
    test_if_accel_shows_status()
