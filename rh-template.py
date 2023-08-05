#!/usr/bin/env python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

from rh_template import expand_and_implode

config = {
    # None - to use project dir name as project name
    "project_name": None,
}

if __name__ == "__main__":
    expand_and_implode(__file__, config)
