#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import os
import shutil
from pathlib import Path
from types import ModuleType
from typing import TypeVar

from mako.lookup import TemplateLookup  # type: ignore reportMissingTypeStubs

from . import conf, utils

sd_path = Path(__file__).parent

T = TypeVar("T", bound=ModuleType)


def _ensure_valid(conf: T) -> T:
    if "project_name" not in conf.__dict__ or conf.project_name is None:
        sd_path = (Path(__file__).parent).resolve(strict=True)
        project_path = sd_path.parent.resolve(strict=True)
        conf.project_name = project_path.name  # type: ignore reportGeneralTypeIssues

    return conf


conf = _ensure_valid(conf)


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
        for in_template_file in in_template_files:
            in_template_file.unlink()


def do_renaming(*, delete_origins: bool) -> None:
    rename_ext = ".rename"

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
            dest_path_str = orig_path_str[: -len(rename_ext)]
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
