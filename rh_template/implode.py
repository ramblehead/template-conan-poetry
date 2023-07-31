#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import importlib.util
from pathlib import Path
from types import ModuleType
from typing import Self


class ImportFromFileError(ModuleNotFoundError):
    def __init__(self: Self, module_path: Path) -> None:
        super().__init__(f"Module '{module_path}' not found.")


def import_module_from_file(
    module_path: Path,
    *,
    module_name: str | None = None,
) -> ModuleType:
    module_name = module_name or module_path.stem
    spec = importlib.util.spec_from_file_location(module_name, module_path)

    if spec is None or spec.loader is None:
        raise ImportFromFileError(module_path)

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sd_path = (Path(__file__).parent).resolve(strict=True)
expand = import_module_from_file(sd_path / "expand.py")

if __name__ == "__main__":
    expand.expand_all_project_templates(delete_templates=True)
    expand.do_renaming(delete_origins=True)
    expand.implode()
