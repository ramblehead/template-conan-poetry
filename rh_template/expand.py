#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import importlib.util
import os
import shutil
from pathlib import Path
from types import ModuleType
from typing import TYPE_CHECKING, Self

from mako.lookup import TemplateLookup  # type: ignore reportMissingTypeStubs

from . import utils
from .config import Config, config

if TYPE_CHECKING:
    from collections.abc import Callable

sd_path = Path(__file__).parent
template_ext = ".mako"
rename_ext = ".rename"


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


def config_ensure_valid(config: Config) -> Config:
    if "project_name" not in config or config["project_name"] is None:
        sd_path = (Path(__file__).parent).resolve(strict=True)
        project_path = sd_path.parent.resolve(strict=True)
        config["project_name"] = project_path.name

    return config


config = config_ensure_valid(config)


def expand_template(in_template_path: Path, out_file_path: Path) -> None:
    template_lookup = TemplateLookup(directories=[in_template_path.parent])

    template = template_lookup.get_template(  # type: ignore unknownMemberType
        in_template_path.name,
    )

    file_out_str: str = template.render(  # type: ignore unknownMemberType
        config=config,
        utils=utils,
    )

    try:
        with Path.open(out_file_path, "w") as file:
            file.write(file_out_str)
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
    in_template_files = get_paths_by_ext(
        sd_path.parent.resolve(strict=True),
        template_ext,
        with_dirs=False,
    )

    if in_template_files:
        print("Expanding from templates:")

    for in_template_file in in_template_files:
        out_file_path_str = str(in_template_file)
        if out_file_path_str.endswith(template_ext):
            out_file_path_str = out_file_path_str[: -len(template_ext)]

        out_file_path = Path(out_file_path_str)

        print(f"  {out_file_path}")
        expand_template(in_template_file, out_file_path)

    if delete_templates:
        for in_template_file in in_template_files:
            in_template_file.unlink()


def get_rename_destination_path(orig_path_str: str) -> str:
    holder_path_str = orig_path_str[: -len(rename_ext)]

    rename_path = Path(f"{holder_path_str}.py")
    if rename_path.is_file():
        reaname_mod = import_module_from_file(rename_path)
        reaname: Callable[[Config, ModuleType], str] = reaname_mod.rename
        return reaname(config, utils)

    return holder_path_str


def do_renaming(*, delete_origins: bool) -> None:
    orig_paths = get_paths_by_ext(
        sd_path.parent.resolve(strict=True),
        rename_ext,
        with_dirs=True,
    )

    if delete_origins:
        dirs_to_move: list[tuple[str, str]] = []

        # Move files first
        for orig_path in orig_paths:
            orig_path_str = str(orig_path)
            dest_path_str = get_rename_destination_path(orig_path_str)
            if not orig_path.is_dir():
                shutil.move(orig_path, dest_path_str)
            else:
                dirs_to_move.append((orig_path_str, dest_path_str))

        # Then move directories
        for orig_dir_path_str, dest_dir_path_str in dirs_to_move:
            shutil.move(orig_dir_path_str, dest_dir_path_str)

    else:
        for orig_path in orig_paths:
            orig_path_str = str(orig_path)
            dest_path_str = orig_path_str[: -len(rename_ext)]

            if orig_path.is_dir():
                shutil.copytree(orig_path, dest_path_str)
            else:
                shutil.copy(orig_path, dest_path_str)


if __name__ == "__main__":
    expand_all_project_templates(delete_templates=False)
    do_renaming(delete_origins=False)
