#!/usr/bin/env python3

from .module import Module

class Engine(Module):
    def __init__(self):
        super(Engine, self).__init__()
        self._file = "engine"

    def status(self):
        return self._get()

    def fire(self, left, center, right):
        self._set("%.3f %.3f %.3f" % (left, center, right))
