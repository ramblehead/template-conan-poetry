# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import re
from typing import cast


def make_words(*human_names: str) -> list[str]:
    result: list[str] = []
    for human_name in human_names:
        result += [word.lower() for word in cast(str, re.split(r" |-", human_name))]
    return result


def to_kebab_case(*human_names: str) -> str:
    return "-".join(make_words(*human_names))
