#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import importlib.util
import os
import shutil
import sys
from pathlib import Path
from types import ModuleType
from typing import Self

from mako.lookup import TemplateLookup  # type: ignore reportMissingTypeStubs


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


def import_module_in_package_from_file(
    module_path: Path,
    *,
    package_name: str | None = None,
    module_name: str | None = None,
) -> ModuleType:
    package_path = module_path.parent
    package_name = package_name or module_path.stem
    package_init_path = package_path / "__init__.py"
    spec = importlib.util.spec_from_file_location(package_name, package_init_path)

    if spec is None or spec.loader is None:
        raise ImportFromFileError(package_init_path)

    package = importlib.util.module_from_spec(spec)
    sys.modules[package_name] = package
    spec.loader.exec_module(package)

    module_name = module_name or module_path.stem
    return importlib.import_module(f"{package_name}.{module_name}")


sd_path = (Path(__file__).parent).resolve(strict=True)
conf = import_module_from_file(sd_path / "conf.py")
utils = import_module_from_file(sd_path / "utils.py")


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


def get_paths_by_ext(path: Path, ext: str, *, with_dirs: bool) -> list[Path]:
    result: list[Path] = []

    for root, dir_names, file_names in os.walk(path):
        names = file_names
        if with_dirs:
            names += dir_names

        result += [
            Path(root) / file_name
            for file_name in file_names
            if file_name.endswith(ext)
        ]

    return result


def expand_all_project_templates(*, delete_templates: bool) -> None:
    template_ext = ".mako"

    in_template_files = get_paths_by_ext(
        sd_path.parent.resolve(strict=True),
        template_ext,
        with_dirs=False,
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


def do_renaming(*, delete_origins: bool) -> None:
    rename_ext = ".rename"

    orig_paths = get_paths_by_ext(
        sd_path.parent.resolve(strict=True),
        rename_ext,
        with_dirs=True,
    )

    for orig_path in orig_paths:
        orig_path_str = str(orig_path)
        dest_path_str = orig_path_str[: -len(rename_ext)]

        if delete_origins:
            print(f"{orig_path} -> {dest_path_str}")
            # shutil.move(orig_path, dest_path_str)
        else:
            if orig_path.is_dir():
                shutil.copytree(orig_path, dest_path_str)
            else:
                shutil.copy(orig_path, dest_path_str)


if __name__ == "__main__":
    expand_all_project_templates(delete_templates=False)
    do_renaming(delete_origins=True)
