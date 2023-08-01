# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

def rename(config, utils):
    return f"{utils.to_kebab_case(config["project_name"])}.txt"
