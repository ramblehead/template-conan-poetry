#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import subprocess
from pathlib import Path

from rh_template import expand


def implode() -> None:
    s_path = Path(__file__)
    sd_path = (s_path.parent).resolve(strict=True)
    rh_template_dir_path = sd_path / "rh_template"

    subprocess.Popen(
        f"python -c \"import shutil, os, time; time.sleep(1); shutil.rmtree('{rh_template_dir_path}'); Path.unlink('{s_path}');\"",
        shell=True,
    )


if __name__ == "__main__":
    expand.expand_all_project_templates(delete_templates=True)
    expand.do_renaming(delete_origins=True)
    implode()
