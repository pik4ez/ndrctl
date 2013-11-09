#!/usr/bin/env python3

class Module(object):
    def __init__(self):
        self._path = "/dev/hw/"
        self._file = None

    def _get(self):
        full_path = "%s%s" % (self._path, self._file)
        with open(full_path, 'r') as f:
            data = f.read()
            result = data.split()
            return tuple(map(float, result))

    def _set(self, data):
        full_path = "%s%s" % (self._path, self._file)
        with open(full_path, 'w') as f:
            f.write(data)
