#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-


# from mako.lookup import TemplateLookup

# from . import conf

import importlib.util
from pathlib import Path
from types import ModuleType
from typing import Self

_sd_path = (Path(__file__).parent / ".").resolve(strict=True)


class ImportModuleFromFileError(ModuleNotFoundError):
    def __init__(self: Self, module_path: Path) -> None:
        super().__init__(f"Module '{module_path}' not found.")


def import_module_from_file(module_path: Path, module_name: str) -> ModuleType:
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    if spec is None or spec.loader is None:
        raise ImportModuleFromFileError(module_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


conf = import_module_from_file(_sd_path / "conf.py", "conf")

# def expand_content(template_in_path: Path, file_out_path: Path) -> None:
#     template_lookup = TemplateLookup(directories=[template_in_path.parent])
#     template = template_lookup.get_template(template_in_path.name)
#     file_out_str: str = template.render(conf=conf)

#     try:
#         with Path.open(file_out_path, "w") as file:
#             file.write(file_out_str)
#         print("String successfully written to", file_out_path)
#     except OSError as cause:
#         print("Error writing to file:", str(cause))


# template_in_path = (
#     Path(__file__).parent.resolve(strict=True) / ".rh-project.rename" / "init.el.mako"
# )

# file_out_path = (
#     Path(__file__).parent.resolve(strict=True) / ".rh-project.rename" / "init.el"
# )

# print(template_in_path, file_out_path)

# expand_content(template_in_path, file_out_path)

print("xxx", conf.project_name)
