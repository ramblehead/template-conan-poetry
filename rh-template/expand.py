#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import importlib.util
import os
from pathlib import Path
from types import ModuleType
from typing import Self

from mako.lookup import TemplateLookup  # type: ignore reportMissingTypeStubs


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


sd_path = (Path(__file__).parent / ".").resolve(strict=True)
conf = import_module_from_file(sd_path / "conf.py", "conf")
utils = import_module_from_file(sd_path / "utils.py", "utils")


def expand_template(in_template_path: Path, out_file_path: Path) -> None:
    template_lookup = TemplateLookup(directories=[in_template_path.parent])

    template = template_lookup.get_template(  # type: ignore unknownMemberType
        in_template_path.name,
    )

    file_out_str: str = template.render(  # type: ignore unknownMemberType
        conf=conf,
        utils=utils,
    )

    try:
        with Path.open(out_file_path, "w") as file:
            file.write(file_out_str)
        print(out_file_path)
    except OSError as cause:
        print(f"Error writing to file: {cause}")


def get_file_paths_by_ext(path: Path, ext: str) -> list[Path]:
    file_paths: list[Path] = []

    for root, _, file_names in os.walk(path):
        file_paths += (
            Path(root) / file_name
            for file_name in file_names
            if file_name.endswith(ext)
        )

    return file_paths


def expand_all_project_templates(*, delete_templates: bool) -> None:
    template_ext = ".mako"

    in_template_files = get_file_paths_by_ext(
        sd_path.parent.resolve(strict=True),
        template_ext,
    )

    if in_template_files:
        print("Expanding from mako templates:")

    for in_template_file in in_template_files:
        out_file_path_str = str(in_template_file)
        if out_file_path_str.endswith(template_ext):
            out_file_path_str = out_file_path_str[: -len(template_ext)]

        out_file_path = Path(out_file_path_str)
        expand_template(in_template_file, out_file_path)

        if delete_templates:
            in_template_file.unlink()


if __name__ == "__main__":
    expand_all_project_templates(delete_templates=False)
