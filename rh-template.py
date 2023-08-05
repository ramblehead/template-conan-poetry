#!/usr/bin/env python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

from rh_template import expand_and_implode

config = {
    # "project_name": "xxx",
}

if __name__ == "__main__":
    expand_and_implode(__file__, config)
