#!/usr/bin/env python3

from .module import Module

class Accel(Module):
    def __init__(self):
        super(Accel, self).__init__()
        self._file = "accel"

    def status(self):
        return self._get()
